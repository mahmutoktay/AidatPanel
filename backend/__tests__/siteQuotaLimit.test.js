import { jest } from "@jest/globals";

jest.unstable_mockModule("../src/constants/subscriptionConstants.js", () => ({
  BUILDING_LIMIT_ACTIVE: 2,
}));

jest.unstable_mockModule("../src/config/db.js", () => ({
  prisma: {
    building: { count: jest.fn() },
    subscription: { findUnique: jest.fn() },
  },
}));

const { prisma } = await import("../src/config/db.js");
const { assertCanAddBuilding, getBuildingUsage } = await import(
  "../src/services/buildingQuotaService.js"
);

describe("buildingQuotaService — finite limit", () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  test("assertCanAddBuilding rejects at limit", async () => {
    prisma.subscription.findUnique.mockResolvedValue({ status: "ACTIVE" });
    prisma.building.count.mockResolvedValue(2);
    await expect(assertCanAddBuilding("mgr-1")).rejects.toMatchObject({
      statusCode: 403,
    });
  });

  test("getBuildingUsage returns count and limit", async () => {
    prisma.subscription.findUnique.mockResolvedValue({ status: "ACTIVE" });
    prisma.building.count.mockResolvedValue(1);
    const usage = await getBuildingUsage("mgr-1");
    expect(usage).toEqual({ buildings: 1, limit: 2 });
  });
});
