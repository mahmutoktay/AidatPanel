<<<<<<< HEAD
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
=======
import crypto from 'crypto';
import { logger } from '../config/logger.js';
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6

export const revenueCatWebhookAuth = (req, res, next) => {
  const authHeader = req.headers.authorization;
<<<<<<< HEAD
  if (authHeader !== `Bearer ${secret}`) {
    logger.warn({ type: "revenuecat_webhook_auth", phase: "failed", headerPresent: !!authHeader });
    return res.status(401).json({
=======
  const webhookSecret = process.env.REVENUECAT_WEBHOOK_SECRET;

  if (!webhookSecret) {
    logger.error({ type: 'revenuecat_webhook_secret_missing' });
    return res.status(500).json({
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
      success: false,
      message: 'Webhook yapılandırılmamış.',
    });
  }
<<<<<<< HEAD
  logger.info({ type: "revenuecat_webhook_auth", phase: "success" });
=======

  const expectedAuth = `Bearer ${webhookSecret}`;
  const expectedBuffer = Buffer.from(expectedAuth);
  const providedBuffer = Buffer.from(authHeader || '');

  if (
    expectedBuffer.length !== providedBuffer.length ||
    !crypto.timingSafeEqual(expectedBuffer, providedBuffer)
  ) {
    return res.status(401).json({
      success: false,
      message: 'Yetkisiz webhook isteği.',
    });
  }

>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
  next();
};
