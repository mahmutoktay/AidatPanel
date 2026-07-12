/**
 * Kullanıcıya gösterilen para birimi — API/DB ISO kodunu sembole çevirir.
 * @param {string | null | undefined} code
 * @returns {string}
 */
export function currencyDisplay(code) {
  if (code == null || String(code).trim() === "") return "₺";
  const normalized = String(code).trim().toUpperCase();
  if (normalized === "TRY" || normalized === "TL") return "₺";
  return String(code).trim();
}
