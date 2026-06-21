/**
 * Dekont debug logları — production öncesi izleme.
 * Temizlik: bu dosyayı kaldırın veya DEKONT_DEBUG=false yapın.
 */
import { logger } from "../config/logger.js";

const ENABLED = process.env.DEKONT_DEBUG !== "false";

export function dekontLog(step, meta = {}) {
  if (!ENABLED) return;
  const payload =
    meta && typeof meta === "object" && !Array.isArray(meta)
      ? meta
      : { detail: meta };
  logger.info({ type: `dekont_${step}`, ...payload });
}

export function dekontLogError(step, err, meta = {}) {
  if (!ENABLED) return;
  logger.error({
    type: `dekont_${step}`,
    ...meta,
    message: err?.message || String(err),
    code: err?.code,
    statusCode: err?.statusCode,
  });
}
