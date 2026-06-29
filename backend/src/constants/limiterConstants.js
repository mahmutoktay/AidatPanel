/**
 * Rate Limiter Sabitleri
 *
 * Tüm rate limit değerleri bu dosyada toplanmıştır.
 * Tek bir noktadan değiştirilebilir (DRY).
 *
 * Ortam değişkenleri ile override:
 * - API_RATE_LIMIT_MAX
 * - AUTH_RATE_LIMIT_MAX
 * - DEKONT_UPLOAD_RATE_MAX
 * - DEKONT_UPLOAD_RATE_WINDOW_MS
 */

// =============================================================================
// Genel API Limiter
// =============================================================================

/** Genel API için pencere aralığı: 15 dakika (ms) */
export const API_WINDOW_MS = 15 * 60 * 1000;

/**
 * Genel API için maksimum istek sayısı (pencere başına).
 * Production: 15dk / 600 istek = sayfa başına ~4 istekten ~150 sayfa görüntüleme.
 */
export const API_MAX_REQUESTS = 600;

// =============================================================================
// Auth Limiter
// =============================================================================

/** Auth endpoint'leri için pencere aralığı: 15 dakika (ms) */
export const AUTH_WINDOW_MS = 15 * 60 * 1000;

/** Auth endpoint'leri için maksimum istek (pencere başına) — brute-force koruması */
export const AUTH_MAX_REQUESTS = 5;

// =============================================================================
// Dekont Upload Limiter
// =============================================================================

/** Dekont yükleme için pencere aralığı: 1 saat (ms) */
export const DEKONT_UPLOAD_WINDOW_MS = 60 * 60 * 1000;

/** Dekont yükleme için maksimum istek sayısı (kullanıcı başına, saatlik) */
export const DEKONT_UPLOAD_MAX_REQUESTS = 50;

// =============================================================================
// Strict Limiter
// =============================================================================

/** Strict limiter için pencere aralığı: 1 saat (ms) */
export const STRICT_WINDOW_MS = 60 * 60 * 1000;

/** Strict limiter için maksimum istek (IP başına, saatlik) */
export const STRICT_MAX_REQUESTS = 3;

// =============================================================================
// OTP Limiter
// =============================================================================

/** OTP gönder/doğrula için pencere: 15 dakika (ms) */
export const OTP_WINDOW_MS = 15 * 60 * 1000;

/** OTP için maksimum istek (telefon başına, pencere başına) */
export const OTP_MAX_REQUESTS = 5;
