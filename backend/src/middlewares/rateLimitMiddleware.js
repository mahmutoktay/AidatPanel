import rateLimit from "express-rate-limit";
import {
  DEKONT_UPLOAD_RATE_MAX,
  DEKONT_UPLOAD_RATE_WINDOW_MS,
} from "../config/dekont.js";

const isProduction = process.env.NODE_ENV === "production";
const isE2E = process.env.AIDATPANEL_E2E === "1";

const apiMaxRequests =
  Number(process.env.API_RATE_LIMIT_MAX) ||
  (isE2E ? 0 : isProduction ? 100 : 5000);

/**
 * Genel API rate limiter
 * Production: 15 dk / 100 istek (IP). Development / E2E: yüksek limit veya kapalı.
 */
export const apiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: apiMaxRequests,
  skip: () => isE2E || (!isProduction && apiMaxRequests === 0),
  message: {
    success: false,
    message: "Çok fazla istek gönderdiniz. Lütfen 15 dakika sonra tekrar deneyin.",
  },
  standardHeaders: true,
  legacyHeaders: false,
});

/**
 * Auth endpoint'leri için daha agresif rate limiter
 * Brute-force saldırılarına karşı koruma
 */
const authMaxRequests =
  Number(process.env.AUTH_RATE_LIMIT_MAX) ||
  (process.env.NODE_ENV === "production" ? 5 : 50);

export const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 dakika
  max: authMaxRequests,
  message: {
    success: false,
    message: "Çok fazla giriş denemesi. Lütfen 15 dakika sonra tekrar deneyin.",
  },
  standardHeaders: true,
  legacyHeaders: false,
  // Başarılı istekler sayılmaz; smoke testteki kasıtlı 4xx'ler için dev'de limit yüksek
  skipSuccessfulRequests: true,
});

/**
 * Şifre sıfırlama gibi hassas işlemler için
 */
/**
 * Dekont yükleme — kullanıcı başına saatlik limit
 */
const dekontUploadMax = isE2E
  ? 0
  : isProduction
    ? DEKONT_UPLOAD_RATE_MAX
    : Math.max(DEKONT_UPLOAD_RATE_MAX, 200);

export const dekontUploadLimiter = rateLimit({
  windowMs: DEKONT_UPLOAD_RATE_WINDOW_MS,
  max: dekontUploadMax,
  skip: () => isE2E || (!isProduction && dekontUploadMax === 0),
  message: {
    success: false,
    message: "Dekont yükleme limitine ulaştınız. Lütfen bir saat sonra tekrar deneyin.",
  },
  standardHeaders: true,
  legacyHeaders: false,
  keyGenerator: (req) => req.user?.id || req.ip,
});

export const strictLimiter = rateLimit({
  windowMs: 60 * 60 * 1000, // 1 saat
  max: 3, // IP başına 3 istek
  message: {
    success: false,
    message: "Bu işlem için saatlik limit aşıldı. Lütfen daha sonra tekrar deneyin.",
  },
  standardHeaders: true,
  legacyHeaders: false,
});
