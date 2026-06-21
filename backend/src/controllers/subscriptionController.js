import {
  getMySubscriptionService,
  processRevenueCatWebhook,
} from "../services/subscriptionService.js";
import { HttpError } from "../utils/httpError.js";
import { logger } from "../config/logger.js";

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
    const eventType = req.body?.event?.type ?? req.body?.type ?? "unknown";
    if (process.env.NODE_ENV !== "production") {
      logger.info({ type: "revenuecat_webhook", eventType, phase: "received" });
    }
    const result = await processRevenueCatWebhook(req.body);
    if (process.env.NODE_ENV !== "production") {
      logger.info({ type: "revenuecat_webhook", eventType, phase: "processed", result });
    }
    res.status(200).json({ success: true, data: result });
  } catch (err) {
    logger.error({ type: "revenuecat_webhook_error", eventType: req.body?.event?.type, err: err?.message });
    handleHttp(err, res, next);
  }
};

