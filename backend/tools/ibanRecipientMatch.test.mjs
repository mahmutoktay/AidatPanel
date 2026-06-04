import { test } from "node:test";
import assert from "node:assert/strict";
import {
  normalizeIban,
  ibansMatch,
  extractAllTrIbans,
  recipientMatchesCollectionIban,
} from "../src/utils/iban.js";

const COLLECTION = "TR330006100519786457841326";

test("ibansMatch ignores spaces and case", () => {
  assert.equal(
    ibansMatch("tr33 0006 1005 1978 6457 8413 26", COLLECTION),
    true
  );
});

test("extractAllTrIbans finds multiple full ibans only", () => {
  const text = `
    Gönderen IBAN: TR11 0001 0000 0000 0000 0000 01
    Alıcı IBAN: TR33 0006 1005 1978 6457 8413 26
  `;
  const all = extractAllTrIbans(text);
  assert.equal(all.length, 2);
  assert.ok(all.includes(COLLECTION));
});

test("recipientMatchesCollectionIban uses rawtext when parsed is sender iban", () => {
  const sender = "TR11000100000000000000000001";
  const rawText = `Gönderen IBAN: ${sender}\nAlıcı IBAN: TR33 0006 1005 1978 6457 8413 26`;
  const r = recipientMatchesCollectionIban({
    parsedReceiverIban: sender,
    collectionIban: COLLECTION,
    rawText,
  });
  assert.equal(r.ok, true);
  assert.equal(r.source, "rawtext_scan");
  assert.equal(r.matchedIban, COLLECTION);
});

test("recipientMatchesCollectionIban fails when no iban in text matches", () => {
  const r = recipientMatchesCollectionIban({
    parsedReceiverIban: "TR11000100000000000000000001",
    collectionIban: COLLECTION,
    rawText: "Gönderen IBAN: TR11 0001 0000 0000 0000 0000 01",
  });
  assert.equal(r.ok, false);
  assert.equal(r.source, "mismatch");
});
