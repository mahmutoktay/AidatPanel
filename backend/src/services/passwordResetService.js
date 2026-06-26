import crypto from "node:crypto";
import bcrypt from "bcryptjs";
import { appendFile, mkdir } from "node:fs/promises";
import { dirname } from "node:path";
import { prisma } from "../config/db.js";
import { logger } from "../config/logger.js";
import { HttpError } from "../utils/httpError.js";
import { revokeAllUserSessions } from "./sessionService.js";

const DEFAULT_EXPIRES_MIN = 60;

/** 32 karakter: rakam (2–9) + büyük harf; 0/O/1/I/L yok (okunabilirlik). */
const RESET_CODE_CHARSET = "23456789ABCDEFGHJKLMNPQRSTUVWXYZ";

function generateResetCode() {
  for (let attempt = 0; attempt < 64; attempt++) {
    let s = "";
    for (let i = 0; i < 6; i++) {
      s += RESET_CODE_CHARSET[crypto.randomInt(0, RESET_CODE_CHARSET.length)];
    }
    if (/[2-9]/.test(s) && /[A-Z]/.test(s)) {
      return s;
    }
  }
  let s = "";
  for (let i = 0; i < 6; i++) {
    s += RESET_CODE_CHARSET[crypto.randomInt(0, RESET_CODE_CHARSET.length)];
  }
  return s;
}

function hashToken(plain) {
  return crypto.createHash("sha256").update(plain, "utf8").digest("hex");
}

function expiresAt() {
  const min =
    Number(process.env.PASSWORD_RESET_EXPIRES_MINUTES) || DEFAULT_EXPIRES_MIN;
  return new Date(Date.now() + min * 60 * 1000);
}

async function sendResendEmail({ to, subject, html }) {
  const key = process.env.RESEND_API_KEY;
  if (!key) {
    return false;
  }
  const from =
    process.env.RESEND_FROM_EMAIL || "AidatPanel <onboarding@resend.dev>";
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
    logger.error({ type: "resend_email_error", status: res.status, body: text });
    return false;
  }
  return true;
}

/**
 * Her zaman aynı mesajı döndürür (email varlığı sızdırmaz).
 * E-posta yalnızca RESEND_API_KEY tanımlıysa gider.
 */
export async function requestPasswordResetService(email) {
  const user = await prisma.user.findFirst({
    where: { email, deletedAt: null },
    select: { id: true, email: true },
  });

  if (!user) {
    return;
  }

  await prisma.passwordResetToken.deleteMany({
    where: { userId: user.id, usedAt: null },
  });

  let plain = generateResetCode();
  let tokenHash = hashToken(plain);
  let created = false;
  for (let attempt = 0; attempt < 8; attempt++) {
    try {
      await prisma.passwordResetToken.create({
        data: {
          userId: user.id,
          tokenHash,
          expiresAt: expiresAt(),
        },
      });
      created = true;
      break;
    } catch (e) {
      if (e?.code === "P2002") {
        plain = generateResetCode();
        tokenHash = hashToken(plain);
        continue;
      }
      throw e;
    }
  }
  if (!created) {
    throw new Error("Şifre sıfırlama kodu üretilemedi; lütfen tekrar deneyin.");
  }

  /** E2E: düz kod yalnızca e2e testte loglanır (üretimde env tanımlı olmamalı).
   *  KVKK: email ve kod içeriği dosyaya yazılmaz — yalnızca test assertion helper'ı
   *  kullanıcıya ait hash ile doğrulama yapar. */
  const e2ePath = process.env.AIDATPANEL_E2E_RESET_LOG;
  const isE2E = process.env.AIDATPANEL_E2E === "1";
  if (e2ePath && isE2E) {
    try {
      const dir = dirname(e2ePath);
      if (dir && dir !== ".") {
        await mkdir(dir, { recursive: true });
      }
      await appendFile(
        e2ePath,
        `${JSON.stringify({
          userId: user.id,
          tokenHash,
          createdAt: new Date().toISOString(),
        })}\n`,
        "utf8",
      );
    } catch (e) {
      logger.error({ type: "e2e_reset_log_write_failed", err: e?.message });
    }
  }

  const key = process.env.RESEND_API_KEY;
  if (!key) {
    if (process.env.NODE_ENV === "development") {
      logger.warn({ type: "password_reset_no_resend_key" });
    }
    return;
  }

  const appHint =
    process.env.PASSWORD_RESET_APP_HINT ||
    "Uygulamada «Şifre sıfırla» ekranına bu kodu yapıştırın.";

  const mins =
    Number(process.env.PASSWORD_RESET_EXPIRES_MINUTES) || DEFAULT_EXPIRES_MIN;
  const html = `
    <p>AidatPanel şifre sıfırlama talebi alındı.</p>
    <p><strong>6 haneli kod (${mins} dk geçerli):</strong></p>
    <p style="font-size:22px;font-weight:700;letter-spacing:4px;font-family:monospace;">${plain}</p>
    <p>${appHint}</p>
  `;

  await sendResendEmail({
    to: user.email,
    subject: "AidatPanel — şifre sıfırlama",
    html,
  });
}

/** Kullanıcı küçük harf veya boşluk girerse normalize et (e-postadaki kod büyük harf). */
function normalizeResetCode(raw) {
  if (typeof raw !== "string") {
    return "";
  }
  return raw.trim().toUpperCase().replace(/\s+/g, "");
}

export async function resetPasswordWithTokenService(plainToken, newPassword) {
  const normalized = normalizeResetCode(plainToken);
  const tokenHash = hashToken(normalized);
  const row = await prisma.passwordResetToken.findUnique({
    where: { tokenHash },
    include: { user: true },
  });

  if (!row || row.usedAt || row.user.deletedAt) {
    throw new HttpError(400, "Geçersiz veya süresi dolmuş sıfırlama kodu.");
  }
  if (row.expiresAt < new Date()) {
    throw new HttpError(400, "Geçersiz veya süresi dolmuş sıfırlama kodu.");
  }

  const passwordHash = await bcrypt.hash(newPassword, 10);

  await prisma.$transaction([
    prisma.user.update({
      where: { id: row.userId },
      data: {
        passwordHash,
        refreshTokenVersion: { increment: 1 },
      },
    }),
    prisma.passwordResetToken.update({
      where: { id: row.id },
      data: { usedAt: new Date() },
    }),
  ]);
  await revokeAllUserSessions(row.userId);
}
