import express from "express";
import { revenueCatWebhook } from "../controllers/subscriptionController.js";
import { revenueCatWebhookAuth } from "../middlewares/revenueCatWebhookAuth.js";

const router = express.Router();

/** POST /api/v1/subscription/webhook/revenuecat — RevenueCat (auth yok, Bearer secret) */
router.post(
  "/webhook/revenuecat",
  revenueCatWebhookAuth,
  revenueCatWebhook
);

export default router;
