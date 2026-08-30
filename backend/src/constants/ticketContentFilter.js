import {
  TICKET_FILTER_WORDS,
  TICKET_FILTER_PATTERNS,
} from "./ticketContentFilter.words.js";

/** Türkçe karakter normalizasyonu — basit eşleştirme için */
export function preprocessText(rawText) {
  let text = String(rawText ?? "").toLowerCase();
  text = text
    .replace(/ı/g, "i")
    .replace(/ğ/g, "g")
    .replace(/ü/g, "u")
    .replace(/ş/g, "s")
    .replace(/ö/g, "o")
    .replace(/ç/g, "c");
  text = text.replace(/[^a-z0-9\s]/g, " ");
  text = text.replace(/\s+/g, " ").trim();
  return text;
}

function wordMatches(text, word) {
  const normalizedWord = preprocessText(word);
  if (!normalizedWord) return false;
  const pattern = new RegExp(`\\b${normalizedWord.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")}\\b`, "i");
  return pattern.test(text);
}

/**
 * Metin uygunsuz kelime filtresine takılıyor mu?
 * @param {string} rawText
 * @returns {boolean}
 */
export function matchesContentFilter(rawText) {
  if (!rawText || !String(rawText).trim()) return false;

  const text = preprocessText(rawText);

  for (const word of TICKET_FILTER_WORDS) {
    if (wordMatches(text, word)) return true;
  }

  for (const pattern of TICKET_FILTER_PATTERNS) {
    if (pattern.test(rawText)) return true;
  }

  return false;
}

/**
 * Birden fazla metin alanını birleştirip kontrol eder.
 * @param  {...string} parts
 * @returns {boolean}
 */
export function matchesContentFilterCombined(...parts) {
  return parts.some((p) => matchesContentFilter(p));
}
