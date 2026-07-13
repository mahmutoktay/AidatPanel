import { test } from "node:test";
import assert from "node:assert/strict";
import { TR_IBAN_BANK_SHORT_NAMES } from "../src/constants/trIbanBankCodes.js";
import {
  extractTrIbanBankCode,
  resolveTrIbanBank,
  buildAutoCollectionIbanLabel,
  normalizeCollectionIbanLabel,
} from "../src/utils/trIbanBank.js";

// Garanti BBVA (00061) — geçerli örnek IBAN
const GARANTI_IBAN = "TR330006100519786457841326";

test("extractTrIbanBankCode reads positions 5-9", () => {
  assert.equal(extractTrIbanBankCode(GARANTI_IBAN), "00061");
  assert.equal(
    extractTrIbanBankCode("tr33 0006 1005 1978 6457 8413 26"),
    "00061"
  );
});

test("resolveTrIbanBank returns short name for known banks", () => {
  const garanti = resolveTrIbanBank(GARANTI_IBAN);
  assert.ok(garanti);
  assert.equal(garanti.bankCode, "00061");
  assert.equal(garanti.shortName, "Garanti BBVA");
});

test("buildAutoCollectionIbanLabel formats Turkish nickname", () => {
  assert.equal(
    buildAutoCollectionIbanLabel(GARANTI_IBAN),
    "Garanti BBVA IBAN'ım"
  );
});

test("buildAutoCollectionIbanLabel returns null for invalid iban", () => {
  assert.equal(buildAutoCollectionIbanLabel("TR00"), null);
  assert.equal(buildAutoCollectionIbanLabel(""), null);
});

test("normalizeCollectionIbanLabel trims and caps length", () => {
  assert.equal(normalizeCollectionIbanLabel(undefined), undefined);
  assert.equal(normalizeCollectionIbanLabel(null), null);
  assert.equal(normalizeCollectionIbanLabel("  "), null);
  assert.equal(
    normalizeCollectionIbanLabel("  Ziraat hesabım  "),
    "Ziraat hesabım"
  );
  const long = "x".repeat(50);
  assert.equal(normalizeCollectionIbanLabel(long)?.length, 40);
});

test("Kuveyt Türk bank code maps correctly", () => {
  assert.equal(TR_IBAN_BANK_SHORT_NAMES["00205"], "Kuveyt Türk");
  assert.equal(TR_IBAN_BANK_SHORT_NAMES["00010"], "Ziraat");
});
