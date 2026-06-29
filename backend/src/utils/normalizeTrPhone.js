/**
 * Türkiye cep telefonu → kanonik 10 hane (5xxxxxxxxx).
 * @param {unknown} input
 * @returns {string|null}
 */
export function normalizeTrPhone(input) {
  if (input == null || typeof input !== "string") return null;
  let digits = input.replace(/\D/g, "");
  if (digits.startsWith("90") && digits.length >= 12) {
    digits = digits.slice(2);
  }
  if (digits.startsWith("0") && digits.length === 11) {
    digits = digits.slice(1);
  }
  if (digits.length === 10 && digits.startsWith("5")) {
    return digits;
  }
  return null;
}

/**
 * Login identifier: email veya normalize telefon.
 * @param {string} identifier
 * @returns {string}
 */
export function normalizeLoginIdentifier(identifier) {
  if (typeof identifier !== "string") return identifier;
  const trimmed = identifier.trim();
  if (trimmed.includes("@")) return trimmed.toLowerCase();
  const phone = normalizeTrPhone(trimmed);
  return phone ?? trimmed;
}
