import {
  getMySubscriptionService,
  processRevenueCatWebhook,
} from "../services/subscriptionService.js";
import { HttpError } from "../utils/httpError.js";

const handleHttp = (err, res, next) => {
  if (err instanceof HttpError) {
    return res.status(err.statusCode).json({
      success: false,
      message: err.message,
    });
  }
  next(err);
};

export const getMySubscription = async (req, res, next) => {
  try {
    const data = await getMySubscriptionService(req.user.id);
    res.status(200).json({ success: true, data });
  } catch (err) {
    handleHttp(err, res, next);
  }
};

export const revenueCatWebhook = async (req, res, next) => {
  try {
    console.log("[RevenueCat Webhook] Request received. Body:", JSON.stringify(req.body, null, 2));
    const result = await processRevenueCatWebhook(req.body);
    console.log("[RevenueCat Webhook] Processed successfully. Result:", JSON.stringify(result, null, 2));
    res.status(200).json({ success: true, data: result });
  } catch (err) {
    console.error("[RevenueCat Webhook] Error processing webhook:", err);
    handleHttp(err, res, next);
  }
};

