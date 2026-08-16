import { test } from "node:test";
import assert from "node:assert/strict";
import { parseReceiptText } from "../src/constants/bankReceiptProfiles.js";

/** Kuveyt Türk 2026 e-Dekont (Giden) — Gönderilen IBAN etiketi */
const KUVEYT_TURK_2026_GIDEN = `
IBAN'a Para Transferi (Giden) e-Dekont
Şube Adı : Genel Müdürlük
Müşteri No : 98669614
İşlem Ref : B8M2P-B-20260805340
Belge No : CJS2026000523860
Belge Tarihi : 05-08-2026 23:56:21
Gönderen Kişi : ABDULLAH ASLAN
Alıcı : Abdullah Aslan
Gönderilen IBAN : TR19 0001 5001 5800 7357 6658 13
Alıcı Banka : Türkiye Vakıflar Bankası T.A.O.
İşlem Yeri : Mobil Şube
Tutar : 1.000,00 TL
Kuveyt Türk Katılım Bankası A.Ş.
Web Adresi : kuveytturk.com.tr
`.trim();

test("Kuveyt Türk 2026 Giden e-Dekont: Gönderilen IBAN parse edilir", () => {
  const { profile, parsed } = parseReceiptText(KUVEYT_TURK_2026_GIDEN);
  assert.equal(profile, "KUVEYT_TURK");
  assert.equal(parsed.bankCode, "KUVEYT_TURK");
  assert.equal(parsed.receiverIban, "TR190001500158007357665813");
  assert.equal(parsed.amount, 1000);
  assert.equal(parsed.referenceNumber, "CJS2026000523860");
  assert.equal(parsed.receiverName, "Abdullah Aslan");
  assert.equal(parsed.transactionDate, "2026-08-05T12:00:00.000Z");
});

test("Kuveyt Türk eski Alıcı IBAN etiketi hâlâ çalışır", () => {
  const text = `
Kuveyt Türk Katılım Bankası A.Ş.
Alıcı : Ayşe Yılmaz
Alıcı IBAN : TR33 0006 1005 1978 6457 8413 26
Tutar : 250,50 TL
Belge No : OLD20250001
Belge Tarihi : 12-03-2025 10:00:00
kuveytturk.com.tr
`.trim();
  const { parsed } = parseReceiptText(text);
  assert.equal(parsed.bankCode, "KUVEYT_TURK");
  assert.equal(parsed.receiverIban, "TR330006100519786457841326");
  assert.equal(parsed.amount, 250.5);
});

test("Alıcı Banka VakıfBank olsa bile logo ile Kuveyt seçilir", () => {
  const text = `
KUVEYTTÜRK
IBAN'a Para Transferi (Giden) e-Dekont
Belge Tarihi : 05-08-2026 23:56:21
Alıcı : Abdullah Aslan
Gönderilen IBAN : TR19 0001 5001 5800 7357 6658 13
Alıcı Banka : Türkiye Vakıflar Bankası T.A.O.
Tutar : 1.000,00 TL
`.trim();
  const { profile, parsed } = parseReceiptText(text);
  assert.equal(profile, "KUVEYT_TURK");
  assert.equal(parsed.amount, 1000);
  assert.equal(parsed.receiverIban, "TR190001500158007357665813");
  assert.equal(parsed.receiverName, "Abdullah Aslan");
});

test("Yalnızca Alıcı Banka satırındaki Vakıflar ünvanı VAKIFBANK sayılmaz", () => {
  const text = `
IBAN'a Para Transferi (Giden) e-Dekont
Belge Tarihi : 05-08-2026 23:56:21
Alıcı : Abdullah Aslan
Gönderilen IBAN : TR19 0001 5001 5800 7357 6658 13
Alıcı Banka : Türkiye Vakıflar Bankası T.A.O.
İşlem Yeri : Mobil Şube
Tutar : 1.000,00 TL
`.trim();
  const { profile, parsed } = parseReceiptText(text);
  assert.notEqual(profile, "VAKIFBANK");
  assert.equal(parsed.receiverIban, "TR190001500158007357665813");
  assert.equal(parsed.amount, 1000);
});

test("pdfjs boşluklu tire tarihleri normalize edilir", () => {
  const text = `
Kuveyt Türk Katılım Bankası A.Ş.
Belge Tarihi : 05 - 08 - 2026 23:56:21
Alıcı : Abdullah Aslan
Gönderilen IBAN : TR19 0001 5001 5800 7357 6658 13
Tutar : 1.000,00 TL
kuveytturk.com.tr
`.trim();
  const { parsed } = parseReceiptText(text);
  assert.equal(parsed.transactionDate, "2026-08-05T12:00:00.000Z");
  assert.equal(parsed.receiverName, "Abdullah Aslan");
});
