import crypto from 'crypto';
import { logger } from '../config/logger.js';

export const revenueCatWebhookAuth = (req, res, next) => {
  const authHeader = req.headers.authorization;
  const webhookSecret = process.env.REVENUECAT_WEBHOOK_SECRET;

  if (!webhookSecret) {
    logger.error({ type: 'revenuecat_webhook_secret_missing' });
    return res.status(500).json({
      success: false,
      message: 'Webhook yapılandırılmamış.',
    });
  }

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

  next();
};
