import { SUBSCRIPTION_PRODUCT_IDS } from "../constants/subscriptionConstants.js";

/**
 * RevenueCat product_id → plan ("monthly" | "annual").
 */
export function mapProductIdToPlan(productId) {
  const id = String(productId ?? "").toLowerCase();
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
