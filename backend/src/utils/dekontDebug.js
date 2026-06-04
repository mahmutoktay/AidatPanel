/**
 * Dekont debug logları — production öncesi izleme.
 * Temizlik: bu dosyayı kaldırın veya DEKONT_DEBUG=false yapın.
 */
const ENABLED = process.env.DEKONT_DEBUG !== "false";

export function dekontLog(step, meta = {}) {
  if (!ENABLED) return;
  const payload =
    meta && typeof meta === "object" && !Array.isArray(meta)
      ? meta
      : { detail: meta };
  console.log(`[dekont] ${step}`, payload);
}

export function dekontLogError(step, err, meta = {}) {
  if (!ENABLED) return;
  console.error(`[dekont] ${step}`, {
    ...meta,
    message: err?.message || String(err),
    code: err?.code,
    statusCode: err?.statusCode,
  });
}
