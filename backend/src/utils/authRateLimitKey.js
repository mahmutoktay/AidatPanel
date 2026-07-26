import { normalizeTrPhone } from "./normalizeTrPhone.js";

function normalizeAuthKeyPart(value) {
  if (typeof value !== "string") return null;
  const trimmed = value.trim().toLowerCase();
  return trimmed || null;
}

/**
 * Auth brute-force limiti: mümkünse hesap tanımlayıcısına göre (IP değil).
 */
export function authRouteKey(req) {
  if (req.user?.id) {
    return `user:${req.user.id}`;
  }

  const path = req.path || "";
  const body = req.body ?? {};

  if (path === "/check-identifier") {
    const raw = body.identifier;
    if (typeof raw === "string" && raw.includes("@")) {
      const email = normalizeAuthKeyPart(raw);
      if (email) return `check-id:email:${email}`;
    }
    const phone = normalizeTrPhone(raw);
    if (phone) return `check-id:phone:${phone}`;
    const id = normalizeAuthKeyPart(raw);
    if (id) return `check-id:${id}`;
  }

  if (path === "/login") {
    const raw = body.identifier;
    const id = raw?.includes("@")
      ? normalizeAuthKeyPart(raw)
      : normalizeTrPhone(raw) ?? normalizeAuthKeyPart(raw);
    if (id) return `login:${id}`;
  }

  if (path === "/otp/send" && body.phone) {
    const p = normalizeTrPhone(body.phone);
    if (p) return `otp-send:${p}`;
  }
  if (path === "/otp/send" && body.email) {
    const email = normalizeAuthKeyPart(body.email);
    if (email) return `otp-send:email:${email}`;
  }

  if (path === "/otp/verify" && body.phone) {
    const p = normalizeTrPhone(body.phone);
    if (p) return `otp-verify:${p}`;
  }
  if (path === "/otp/verify" && body.email) {
    const email = normalizeAuthKeyPart(body.email);
    if (email) return `otp-verify:email:${email}`;
  }

  if (path === "/invite/validate" && body.inviteCode) {
    return `invite:${String(body.inviteCode).trim().toUpperCase()}`;
  }

  if (path === "/forgot-password") {
    const email = normalizeAuthKeyPart(body.email);
    if (email) return `fp:${email}`;
  }

  if (path === "/register" || path === "/join") {
    const email = normalizeAuthKeyPart(body.email);
    if (email) return `${path.slice(1)}:${email}`;
    const phone = normalizeTrPhone(body.phone);
    if (phone) return `${path.slice(1)}:${phone}`;
  }

  if (path === "/reset-password" && body.token) {
    return `reset:${String(body.token).trim().toUpperCase()}`;
  }

  if (path === "/refresh" && body.refreshToken) {
    return `refresh:${String(body.refreshToken).slice(0, 32)}`;
  }

  return req.ip;
}
