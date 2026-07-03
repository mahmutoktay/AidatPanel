import rateLimit from "express-rate-limit";

export const adminAuthLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: Number(process.env.ADMIN_AUTH_RATE_LIMIT_MAX) || 5,
  message: {
    success: false,
    message: "Çok fazla admin giriş denemesi. 15 dakika sonra tekrar deneyin.",
  },
  standardHeaders: true,
  legacyHeaders: false,
  skipSuccessfulRequests: true,
});
