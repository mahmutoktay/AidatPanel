import bcrypt from "bcryptjs";
import { prisma } from "../../config/db.js";
import { HttpError } from "../../utils/httpError.js";
import {
  generateAdminAccessToken,
  generateAdminRefreshToken,
  verifyAdminToken,
} from "../../utils/adminTokens.js";
import { writeAdminAuditLog } from "./adminAuditService.js";

function assertIpAllowed(ip) {
  const allowlist = process.env.ADMIN_ALLOWED_IPS;
  if (!allowlist || process.env.NODE_ENV !== "production") return;
  const allowed = allowlist.split(",").map((s) => s.trim()).filter(Boolean);
  if (allowed.length === 0) return;
  const normalized = (ip || "").replace("::ffff:", "");
  if (!allowed.includes(normalized)) {
    throw new HttpError(403, "Bu IP adresinden admin erişimine izin verilmiyor.");
  }
}

export async function adminLoginService({ email, password, ipAddress }) {
  assertIpAllowed(ipAddress);

  const admin = await prisma.adminUser.findUnique({ where: { email } });
  if (!admin || !admin.isActive) {
    throw new HttpError(401, "E-posta veya şifre hatalı.");
  }

  const valid = await bcrypt.compare(password, admin.passwordHash);
  if (!valid) {
    throw new HttpError(401, "E-posta veya şifre hatalı.");
  }

  await prisma.adminUser.update({
    where: { id: admin.id },
    data: { lastLoginAt: new Date() },
  });

  await writeAdminAuditLog({
    adminId: admin.id,
    action: "ADMIN_LOGIN",
    ipAddress,
  });

  const accessToken = generateAdminAccessToken(admin);
  const refreshToken = generateAdminRefreshToken(admin);

  return {
    admin: {
      id: admin.id,
      email: admin.email,
      name: admin.name,
      role: admin.role,
    },
    accessToken,
    refreshToken,
  };
}

export async function adminRefreshService(refreshToken) {
  let decoded;
  try {
    decoded = verifyAdminToken(refreshToken);
  } catch {
    throw new HttpError(401, "Oturum süresi doldu. Lütfen tekrar giriş yapın.");
  }
  if (decoded.type !== "admin_refresh") {
    throw new HttpError(401, "Geçersiz oturum.");
  }

  const admin = await prisma.adminUser.findFirst({
    where: { id: decoded.id, isActive: true },
  });
  if (!admin) {
    throw new HttpError(401, "Hesap bulunamadı veya devre dışı.");
  }

  return {
    accessToken: generateAdminAccessToken(admin),
    refreshToken: generateAdminRefreshToken(admin),
    admin: {
      id: admin.id,
      email: admin.email,
      name: admin.name,
      role: admin.role,
    },
  };
}

export async function getAdminProfileService(adminId) {
  const admin = await prisma.adminUser.findFirst({
    where: { id: adminId, isActive: true },
    select: { id: true, email: true, name: true, role: true, lastLoginAt: true },
  });
  if (!admin) {
    throw new HttpError(401, "Admin bulunamadı.");
  }
  return admin;
}

export async function adminLogoutService(adminId, ipAddress) {
  await writeAdminAuditLog({
    adminId,
    action: "ADMIN_LOGOUT",
    ipAddress,
  });
}
