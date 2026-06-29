/**
 * Admin JWT — mobil JWT ile paylaşılmaz.
 */
import jwt from "jsonwebtoken";

const ADMIN_ACCESS_EXPIRES = process.env.ADMIN_JWT_EXPIRES_IN || "15m";
const ADMIN_REFRESH_EXPIRES = process.env.ADMIN_REFRESH_EXPIRES_IN || "8h";

function getAdminSecret() {
  const secret = process.env.ADMIN_JWT_SECRET || process.env.JWT_SECRET;
  if (!secret || secret.length < 32) {
    throw new Error("ADMIN_JWT_SECRET en az 32 karakter olmalıdır.");
  }
  return secret;
}

export function generateAdminAccessToken(admin) {
  return jwt.sign(
    { id: admin.id, role: admin.role, type: "admin" },
    getAdminSecret(),
    { expiresIn: ADMIN_ACCESS_EXPIRES }
  );
}

export function generateAdminRefreshToken(admin) {
  return jwt.sign(
    { id: admin.id, type: "admin_refresh" },
    getAdminSecret(),
    { expiresIn: ADMIN_REFRESH_EXPIRES }
  );
}

export function verifyAdminToken(token) {
  const decoded = jwt.verify(token, getAdminSecret());
  if (decoded.type !== "admin" && decoded.type !== "admin_refresh") {
    throw new Error("Geçersiz admin token.");
  }
  return decoded;
}
