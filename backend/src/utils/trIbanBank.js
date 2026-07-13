import { normalizeIban, isValidTrIban } from "./iban.js";
import { TR_IBAN_BANK_SHORT_NAMES } from "../constants/trIbanBankCodes.js";

/**
 * TR IBAN'dan 5 haneli banka kodunu çıkarır (karakter 4–8).
 * @param {string} iban
 * @returns {string|null}
 */
export function extractTrIbanBankCode(iban) {
  const normalized = normalizeIban(iban);
  if (!isValidTrIban(normalized)) return null;
  return normalized.slice(4, 9);
}

/**
 * @param {string} iban
 * @returns {{ bankCode: string, shortName: string }|null}
 */
export function resolveTrIbanBank(iban) {
  const bankCode = extractTrIbanBankCode(iban);
  if (!bankCode) return null;
  const shortName = TR_IBAN_BANK_SHORT_NAMES[bankCode] ?? null;
  if (!shortName) return null;
  return { bankCode, shortName };
}

/**
 * Otomatik takma ad: "{banka} IBAN'ım"
 * @param {string} iban
 * @returns {string|null}
 */
export function buildAutoCollectionIbanLabel(iban) {
  const bank = resolveTrIbanBank(iban);
  if (!bank) return null;
  return `${bank.shortName} IBAN'ım`;
}

const MAX_LABEL_LENGTH = 40;

/**
 * Kullanıcı / API label normalize.
 * @param {unknown} value
 * @returns {string|null|undefined} undefined = alan yok; null = temizle
 */
export function normalizeCollectionIbanLabel(value) {
  if (value === undefined) return undefined;
  if (value === null) return null;
  const trimmed = String(value).trim();
  if (trimmed === "") return null;
  return trimmed.slice(0, MAX_LABEL_LENGTH);
}
