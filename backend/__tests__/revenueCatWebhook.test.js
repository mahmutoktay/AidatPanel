import {
  mapEventToStatus,
  mapProductIdToPlan,
  mapStoreToPlatform,
  parseWebhookPeriodDates,
} from "../src/utils/revenueCatWebhook.js";

describe("revenueCatWebhook utils", () => {
  test("mapProductIdToPlan", () => {
    expect(mapProductIdToPlan("aidatpanel_monthly")).toBe("monthly");
    expect(mapProductIdToPlan("aidatpanel_annual")).toBe("annual");
    expect(mapProductIdToPlan("premium_yearly")).toBe("annual");
    expect(mapProductIdToPlan("")).toBe("monthly");
  });

  test("mapStoreToPlatform", () => {
    expect(mapStoreToPlatform("APP_STORE")).toBe("ios");
    expect(mapStoreToPlatform("PLAY_STORE")).toBe("android");
    expect(mapStoreToPlatform("UNKNOWN")).toBe("android");
  });

  test("mapEventToStatus", () => {
    expect(mapEventToStatus("INITIAL_PURCHASE", "NORMAL")).toBe("ACTIVE");
    expect(mapEventToStatus("INITIAL_PURCHASE", "TRIAL")).toBe("TRIAL");
    expect(mapEventToStatus("RENEWAL", "NORMAL")).toBe("ACTIVE");
    expect(mapEventToStatus("CANCELLATION", "NORMAL")).toBe("CANCELLED");
    expect(mapEventToStatus("EXPIRATION", "NORMAL")).toBe("EXPIRED");
    expect(mapEventToStatus("BILLING_ISSUE", "NORMAL")).toBe("ACTIVE");
    expect(mapEventToStatus("TEST", "NORMAL")).toBeNull();
    expect(mapEventToStatus("SUBSCRIBER_ALIAS", "NORMAL")).toBeNull();
  });

  test("parseWebhookPeriodDates", () => {
    const { currentPeriodStart, currentPeriodEnd } = parseWebhookPeriodDates({
      purchased_at_ms: 1_700_000_000_000,
      expiration_at_ms: 1_702_592_000_000,
    });
    expect(currentPeriodStart.toISOString()).toBe(
      new Date(1_700_000_000_000).toISOString()
    );
    expect(currentPeriodEnd.toISOString()).toBe(
      new Date(1_702_592_000_000).toISOString()
    );
  });
});
