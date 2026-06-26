import fs from "node:fs";
import { logger } from "../config/logger.js";
import { randomUUID } from "node:crypto";
import { prisma } from "../config/db.js";
import { HttpError } from "../utils/httpError.js";
import {
  assertManagerOwnsBuilding,
  assertManagerOwnsExpense,
} from "../utils/access.js";
import {
  resolveListTake,
  resolvePageLimit,
  wantsPaginatedList,
  buildListResponse,
  mergeCreatedAtCursorWhere,
} from "../utils/listQuery.js";
import { validateMulterDekontFile, cleanupMulterTempFile } from "../utils/dekontUploadFile.js";
import {
  moveTempToDekontFile,
  saveDekontFile,
  dekontFileExists,
  deleteDekontFile,
  resolveDekontAbsolutePath,
} from "./dekontStorageService.js";
import { enqueueExpenseOcrPipeline } from "./expenseOcrService.js";
import { notifyResidentsOfNewExpense } from "./expenseNotificationService.js";
import {
  addMonthsFrom,
  applyCarryForwardForExpense,
  computePerUnitAmount,
  getApartmentCount,
  isPastTargetMonth,
  previewPaidImpact,
  recalculateBuildingDuesForMonth,
  removeCarryforwardsForExpense,
  splitAmount,
} from "./dueExpenseRecalcService.js";

function serializeExpense(expense) {
  const receiptUrls = Array.isArray(expense.storedPaths)
    ? expense.storedPaths.map((p) => `/api/v1/expenses/${expense.id}/file/${p.split("/").pop()}`)
    : [];

  return {
    ...expense,
    amount: expense.amount != null
      ? Number(expense.amount)
      : null,
    perUnitAmount: expense.perUnitAmount != null
      ? Number(expense.perUnitAmount)
      : null,
    parsedAmount: expense.parsedAmount != null
      ? Number(expense.parsedAmount)
      : null,
    receiptUrl: expense.receiptUrl
      ? `/api/v1/expenses/${expense.id}/file/${expense.receiptUrl.split("/").pop()}`
      : null,
    receiptUrls,
  };
}

function buildListWhere(buildingId, filters) {
  const where = { buildingId };
  const { month, year, category } = filters;

  if (month && year) {
    where.targetMonth = parseInt(String(month), 10);
    where.targetYear = parseInt(String(year), 10);
  } else if (year) {
    where.targetYear = parseInt(String(year), 10);
  }

  if (category) {
    where.category = category;
  }

  return where;
}

function buildSplitTargets(targetMonth, targetYear, splitMonths) {
  const parts = Math.max(1, Math.min(12, parseInt(String(splitMonths), 10) || 1));
  const targets = [];
  for (let i = 0; i < parts; i += 1) {
    targets.push(addMonthsFrom(targetMonth, targetYear, i));
  }
  return targets;
}

async function createSingleExpenseWithRecalc(
  buildingId,
  managerId,
  payload,
  { carryForwardPolicy, confirmPaidImpact, apartmentCount, splitGroupId, sourceExpenseId }
) {
  const {
    title,
    amount,
    category,
    date,
    note,
    targetMonth,
    targetYear,
  } = payload;

  const hasAmount =
    amount != null && !Number.isNaN(Number(amount)) && Number(amount) > 0;
  const perUnitAmount = hasAmount
    ? computePerUnitAmount(amount, apartmentCount)
    : null;

  if (!confirmPaidImpact && hasAmount) {
    const preview = await previewPaidImpact(buildingId, targetMonth, targetYear, perUnitAmount);
    if (preview) {
      return {
        preview: {
          ...preview,
          pastMonthWarning: isPastTargetMonth(targetMonth, targetYear),
        },
      };
    }
  }

  const expense = await prisma.expense.create({
    data: {
      buildingId,
      title,
      amount: hasAmount ? amount : null,
      category,
      date: new Date(date),
      note: note ?? null,
      targetMonth,
      targetYear,
      perUnitAmount,
      splitGroupId: splitGroupId ?? null,
      sourceExpenseId: sourceExpenseId ?? null,
      storedPaths: [],
    },
  });

  if (hasAmount) {
    await recalculateBuildingDuesForMonth(buildingId, targetMonth, targetYear);
  }

  const carryResult = hasAmount
    ? await applyCarryForwardForExpense(expense, carryForwardPolicy)
    : { carryForwardCount: 0 };

  const warnings = [];
  if (hasAmount && isPastTargetMonth(targetMonth, targetYear)) {
    warnings.push("Geçmiş bir aya gider eklendi. Aidat tutarları güncellendi.");
  }
  if (
    hasAmount &&
    carryForwardPolicy === "WARN_ONLY" &&
    carryResult.carryForwardCount === 0
  ) {
    const paidPreview = await previewPaidImpact(buildingId, targetMonth, targetYear, perUnitAmount);
    if (paidPreview) {
      warnings.push(paidPreview.message);
    }
  }

  return {
    expense: serializeExpense(expense),
    warnings,
    carryForwardCount: carryResult.carryForwardCount,
    pastMonthWarning: isPastTargetMonth(targetMonth, targetYear),
  };
}

