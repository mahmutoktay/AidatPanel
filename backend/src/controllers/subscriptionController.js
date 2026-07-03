import {
  getMySubscriptionService,
  processRevenueCatWebhook,
} from "../services/subscriptionService.js";
<<<<<<< HEAD
import { HttpError } from "../utils/httpError.js";
import { logger } from "../config/logger.js";
=======
import { logger } from "../config/logger.js";
import { asyncHandler } from "../utils/asyncHandler.js";
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6

export const getMySubscription = asyncHandler(async (req, res) => {
  const data = await getMySubscriptionService(req.user.id);
  res.status(200).json({ success: true, data });
});

export const revenueCatWebhook = asyncHandler(async (req, res) => {
  const eventType = req.body?.event?.type ?? req.body?.type ?? "unknown";
  if (process.env.NODE_ENV !== "production") {
    logger.info({ type: "revenuecat_webhook", eventType, phase: "received" });
  }
  const result = await processRevenueCatWebhook(req.body);
  if (process.env.NODE_ENV !== "production") {
    logger.info({ type: "revenuecat_webhook", eventType, phase: "processed", result });
  }
<<<<<<< HEAD
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

=======
  res.status(200).json({ success: true, data: result });
});
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
