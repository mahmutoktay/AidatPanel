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
import { moveTempToDekontFile, saveDekontFile, dekontFileExists, deleteDekontFile } from "./dekontStorageService.js";
import { extractDekontTextForPipeline } from "./dekontOcrRunner.js";

const ALLOWED_IMAGE_MIMES = new Set(["image/jpeg", "image/png"]);

function serializeExpense(expense) {
  return {
    ...expense,
    amount: expense.amount != null
      ? (expense.amount?.toString?.() ?? String(expense.amount))
      : null,
    parsedAmount: expense.parsedAmount != null
      ? (expense.parsedAmount?.toString?.() ?? String(expense.parsedAmount))
      : null,
  };
}

function monthYearRange(year, month) {
  const y = parseInt(String(year), 10);
  const m = parseInt(String(month), 10);
  if (m < 1 || m > 12) {
    throw new HttpError(400, "Ay 1-12 arasında olmalıdır.");
  }
  const start = new Date(Date.UTC(y, m - 1, 1, 0, 0, 0, 0));
  const end = new Date(Date.UTC(y, m, 0, 23, 59, 59, 999));
  return { start, end };
}

function buildListWhere(buildingId, filters) {
  const where = { buildingId };
  const { month, year, category } = filters;

  if (month && year) {
    const { start, end } = monthYearRange(year, month);
    where.date = { gte: start, lte: end };
  } else if (year) {
    const y = parseInt(String(year), 10);
    where.date = {
      gte: new Date(Date.UTC(y, 0, 1)),
      lte: new Date(Date.UTC(y, 11, 31, 23, 59, 59, 999)),
    };
  }

  if (category) {
    where.category = category;
  }

  return where;
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
    : { date: "desc" };

  const expenses = await prisma.expense.findMany({
    where,
    orderBy,
    take,
  });

  return buildListResponse(filters, expenses, serializeExpense);
}

export async function getExpenseSummaryService(buildingId, managerId, { month, year }) {
  const building = await assertManagerOwnsBuilding(buildingId, managerId);
  const { start, end } = monthYearRange(year, month);

  const groups = await prisma.expense.groupBy({
    by: ["category"],
    where: {
      buildingId,
      date: { gte: start, lte: end },
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
      amount: amount.toFixed(2),
      count: g._count._all,
    };
  });

  return {
    month: parseInt(String(month), 10),
    year: parseInt(String(year), 10),
    totalAmount: total.toFixed(2),
    currency: building.currency ?? "TRY",
    byCategory,
  };
}

/**
 * Gider oluşturur — tutar OCR'dan gelecek; şimdilik null.
 */
export async function createExpenseService(
  buildingId,
  managerId,
  { title, category, date, note }
) {
  await assertManagerOwnsBuilding(buildingId, managerId);

  const expense = await prisma.expense.create({
    data: {
      buildingId,
      title,
      amount: null,    // OCR tamamlanınca güncellenecek
      category,
      date: new Date(date),
      note: note ?? null,
      storedPaths: [],
    },
  });

  return serializeExpense(expense);
}

export async function updateExpenseService(expenseId, managerId, data) {
  await assertManagerOwnsExpense(expenseId, managerId);

  const updateData = {};
  if (data.title !== undefined) updateData.title = data.title;
  if (data.amount !== undefined) updateData.amount = data.amount;
  if (data.category !== undefined) updateData.category = data.category;
  if (data.date !== undefined) updateData.date = new Date(data.date);
  if (data.note !== undefined) updateData.note = data.note;

  const expense = await prisma.expense.update({
    where: { id: expenseId },
    data: updateData,
  });

  return serializeExpense(expense);
}

export async function deleteExpenseService(expenseId, managerId) {
  const expense = await assertManagerOwnsExpense(expenseId, managerId);

  // Kayıtlı tüm dosyaları sil
  const paths = Array.isArray(expense.storedPaths) ? expense.storedPaths : [];
  for (const p of paths) {
    await deleteDekontFile(p).catch(() => {});
  }

  await prisma.expense.delete({
    where: { id: expenseId },
  });

  return { id: expenseId };
}

