import { logger } from "../../config/logger.js";

/**
 * NetGsm SMS gönderimi.
 * @param {string} phone10 — kanonik 10 hane
 * @param {string} message
 */
export async function sendNetgsmSms(phone10, message) {
  const user = process.env.NETGSM_USER;
  const pass = process.env.NETGSM_PASS;
  const header = process.env.NETGSM_HEADER || "AIDATPANEL";

  if (!user || !pass) {
    return { ok: false, skipped: true, reason: "netgsm_env_missing" };
  }

  const gsm = `90${phone10}`;
  const params = new URLSearchParams({
    usercode: user,
    password: pass,
    gsmno: gsm,
    message,
    msgheader: header,
    dil: "TR",
  });

  const res = await fetch(`https://api.netgsm.com.tr/sms/send/get?${params}`);
  const text = await res.text();
  if (!res.ok || text.startsWith("00") === false) {
    logger.error({ type: "netgsm_error", status: res.status, body: text });
    return { ok: false };
  }
  return { ok: true };
}