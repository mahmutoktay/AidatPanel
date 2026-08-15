/** RevenueCat ürün kimlikleri — App Store Connect / Play Console ile eşleşmeli. */
export const SUBSCRIPTION_PRODUCT_IDS = {
  monthly: "aidatpanel_monthly",
  annual: "aidatpanel_annual",
  businessMonthly: "aidatpanel_business_monthly",
  businessAnnual: "aidatpanel_business_annual",
};

/** DB / webhook plan değerleri */
export const SUBSCRIPTION_PLANS = [
  "monthly",
  "annual",
  "business_monthly",
  "business_annual",
];

export const SUBSCRIPTION_PLATFORMS = ["ios", "android"];

/** Temel plan (monthly / annual) bina üst sınırı */
export const BUILDING_LIMIT_BASIC = 20;

/** Business plan — null = sınırsız */
export const BUILDING_LIMIT_BUSINESS = null;

/** Abonelik yok / süresi dolmuş — yeni bina eklenemez */
export const BUILDING_LIMIT_NONE = 0;

export function isBusinessPlan(plan) {
  return plan === "business_monthly" || plan === "business_annual";
}

export function isBasicPlan(plan) {
  return plan === "monthly" || plan === "annual";
}

export function isEntitledStatus(status) {
  return status === "ACTIVE" || status === "TRIAL";
}
