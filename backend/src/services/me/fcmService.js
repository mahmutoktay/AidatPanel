import { saveFcmToken } from "../fcmTokenService.js";

export async function updateFcmTokenService(userId, fcmToken) {
  await saveFcmToken(userId, fcmToken);
}
