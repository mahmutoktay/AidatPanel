import crypto from 'crypto';

export const revenueCatWebhookAuth = (req, res, next) => {
  const authHeader = req.headers.authorization;
  const webhookSecret = process.env.REVENUECAT_WEBHOOK_SECRET;

  if (!webhookSecret) {
    console.error('REVENUECAT_WEBHOOK_SECRET is not configured');
    return res.status(500).json({ error: 'Server configuration error' });
  }

  const expectedAuth = `Bearer ${webhookSecret}`;
  const expectedBuffer = Buffer.from(expectedAuth);
  const providedBuffer = Buffer.from(authHeader || '');

  if (
    expectedBuffer.length !== providedBuffer.length ||
    !crypto.timingSafeEqual(expectedBuffer, providedBuffer)
  ) {
    return res.status(401).json({ error: 'Unauthorized webhook request' });
  }

  next();
};
