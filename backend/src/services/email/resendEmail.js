import { logger } from "../../config/logger.js";

/**
 * Resend ile işlem e-postası gönderir.
 * @returns {Promise<{ ok: boolean, skipped?: boolean, error?: string }>}
 */
export async function sendResendEmail({ to, subject, html }) {
  const key = process.env.RESEND_API_KEY?.trim();
  if (!key) {
    return { ok: false, skipped: true, reason: "resend_env_missing" };
  }

  const from =
    process.env.RESEND_FROM_EMAIL?.trim() ||
    "AidatPanel <onboarding@resend.dev>";

  const res = await fetch("https://api.resend.com/emails", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${key}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({ from, to: [to], subject, html }),
  });

  if (!res.ok) {
    const text = await res.text();
    logger.error({
      type: "resend_email_error",
      status: res.status,
      body: text,
      to,
    });
    return { ok: false, error: text };
  }

  logger.info({ type: "resend_email_sent", to, subject });
  return { ok: true };
}

export async function sendOtpEmail(toEmail, code) {
  const mins = 5;
  const html = `
    <p>AidatPanel doğrulama kodunuz:</p>
    <p style="font-size:28px;font-weight:700;letter-spacing:6px;font-family:monospace;">${code}</p>
    <p>Bu kod ${mins} dakika geçerlidir. Kimseyle paylaşmayın.</p>
  `;
  return sendResendEmail({
    to: toEmail,
    subject: "AidatPanel — doğrulama kodu",
    html,
  });
}
