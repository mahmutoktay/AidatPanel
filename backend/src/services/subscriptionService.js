import { prisma } from "../config/db.js";
import { HttpError } from "../utils/httpError.js";
import { getBuildingUsage } from "./buildingQuotaService.js";
import {
  mapEventToStatus,
  mapProductIdToPlan,
  mapStoreToPlatform,
  mergeStoreSubscriptionUpdate,
  parseWebhookPeriodDates,
} from "../utils/revenueCatWebhook.js";

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

  const existing = await prisma.subscription.findUnique({ where: { userId } });
  const merged = mergeStoreSubscriptionUpdate(existing, {
    status,
    plan,
    platform,
    revenuecatId,
    currentPeriodStart,
    currentPeriodEnd,
  });

  await prisma.subscription.upsert({
    where: { userId },
    create: {
      userId,
      ...merged,
    },
    update: {
      status: merged.status,
      plan: merged.plan,
      platform: merged.platform,
      revenuecatId: merged.revenuecatId,
      currentPeriodStart: merged.currentPeriodStart,
      currentPeriodEnd: merged.currentPeriodEnd,
    },
  });

  return {
    handled: true,
    type: eventType,
    userId,
    status: merged.status,
    plan: merged.plan,
  };
}
