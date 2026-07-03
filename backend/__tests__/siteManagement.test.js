<<<<<<< HEAD
import { resolveEffectiveBuildingConfig } from "../src/utils/effectiveBuildingConfig.js";
import { computeSitePerUnitAmount } from "../src/services/siteExpenseAllocationService.js";

describe("resolveEffectiveBuildingConfig", () => {
  test("falls back to site defaults when building fields are null", () => {
    const building = {
      id: "b1",
      name: "A Blok",
      siteId: "s1",
      blockLabel: "A Blok",
      address: "",
      addressExtra: null,
      city: "",
      dueAmount: null,
      dueDay: null,
      currency: null,
      collectionIban: null,
      collectionAccountTitle: null,
      paymentReferenceTemplate: null,
      collectionVerifiedAt: null,
      site: {
        name: "Güneş Sitesi",
        address: "Merkez Mah.",
        city: "İstanbul",
        dueAmount: 500,
        dueDay: 5,
        currency: "TRY",
        collectionIban: "TR330006100519786457841326",
        collectionAccountTitle: "Site Yönetimi",
        paymentReferenceTemplate: "Daire {no}",
        collectionVerifiedAt: null,
      },
    };

    const effective = resolveEffectiveBuildingConfig(building);

    expect(effective.effectiveDueAmount).toBe(500);
    expect(effective.effectiveDueDay).toBe(5);
    expect(effective.effectiveCollectionIban).toBe("TR330006100519786457841326");
    expect(effective.isCollectionConfigured).toBe(true);
    expect(effective.siteName).toBe("Güneş Sitesi");
    expect(effective.effectiveCity).toBe("İstanbul");
  });

  test("building override wins over site defaults", () => {
    const building = {
      id: "b1",
      name: "B Blok",
      siteId: "s1",
      blockLabel: null,
      address: "Özel adres",
      addressExtra: "Kat 2",
      city: "Ankara",
      dueAmount: 750,
      dueDay: 10,
      currency: "TRY",
      collectionIban: "TR760006400000123456789012",
      collectionAccountTitle: "B Blok",
      paymentReferenceTemplate: null,
      collectionVerifiedAt: null,
      site: {
        name: "Site",
        address: "Site adres",
        city: "İstanbul",
        dueAmount: 500,
        dueDay: 5,
        currency: "TRY",
        collectionIban: "TR330006100519786457841326",
        collectionAccountTitle: "Site",
        paymentReferenceTemplate: "X",
        collectionVerifiedAt: null,
      },
    };

    const effective = resolveEffectiveBuildingConfig(building);

    expect(effective.effectiveDueAmount).toBe(750);
    expect(effective.effectiveCollectionIban).toBe("TR760006400000123456789012");
    expect(effective.effectiveAddress).toBe("Özel adres");
    expect(effective.effectiveCity).toBe("Ankara");
  });
});

describe("computeSitePerUnitAmount", () => {
  test("splits site expense equally across apartments", () => {
    expect(computeSitePerUnitAmount(900, 3)).toBe(300);
    expect(computeSitePerUnitAmount(100, 3)).toBe(33.33);
=======
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

  test("assertCanAddBuilding passes when limit is null", async () => {
    prisma.subscription.findUnique.mockResolvedValue({ status: "ACTIVE" });
    prisma.building.count.mockResolvedValue(99);
    await expect(assertCanAddBuilding("mgr-1")).resolves.toBeUndefined();
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
  });
});
