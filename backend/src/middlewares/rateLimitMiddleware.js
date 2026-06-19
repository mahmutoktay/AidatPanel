import rateLimit from "express-rate-limit";
import { authRouteKey } from "../utils/authRateLimitKey.js";
import {
  API_WINDOW_MS,
  API_MAX_REQUESTS,
  AUTH_WINDOW_MS,
  AUTH_MAX_REQUESTS,
  DEKONT_UPLOAD_WINDOW_MS,
  DEKONT_UPLOAD_MAX_REQUESTS,
  STRICT_WINDOW_MS,
  STRICT_MAX_REQUESTS,
} from "../constants/limiterConstants.js";

const isProduction = process.env.NODE_ENV === "production";
const isE2E = process.env.AIDATPANEL_E2E === "1";

/// Kullanıcı bazlı rate limit key: authenticated ise userId, yoksa IP.
/// Böylece aynı WiFi'daki birden çok kullanıcı birbirini etkilemez.
function userOrIpKey(req) {
  return req.user?.id || req.ip;
}

const apiMaxRequests =
  Number(process.env.API_RATE_LIMIT_MAX) ||
  (isE2E ? 0 : isProduction ? API_MAX_REQUESTS : 5000);

/**
 * Genel API rate limiter
 * Production: 15 dk / 600 istek (kullanıcı bazlı).
 * 600 istek = sayfa başına ~4 istekten, 15dk'da ~150 sayfa görüntüleme.
 * Development / E2E: yüksek limit veya kapalı.
 */
export const apiLimiter = rateLimit({
  windowMs: API_WINDOW_MS,
  max: apiMaxRequests,
  keyGenerator: userOrIpKey,
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
  (process.env.NODE_ENV === "production" ? AUTH_MAX_REQUESTS : 50);

export const authLimiter = rateLimit({
  windowMs: AUTH_WINDOW_MS,
  max: authMaxRequests,
  keyGenerator: authRouteKey,
  skip: () => isE2E,
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
 * Dekont yükleme — kullanıcı başına saatlik limit
 */
const dekontUploadMax = isE2E
  ? 0
  : isProduction
    ? DEKONT_UPLOAD_MAX_REQUESTS
    : Math.max(DEKONT_UPLOAD_MAX_REQUESTS, 200);

export const dekontUploadLimiter = rateLimit({
  windowMs: DEKONT_UPLOAD_WINDOW_MS,
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

/**
 * Strict rate limiter — hassas işlemler (şifre sıfırlama, vs.)
 */
export const strictLimiter = rateLimit({
  windowMs: STRICT_WINDOW_MS,
  max: STRICT_MAX_REQUESTS,
  message: {
    success: false,
    message: "Bu işlem için saatlik limit aşıldı. Lütfen daha sonra tekrar deneyin.",
  },
  standardHeaders: true,
  legacyHeaders: false,
});
