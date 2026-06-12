import { randomUUID } from "node:crypto";
import { prisma } from "../config/db.js";
import { HttpError } from "../utils/httpError.js";
import { assertManagerOwnsBuilding } from "../utils/access.js";
import {
  saveDekontFile,
  moveTempToDekontFile,
  dekontFileExists,
  deleteDekontFile,
} from "./dekontStorageService.js";
import {
  validateMulterDekontFile,
  cleanupMulterTempFile,
} from "../utils/dekontUploadFile.js";
import { runVerificationPipeline } from "./dekontVerificationService.js";
import { enqueueDekontPipeline } from "./dekontPipelineQueue.js";
import {
  notifyDekontStatus,
  notifyDekontRejected,
} from "./dekontNotificationService.js";
import { applyDekontPayment } from "./dekontPaymentService.js";
import {
  DEKONT_APPROVABLE_STATUSES,
  DEKONT_REJECTABLE_STATUSES,
} from "../constants/dekontReview.js";
import {
  resolveListTake,
  resolvePageLimit,
  wantsPaginatedList,
  buildListResponse,
  mergeCreatedAtCursorWhere,
} from "../utils/listQuery.js";
import { dekontListSelect, formatDekont } from "../utils/dekontFormat.js";
import { dekontLog, dekontLogError } from "../utils/dekontDebug.js";

/**
 * @returns {Promise<import("@prisma/client").Dekont>}
 */
export async function assertCanAccessDekont(dekontId, user) {
  const dekont = await prisma.dekont.findUnique({
    where: { id: dekontId },
    include: {
      building: { select: { managerId: true } },
    },
  });

  if (!dekont) {
    throw new HttpError(404, "Dekont bulunamadı.");
  }

  const isUploader = dekont.uploadedById === user.id;
  const isManager =
    user.role === "MANAGER" && dekont.building.managerId === user.id;

  if (!isUploader && !isManager) {
    throw new HttpError(404, "Dekont bulunamadı.");
  }

  return dekont;
}

/** DB'de dosya yolu yok / pending veya diskte dosya eksik. */
async function isDekontFileBroken(row) {
  if (!row?.storedPath || row.storedPath === "pending") {
    return true;
  }
  return !(await dekontFileExists(row.storedPath));
}

async function removeBrokenDekontRecord(row) {
  if (!row?.id) return;
  if (row.storedPath && row.storedPath !== "pending") {
    await deleteDekontFile(row.storedPath).catch(() => {});
  }
  await prisma.dekont.delete({ where: { id: row.id } }).catch(() => {});
  dekontLog("removed broken dekont record", { dekontId: row.id });
}

async function resolveUploadContext(user, dueId) {
  if (user.role === "RESIDENT") {
    const resident = await prisma.user.findFirst({
      where: { id: user.id, deletedAt: null, role: "RESIDENT" },
      select: { apartmentId: true },
    });

    if (!resident?.apartmentId) {
      throw new HttpError(403, "Daire kaydınız bulunmuyor.");
    }

    const apartment = await prisma.apartment.findUnique({
      where: { id: resident.apartmentId },
      include: { building: true },
    });

    if (!apartment) {
      throw new HttpError(404, "Daire bulunamadı.");
    }

    let due = null;
    if (dueId) {
      due = await prisma.due.findFirst({
        where: { id: dueId, apartmentId: resident.apartmentId },
      });
      if (!due) {
        throw new HttpError(404, "Aidat kaydı bulunamadı.");
      }
    }

    return {
      buildingId: apartment.buildingId,
      apartmentId: apartment.id,
      dueId: due?.id ?? null,
      source: "RESIDENT_UPLOAD",
    };
  }

  if (user.role === "MANAGER") {
    if (!dueId) {
      throw new HttpError(400, "Yönetici yüklemesi için dueId zorunludur.");
    }

    const due = await prisma.due.findUnique({
      where: { id: dueId },
      include: {
        apartment: { include: { building: true } },
      },
    });

    if (!due || due.apartment.building.managerId !== user.id) {
      throw new HttpError(404, "Aidat kaydı bulunamadı.");
    }

    return {
      buildingId: due.apartment.buildingId,
      apartmentId: due.apartmentId,
      dueId: due.id,
      source: "MANAGER_UPLOAD",
    };
  }

  throw new HttpError(403, "Bu işlem için yetkiniz yok.");
}

