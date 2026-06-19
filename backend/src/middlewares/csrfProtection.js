/**
 * CSRF Protection Middleware
 * 
 * Stateful CSRF token validation — web UI (future) için gerekli.
 * Flutter mobile: JWT-only (CSRF token yok), bu middleware bypass edilir.
 * 
 * Usage:
 *   app.use('/api/v1/web', csrfProtection, ...routes)
 *   app.use('/api/v1/mobile', ...routes)  // CSRF bypass
 */

import crypto from 'crypto';

const CSRF_HEADER = 'x-csrf-token';
const CSRF_COOKIE = '__csrf_token';
const SESSION_KEY = '__csrf_session';

/**
 * CSRF token oluştur (stateful)
 */
export function generateCsrfToken() {
  return crypto.randomBytes(32).toString('hex');
}

/**
 * Session'a CSRF token kaydı yapan middleware
 * Express-session sonrası mount edilmeli
 */
export const csrfSessionMiddleware = (req, res, next) => {
  if (!req.session) {
    return next(new Error('express-session required for CSRF'));
  }

  if (!req.session[SESSION_KEY]) {
    req.session[SESSION_KEY] = generateCsrfToken();
  }

  // CSRF token'ı response'a set et (frontend → header gönderecek)
  res.set(CSRF_HEADER, req.session[SESSION_KEY]);

  next();
};

/**
 * CSRF token doğrulama middleware
 * Sadece state-changing methods için (POST, PUT, DELETE, PATCH)
 */
export const csrfProtection = (req, res, next) => {
  // GET, HEAD, OPTIONS → no CSRF needed
  if (['GET', 'HEAD', 'OPTIONS'].includes(req.method)) {
    return next();
  }

  if (!req.session || !req.session[SESSION_KEY]) {
    return res.status(403).json({
      success: false,
      message: 'CSRF token invalid: session expired',
    });
  }

  // Request'ten token al (header veya body)
  const token =
    req.get(CSRF_HEADER) ||
    req.get('x-csrf-token') ||
    req.body?._csrf ||
    req.body?.csrfToken;

  if (!token) {
    return res.status(403).json({
      success: false,
      message: 'CSRF token missing',
    });
  }

  // Constant-time comparison
  const sessionToken = req.session[SESSION_KEY];
  const isValid =
    crypto.timingSafeEqual(
      Buffer.from(token),
      Buffer.from(sessionToken)
    ) === true;

  if (!isValid) {
    return res.status(403).json({
      success: false,
      message: 'CSRF token invalid',
    });
  }

  next();
};

/**
 * CSRF token refresh (Form submit sonrası)
 */
export const refreshCsrfToken = (req, res) => {
  if (!req.session) {
    return res.status(500).json({
      success: false,
      message: 'Session error',
    });
  }

  req.session[SESSION_KEY] = generateCsrfToken();
  res.json({
    success: true,
    token: req.session[SESSION_KEY],
  });
};
