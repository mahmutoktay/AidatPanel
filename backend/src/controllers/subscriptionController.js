import {
  getMySubscriptionService,
  processRevenueCatWebhook,
} from "../services/subscriptionService.js";
import { logger } from "../config/logger.js";
import { asyncHandler } from "../utils/asyncHandler.js";

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
  res.status(200).json({ success: true, data: result });
});
