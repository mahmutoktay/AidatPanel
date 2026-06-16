/**
 * RevenueCat dashboard'da tanımlanan Authorization: Bearer <secret> başlığını doğrular.
 */
export const revenueCatWebhookAuth = (req, res, next) => {
  const secret = process.env.REVENUECAT_WEBHOOK_SECRET;
  console.log("[RevenueCat Webhook Auth] Checking authorization header.");
  if (!secret) {
    if (process.env.NODE_ENV === "production") {
      console.warn("[RevenueCat Webhook Auth] Secret is not configured in production!");
      return res.status(503).json({
        success: false,
        message: "Abonelik webhook yapılandırılmamış.",
      });
    }
    console.log("[RevenueCat Webhook Auth] No secret configured, skipping auth check.");
    return next();
  }

  const authHeader = req.headers.authorization;
  if (authHeader !== `Bearer ${secret}`) {
    console.warn(`[RevenueCat Webhook Auth] Authorization failed. Header: ${authHeader}`);
    return res.status(401).json({
      success: false,
      message: "Geçersiz webhook yetkisi.",
    });
  }
  console.log("[RevenueCat Webhook Auth] Authorization successful.");
  next();
};

