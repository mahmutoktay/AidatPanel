import {
  SUBSCRIPTION_PRODUCT_IDS,
  isBusinessPlan,
} from "../constants/subscriptionConstants.js";

/** Plan önceliği: Business yıllık > Business aylık > Temel yıllık > Temel aylık */
export function planRank(plan) {
  if (isBusinessPlan(plan)) {
    return String(plan).includes("annual") ? 4 : 3;
  }
  return plan === "annual" ? 2 : 1;
}

/**
 * Mağaza (RevenueCat) güncellemesini mevcut kayıtla birleştirir.
 * Admin hediyesi yalnızca DB’de yaşar; webhook üzerine yazarken:
 * - currentPeriodEnd = max(mevcut, mağaza)
 * - Hediye dönemi devam ederken daha yüksek plan korunur
 * - Mağaza EXPIRATION/CANCELLED iken saklanan hediye bitişi ilerideyse ACTIVE kalır
 *
 * @param {object|null} existing Prisma Subscription veya null
 * @param {object} incoming Webhook’tan türetilmiş alanlar
 * @param {Date} [now]
 */
export function mergeStoreSubscriptionUpdate(existing, incoming, now = new Date()) {
  if (!existing) {
    return { ...incoming };
  }

  const existingEnd = new Date(existing.currentPeriodEnd);
  const incomingEnd = new Date(incoming.currentPeriodEnd);
  const currentPeriodEnd =
    existingEnd.getTime() > incomingEnd.getTime() ? existingEnd : incomingEnd;

  const giftPeriodRemaining = existingEnd.getTime() > now.getTime();
  let plan = incoming.plan;
  if (
    giftPeriodRemaining &&
    planRank(existing.plan) > planRank(incoming.plan)
  ) {
    plan = existing.plan;
  }

  let status = incoming.status;
  if (
    (incoming.status === "EXPIRED" || incoming.status === "CANCELLED") &&
    currentPeriodEnd.getTime() > now.getTime() &&
    existingEnd.getTime() > incomingEnd.getTime()
  ) {
    status = "ACTIVE";
  }

  return {
    status,
    plan,
    platform: incoming.platform,
    revenuecatId: incoming.revenuecatId ?? existing.revenuecatId ?? null,
    currentPeriodStart: incoming.currentPeriodStart,
    currentPeriodEnd,
  };
}

/**
 * RevenueCat product_id → plan.
 * Business ürünleri Temel annual eşlemesinden ÖNCE kontrol edilmeli
 * (`business_annual` içinde "annual" geçer).
 */
export function mapProductIdToPlan(productId) {
  const id = String(productId ?? "").toLowerCase();

  if (
    id === SUBSCRIPTION_PRODUCT_IDS.businessAnnual ||
    id === "aidatpanel_business_annual" ||
    (id.includes("business") &&
      (id.includes("annual") || id.includes("yearly")))
  ) {
    return "business_annual";
  }

  if (
    id === SUBSCRIPTION_PRODUCT_IDS.businessMonthly ||
    id === "aidatpanel_business_monthly" ||
    (id.includes("business") && id.includes("monthly"))
  ) {
    return "business_monthly";
  }

  if (
    id === SUBSCRIPTION_PRODUCT_IDS.annual ||
    id.includes("annual") ||
    id.includes("yearly")
  ) {
    return "annual";
  }

  return "monthly";
}

/**
 * RevenueCat store → platform ("ios" | "android").
 */
export function mapStoreToPlatform(store) {
  switch (store) {
    case "APP_STORE":
    case "MAC_APP_STORE":
      return "ios";
    case "PLAY_STORE":
    case "AMAZON":
      return "android";
    default:
      return "android";
  }
}

/**
 * Webhook event type + period_type → Prisma SubscriptionStatus.
 * null = veritabanı güncellemesi yapılmaz.
 */
export function mapEventToStatus(eventType, periodType) {
  switch (eventType) {
    case "INITIAL_PURCHASE":
    case "RENEWAL":
    case "UNCANCELLATION":
    case "PRODUCT_CHANGE":
    case "NON_RENEWING_PURCHASE":
    case "TEMPORARY_ENTITLEMENT_GRANT":
      return periodType === "TRIAL" ? "TRIAL" : "ACTIVE";
    case "CANCELLATION":
      return "CANCELLED";
    case "EXPIRATION":
      return "EXPIRED";
    case "BILLING_ISSUE":
      return "ACTIVE";
    case "TEST":
      return null;
    default:
      return null;
  }
}

export function parseWebhookPeriodDates(event) {
  const startMs = event.purchased_at_ms ?? event.event_timestamp_ms;
  const endMs = event.expiration_at_ms;

  const currentPeriodStart = startMs ? new Date(startMs) : new Date();
  const currentPeriodEnd = endMs
    ? new Date(endMs)
    : new Date(currentPeriodStart.getTime() + 30 * 24 * 60 * 60 * 1000);

  return { currentPeriodStart, currentPeriodEnd };
}
