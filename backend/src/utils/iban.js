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

/** Tam TR IBAN (26 karakter) — boşluklu/boşluksuz metinden */
const TR_IBAN_FULL_PATTERN = /TR\s*\d{2}(?:\s*\d{4}){5}\s*\d{2}/gi;

/**
 * Metindeki tüm geçerli TR IBAN'larını döndürür (normalize, tekrarsız).
 * @param {string} text
 * @returns {string[]}
 */
export function extractAllTrIbans(text) {
  if (text == null || text === "") return [];
  const seen = new Set();
  const out = [];
  const re = new RegExp(TR_IBAN_FULL_PATTERN.source, TR_IBAN_FULL_PATTERN.flags);
  for (const m of String(text).matchAll(re)) {
    const n = normalizeIban(m[0]);
    if (/^TR\d{24}$/.test(n) && !seen.has(n)) {
      seen.add(n);
      out.push(n);
    }
  }
  return out;
}

/**
 * Dekont alıcı IBAN doğrulaması: önce OCR parsed alan, olmazsa rawText taraması.
 *
 * @param {{ parsedReceiverIban?: string|null, collectionIban?: string|null, rawText?: string|null }} input
 */
export function recipientMatchesCollectionIban({
  parsedReceiverIban,
  collectionIban,
  rawText,
}) {
  const expected = normalizeIban(collectionIban);
  if (!expected) {
    return { ok: false, matchedIban: null, source: "no_collection_iban" };
  }

  const parsed = normalizeIban(parsedReceiverIban);
  if (parsed && ibansMatch(parsed, expected)) {
    return { ok: true, matchedIban: parsed, source: "parsed_field" };
  }

  const fromText = extractAllTrIbans(rawText);
  const hit = fromText.find((iban) => ibansMatch(iban, expected));
  if (hit) {
    return { ok: true, matchedIban: hit, source: "rawtext_scan" };
  }

  return {
    ok: false,
    matchedIban: parsed || fromText[0] || null,
    source: "mismatch",
    parsedIban: parsed || null,
    collectionIban: expected,
    ibansInRawText: fromText,
  };
}