/**
 * Çoklu makbuz (proof) yükleme + OCR toplama.
 * files: multer req.files[] (her biri disk'e yazılmış)
 */
export async function uploadExpenseProofsService(expenseId, managerId, files) {
  const expense = await assertManagerOwnsExpense(expenseId, managerId);

  if (!files || files.length === 0) {
    throw new HttpError(400, "En az bir makbuz dosyası gereklidir.");
  }

  const savedPaths = [];
  const ocrResults = [];
  let totalParsedAmount = 0;
  let hasAnyAmount = false;

  try {
    for (let i = 0; i < files.length; i++) {
      const file = files[i];

      const validation = await validateMulterDekontFile(file);
      if (!validation.ok) {
        throw new HttpError(validation.code, validation.message);
      }

      // Dosyayı kaydet
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

      // OCR — sadece image/jpeg veya image/png ise (PDF için de çalışır)
      let parsedAmount = null;
      let confidence = null;
      let rawText = null;
      let ocrNote = null;

      try {
        if (ALLOWED_IMAGE_MIMES.has(validation.mime) || validation.mime === "application/pdf") {
          const ocr = await extractDekontTextForPipeline(storedPath, validation.mime);
          if (ocr) {
            rawText = ocr.rawText || null;
            confidence = ocr.confidence || null;
            if (ocr.parsed?.amount) {
              const amount = parseFloat(String(ocr.parsed.amount).replace(",", "."));
              if (!isNaN(amount) && amount > 0) {
                parsedAmount = amount;
                totalParsedAmount += amount;
                hasAnyAmount = true;
              }
            }
          }
        } else {
          ocrNote = "Desteklenmeyen dosya türü — OCR atlandı.";
        }
      } catch (ocrErr) {
        console.warn(`[expenseService] OCR hatası (${i + 1}. dosya):`, ocrErr.message);
        ocrNote = "OCR işlemi sırasında hata oluştu.";
      }

      ocrResults.push({
        index: i,
        path: storedPath,
        parsedAmount,
        confidence,
        rawText: rawText ? rawText.slice(0, 500) : null, // fazla veri saklama
        note: ocrNote,
      });
    }

    // Eski dosyaları temizle (yeniler başarıyla kaydedildiyse)
    const oldPaths = Array.isArray(expense.storedPaths) ? expense.storedPaths : [];
    for (const oldPath of oldPaths) {
      await deleteDekontFile(oldPath).catch(() => {});
    }

    // Expense'i güncelle
    const updatedExpense = await prisma.expense.update({
      where: { id: expenseId },
      data: {
        storedPaths: savedPaths,
        amount: hasAnyAmount ? totalParsedAmount : null,
        parsedAmount: hasAnyAmount ? totalParsedAmount : null,
        ocrReceiptsJson: ocrResults,
        // receiptUrl eski alan — ilk dosyanın yolunu referans olarak yaz
        receiptUrl: savedPaths.length > 0 ? savedPaths[0] : null,
      },
    });

    const result = serializeExpense(updatedExpense);
    result.ocrSummary = {
      fileCount: files.length,
      hasAmount: hasAnyAmount,
      totalParsedAmount: hasAnyAmount ? totalParsedAmount.toFixed(2) : null,
      message: hasAnyAmount
        ? `${files.length} makbuzdan toplam tutar okundu: ${totalParsedAmount.toFixed(2)} TL`
        : "Makbuzlardan tutar bilgisi okunamadı.",
    };

    return result;
  } catch (err) {
    // Başarıyla kaydedilmiş dosyaları temizle
    for (const sp of savedPaths) {
      await deleteDekontFile(sp).catch(() => {});
    }
    throw err;
  } finally {
    // Multer geçici dosyalarını temizle
    for (const file of files) {
      await cleanupMulterTempFile(file).catch(() => {});
    }
  }
}
