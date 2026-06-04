import { prisma } from "../config/db.js";
import {
  DEKONT_AUTO_APPLY_PAYMENT,
  DEKONT_OCR_MIN_CONFIDENCE,
  DEKONT_PIPELINE_MAX_RETRIES,
} from "../config/dekont.js";
import { notifyDekontStatus } from "./dekontNotificationService.js";
import { readDekontFileBuffer } from "./dekontStorageService.js";
import { validateDekontUploadFile } from "./fileValidationService.js";
import { extractDekontTextForPipeline } from "./dekontOcrRunner.js";
import { evaluateDekontBusinessRules } from "./dekontBusinessRulesService.js";
import { applyDekontPayment } from "./dekontPaymentService.js";
import { enqueueDekontPipeline } from "./dekontPipelineQueue.js";
import { dekontLog, dekontLogError } from "../utils/dekontDebug.js";

/** OCR öncesi event loop'a nefes — eşzamanlı HTTP istekleri işlenebilsin */
function yieldEventLoop() {
  return new Promise((resolve) => setImmediate(resolve));
}

async function tryAutoApplyPayment(dekontId, managerId) {
  if (!DEKONT_AUTO_APPLY_PAYMENT || !managerId) {
    return false;
  }

  const dekont = await prisma.dekont.findUnique({
    where: { id: dekontId },
    select: { id: true, status: true, dueId: true },
  });

  if (!dekont || dekont.status !== "MATCHED" || !dekont.dueId) {
    return false;
  }

  try {
    await applyDekontPayment({
      dekontId,
      managerId,
      dueId: dekont.dueId,
    });
    console.log("[dekont] Otomatik ödeme uygulandı:", dekontId);
    return true;
  } catch (err) {
    console.error("[dekont] Otomatik ödeme başarısız:", dekontId, err.message);
    return false;
  }
}

/**
 * Ücretsiz OCR pipeline: fileValidation → OCR (pdf-parse / Tesseract) → iş kuralları.
 * Claude Vision kullanılmaz.
 *
 * @param {string} dekontId
 * @param {number} [attempt]
 * @param {{ skipUploadValidation?: boolean }} [options] — upload'ta zaten doğrulandıysa true
 */
export async function runVerificationPipeline(dekontId, attempt = 1, options = {}) {
  const { skipUploadValidation = false } = options;
  dekontLog("pipeline.start", { dekontId, attempt, skipUploadValidation });
  const dekont = await prisma.dekont.findUnique({
    where: { id: dekontId },
    include: { building: true, due: true },
  });

  const mayRun =
    dekont &&
    (dekont.status === "RECEIVED" ||
      (dekont.status === "EXTRACT_FAILED" && attempt > 1));

  if (!mayRun) {
    dekontLog("pipeline.skip", {
      dekontId,
      status: dekont?.status ?? "missing",
    });
    return;
  }

  await prisma.dekont.update({
    where: { id: dekontId },
    data: { status: "EXTRACTING" },
  });
  dekontLog("pipeline.extracting", { dekontId, attempt });

  try {
    if (!skipUploadValidation) {
      const buffer = await readDekontFileBuffer(dekont.storedPath);
      const fileCheck = await validateDekontUploadFile(buffer, {
        mimetype: dekont.mimeType,
        size: dekont.sizeBytes,
      });
      if (!fileCheck.ok) {
        await prisma.dekont.update({
          where: { id: dekontId },
          data: { status: "REJECTED", parseError: fileCheck.message },
        });
        await notifyDekontStatus(dekontId);
        return;
      }
    }

    await yieldEventLoop();
    const ocr = await extractDekontTextForPipeline(
      dekont.storedPath,
      dekont.mimeType
    );
    dekontLog("pipeline.ocr-done", {
      dekontId,
      profile: ocr.profile,
      confidence: ocr.confidence,
      textLen: ocr.rawText?.length ?? 0,
    });

    await prisma.dekont.update({
      where: { id: dekontId },
      data: {
        status:
          ocr.confidence < DEKONT_OCR_MIN_CONFIDENCE
            ? "PARSE_LOW_CONFIDENCE"
            : "PARSED",
        rawText: ocr.rawText || null,
        parsedJson: ocr.parsed ?? null,
        parserProfile: ocr.profile ?? null,
        referenceNumber: ocr.parsed?.referenceNumber ?? null,
        receiverIban: ocr.parsed?.receiverIban ?? null,
        parsedAmount: ocr.parsed?.amount ?? null,
        transactionDate: ocr.parsed?.transactionDate
          ? new Date(ocr.parsed.transactionDate)
          : null,
      },
    });

    const rules = await evaluateDekontBusinessRules(dekontId, ocr.parsed);

    await prisma.dekont.update({
      where: { id: dekontId },
      data: {
        status: rules.suggestedStatus,
        recipientVerified: rules.recipientOk ?? null,
        verificationJson: { rules, pipelineAttempt: attempt },
      },
    });

    const autoApplied = await tryAutoApplyPayment(
      dekontId,
      dekont.building.managerId
    );
    if (!autoApplied) {
      await notifyDekontStatus(dekontId);
    }
  } catch (err) {
    if (attempt < DEKONT_PIPELINE_MAX_RETRIES) {
      await prisma.dekont.update({
        where: { id: dekontId },
        data: {
          status: "RECEIVED",
          parseError: `retry ${attempt}: ${err.message || String(err)}`,
        },
      });
      enqueueDekontPipeline(
        () => runVerificationPipeline(dekontId, attempt + 1, { skipUploadValidation: true }),
        { label: `retry-${dekontId}-${attempt + 1}` }
      );
      return;
    }

    await prisma.dekont.update({
      where: { id: dekontId },
      data: {
        status: "EXTRACT_FAILED",
        parseError: err.message || String(err),
        verificationJson: { pipelineAttempt: attempt },
      },
    });
    await notifyDekontStatus(dekontId);
  }
}
