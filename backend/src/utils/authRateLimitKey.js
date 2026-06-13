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

  if (path === "/login") {
    const id = normalizeAuthKeyPart(body.identifier);
    if (id) return `login:${id}`;
  }

  if (path === "/forgot-password") {
    const email = normalizeAuthKeyPart(body.email);
    if (email) return `fp:${email}`;
  }

  if (path === "/register" || path === "/join") {
    const email = normalizeAuthKeyPart(body.email);
    if (email) return `${path.slice(1)}:${email}`;
  }

  if (path === "/reset-password" && body.token) {
    return `reset:${String(body.token).trim().toUpperCase()}`;
  }

  if (path === "/refresh" && body.refreshToken) {
    return `refresh:${String(body.refreshToken).slice(0, 32)}`;
  }

  return req.ip;
}
