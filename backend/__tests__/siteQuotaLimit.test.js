import { jest } from "@jest/globals";

jest.unstable_mockModule("../src/config/db.js", () => ({
  prisma: {
    building: { count: jest.fn() },
    subscription: { findUnique: jest.fn() },
  },
}));

const { prisma } = await import("../src/config/db.js");
const {
  assertCanAddBuilding,
  getBuildingUsage,
  resolveBuildingLimit,
} = await import("../src/services/buildingQuotaService.js");

describe("buildingQuotaService — Temel / Business kota", () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  test("resolveBuildingLimit: no subscription → 0", () => {
    expect(resolveBuildingLimit(null)).toBe(0);
  });

  test("resolveBuildingLimit: expired → 0", () => {
    expect(
      resolveBuildingLimit({ status: "EXPIRED", plan: "monthly" })
    ).toBe(0);
  });

  test("resolveBuildingLimit: Temel ACTIVE → 20", () => {
    expect(
      resolveBuildingLimit({ status: "ACTIVE", plan: "monthly" })
    ).toBe(20);
    expect(
      resolveBuildingLimit({ status: "TRIAL", plan: "annual" })
    ).toBe(20);
  });

  test("resolveBuildingLimit: Business → null (sınırsız)", () => {
    expect(
      resolveBuildingLimit({ status: "ACTIVE", plan: "business_monthly" })
    ).toBeNull();
    expect(
      resolveBuildingLimit({ status: "ACTIVE", plan: "business_annual" })
    ).toBeNull();
  });

  test("assertCanAddBuilding rejects without subscription", async () => {
    prisma.subscription.findUnique.mockResolvedValue(null);
    await expect(assertCanAddBuilding("mgr-1")).rejects.toMatchObject({
      statusCode: 403,
    });
  });

  test("assertCanAddBuilding rejects at Temel limit", async () => {
    prisma.subscription.findUnique.mockResolvedValue({
      status: "ACTIVE",
      plan: "monthly",
    });
    prisma.building.count.mockResolvedValue(20);
    await expect(assertCanAddBuilding("mgr-1")).rejects.toMatchObject({
      statusCode: 403,
    });
  });

  test("assertCanAddBuilding allows under Temel limit", async () => {
    prisma.subscription.findUnique.mockResolvedValue({
      status: "ACTIVE",
      plan: "annual",
    });
    prisma.building.count.mockResolvedValue(19);
    await expect(assertCanAddBuilding("mgr-1")).resolves.toBeUndefined();
  });

  test("assertCanAddBuilding allows Business unlimited", async () => {
    prisma.subscription.findUnique.mockResolvedValue({
      status: "ACTIVE",
      plan: "business_monthly",
    });
    prisma.building.count.mockResolvedValue(99);
    await expect(assertCanAddBuilding("mgr-1")).resolves.toBeUndefined();
  });

  test("getBuildingUsage returns count and Temel limit", async () => {
    prisma.subscription.findUnique.mockResolvedValue({
      status: "ACTIVE",
      plan: "monthly",
    });
    prisma.building.count.mockResolvedValue(3);
    const usage = await getBuildingUsage("mgr-1");
    expect(usage).toEqual({ buildings: 3, limit: 20 });
  });
});
