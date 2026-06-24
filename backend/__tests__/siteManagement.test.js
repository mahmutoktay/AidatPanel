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
  });
});
