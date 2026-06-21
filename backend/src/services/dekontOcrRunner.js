import { Worker } from "worker_threads";
import { fileURLToPath } from "url";
import { extractDekontText } from "./ocrService.js";
import { readDekontFileBuffer } from "./dekontStorageService.js";
import { resolveDekontAbsolutePath } from "./dekontStorage/local.js";
import { logger } from "../config/logger.js";
import {
  DEKONT_OCR_IN_WORKER,
  DEKONT_OCR_WORKER_TIMEOUT_MS,
} from "../config/dekont.js";

const workerFile = fileURLToPath(
  new URL("../workers/dekontOcr.worker.js", import.meta.url)
);

function runOcrWorker(absoluteFilePath, mimeType) {
  return new Promise((resolve, reject) => {
    const worker = new Worker(workerFile, {
      workerData: { filePath: absoluteFilePath, mimeType },
    });

    const timer = setTimeout(() => {
      worker.terminate().catch(() => {});
      reject(new Error("OCR işlemi zaman aşımına uğradı."));
    }, DEKONT_OCR_WORKER_TIMEOUT_MS);

    let settled = false;

    worker.once("message", (msg) => {
      settled = true;
      clearTimeout(timer);
      if (msg?.ok) {
        resolve(msg.result);
        return;
      }
      reject(new Error(msg?.error || "OCR worker hatası"));
    });

    worker.once("error", (err) => {
      if (settled) return;
      settled = true;
      clearTimeout(timer);
      reject(err);
    });

    worker.once("exit", (code) => {
      if (settled) return;
      clearTimeout(timer);
      if (code !== 0) {
        reject(new Error(`OCR worker çıkış kodu: ${code}`));
      }
    });
  });
}

/**
 * OCR'ı mümkünse worker thread'de çalıştırır; hata olursa ana süreçte dener.
 * @param {string} storedPath — DB'deki göreli yol
 * @param {string} mimeType
 */
export async function extractDekontTextForPipeline(storedPath, mimeType) {
  const absolutePath = resolveDekontAbsolutePath(storedPath);

  if (DEKONT_OCR_IN_WORKER) {
    try {
      return await runOcrWorker(absolutePath, mimeType);
    } catch (err) {
      logger.warn({ type: "dekont_ocr_worker_fallback", err: err.message });
    }
  }

  const buffer = await readDekontFileBuffer(storedPath);
  return extractDekontText(buffer, mimeType);
}
