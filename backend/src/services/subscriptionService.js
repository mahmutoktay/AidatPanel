import { prisma } from "../config/db.js";
import { HttpError } from "../utils/httpError.js";
import { getBuildingUsage } from "./buildingQuotaService.js";
import {
  mapEventToStatus,
  mapProductIdToPlan,
  mapStoreToPlatform,
  parseWebhookPeriodDates,
} from "../utils/revenueCatWebhook.js";
import { getManagementQuotaUsage } from "./managementQuotaService.js";

function toSubscriptionDto(subscription, usage) {
  return {
    id: subscription.id,
    status: subscription.status,
    plan: subscription.plan,
    platform: subscription.platform,
    currentPeriodStart: subscription.currentPeriodStart.toISOString(),
    currentPeriodEnd: subscription.currentPeriodEnd.toISOString(),
    usage: { buildings: usage.buildings },
    limits: { buildings: usage.limit },
  };
}

export async function getMySubscriptionService(userId) {
  const subscription = await prisma.subscription.findUnique({
    where: { userId },
  });
<<<<<<< HEAD
  const usage = await getManagementQuotaUsage(userId);
  const quotaFields = {
    usage: { managementUnits: usage.managementUnits },
    limits: { managementUnits: usage.limit },
  };

  if (!subscription) {
    return quotaFields;
  }

  return {
    ...toSubscriptionDto(subscription),
    ...quotaFields,
  };
=======
  const usage = await getBuildingUsage(userId);
  if (!subscription) {
    return {
      status: null,
      plan: null,
      platform: null,
      usage: { buildings: usage.buildings },
      limits: { buildings: usage.limit },
    };
  }
  return toSubscriptionDto(subscription, usage);
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
}

/**
 * RevenueCat webhook gövdesini işler; idempotent upsert.
 */
export async function processRevenueCatWebhook(payload) {
  const event = payload?.event;
  if (!event || typeof event !== "object") {
    throw new HttpError(400, "Geçersiz webhook gövdesi.");
  }

  const eventType = event.type;
  if (eventType === "TEST") {
    return { handled: false, type: eventType, reason: "test_event" };
  }

  const userId = event.app_user_id;
  if (!userId) {
    return { handled: false, type: eventType, reason: "no_app_user_id" };
  }

  const status = mapEventToStatus(eventType, event.period_type);
  if (!status) {
    return { handled: false, type: eventType, reason: "ignored_event_type" };
  }

  const user = await prisma.user.findUnique({
    where: { id: userId },
    select: { id: true, role: true },
  });
  if (!user) {
    return { handled: false, type: eventType, reason: "user_not_found", userId };
  }
  if (user.role !== "MANAGER") {
    return {
      handled: false,
      type: eventType,
      reason: "not_manager",
      userId,
    };
  }

  const { currentPeriodStart, currentPeriodEnd } = parseWebhookPeriodDates(event);
  const plan = mapProductIdToPlan(event.product_id);
  const platform = mapStoreToPlatform(event.store);
  const revenuecatId =
    event.original_transaction_id ??
    event.transaction_id ??
    event.id ??
    null;

  await prisma.subscription.upsert({
    where: { userId },
    create: {
      userId,
      status,
      plan,
      platform,
      revenuecatId,
      currentPeriodStart,
      currentPeriodEnd,
    },
    update: {
      status,
      plan,
      platform,
      revenuecatId,
      currentPeriodStart,
      currentPeriodEnd,
    },
  });

  return {
    handled: true,
    type: eventType,
    userId,
    status,
    plan,
  };
}
