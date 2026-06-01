/**
 * TR IBAN normalize ve mod-97 doğrulama.
 */

export function normalizeIban(value) {
  if (value == null || value === "") return "";
  return String(value).replace(/\s/g, "").toUpperCase();
}

/**
 * @param {string} iban — normalize edilmiş TR IBAN
 */
export function isValidTrIban(iban) {
  const normalized = normalizeIban(iban);
  if (!/^TR\d{24}$/.test(normalized)) return false;

  const rearranged = normalized.slice(4) + normalized.slice(0, 4);
  const numeric = rearranged
    .split("")
    .map((ch) => {
      const code = ch.charCodeAt(0);
      if (code >= 48 && code <= 57) return ch;
      return String(code - 55);
    })
    .join("");

  let remainder = 0;
  for (let i = 0; i < numeric.length; i += 1) {
    remainder = (remainder * 10 + Number(numeric[i])) % 97;
  }
  return remainder === 1;
}

export function ibansMatch(a, b) {
  const na = normalizeIban(a);
  const nb = normalizeIban(b);
  if (!na || !nb) return false;
  return na === nb;
}
