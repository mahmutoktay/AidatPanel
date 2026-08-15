import { jest } from "@jest/globals";

jest.unstable_mockModule("../src/config/db.js", () => ({
  prisma: {
    building: { count: jest.fn() },
    subscription: { findUnique: jest.fn() },
    site: { findFirst: jest.fn(), findUnique: jest.fn() },
  },
}));

const { prisma } = await import("../src/config/db.js");
const { resolveEffectiveBuildingConfig } = await import(
  "../src/services/buildingConfigService.js"
);
const { countManagerBuildings, assertCanAddBuilding } = await import(
  "../src/services/buildingQuotaService.js"
);
const { HttpError } = await import("../src/utils/httpError.js");

describe("buildingConfigService", () => {
  test("resolveEffectiveBuildingConfig inherits site IBAN and due", async () => {
    const building = {
      id: "b1",
      name: "A Blok",
      blockLabel: "A Blok",
      address: "No:1",
      city: "Istanbul",
      dueAmount: null,
      dueDay: 5,
      currency: "TRY",
      collectionIban: null,
      collectionAccountTitle: null,
      paymentReferenceTemplate: null,
      site: {
        name: "Gül Sitesi",
        address: "Site Cad.",
        city: "Istanbul",
        dueAmount: 500,
        dueDay: 1,
        currency: "TRY",
        collectionIban: "TR330006100519786457841326",
        collectionAccountTitle: "Site Yönetimi",
        paymentReferenceTemplate: "DAIRE-{no}",
      },
    };

    const effective = await resolveEffectiveBuildingConfig(building);
    expect(Number(effective.effectiveDueAmount)).toBe(500);
    expect(effective.effectiveCollectionIban).toBe("TR330006100519786457841326");
    expect(effective.siteName).toBe("Gül Sitesi");
    expect(effective.displayName).toBe("A Blok");
  });

  test("displayName falls back to blockLabel when name empty", async () => {
    const building = {
      id: "b2",
      name: "",
      blockLabel: "C Blok",
      address: "x",
      city: "Ankara",
      site: null,
      siteId: null,
    };
    prisma.site.findUnique.mockResolvedValue(null);
    const effective = await resolveEffectiveBuildingConfig(building);
    expect(effective.displayName).toBe("C Blok");
  });
});

describe("buildingQuotaService", () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  test("countManagerBuildings counts all buildings", async () => {
    prisma.building.count.mockResolvedValue(7);
    const count = await countManagerBuildings("mgr-1");
    expect(count).toBe(7);
    expect(prisma.building.count).toHaveBeenCalledWith({
      where: { managerId: "mgr-1" },
    });
  });

  test("assertCanAddBuilding passes for Business (sınırsız)", async () => {
    prisma.subscription.findUnique.mockResolvedValue({
      status: "ACTIVE",
      plan: "business_monthly",
    });
    prisma.building.count.mockResolvedValue(99);
    await expect(assertCanAddBuilding("mgr-1")).resolves.toBeUndefined();
  });
});