export async function getExpenseFileService(expenseId, userId, userRole) {
  let expense;
  if (userRole === "MANAGER") {
    expense = await assertManagerOwnsExpense(expenseId, userId);
  } else if (userRole === "RESIDENT") {
    const user = await prisma.user.findFirst({
      where: { id: userId, deletedAt: null },
      select: { apartment: { select: { buildingId: true } } },
    });
    const buildingId = user?.apartment?.buildingId;
    if (!buildingId) {
      throw new HttpError(403, "Binanız bulunamadı.");
    }
    expense = await prisma.expense.findFirst({
      where: { id: expenseId, buildingId },
    });
    if (!expense) {
      throw new HttpError(404, "Gider kaydı bulunamadı.");
    }
  } else {
    throw new HttpError(403, "Bu işlem için yetkiniz yok.");
  }

  if (!expense.receiptUrl) {
    throw new HttpError(404, "Bu gidere ait makbuz bulunamadı.");
  }
  const exists = await dekontFileExists(expense.receiptUrl);
  if (!exists) {
    throw new HttpError(404, "Makbuz dosyası diskte bulunamadı.");
  }

  const ext = expense.receiptUrl.substring(expense.receiptUrl.lastIndexOf(".")).toLowerCase();
  let mimeType = "application/octet-stream";
  if (ext === ".pdf") mimeType = "application/pdf";
  else if (ext === ".jpg" || ext === ".jpeg") mimeType = "image/jpeg";
  else if (ext === ".png") mimeType = "image/png";

  const filename = expense.receiptUrl.split("/").pop();
  const absolutePath = resolveDekontAbsolutePath(expense.receiptUrl);

  let sizeBytes = null;
  try {
    const stats = await fs.promises.stat(absolutePath);
    sizeBytes = stats.size;
  } catch (_) {
    logger.warn({ type: "expense_file_stat_failed", expenseId });
  }

  return {
    storedPath: expense.receiptUrl,
    mimeType,
    filename,
    sizeBytes,
  };
}

export async function listExpensesByBuildingService(buildingId, managerId, filters = {}) {
  await assertManagerOwnsBuilding(buildingId, managerId);

  const paginated = wantsPaginatedList(filters);
  const pageLimit = paginated ? resolvePageLimit(filters.limit) : resolveListTake(filters.limit);
  const take = paginated ? pageLimit + 1 : pageLimit;

  let where = buildListWhere(buildingId, filters);

  if (paginated && filters.cursor) {
    where = await mergeCreatedAtCursorWhere(where, filters.cursor, (id) =>
      prisma.expense.findFirst({
        where: { id, buildingId },
        select: { id: true, createdAt: true },
      })
    );
  }

  const orderBy = paginated
    ? [{ createdAt: "desc" }, { id: "desc" }]
    : [{ targetYear: "desc" }, { targetMonth: "desc" }];

  const expenses = await prisma.expense.findMany({
    where,
    orderBy,
    take,
  });

  return buildListResponse(filters, expenses, serializeExpense);
}

export async function getExpenseSummaryService(buildingId, managerId, { month, year }) {
  const building = await assertManagerOwnsBuilding(buildingId, managerId);
  const m = parseInt(String(month), 10);
  const y = parseInt(String(year), 10);

  const groups = await prisma.expense.groupBy({
    by: ["category"],
    where: {
      buildingId,
      targetMonth: m,
      targetYear: y,
    },
    _sum: { amount: true },
    _count: { _all: true },
  });

  let total = 0;
  const byCategory = groups.map((g) => {
    const amount = g._sum.amount ? Number(g._sum.amount) : 0;
    total += amount;
    return {
      category: g.category,
      amount: Number(amount.toFixed(2)),
      count: g._count._all,
    };
  });

  return {
    month: m,
    year: y,
    totalAmount: Number(total.toFixed(2)),
    currency: building.currency ?? "TRY",
    byCategory,
  };
}

