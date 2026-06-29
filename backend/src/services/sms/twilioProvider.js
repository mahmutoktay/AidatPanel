import { logger } from "../../config/logger.js";

/**
 * Twilio REST SMS — ek paket gerekmez.
 * @param {string} phone10 — kanonik TR 10 hane (5xxxxxxxxx)
 * @param {string} message
 */
export async function sendTwilioSms(phone10, message) {
  const accountSid = process.env.TWILIO_ACCOUNT_SID?.trim();
  const authToken = process.env.TWILIO_AUTH_TOKEN?.trim();
  const from = process.env.TWILIO_PHONE_FROM?.trim();

  if (!accountSid || !authToken || !from) {
    return { ok: false, skipped: true, reason: "twilio_env_missing" };
  }

  const to = `+90${phone10}`;
  const url = `https://api.twilio.com/2010-04-01/Accounts/${accountSid}/Messages.json`;
  const body = new URLSearchParams({
    To: to,
    From: from,
    Body: message,
  });

  const auth = Buffer.from(`${accountSid}:${authToken}`).toString("base64");

  const res = await fetch(url, {
    method: "POST",
    headers: {
      Authorization: `Basic ${auth}`,
      "Content-Type": "application/x-www-form-urlencoded",
    },
    body: body.toString(),
  });

  let data;
  try {
    data = await res.json();
  } catch {
    data = { message: await res.text() };
  }

  if (!res.ok) {
    logger.error({
      type: "twilio_error",
      status: res.status,
      code: data.code,
      message: data.message,
      to,
    });
    return { ok: false, error: data.message, code: data.code };
  }

  logger.info({ type: "twilio_sent", sid: data.sid, to });
  return { ok: true, sid: data.sid };
}
