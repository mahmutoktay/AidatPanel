import { NOTIFICATION_CATALOG } from "../constants/notificationCatalog.js";
import { HttpError } from "../utils/httpError.js";

const SUPPORTED_LANGUAGES = new Set(["tr", "en"]);

export function normalizeNotificationLanguage(language) {
  const normalized = String(language ?? "tr").trim().toLowerCase();
  return SUPPORTED_LANGUAGES.has(normalized) ? normalized : "tr";
}

export function assertNotificationCode(code) {
  if (!code || !NOTIFICATION_CATALOG[code]) {
    throw new HttpError(500, `Bilinmeyen bildirim kodu: ${code ?? "<empty>"}`);
  }
}

export function renderNotification(code, params = {}, language = "tr") {
  assertNotificationCode(code);
  const locale = normalizeNotificationLanguage(language);
  const template = NOTIFICATION_CATALOG[code][locale] ?? NOTIFICATION_CATALOG[code].tr;
  return {
    title: template.title(params),
    body: template.body(params),
  };
}
