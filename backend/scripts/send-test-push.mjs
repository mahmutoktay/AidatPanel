#!/usr/bin/env node
/**
 * Tek cihaza test FCM (emülatör/debug doğrulama).
 *
 * Kullanım (backend/ dizininden):
 *   node scripts/send-test-push.mjs "<fcmToken>" "Test başlık" "Test mesaj"
 *
 * Logcat: adb logcat | findstr FCM
 */
import { config } from "dotenv";
import { initFirebase } from "../src/config/firebase.js";
import { sendToToken } from "../src/services/pushService.js";

config();

const token = process.argv[2]?.trim().replace(/^["']|["']$/g, "");
const title = process.argv[3]?.trim() || "AidatPanel test";
const body =
  process.argv[4]?.trim() || "Kapalı uygulama push testi — " + new Date().toISOString();

if (!token) {
  console.error(
    "Kullanım: node scripts/send-test-push.mjs \"<fcmToken>\" [başlık] [gövde]"
  );
  process.exit(1);
}

if (!initFirebase()) {
  console.error(
    "[test-push] Firebase başlatılamadı. FIREBASE_SERVICE_ACCOUNT_JSON veya PATH tanımlayın."
  );
  process.exit(1);
}

const result = await sendToToken(token, {
  title,
  body,
  data: {
    type: "SYSTEM",
    notificationId: "test-" + Date.now(),
    route: "/notifications",
  },
});

console.log("[test-push] sonuç:", JSON.stringify(result, null, 2));
if (!result.sent) {
  console.log("\nDetaylı teşhis: npm run diagnose:fcm -- \"<aynı token>\"");
}
process.exit(result.sent ? 0 : 1);
