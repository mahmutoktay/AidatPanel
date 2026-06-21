/**
 * RevenueCat dashboard'da tanımlanan Authorization: Bearer <secret> başlığını doğrular.
 */
import { logger } from "../config/logger.js";

export const revenueCatWebhookAuth = (req, res, next) => {
  const secret = process.env.REVENUECAT_WEBHOOK_SECRET;
  logger.info({ type: "revenuecat_webhook_auth", phase: "checking" });
  if (!secret) {
    if (process.env.NODE_ENV === "production") {
      logger.warn({ type: "revenuecat_webhook_auth", phase: "no_secret_production" });
      return res.status(503).json({
        success: false,
        message: "Abonelik webhook yapılandırılmamış.",
      });
    }
    logger.info({ type: "revenuecat_webhook_auth", phase: "no_secret_skip" });
    return next();
  }

  const authHeader = req.headers.authorization;
  if (authHeader !== `Bearer ${secret}`) {
    logger.warn({ type: "revenuecat_webhook_auth", phase: "failed", headerPresent: !!authHeader });
    return res.status(401).json({
      success: false,
      message: "Geçersiz webhook yetkisi.",
    });
  }
  logger.info({ type: "revenuecat_webhook_auth", phase: "success" });
  next();
};

