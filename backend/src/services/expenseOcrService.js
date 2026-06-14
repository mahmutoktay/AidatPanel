import { prisma } from "../config/db.js";
import { extractDekontTextForPipeline } from "./dekontOcrRunner.js";
import { enqueueDekontPipeline } from "./dekontPipelineQueue.js";
import {
  computePerUnitAmount,
  getApartmentCount,
  recalculateBuildingDuesForMonth,
} from "./dueExpenseRecalcService.js";

const ALLOWED_OCR_MIMES = new Set([
  "image/jpeg",
  "image/png",
  "application/pdf",
]);

export function aggregateOcrAmounts(ocrResults) {
  let totalParsedAmount = 0;
  let hasAnyAmount = false;

  for (const result of ocrResults) {
    if (result.parsedAmount != null && result.parsedAmount > 0) {
      totalParsedAmount += result.parsedAmount;
      hasAnyAmount = true;
    }
  }

  return { totalParsedAmount, hasAnyAmount };
}

/**
 * @param {{ path: string, mime: string, index: number }} fileMeta
 */
export async function runExpenseReceiptOcr(fileMeta) {
  const { path, mime, index } = fileMeta;
  let parsedAmount = null;
  let confidence = null;
  let rawText = null;
  let ocrNote = null;

  try {
    if (ALLOWED_OCR_MIMES.has(mime)) {
      const ocr = await extractDekontTextForPipeline(path, mime);
      if (ocr) {
        rawText = ocr.rawText || null;
        confidence = ocr.confidence || null;
        if (ocr.parsed?.amount) {
          const amount = parseFloat(String(ocr.parsed.amount).replace(",", "."));
          if (!isNaN(amount) && amount > 0) {
            parsedAmount = amount;
          }
        }
      }
    } else {
      ocrNote = "Desteklenmeyen dosya türü — OCR atlandı.";
    }
  } catch (ocrErr) {
    console.warn(`[expenseOcr] OCR hatası (${index + 1}. dosya):`, ocrErr.message);
    ocrNote = "OCR işlemi sırasında hata oluştu.";
  }

  return {
    index,
    path,
    parsedAmount,
    confidence,
    rawText: rawText ? rawText.slice(0, 500) : null,
    note: ocrNote,
  };
}

/**
 * Kayıtlı makbuzlar için OCR çalıştırır ve Expense alanlarını günceller.
 * @param {string} expenseId
 * @param {Array<{ path: string, mime: string }>} files
 */
export async function runExpenseOcrPipeline(expenseId, files) {
  const ocrResults = [];

  for (let i = 0; i < files.length; i++) {
    const file = files[i];
    const result = await runExpenseReceiptOcr({
      path: file.path,
      mime: file.mime,
      index: i,
    });
    ocrResults.push(result);
  }

  const { totalParsedAmount, hasAnyAmount } = aggregateOcrAmounts(ocrResults);

  const expense = await prisma.expense.findUnique({
    where: { id: expenseId },
    select: {
      amount: true,
      buildingId: true,
      targetMonth: true,
      targetYear: true,
    },
  });

  if (!expense) return;

  const updateData = {
    parsedAmount: hasAnyAmount ? totalParsedAmount : null,
    ocrReceiptsJson: ocrResults,
  };

  if (hasAnyAmount) {
    const apartmentCount = await getApartmentCount(expense.buildingId);
    updateData.amount = totalParsedAmount;
    updateData.perUnitAmount = computePerUnitAmount(totalParsedAmount, apartmentCount);
  }

  await prisma.expense.update({
    where: { id: expenseId },
    data: updateData,
  });

  if (hasAnyAmount) {
    await recalculateBuildingDuesForMonth(
      expense.buildingId,
      expense.targetMonth,
      expense.targetYear
    );
  }
}

/**
 * OCR işini dekont pipeline kuyruğuna ekler (aynı eşzamanlılık limiti).
 */
export function enqueueExpenseOcrPipeline(expenseId, files) {
  enqueueDekontPipeline(
    () => runExpenseOcrPipeline(expenseId, files),
    { label: `expense-ocr-${expenseId}` }
  );
}
