#!/usr/bin/env node
/**
 * Twilio OTP yapılandırma teşhisi
 *   cd backend && npm run diagnose:twilio
 */
import { config } from "dotenv";
import { isTwilioVerifyConfigured } from "../src/services/sms/twilioVerifyProvider.js";

config();

const accountSid = process.env.TWILIO_ACCOUNT_SID?.trim();
const authToken = process.env.TWILIO_AUTH_TOKEN?.trim();
const from = process.env.TWILIO_PHONE_FROM?.trim();
const verifySid = process.env.TWILIO_VERIFY_SERVICE_SID?.trim();

console.log("=== AidatPanel Twilio Teşhis ===\n");
console.log("NODE_ENV:", process.env.NODE_ENV || "(yok)");
console.log("SMS_PROVIDER:", process.env.SMS_PROVIDER || "auto");
console.log("TWILIO_ACCOUNT_SID:", accountSid ? "tanımlı" : "EKSİK");
console.log("TWILIO_AUTH_TOKEN:", authToken ? "tanımlı" : "EKSİK");
console.log("TWILIO_PHONE_FROM:", from || "(yok)");
console.log("TWILIO_VERIFY_SERVICE_SID:", verifySid || "(yok)");
console.log("Twilio Verify aktif:", isTwilioVerifyConfigured() ? "evet" : "hayır");
console.log("");

if (!accountSid || !authToken) {
  console.error("TWILIO_ACCOUNT_SID ve TWILIO_AUTH_TOKEN .env dosyasında olmalı.");
  process.exit(1);
}

const authHeader = `Basic ${Buffer.from(`${accountSid}:${authToken}`).toString("base64")}`;

const numbersRes = await fetch(
  `https://api.twilio.com/2010-04-01/Accounts/${accountSid}/IncomingPhoneNumbers.json?PageSize=20`,
  { headers: { Authorization: authHeader } }
);
const numbersData = await numbersRes.json();
const owned = (numbersData.incoming_phone_numbers ?? []).map((n) => n.phone_number);

console.log("Hesaptaki Twilio numaraları:", owned.length ? owned.join(", ") : "(hiç yok)");

if (from && !owned.includes(from)) {
  console.error(
    "\nHATA: TWILIO_PHONE_FROM bu hesaba ait bir Twilio numarası değil.",
    "\n       Twilio Console → Phone Numbers → Buy a number ile numara alın",
    "\n       veya TWILIO_VERIFY_SERVICE_SID kullanın (önerilen — FROM gerekmez)."
  );
}

if (!verifySid) {
  console.warn(
    "\nUYARI: TWILIO_VERIFY_SERVICE_SID yok — ham SMS modu kullanılıyor.",
    "\n       OTP için Console → Verify → Services → Service SID ekleyin (.env)."
  );
}

if (verifySid) {
  const vRes = await fetch(
    `https://verify.twilio.com/v2/Services/${verifySid}`,
    { headers: { Authorization: authHeader } }
  );
  if (!vRes.ok) {
    const vData = await vRes.json().catch(() => ({}));
    console.error("\nHATA: Verify Service SID geçersiz:", vData.message || vRes.status);
  } else {
    console.log("\nVerify Service SID geçerli.");
  }
}

console.log(
  "\nTrial hesap: alıcı +90 numarası Console → Verified Caller IDs listesinde olmalı.",
  "\nTürkiye: Console → Messaging → Geo permissions → Turkey açık olmalı.",
  "\nTest: npm run test:verify -- 5XXXXXXXXX"
);
