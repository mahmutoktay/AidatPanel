import { prisma } from "../../config/db.js";
import { HttpError } from "../../utils/httpError.js";
import { maskEmail, maskPhone, adminDisplayEmail, adminDisplayPhone, adminDisplayName } from "../../utils/piiMasking.js";
import { writeAdminAuditLog } from "./adminAuditService.js";
import { requestPasswordResetService } from "../passwordResetService.js";
import { revokeAllUserSessions } from "../sessionService.js";
import bcrypt from "bcryptjs";

function buildUserSearchWhere({ q, role, deleted, hasSubscription }) {
  const where = {};
  if (role) where.role = role;
  if (deleted === "true") where.deletedAt = { not: null };
  else if (deleted === "false") where.deletedAt = null;

  if (hasSubscription === "true") {
    where.subscription = { isNot: null };
  } else if (hasSubscription === "false") {
    where.subscription = null;
  }

  if (q) {
    where.OR = [
      { email: { contains: q, mode: "insensitive" } },
      { phone: { contains: q } },
      { name: { contains: q, mode: "insensitive" } },
    ];
  }

  return where;
}

export async function listAdminUsersService({ q, role, deleted, hasSubscription, page = 1, limit = 25 }) {
  const where = buildUserSearchWhere({ q, role, deleted, hasSubscription });
  const skip = (page - 1) * limit;

  const [users, total] = await Promise.all([
    prisma.user.findMany({
      where,
      orderBy: { createdAt: "desc" },
      skip,
      take: limit,
      select: {
        id: true,
        name: true,
        email: true,
        phone: true,
        role: true,
        deletedAt: true,
        createdAt: true,
        subscription: { select: { status: true, plan: true, currentPeriodEnd: true } },
        _count: { select: { managedBuildings: true } },
      },
    }),
    prisma.user.count({ where }),
  ]);

  return {
    items: users.map((u) => ({
      id: u.id,
      name: adminDisplayName(u.name),
      email: adminDisplayEmail(u.email),
      phone: adminDisplayPhone(u.phone),
      role: u.role,
      isDeleted: !!u.deletedAt,
      createdAt: u.createdAt,
      subscription: u.subscription,
      buildingCount: u._count.managedBuildings,
    })),
    total,
    page,
    limit,
    totalPages: Math.ceil(total / limit),
  };
}

export async function getAdminUserDetailService(adminId, userId, ipAddress) {
  const user = await prisma.user.findUnique({
    where: { id: userId },
    include: {
      subscription: true,
      managedBuildings: { select: { id: true, name: true, city: true, district: true } },
      managedSites: { select: { id: true, name: true, city: true, district: true } },
      apartment: {
        select: {
          id: true,
          number: true,
          building: { select: { id: true, name: true, city: true } },
        },
      },
      sessions: {
        where: { revokedAt: null },
        orderBy: { lastSeenAt: "desc" },
        take: 5,
        select: { id: true, deviceLabel: true, platform: true, lastSeenAt: true, createdAt: true },
      },
    },
  });

  if (!user) {
    throw new HttpError(404, "Kullanıcı bulunamadı.");
  }

  await writeAdminAuditLog({
    adminId,
    action: "USER_VIEW",
    targetType: "User",
    targetId: userId,
    ipAddress,
  });

  return user;
}

export async function adminResetPasswordService(adminId, userId, ipAddress) {
  const user = await prisma.user.findFirst({
    where: { id: userId, deletedAt: null },
    select: { id: true, email: true },
  });
  if (!user?.email) {
    throw new HttpError(404, "Aktif e-posta adresi olan kullanıcı bulunamadı.");
  }

  await requestPasswordResetService(user.email);

  await writeAdminAuditLog({
    adminId,
    action: "PASSWORD_RESET",
    targetType: "User",
    targetId: userId,
    ipAddress,
  });

  return { sent: true };
}

export async function adminCloseAccountService(adminId, userId, { reason, forceManager = false }, adminRole, ipAddress) {
  if (adminRole !== "SUPER_ADMIN") {
    throw new HttpError(403, "Hesap kapatma yalnızca SUPER_ADMIN tarafından yapılabilir.");
  }
  if (!reason || reason.trim().length < 5) {
    throw new HttpError(400, "Kapatma gerekçesi en az 5 karakter olmalıdır.");
  }

  const user = await prisma.user.findFirst({
    where: { id: userId, deletedAt: null },
    include: { _count: { select: { managedBuildings: true, managedSites: true } } },
  });
  if (!user) {
    throw new HttpError(404, "Kullanıcı bulunamadı veya zaten kapatılmış.");
  }

  if (!forceManager && (user._count.managedBuildings > 0 || user._count.managedSites > 0)) {
    throw new HttpError(
      409,
      "Yönettiği bina/site varken hesap kapatılamaz. forceManager=true ile SUPER_ADMIN override gerekir."
    );
  }

  const ghostEmail = `deleted.${user.id}@closed.aidatpanel.invalid`;
  const random = await bcrypt.hash(`${user.id}:${Date.now()}`, 4);

  await prisma.$transaction(async (tx) => {
    await tx.passwordResetToken.deleteMany({ where: { userId } });
    await tx.user.update({
      where: { id: userId },
      data: {
        deletedAt: new Date(),
        email: ghostEmail,
        phone: null,
        name: "Silinmiş kullanıcı",
        passwordHash: random,
        apartmentId: null,
        fcmToken: null,
        profilePicture: null,
        refreshTokenVersion: { increment: 1 },
      },
    });
    await tx.subscription.updateMany({
      where: { userId },
      data: { status: "CANCELLED" },
    });
  });

  await revokeAllUserSessions(userId);

  await writeAdminAuditLog({
    adminId,
    action: "ACCOUNT_DELETE",
    targetType: "User",
    targetId: userId,
    metadata: { forceManager, reasonLength: reason.trim().length },
    ipAddress,
  });
}
