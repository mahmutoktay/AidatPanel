import admin from "firebase-admin";
import { existsSync, readFileSync } from "node:fs";
import { isAbsolute, resolve } from "node:path";

let initialized = false;
/** @type {string | null} */
let credentialSource = null;

function resolveCredentialPath(candidate) {
  const trimmed = candidate.trim();
  return isAbsolute(trimmed) ? trimmed : resolve(process.cwd(), trimmed);
}

/** JSON string veya service account dosya yolu. */
function readCredentialFile(path) {
  const resolved = resolveCredentialPath(path);
  if (!existsSync(resolved)) {
    throw new Error(
      `Service account dosyası bulunamadı: ${resolved} (FIREBASE_SERVICE_ACCOUNT_JSON veya FIREBASE_SERVICE_ACCOUNT_PATH)`
    );
  }
  return readFileSync(resolved, "utf8");
}

function loadServiceAccountJson() {
  credentialSource = null;
  // PATH öncelikli — eski FIREBASE_SERVICE_ACCOUNT_JSON (deneme projesi) kalıntısını ezmesin
  const path = process.env.FIREBASE_SERVICE_ACCOUNT_PATH?.trim();
  if (path) {
    const resolved = resolveCredentialPath(path);
    credentialSource = `PATH:${resolved}`;
    return readCredentialFile(path);
  }

  const fromEnv = process.env.FIREBASE_SERVICE_ACCOUNT_JSON?.trim();
  if (fromEnv) {
    if (fromEnv.startsWith("{")) {
      credentialSource = "JSON:inline";
      return fromEnv;
    }
    const resolved = resolveCredentialPath(fromEnv);
    credentialSource = `JSON:file:${resolved}`;
    return readCredentialFile(fromEnv);
  }

  return null;
}

export function getFirebaseCredentialSource() {
  return credentialSource;
}

export function getFirebaseProjectId() {
  if (!admin.apps.length) return null;
  return admin.app().options.projectId ?? null;
}

function validateServiceAccountProject(serviceAccount) {
  const expectedProject =
    process.env.FIREBASE_PROJECT_ID?.trim() || "aidatpanel";
  const actualProject = serviceAccount.project_id ?? "";
  if (actualProject === expectedProject) return true;

  console.error(
    "[firebase] project_id uyuşmuyor — push çalışmaz (mismatched-credential).",
    "Dosyadaki:",
    actualProject || "(boş)",
    "Beklenen:",
    expectedProject,
    "→ Console'dan",
    expectedProject,
    "için YENİ service account key indirin."
  );
  return false;
}

export function isFirebaseReady() {
  return initialized;
}

/**
 * Firebase Admin SDK — production'da FIREBASE_SERVICE_ACCOUNT_JSON zorunlu.
 * @returns {boolean} push kullanılabilir mi
 */
export function initFirebase() {
  const isProduction = process.env.NODE_ENV === "production";
  const raw = loadServiceAccountJson();

  if (!raw) {
    if (isProduction) {
      console.error(
        "[firebase] FIREBASE_SERVICE_ACCOUNT_JSON production ortamında zorunludur."
      );
      process.exit(1);
    }
    console.warn(
      "[firebase] FIREBASE_SERVICE_ACCOUNT_JSON tanımlı değil — push devre dışı (development)."
    );
    return false;
  }

  try {
    const serviceAccount = JSON.parse(raw);
    if (!validateServiceAccountProject(serviceAccount)) {
      if (isProduction) {
        process.exit(1);
      }
      return false;
    }

    if (!admin.apps.length) {
      admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
        projectId: serviceAccount.project_id,
      });
    }
    initialized = true;
    console.log(
      "[firebase] Admin SDK başlatıldı. project_id=",
      serviceAccount.project_id,
      "kaynak=",
      credentialSource ?? "?"
    );
    if (
      process.env.FIREBASE_SERVICE_ACCOUNT_JSON?.trim() &&
      process.env.FIREBASE_SERVICE_ACCOUNT_PATH?.trim()
    ) {
      console.warn(
        "[firebase] Hem PATH hem JSON env tanımlı — PATH kullanıldı. "
          + "PM2/ecosystem içindeki eski FIREBASE_SERVICE_ACCOUNT_JSON satırını silin."
      );
    }
    return true;
  } catch (err) {
    console.error("[firebase] Başlatma hatası:", err.message);
    if (isProduction) {
      process.exit(1);
    }
    return false;
  }
}

/** @returns {import("firebase-admin/messaging").Messaging | null} */
export function getMessaging() {
  if (!initialized) {
    return null;
  }
  return admin.messaging();
}