export async function createExpenseService(buildingId, managerId, body) {
  await assertManagerOwnsBuilding(buildingId, managerId);

  const {
    title,
    amount,
    category,
    date,
    note,
    targetMonth,
    targetYear,
    splitMonths = 1,
    carryForwardPolicy = "WARN_ONLY",
    confirmPaidImpact = false,
  } = body;

  const apartmentCount = await getApartmentCount(buildingId);
  if (apartmentCount === 0) {
    throw new HttpError(400, "Binada daire bulunmuyor. Önce daire ekleyin.");
  }

  const hasAmount =
    amount != null && !Number.isNaN(Number(amount)) && Number(amount) > 0;

  const targets = buildSplitTargets(targetMonth, targetYear, splitMonths);
  if (targets.length > 1 && !hasAmount) {
    throw new HttpError(
      400,
      "Makbuzlardan tutar okunmadan gider aylara bölünemez. Önce makbuz yükleyin."
    );
  }

  const splitAmounts = hasAmount ? splitAmount(amount, targets.length) : [null];
  const splitGroupId = targets.length > 1 ? randomUUID() : null;

  if (!confirmPaidImpact && targets.length === 1 && hasAmount) {
    const perUnit = computePerUnitAmount(amount, apartmentCount);
    const preview = await previewPaidImpact(buildingId, targetMonth, targetYear, perUnit);
    if (preview) {
      return {
        preview: {
          ...preview,
          pastMonthWarning: isPastTargetMonth(targetMonth, targetYear),
        },
      };
    }
  }

  const created = [];
  const allWarnings = [];

  for (let i = 0; i < targets.length; i += 1) {
    const target = targets[i];
    const partAmount = splitAmounts[i];
    const partTitle = targets.length > 1 ? `${title} (${i + 1}/${targets.length})` : title;

    const result = await createSingleExpenseWithRecalc(
      buildingId,
      managerId,
      {
        title: partTitle,
        amount: partAmount,
        category,
        date,
        note,
        targetMonth: target.month,
        targetYear: target.year,
      },
      {
        carryForwardPolicy,
        confirmPaidImpact: true,
        apartmentCount,
        splitGroupId,
        sourceExpenseId: i === 0 ? null : created[0]?.id,
      }
    );

    if (result.preview) {
      return result;
    }

    created.push(result.expense);
    if (result.warnings?.length) {
      allWarnings.push(...result.warnings);
    }
  }

  await notifyResidentsOfNewExpense(buildingId, {
    expenseId: created[0].id,
    title,
    amount: hasAmount ? amount : null,
    category,
    targetMonth,
    targetYear,
    splitMonths: targets.length,
  });

  return {
    expenses: created,
    expense: created[0],
    warnings: allWarnings,
    pastMonthWarning: isPastTargetMonth(targetMonth, targetYear),
    splitGroupId,
  };
}

export async function updateExpenseService(expenseId, managerId, data) {
  const existing = await assertManagerOwnsExpense(expenseId, managerId);

  const updateData = {};
  if (data.title !== undefined) updateData.title = data.title;
  if (data.amount !== undefined) updateData.amount = data.amount;
  if (data.category !== undefined) updateData.category = data.category;
  if (data.date !== undefined) updateData.date = new Date(data.date);
  if (data.note !== undefined) updateData.note = data.note;
  if (data.targetMonth !== undefined) updateData.targetMonth = data.targetMonth;
  if (data.targetYear !== undefined) updateData.targetYear = data.targetYear;

  const apartmentCount = await getApartmentCount(existing.buildingId);
  const nextAmount = data.amount !== undefined ? data.amount : Number(existing.amount);
  if (nextAmount != null && !Number.isNaN(nextAmount)) {
    updateData.perUnitAmount = computePerUnitAmount(nextAmount, apartmentCount);
  }

  const oldMonth = existing.targetMonth;
  const oldYear = existing.targetYear;

  const expense = await prisma.expense.update({
    where: { id: expenseId },
    data: updateData,
  });

  await recalculateBuildingDuesForMonth(existing.buildingId, expense.targetMonth, expense.targetYear);
  if (expense.targetMonth !== oldMonth || expense.targetYear !== oldYear) {
    await recalculateBuildingDuesForMonth(existing.buildingId, oldMonth, oldYear);
  }

  return serializeExpense(expense);
}

export async function deleteExpenseService(expenseId, managerId) {
  const expense = await assertManagerOwnsExpense(expenseId, managerId);

  const paths = Array.isArray(expense.storedPaths) ? expense.storedPaths : [];
  for (const p of paths) {
    await deleteDekontFile(p).catch((err) => {
      logger.warn({ type: "expense_delete_old_file", path: p, err: err?.message });
    });
  }

  const { targetMonth, targetYear, buildingId } = expense;

  await removeCarryforwardsForExpense(expenseId);

  await prisma.expense.delete({
    where: { id: expenseId },
  });

  await recalculateBuildingDuesForMonth(buildingId, targetMonth, targetYear);

  return { id: expenseId };
}

