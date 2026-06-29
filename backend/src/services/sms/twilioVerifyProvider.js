import { logger } from "../../config/logger.js";

function twilioAuth() {
  const accountSid = process.env.TWILIO_ACCOUNT_SID?.trim();
  const authToken = process.env.TWILIO_AUTH_TOKEN?.trim();
  const serviceSid = process.env.TWILIO_VERIFY_SERVICE_SID?.trim();
  if (!accountSid || !authToken || !serviceSid) {
    return null;
  }
  return {
    accountSid,
    authToken,
    serviceSid,
    authHeader: `Basic ${Buffer.from(`${accountSid}:${authToken}`).toString("base64")}`,
  };
}

async function parseTwilioJson(res) {
  let data;
  try {
    data = await res.json();
  } catch {
    data = { message: await res.text() };
  }
  return data;
}

/**
 * Twilio Verify — Benjamin Helper ile aynı kanal (Türkiye teslimatı daha güvenilir).
 * @param {string} phone10
 */
export async function startTwilioVerification(phone10) {
  const cfg = twilioAuth();
  if (!cfg) {
    return { ok: false, skipped: true, reason: "twilio_verify_env_missing" };
  }

  const to = `+90${phone10}`;
  const url = `https://verify.twilio.com/v2/Services/${cfg.serviceSid}/Verifications`;
  const body = new URLSearchParams({
    To: to,
    Channel: "sms",
  });

  const res = await fetch(url, {
    method: "POST",
    headers: {
      Authorization: cfg.authHeader,
      "Content-Type": "application/x-www-form-urlencoded",
    },
    body: body.toString(),
  });

  const data = await parseTwilioJson(res);
  if (!res.ok) {
    logger.error({
      type: "twilio_verify_error",
      action: "start",
      status: res.status,
      code: data.code,
      message: data.message,
      to,
    });
    return { ok: false, error: data.message, code: data.code };
  }

  logger.info({
    type: "twilio_verify_started",
    sid: data.sid,
    status: data.status,
    to,
  });
  return { ok: true, sid: data.sid, status: data.status };
}

/**
 * @param {string} phone10
 * @param {string} code
 */
export async function checkTwilioVerification(phone10, code) {
  const cfg = twilioAuth();
  if (!cfg) {
    return { ok: false, skipped: true, reason: "twilio_verify_env_missing" };
  }

  const to = `+90${phone10}`;
  const url = `https://verify.twilio.com/v2/Services/${cfg.serviceSid}/VerificationCheck`;
  const body = new URLSearchParams({
    To: to,
    Code: String(code).trim(),
  });

  const res = await fetch(url, {
    method: "POST",
    headers: {
      Authorization: cfg.authHeader,
      "Content-Type": "application/x-www-form-urlencoded",
    },
    body: body.toString(),
  });

  const data = await parseTwilioJson(res);
  if (!res.ok) {
    logger.warn({
      type: "twilio_verify_check_failed",
      status: res.status,
      code: data.code,
      message: data.message,
      to,
    });
    return { ok: false, error: data.message, code: data.code, status: data.status };
  }

  const approved = data.status === "approved";
  logger.info({
    type: "twilio_verify_checked",
    status: data.status,
    approved,
    to,
  });
  return { ok: approved, status: data.status, sid: data.sid };
}

export function isTwilioVerifyConfigured() {
  return Boolean(twilioAuth());
}
