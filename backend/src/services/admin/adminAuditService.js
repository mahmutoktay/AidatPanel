import { prisma } from "../../config/db.js";

/**
 * @param {object} params
 * @param {string} params.adminId
 * @param {string} params.action
 * @param {string} [params.targetType]
 * @param {string} [params.targetId]
 * @param {object} [params.metadata] — PII içermemeli
 * @param {string} [params.ipAddress]
 */
export async function writeAdminAuditLog({
  adminId,
  action,
  targetType,
  targetId,
  metadata,
  ipAddress,
}) {
  return prisma.adminAuditLog.create({
    data: {
      adminId,
      action,
      targetType: targetType ?? null,
      targetId: targetId ?? null,
      metadata: metadata ?? undefined,
      ipAddress: ipAddress ?? null,
    },
  });
}

export async function listAdminAuditLogs({ adminId, action, page = 1, limit = 25 }) {
  const where = {};
  if (adminId) where.adminId = adminId;
  if (action) where.action = action;

  const skip = (page - 1) * limit;
  const [items, total] = await Promise.all([
    prisma.adminAuditLog.findMany({
      where,
      orderBy: { createdAt: "desc" },
      skip,
      take: limit,
      include: {
        admin: { select: { id: true, name: true, email: true } },
      },
    }),
    prisma.adminAuditLog.count({ where }),
  ]);

  return { items, total, page, limit, totalPages: Math.ceil(total / limit) };
}
