#!/usr/bin/env node
/**
 * Twilio / NetGsm SMS testi
 *
 *   cd backend
 *   node scripts/send-test-sms.mjs 5551234567
 *
 * Telefon: 10 hane (5xxxxxxxxx) veya +90 / 0 ile başlayan format.
 */
import { config } from "dotenv";
import { normalizeTrPhone } from "../src/utils/normalizeTrPhone.js";
import { sendSms } from "../src/services/sms/sendSms.js";

config();

const rawPhone = process.argv[2];
const customMessage = process.argv.slice(3).join(" ");

if (!rawPhone) {
  console.error("Kullanım: node scripts/send-test-sms.mjs 5551234567 [mesaj]");
  process.exit(1);
}

const phone = normalizeTrPhone(rawPhone);
if (!phone) {
  console.error("Geçersiz telefon. Örnek: 5551234567");
  process.exit(1);
}

const message =
  customMessage ||
  `AidatPanel test SMS — ${new Date().toLocaleString("tr-TR")}`;

console.log("SMS_PROVIDER:", process.env.SMS_PROVIDER || "auto");
console.log("Hedef:", `+90${phone}`);
console.log("Twilio From:", process.env.TWILIO_PHONE_FROM || "(yok)");
console.log("Gönderiliyor...\n");

const result = await sendSms(phone, message);

if (result.dev) {
  console.log("DEV modu — SMS gönderilmedi, mesaj sunucu logunda:");
  console.log(message);
  process.exit(0);
}

if (result.ok) {
  console.log("Başarılı!", result.sid ? `SID: ${result.sid}` : "");
  process.exit(0);
}

console.error("Hata:", result.error || result.code || "bilinmiyor");
console.error(
  "\nTwilio trial: Console → Verified Caller IDs → +90 numaranızı doğrulayın."
);
process.exit(1);