export async function createDekontFromUpload(user, file, { dueId } = {}) {
  if (!file?.buffer?.length && !file?.path) {
    throw new HttpError(400, "Dosya gereklidir.");
  }

  let createdDekontId = null;
  let savedStoredPath = null;
  let validation;
  try {
    validation = await validateMulterDekontFile(file);
    if (!validation.ok) {
      throw new HttpError(validation.code, validation.message);
    }

    const context = await resolveUploadContext(user, dueId ?? undefined);

    const duplicate = await prisma.dekont.findFirst({
      where: {
        buildingId: context.buildingId,
        fileHash: validation.fileHash,
      },
      select: { ...dekontListSelect, storedPath: true },
    });

    if (duplicate) {
      if (await isDekontFileBroken(duplicate)) {
        dekontLogError(
          "duplicate dekont broken — removing and re-uploading",
          new Error("BROKEN_STORED_PATH"),
          { dekontId: duplicate.id, storedPath: duplicate.storedPath }
        );
        await removeBrokenDekontRecord(duplicate);
      } else {
        throw new HttpError(409, "Bu dekont dosyası daha önce yüklenmiş.", {
          dekontId: duplicate.id,
          dekont: formatDekont(duplicate),
        });
      }
    }

    const sizeBytes = file.size ?? validation.sizeBytes ?? file.buffer?.length ?? 0;
    const dekontId = randomUUID();
    const prefix = context.source === "RESIDENT_UPLOAD" ? "residents_" : "managers_";
    const storageDekontId = `${prefix}${dekontId}`;
    let storedPath = null;

    if (file.path) {
      storedPath = await moveTempToDekontFile(file.path, {
        buildingId: context.buildingId,
        dekontId: storageDekontId,
        mimeType: validation.mime,
        source: context.source,
      });
      file.path = null;
    } else {
      storedPath = await saveDekontFile(file.buffer, {
        buildingId: context.buildingId,
        dekontId: storageDekontId,
        mimeType: validation.mime,
        source: context.source,
      });
    }

    const fileOnDisk = await dekontFileExists(storedPath);
    dekontLog("upload file saved before db", {
      dekontId,
      storedPath,
      fileOnDisk,
      sizeBytes,
    });
    if (!fileOnDisk) {
      await deleteDekontFile(storedPath).catch(() => {});
      throw new HttpError(
        503,
        "Dosya sunucuya kaydedilemedi. Lütfen daha sonra tekrar deneyin."
      );
    }
    savedStoredPath = storedPath;

    const dekont = await prisma.dekont.create({
      data: {
        id: dekontId,
        buildingId: context.buildingId,
        apartmentId: context.apartmentId,
        uploadedById: user.id,
        dueId: context.dueId,
        status: "RECEIVED",
        source: context.source,
        storedPath,
        originalFilename: file.originalname || "dekont",
        mimeType: validation.mime,
        sizeBytes,
        fileHash: validation.fileHash,
      },
      select: dekontListSelect,
    });
    createdDekontId = dekont.id;

    enqueueDekontPipeline(
      async () => {
        await notifyDekontStatus(dekont.id);
        await runVerificationPipeline(dekont.id, 1, { skipUploadValidation: true });
      },
      { label: `upload-${dekont.id}` }
    );

    return formatDekont(dekont);
  } catch (err) {
    if (createdDekontId) {
      const row = await prisma.dekont
        .findUnique({
          where: { id: createdDekontId },
          select: { id: true, storedPath: true },
        })
        .catch(() => null);
      if (row) {
        await removeBrokenDekontRecord(row);
      }
    } else if (savedStoredPath) {
      await deleteDekontFile(savedStoredPath).catch(() => {});
    }
    if (err instanceof HttpError || err?.name === "HttpError") {
      throw err;
    }
    if (err?.code === "P2002") {
      const target = err.meta?.target;
      const fields = Array.isArray(target) ? target : [];
      const isFileHashConflict =
        fields.includes("fileHash") ||
        fields.includes("buildingId_fileHash") ||
        (fields.includes("buildingId") && fields.includes("fileHash"));
      if (isFileHashConflict && validation?.fileHash) {
        const context = await resolveUploadContext(user, dueId ?? undefined);
        const duplicate = await prisma.dekont.findFirst({
          where: {
            buildingId: context.buildingId,
            fileHash: validation.fileHash,
          },
          select: { ...dekontListSelect, storedPath: true },
        });
        if (duplicate) {
          throw new HttpError(409, "Bu dekont dosyası daha önce yüklenmiş.", {
            dekontId: duplicate.id,
            dekont: formatDekont(duplicate),
          });
        }
      }
    }
    console.error("[dekont] upload failed:", err);
    dekontLogError("upload failed", err, {
      userId: user?.id,
      createdDekontId,
      savedStoredPath,
    });
    const fsCodes = new Set(["EACCES", "ENOENT", "EROFS", "EPERM"]);
    if (fsCodes.has(err?.code)) {
      throw new HttpError(
        503,
        "Dosya sunucuya kaydedilemedi. Lütfen daha sonra tekrar deneyin."
      );
    }
    throw new HttpError(
      500,
      process.env.NODE_ENV === "production"
        ? "Dekont yüklenemedi. Lütfen tekrar deneyin."
        : err?.message || "Dekont yüklenemedi."
    );
  } finally {
    await cleanupMulterTempFile(file);
  }
}

