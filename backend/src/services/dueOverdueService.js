import { prisma } from "../config/db.js";

/**
 * Vadesi geçmiş PENDING aidatları OVERDUE yapar; mevcut OVERDUE kayıtların
 * `overdueDays` alanını günceller.
 */
export async function markOverdueDuesService() {
  const transitioned = await prisma.$executeRaw`
    UPDATE "Due"
    SET
      status = 'OVERDUE'::"DueStatus",
      "overdueDays" = GREATEST(
        0,
        CEIL(EXTRACT(EPOCH FROM (NOW() - "dueDate")) / 86400)::integer
      )
    WHERE status = 'PENDING'::"DueStatus"
      AND "dueDate" < NOW()
  `;

  const refreshed = await prisma.$executeRaw`
    UPDATE "Due"
    SET "overdueDays" = GREATEST(
      0,
      CEIL(EXTRACT(EPOCH FROM (NOW() - "dueDate")) / 86400)::integer
    )
    WHERE status = 'OVERDUE'::"DueStatus"
  `;

  return {
    transitioned: Number(transitioned) || 0,
    refreshed: Number(refreshed) || 0,
  };
}
