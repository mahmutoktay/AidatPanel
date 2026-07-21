import { getAuth, isFirebaseReady } from "../config/firebase.js";
import { HttpError } from "../utils/httpError.js";
import { normalizeTrPhone } from "../utils/normalizeTrPhone.js";
import { logger } from "../config/logger.js";

/**
 * Firebase Phone Auth ID token doğrular.
 * @param {string} idToken
 * @returns {Promise<{ firebaseUid: string, phoneE164: string, phone10: string }>}
 */
export async function verifyFirebasePhoneIdToken(idToken) {
  if (!idToken || typeof idToken !== "string" || !idToken.trim()) {
    throw new HttpError(400, "Firebase doğrulama jetonu gereklidir.");
  }

  if (!isFirebaseReady()) {
    logger.error({ type: "firebase_phone_auth_not_ready" });
    throw new HttpError(
      503,
      "Telefon doğrulama şu an kullanılamıyor. Lütfen biraz sonra tekrar deneyin."
    );
  }

  const auth = getAuth();
  if (!auth) {
    throw new HttpError(
      503,
      "Telefon doğrulama şu an kullanılamıyor. Lütfen biraz sonra tekrar deneyin."
    );
  }

  let decoded;
  try {
    decoded = await auth.verifyIdToken(idToken.trim(), true);
  } catch (err) {
    logger.warn({
      type: "firebase_id_token_invalid",
      error: err?.message,
      code: err?.code,
    });
    throw new HttpError(401, "Telefon doğrulaması geçersiz veya süresi dolmuş.");
  }

  const phoneE164 =
    typeof decoded.phone_number === "string" ? decoded.phone_number.trim() : "";
  if (!phoneE164) {
    throw new HttpError(401, "Bu jeton telefon doğrulaması içermiyor.");
  }

  const phone10 = normalizeTrPhone(phoneE164);
  if (!phone10) {
    throw new HttpError(400, "Geçerli bir Türkiye cep telefonu numarası gereklidir.");
  }

  const firebaseUid = decoded.uid;
  if (!firebaseUid) {
    throw new HttpError(401, "Telefon doğrulaması geçersiz veya süresi dolmuş.");
  }

  return { firebaseUid, phoneE164, phone10 };
}