export async function uploadExpenseProofsService(expenseId, managerId, files) {
  const expense = await assertManagerOwnsExpense(expenseId, managerId);

  if (!files || files.length === 0) {
    throw new HttpError(400, "En az bir makbuz dosyası gereklidir.");
  }

  const savedPaths = [];
  const ocrQueueFiles = [];

  try {
    for (let i = 0; i < files.length; i++) {
      const file = files[i];

      const validation = await validateMulterDekontFile(file);
      if (!validation.ok) {
        throw new HttpError(validation.code, validation.message);
      }

      const fileId = `exp_${expenseId}_${i}_${randomUUID().slice(0, 8)}`;
      let storedPath = null;

      if (file.path) {
        storedPath = await moveTempToDekontFile(file.path, {
          buildingId: expense.buildingId,
          dekontId: fileId,
          mimeType: validation.mime,
          source: "EXPENSE",
        });
        file.path = null;
      } else {
        storedPath = await saveDekontFile(file.buffer, {
          buildingId: expense.buildingId,
          dekontId: fileId,
          mimeType: validation.mime,
          source: "EXPENSE",
        });
      }

      const fileOnDisk = await dekontFileExists(storedPath);
      if (!fileOnDisk) {
        throw new HttpError(503, "Dosya sunucuya kaydedilemedi. Lütfen daha sonra tekrar deneyin.");
      }

      savedPaths.push(storedPath);
      ocrQueueFiles.push({ path: storedPath, mime: validation.mime });
    }

    const oldPaths = Array.isArray(expense.storedPaths) ? expense.storedPaths : [];
    for (const oldPath of oldPaths) {
      await deleteDekontFile(oldPath).catch((err) => {
        logger.warn({ type: "expense_old_file_cleanup", oldPath, err: err?.message });
      });
    }

    const ocrUpdateData = {
      storedPaths: savedPaths,
      parsedAmount: null,
      ocrReceiptsJson: null,
      receiptUrl: savedPaths.length > 0 ? savedPaths[0] : null,
    };

    const updatedExpense = await prisma.expense.update({
      where: { id: expenseId },
      data: ocrUpdateData,
    });

    enqueueExpenseOcrPipeline(expenseId, ocrQueueFiles);

    const result = serializeExpense(updatedExpense);
    result.ocrSummary = {
      fileCount: files.length,
      hasAmount: false,
      totalParsedAmount: null,
      ocrPending: true,
      message:
        files.length === 1
          ? "Makbuz kaydedildi. Tutar okuma işlemi arka planda devam ediyor."
          : `${files.length} makbuz kaydedildi. Tutar okuma işlemi arka planda devam ediyor.`,
    };

    return result;
  } catch (err) {
    for (const sp of savedPaths) {
      await deleteDekontFile(sp).catch((cleanupErr) => {
        logger.warn({ type: "expense_upload_rollback_failed", storedPath: sp, err: cleanupErr?.message });
      });
    }
    throw err;
  } finally {
    for (const file of files) {
      await cleanupMulterTempFile(file).catch((cleanupErr) => {
        logger.warn({ type: "expense_upload_temp_cleanup_failed", file: file?.originalname, err: cleanupErr?.message });
      });
    }
  }
}

export async function listExpensesForResidentService(userId, filters = {}) {
  const user = await prisma.user.findFirst({
    where: { id: userId, deletedAt: null, role: "RESIDENT" },
    select: { apartment: { select: { buildingId: true } } },
  });
  const buildingId = user?.apartment?.buildingId;
  if (!buildingId) {
    throw new HttpError(404, "Binanız bulunamadı.");
  }

  const paginated = wantsPaginatedList(filters);
  const pageLimit = paginated ? resolvePageLimit(filters.limit) : resolveListTake(filters.limit);
  const take = paginated ? pageLimit + 1 : pageLimit;

  let where = buildListWhere(buildingId, filters);

  if (paginated && filters.cursor) {
    where = await mergeCreatedAtCursorWhere(where, filters.cursor, (id) =>
      prisma.expense.findFirst({
        where: { id, buildingId },
        select: { id: true, createdAt: true },
      })
    );
  }

  const orderBy = paginated
    ? [{ createdAt: "desc" }, { id: "desc" }]
    : [{ targetYear: "desc" }, { targetMonth: "desc" }];

  const expenses = await prisma.expense.findMany({
    where,
    orderBy,
    take,
  });

  return buildListResponse(filters, expenses, serializeExpense);
}
