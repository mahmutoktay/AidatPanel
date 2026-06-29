/** Admin panelde Prisma enum değerlerinin Türkçe karşılıkları */

export const DEKONT_STATUS_TR = {
  RECEIVED: "Alındı",
  EXTRACTING: "Metin çıkarılıyor",
  EXTRACT_FAILED: "Okuma başarısız",
  PARSED: "Okundu",
  PARSE_LOW_CONFIDENCE: "Düşük güven",
  MATCHING: "Eşleştiriliyor",
  MATCHED: "Eşleşti",
  MATCH_AMBIGUOUS: "Belirsiz eşleşme",
  UNMATCHED: "Eşleşmedi",
  PAYMENT_APPLIED: "Ödeme uygulandı",
  PAYMENT_PARTIAL: "Kısmi ödeme",
  REJECTED: "Reddedildi",
  RECIPIENT_MISMATCH: "Alıcı uyuşmazlığı",
  NEEDS_MANAGER_REVIEW: "Yönetici incelemesi",
};

export const SUBSCRIPTION_STATUS_TR = {
  ACTIVE: "Aktif",
  EXPIRED: "Süresi dolmuş",
  CANCELLED: "İptal",
  TRIAL: "Deneme",
};

export const SUBSCRIPTION_PLAN_TR = {
  monthly: "Aylık",
  annual: "Yıllık",
};

export const USER_ROLE_TR = {
  MANAGER: "Yönetici",
  RESIDENT: "Sakin",
};

export const PROMO_TYPE_TR = {
  FREE_PERIOD: "Ücretsiz süre",
  DISCOUNT_PERCENT: "İndirim yüzdesi",
};

export function labelDekontStatus(status) {
  return DEKONT_STATUS_TR[status] ?? status;
}

export function labelSubscriptionStatus(status) {
  return SUBSCRIPTION_STATUS_TR[status] ?? status;
}
