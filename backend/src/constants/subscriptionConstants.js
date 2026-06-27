/** RevenueCat ürün kimlikleri — App Store Connect / Play Console ile eşleşmeli. */
export const SUBSCRIPTION_PRODUCT_IDS = {
  monthly: "aidatpanel_monthly",
  annual: "aidatpanel_annual",
};

export const SUBSCRIPTION_PLANS = ["monthly", "annual"];

export const SUBSCRIPTION_PLATFORMS = ["ios", "android"];

/** Her plan için bina limit haritası.
 *  null = sınırsız.
 *  key: plan adı (lowercase), value: max bina sayısı veya null (sınırsız).
 */
export const PLAN_BUILDING_LIMITS = {
  monthly: 5,
  annual: 5,
  // Gelecekteki paketler için:
  // monthly_5_20: 20,
  // annual_5_20: 20,
  // monthly_20_50: 50,
  // annual_20_50: 50,
  // monthly_50_plus: null,
  // annual_50_plus: null,
};

/** Aboneliği olmayan kullanıcı için varsayılan limit. */
export const DEFAULT_BUILDING_LIMIT = 1;

/** RevenueCat ürün ID → paket adı eşleme kuralları.
 *  Sıralı: ilk eşleşen kazanır.
 *  [regex pattern, plan_name]
 */
export const PRODUCT_ID_PLAN_MAP = [
  [/annual|yearly/i, "annual"],
  [/monthly/i, "monthly"],
];