export async function getDekontByIdForUser(dekontId, user) {
  const row = await prisma.dekont.findUnique({
    where: { id: dekontId },
    select: {
      ...dekontListSelect,
      parseError: true,
      parserProfile: true,
      parsedJson: true,
      building: { select: { managerId: true } },
      apartment: { select: { id: true, number: true } },
      uploadedBy: { select: { id: true, name: true, email: true } },
    },
  });

  if (!row) {
    throw new HttpError(404, "Dekont bulunamadı.");
  }

  const isUploader = row.uploadedById === user.id;
  const isManager =
    user.role === "MANAGER" && row.building.managerId === user.id;

  if (!isUploader && !isManager) {
    throw new HttpError(404, "Dekont bulunamadı.");
  }

  const { building: _b, ...rest } = row;
  const formatted = formatDekont(rest);
  return {
    ...formatted,
    apartment: row.apartment ?? undefined,
    uploadedBy: row.uploadedBy ?? undefined,
  };
}

export async function listDekontsForResident(userId, filters = {}) {
  const { status } = filters;
  const paginated = wantsPaginatedList(filters);
  const pageLimit = paginated ? resolvePageLimit(filters.limit) : resolveListTake(filters.limit);
  const take = paginated ? pageLimit + 1 : pageLimit;

  let where = { uploadedById: userId };
  if (status) where.status = status;

  if (paginated && filters.cursor) {
    where = await mergeCreatedAtCursorWhere(where, filters.cursor, (id) =>
      prisma.dekont.findFirst({
        where: { id, uploadedById: userId },
        select: { id: true, createdAt: true },
      })
    );
  }

  const rows = await prisma.dekont.findMany({
    where,
    orderBy: [{ createdAt: "desc" }, { id: "desc" }],
    select: dekontListSelect,
    take,
  });

  return buildListResponse(filters, rows, formatDekont);
}

