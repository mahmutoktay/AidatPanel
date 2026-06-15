/**
 * RevenueCat dashboard'da tanımlanan Authorization: Bearer <secret> başlığını doğrular.
 */
export const revenueCatWebhookAuth = (req, res, next) => {
  const secret = process.env.REVENUECAT_WEBHOOK_SECRET;
  if (!secret) {
    if (process.env.NODE_ENV === "production") {
      return res.status(503).json({
        success: false,
        message: "Abonelik webhook yapılandırılmamış.",
      });
    }
    return next();
  }

  const authHeader = req.headers.authorization;
  if (authHeader !== `Bearer ${secret}`) {
    return res.status(401).json({
      success: false,
      message: "Geçersiz webhook yetkisi.",
    });
  }
  next();
};
