/**
 * Merkezi Yapılandırılmış Logger (Pino)
 *
 * Proje genelinde console.log/console.error kullanımını ortadan kaldırır.
 *
 * ## Kullanım
 *
 * ```js
 * import { logger } from "../config/logger.js";
 *
 * logger.info("Dekont işlendi", { dekontId, userId });
 * logger.error("Ödeme başarısız", { userId, error: err.message });
 * logger.warn("Rate limit aşıldı", { ip, route });
 * ```
 *
 * ## Request Logging (Express middleware)
 *
 * ```js
 * import { requestLogger } from "../config/logger.js";
 * app.use(requestLogger);
 * ```
 *
 * ## Özellikler
 *
 * - Production: JSON stdout (log aggregator uyumlu)
 * - Development: prettyPrint ile renkli, okunabilir çıktı
 * - Otomatik timestamp (ISO 8601)
 * - Hata objeleri otomatik serialize (stack trace dahil)
 * - correlationId desteği (request bazında takip)
 */

import pino from "pino";

const isProduction = process.env.NODE_ENV === "production";

/**
 * Pino logger instance.
 * Tüm modüllerde kullanılacak merkezi loglayıcı.
 *
 * Transport:
 * - Development: pino-pretty (renkli, insan okunabilir)
 * - Production: JSON lines → stdout (Docker/CloudWatch/ELK uyumlu)
 *
 * Level:
 * - Test: silent
 * - Development: debug
 * - Production: info (env.override ile LOG_LEVEL)
 */
export const logger = pino({
  level:
    process.env.NODE_ENV === "test"
      ? "silent"
      : process.env.LOG_LEVEL || (isProduction ? "info" : "debug"),

  ...(isProduction
    ? {
        // Production: ham JSON (log aggregator uyumlu)
        timestamp: pino.stdTimeFunctions.isoTime,
      }
    : {
        // Development: pretty print
        transport: {
          target: "pino-pretty",
          options: {
            colorize: true,
            translateTime: "SYS:yyyy-mm-dd HH:MM:ss.l",
            ignore: "pid,hostname",
          },
        },
      }),

  // Her loga eklenen sabit alanlar
  base: {
    env: process.env.NODE_ENV || "development",
    service: "aidatpanel-api",
  },
});

/**
 * Request odaklı child logger oluşturur.
 * Express middleware'lerinde kullanım için tasarlanmıştır.
 *
 * @param {import("express").Request} req - Express request nesnesi
 * @returns {import("pino").Logger} Request-scoped logger
 */
export function reqLogger(req) {
  return logger.child({
    reqId: req.id || `${Date.now()}-${Math.random().toString(36).slice(2, 10)}`,
    method: req.method,
    url: req.originalUrl || req.url,
    userId: req.user?.id,
    ip: req.ip,
  });
}

/**
 * Express middleware: her HTTP isteğini loglar.
 * Response tamamlanınca (finish) status code ve süreyi kaydeder.
 *
 * @type {import("express").RequestHandler}
 */
export const requestLogger = (req, res, next) => {
  const start = Date.now();
  const log = reqLogger(req);

  res.on("finish", () => {
    const duration = Date.now() - start;
    const level = res.statusCode >= 500 ? "error" : res.statusCode >= 400 ? "warn" : "info";

    log[level]({
      msg: `${req.method} ${req.originalUrl || req.url}`,
      statusCode: res.statusCode,
      durationMs: duration,
      contentLength: res.getHeader("content-length"),
    });
  });

  next();
};
