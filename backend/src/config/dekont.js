import path from "path";

/** Dekont upload ve doğrulama sabitleri */

export const DEKONT_MAX_BYTES =
  Number(process.env.DEKONT_MAX_BYTES) || 10 * 1024 * 1024;

export const DEKONT_ALLOWED_MIMES = new Set([
  "application/pdf",
  "image/jpeg",
  "image/png",
]);

export const DEKONT_UPLOAD_DIR =
  process.env.DEKONT_UPLOAD_DIR || "./uploads/dekonts";

/** Multer geçici dosyaları (bellek yerine disk) */
export const DEKONT_UPLOAD_TMP_DIR =
  process.env.DEKONT_UPLOAD_TMP_DIR ||
  path.join(DEKONT_UPLOAD_DIR, "_tmp");

/** Yalnızca yerel disk (`DEKONT_UPLOAD_DIR`) */
export const DEKONT_STORAGE = "local";

export const DEKONT_UPLOAD_RATE_MAX =
  Number(process.env.DEKONT_UPLOAD_RATE_MAX) || 10;

export const DEKONT_UPLOAD_RATE_WINDOW_MS = 60 * 60 * 1000;

export const DEKONT_MIN_TEXT_LENGTH = 80;

export const TESSERACT_CMD = process.env.TESSERACT_CMD || "tesseract";
export const TESSERACT_LANG = process.env.TESSERACT_LANG || "tur+eng";

/** OCR + iş kuralları MATCHED iken otomatik DuePayment (varsayılan kapalı) */
export const DEKONT_AUTO_APPLY_PAYMENT =
  process.env.DEKONT_AUTO_APPLY_PAYMENT === "true";

export const DEKONT_OCR_MIN_CONFIDENCE =
  Number(process.env.DEKONT_OCR_MIN_CONFIDENCE) || 0.6;

/** Pipeline hata durumunda yeniden deneme (1 = retry yok) */
export const DEKONT_PIPELINE_MAX_RETRIES =
  Number(process.env.DEKONT_PIPELINE_MAX_RETRIES) || 1;

/** Aynı anda çalışan OCR pipeline sayısı (varsayılan 1 — CPU/event loop koruması) */
export const DEKONT_PIPELINE_CONCURRENCY = Math.max(
  1,
  Number(process.env.DEKONT_PIPELINE_CONCURRENCY) || 1
);

/** OCR'ı worker thread'de çalıştır (varsayılan açık; `false` ile kapatılır) */
export const DEKONT_OCR_IN_WORKER = process.env.DEKONT_OCR_IN_WORKER !== "false";

export const DEKONT_OCR_WORKER_TIMEOUT_MS = Math.max(
  15_000,
  Number(process.env.DEKONT_OCR_WORKER_TIMEOUT_MS) || 120_000
);
