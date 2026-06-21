/**
 * Dashboard Aggregation Controller
 *
 * Tek endpoint'te dashboard için gerekli tüm özet verileri döner.
 * N+1 API çağrısı problemini çözer — 6 paralel istek yerine 1 istek.
 *
 * GET /api/v1/buildings/:id/dashboard-summary
 */

import { prisma } from "../config/db.js";
import { asyncHandler } from "../utils/asyncHandler.js";
import { assertManagerOwnsBuilding } from "../utils/access.js";

/**
 * Bina dashboard özeti — aidat, gider, bildirim, ticket, dekont sayıları.
 * Yalnızca yönetici (bina sahibi) erişebilir.
 */
export const getDashboardSummary = asyncHandler(async (req, res) => {
  const buildingId = req.params.id;
  const managerId = req.user.id;

  // Yönetici bina sahipliği doğrulaması
  await assertManagerOwnsBuilding(buildingId, managerId);

  const now = new Date();
  const currentMonth = now.getMonth() + 1;
  const currentYear = now.getFullYear();

  // Tüm sorgular paralel çalışır (Promise.all)
  const [
    totalApartments,
    occupiedApartments,
    duesByStatus,
    expensesThisMonth,
    unreadNotifications,
    openTickets,
    pendingDekonts,
  ] = await Promise.all([
    // 1. Toplam daire
    prisma.apartment.count({ where: { buildingId } }),

    // 2. Dolu daire (sakini olan)
    prisma.apartment.count({
      where: { buildingId, resident: { isNot: null } },
    }),

    // 3. Bu ayki aidatlar (durum bazlı gruplu)
    prisma.due.groupBy({
      by: ["status"],
      where: {
        apartment: { buildingId },
        month: currentMonth,
        year: currentYear,
      },
      _count: true,
      _sum: { amount: true },
    }),

    // 4. Bu ayki giderler (toplam + sayı)
    prisma.expense.aggregate({
      where: {
        buildingId,
        targetMonth: currentMonth,
        targetYear: currentYear,
      },
      _sum: { amount: true },
      _count: true,
    }),

    // 5. Okunmamış bildirim sayısı
    prisma.notification.count({
      where: { userId: managerId, isRead: false },
    }),

    // 6. Açık/Devam eden ticket'lar
    prisma.ticket.count({
      where: {
        apartment: { buildingId },
        status: { in: ["OPEN", "IN_PROGRESS"] },
      },
    }),

    // 7. İnceleme bekleyen dekontlar
    prisma.dekont.count({
      where: {
        buildingId,
        status: {
          in: ["RECEIVED", "PARSED", "MATCHING", "NEEDS_MANAGER_REVIEW"],
        },
      },
    }),
  ]);

  // Aidat durumlarını objeye dönüştür
  const duesBreakdown = {};
  for (const group of duesByStatus) {
    duesBreakdown[group.status] = {
      count: group._count,
      totalAmount: Number(group._sum.amount ?? 0),
    };
  }

  res.json({
    success: true,
    data: {
      apartments: {
        total: totalApartments,
        occupied: occupiedApartments,
      },
      dues: duesBreakdown,
      expenses: {
        total: Number(expensesThisMonth._sum.amount ?? 0),
        count: expensesThisMonth._count,
      },
      unreadNotifications,
      openTickets,
      pendingDekonts,
      period: { month: currentMonth, year: currentYear },
    },
  });
});
