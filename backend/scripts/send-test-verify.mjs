#!/usr/bin/env node
/**
 * Twilio Verify OTP testi (Benjamin Helper ile aynı kanal)
 * Kullanım: npm run test:verify -- 5315635049
 */
import { config } from "dotenv";
import { startTwilioVerification } from "../src/services/sms/twilioVerifyProvider.js";
import { normalizeTrPhone } from "../src/utils/normalizeTrPhone.js";

config();

const raw = process.argv[2];
const phone = normalizeTrPhone(raw);
if (!phone) {
  console.error("Geçerli TR cep numarası girin (örn. 5315635049)");
  process.exit(1);
}

console.log("Verify Service:", process.env.TWILIO_VERIFY_SERVICE_SID || "(yok)");
console.log("Hedef: +90" + phone);
console.log("Gönderiliyor...\n");

const result = await startTwilioVerification(phone);
if (!result.ok) {
  console.error("Hata:", result.error || result.reason);
  process.exit(1);
}

console.log("Başarılı! Verification SID:", result.sid);
console.log("Telefonunuza 6 haneli kod gelmeli (Twilio Verify).");
