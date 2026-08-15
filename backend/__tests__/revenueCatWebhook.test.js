import {
  mapEventToStatus,
  mapProductIdToPlan,
  mapStoreToPlatform,
  mergeStoreSubscriptionUpdate,
  parseWebhookPeriodDates,
  planRank,
} from "../src/utils/revenueCatWebhook.js";

describe("revenueCatWebhook utils", () => {
  test("mapProductIdToPlan", () => {
    expect(mapProductIdToPlan("aidatpanel_monthly")).toBe("monthly");
    expect(mapProductIdToPlan("aidatpanel_annual")).toBe("annual");
    expect(mapProductIdToPlan("premium_yearly")).toBe("annual");
    expect(mapProductIdToPlan("")).toBe("monthly");
    expect(mapProductIdToPlan("aidatpanel_business_monthly")).toBe(
      "business_monthly"
    );
    expect(mapProductIdToPlan("aidatpanel_business_annual")).toBe(
      "business_annual"
    );
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

  test("planRank Business > Temel", () => {
    expect(planRank("business_annual")).toBeGreaterThan(planRank("annual"));
    expect(planRank("business_monthly")).toBeGreaterThan(planRank("monthly"));
    expect(planRank("annual")).toBeGreaterThan(planRank("monthly"));
  });
});

describe("mergeStoreSubscriptionUpdate", () => {
  const now = new Date("2026-08-09T12:00:00.000Z");
  const giftEnd = new Date("2026-11-01T00:00:00.000Z");
  const purchaseEnd = new Date("2026-09-09T12:00:00.000Z");

  const giftExisting = {
    plan: "business_monthly",
    platform: "admin_grant",
    revenuecatId: null,
    currentPeriodEnd: giftEnd,
  };

  const purchaseIncoming = {
    status: "ACTIVE",
    plan: "monthly",
    platform: "android",
    revenuecatId: "txn_1",
    currentPeriodStart: now,
    currentPeriodEnd: purchaseEnd,
  };

  test("null existing → incoming aynen", () => {
    expect(mergeStoreSubscriptionUpdate(null, purchaseIncoming, now)).toEqual(
      purchaseIncoming
    );
  });

  test("bitiş max(hediye, satın alma); Business hediye Temel satın almada korunur", () => {
    const merged = mergeStoreSubscriptionUpdate(
      giftExisting,
      purchaseIncoming,
      now
    );
    expect(merged.currentPeriodEnd.toISOString()).toBe(giftEnd.toISOString());
    expect(merged.plan).toBe("business_monthly");
    expect(merged.platform).toBe("android");
    expect(merged.revenuecatId).toBe("txn_1");
    expect(merged.status).toBe("ACTIVE");
  });

  test("satın alma bitişi hediyeden uzunsa satın alma bitişi yazılır", () => {
    const longPurchaseEnd = new Date("2027-08-09T12:00:00.000Z");
    const merged = mergeStoreSubscriptionUpdate(
      giftExisting,
      { ...purchaseIncoming, currentPeriodEnd: longPurchaseEnd },
      now
    );
    expect(merged.currentPeriodEnd.toISOString()).toBe(
      longPurchaseEnd.toISOString()
    );
    expect(merged.plan).toBe("business_monthly");
  });

  test("mağaza EXPIRATION iken hediye bitişi ilerideyse ACTIVE kalır", () => {
    const merged = mergeStoreSubscriptionUpdate(
      giftExisting,
      {
        ...purchaseIncoming,
        status: "EXPIRED",
        currentPeriodEnd: purchaseEnd,
      },
      now
    );
    expect(merged.status).toBe("ACTIVE");
    expect(merged.currentPeriodEnd.toISOString()).toBe(giftEnd.toISOString());
    expect(merged.plan).toBe("business_monthly");
  });

  test("hediye süresi geçmişse satın alınan plan yazılır", () => {
    const expiredGift = {
      ...giftExisting,
      currentPeriodEnd: new Date("2026-07-01T00:00:00.000Z"),
    };
    const merged = mergeStoreSubscriptionUpdate(
      expiredGift,
      purchaseIncoming,
      now
    );
    expect(merged.plan).toBe("monthly");
    expect(merged.currentPeriodEnd.toISOString()).toBe(
      purchaseEnd.toISOString()
    );
  });
});
