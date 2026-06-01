#!/usr/bin/env node
/**
 * FCM credential + gönderim teşhisi.
 *
 * Credential only: npm run verify:firebase  |  npm run diagnose:fcm
 * Gerçek push:      npm run diagnose:fcm -- "<fcmToken>"
 */
import { config } from "dotenv";
import {
  getFirebaseCredentialSource,
  getFirebaseProjectId,
  initFirebase,
} from "../src/config/firebase.js";
import { sendToToken } from "../src/services/pushService.js";

config();

const tokenArg = process.argv[2]?.trim().replace(/^["']|["']$/g, "");

if (!initFirebase()) {
  console.error(
    "HATA: Firebase başlatılamadı. FIREBASE_SERVICE_ACCOUNT_PATH veya JSON tanımlayın."
  );
  process.exit(1);
}

console.log("--- Firebase Admin ---");
console.log("project_id:", getFirebaseProjectId() ?? "?");
console.log("kaynak:", getFirebaseCredentialSource() ?? "?");
console.log(
  "beklenen FIREBASE_PROJECT_ID:",
  process.env.FIREBASE_PROJECT_ID || "aidatpanel"
);

if (!tokenArg) {
  console.log(
    "\n(Token verilmedi — yalnızca credential testi. Gönderim: npm run diagnose:fcm -- \"<token>\")"
  );
  console.log("\n✅ Firebase Admin SDK hazır.");
  process.exit(0);
}

console.log("\n--- FCM gönderim denemesi ---");
const result = await sendToToken(tokenArg, {
  title: "AidatPanel diagnose",
  body: "FCM test",
  data: {
    type: "SYSTEM",
    notificationId: "diagnose-" + Date.now(),
    route: "/notifications",
  },
});

if (result.sent) {
  console.log("✅ GÖNDERİLDİ");
  process.exit(0);
}

console.error("❌ GÖNDERİLEMEDİ");
console.error("code:", result.code ?? "?");
console.error("error:", result.error ?? result.reason ?? "unknown");

const msg = String(result.error ?? "");
console.log("\n--- Önerilen düzeltmeler ---");
if (msg.includes("cloudmessaging.messages.create")) {
  console.log("1. Google Cloud → APIs → 'Firebase Cloud Messaging API' → ENABLE");
  console.log(
    "   https://console.cloud.google.com/apis/library/fcm.googleapis.com?project=aidatpanel"
  );
  console.log("2. IAM → service account → Firebase Admin veya Cloud Messaging Admin");
  console.log("3. Firebase Console → YENİ private key → pm2 restart");
} else if (msg.includes("not a valid FCM registration token")) {
  console.log("Token geçersiz — uygulamada yeniden giriş, PUT /me/fcm-token");
} else {
  console.log("npm run test:push ile aynı tokenı deneyin; IAM + yeni key kontrol edin.");
}
process.exit(1);
