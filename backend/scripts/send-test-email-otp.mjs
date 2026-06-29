#!/usr/bin/env node
/**
 * E-posta OTP testi (Resend)
 * Kullanım: npm run test:email-otp -- user@example.com
 */
import { config } from "dotenv";
import { sendOtpEmail } from "../src/services/email/resendEmail.js";

config();

const to = process.argv[2]?.trim().toLowerCase();
if (!to || !to.includes("@")) {
  console.error("Geçerli e-posta girin (örn. jose.krgzl156@gmail.com)");
  process.exit(1);
}

const code = String(Math.floor(100000 + Math.random() * 900000));
console.log("RESEND_FROM:", process.env.RESEND_FROM_EMAIL || "(varsayılan)");
console.log("Hedef:", to);
console.log("Gönderiliyor...\n");

const result = await sendOtpEmail(to, code);
if (!result.ok) {
  console.error("Hata:", result.error || result.reason);
  process.exit(1);
}

console.log("Başarılı! E-posta gönderildi.");
if (process.env.NODE_ENV !== "production") {
  console.log("Dev kod (backend log):", code);
}