export async function listDekontsForBuilding(buildingId, managerId, filters = {}) {
  const { status, apartmentId } = filters;
  await assertManagerOwnsBuilding(buildingId, managerId);

  const paginated = wantsPaginatedList(filters);
  const pageLimit = paginated ? resolvePageLimit(filters.limit) : resolveListTake(filters.limit);
  const take = paginated ? pageLimit + 1 : pageLimit;

  let where = { buildingId };
  if (status) where.status = status;
  if (apartmentId) where.apartmentId = apartmentId;

  if (paginated && filters.cursor) {
    where = await mergeCreatedAtCursorWhere(where, filters.cursor, (id) =>
      prisma.dekont.findFirst({
        where: { id, buildingId },
        select: { id: true, createdAt: true },
      })
    );
  }

  const rows = await prisma.dekont.findMany({
    where,
    orderBy: [{ createdAt: "desc" }, { id: "desc" }],
    select: {
      ...dekontListSelect,
      apartment: { select: { id: true, number: true } },
      uploadedBy: { select: { id: true, name: true, email: true } },
    },
    take,
  });

  return buildListResponse(filters, rows, (row) => {
    const formatted = formatDekont(row);
    return {
      ...formatted,
      apartment: row.apartment,
      uploadedBy: row.uploadedBy,
    };
  });
}

export async function reviewDekont(dekontId, managerId, { decision, note, dueId }) {
  const dekont = await prisma.dekont.findUnique({
    where: { id: dekontId },
    include: { building: { select: { managerId: true } } },
  });

  if (!dekont || dekont.building.managerId !== managerId) {
    throw new HttpError(404, "Dekont bulunamadı.");
  }

  if (dekont.status === "PAYMENT_APPLIED") {
    throw new HttpError(409, "Bu dekont için ödeme zaten işlenmiş.");
  }

  if (decision === "REJECT") {
    if (!DEKONT_REJECTABLE_STATUSES.has(dekont.status)) {
      throw new HttpError(409, `Bu durumda dekont reddedilemez: ${dekont.status}`);
    }
    const updated = await prisma.dekont.update({
      where: { id: dekontId },
      data: {
        status: "REJECTED",
        reviewedById: managerId,
        reviewedAt: new Date(),
        reviewNote: note ?? null,
        rejectionReason: note ?? "Yönetici tarafından reddedildi.",
      },
      select: dekontListSelect,
    });
    await notifyDekontRejected(dekontId);
    return formatDekont(updated);
  }

  if (decision === "APPROVE") {
    if (!DEKONT_APPROVABLE_STATUSES.has(dekont.status)) {
      throw new HttpError(
        409,
        `Bu durumda dekont onaylanamaz: ${dekont.status}. Önce pipeline tamamlanmalı veya reddedilmiş olmamalı.`
      );
    }
    const result = await applyDekontPayment({
      dekontId,
      managerId,
      dueId: dueId ?? undefined,
      note: note ?? undefined,
    });

    return formatDekont(result.updatedDekont);
  }

  throw new HttpError(400, "Geçersiz karar.");
}

export async function getDekontFileForUser(dekontId, user) {
  const dekont = await assertCanAccessDekont(dekontId, user);
  const pathMissing =
    !dekont.storedPath || dekont.storedPath === "pending";
  const exists =
    !pathMissing && (await dekontFileExists(dekont.storedPath));

  if (pathMissing || !exists) {
    const ageMs = Date.now() - new Date(dekont.createdAt).getTime();
    const stale = ageMs > 2 * 60 * 1000;

    dekontLogError("GET file unavailable", new Error("FILE_UNAVAILABLE"), {
      dekontId,
      storedPath: dekont.storedPath,
      pathMissing,
      exists,
      ageMs,
      stale,
    });

    if (stale) {
      await removeBrokenDekontRecord(dekont);
      throw new HttpError(
        404,
        "Dekont dosyası kaydedilememiş. Lütfen dekontu yeniden yükleyin."
      );
    }

    throw new HttpError(
      503,
      "Dekont dosyası henüz hazırlanıyor. Lütfen kısa süre sonra tekrar deneyin."
    );
  }

  return dekont;
}
