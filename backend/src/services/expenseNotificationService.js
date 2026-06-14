import { prisma } from "../config/db.js";
import { NOTIFICATION_TYPES } from "../constants/notificationConstants.js";
import { EXPENSE_CATEGORY_LABELS } from "../constants/reportLabels.js";
import { EXPENSE_ADDED_RESIDENT } from "../constants/notificationTemplates.js";
import { createForUsers } from "./notificationService.js";

/**
 * Yönetici gider eklediğinde binadaki aktif sakinlere bildirim (in-app + FCM).
 * @param {string} buildingId
 * @param {{
 *   expenseId: string,
 *   title: string,
 *   amount?: string | number | null,
 *   category: string,
 *   targetMonth: number,
 *   targetYear: number,
 *   splitMonths?: number,
 * }} payload
 */
export async function notifyResidentsOfNewExpense(buildingId, payload) {
  try {
    const {
      expenseId,
      title,
      amount,
      category,
      targetMonth,
      targetYear,
      splitMonths = 1,
    } = payload;

    const residents = await prisma.user.findMany({
      where: {
        deletedAt: null,
        role: "RESIDENT",
        apartmentId: { not: null },
        apartment: { buildingId },
      },
      select: { id: true },
    });

    if (residents.length === 0) return;

    const building = await prisma.building.findUnique({
      where: { id: buildingId },
      select: { currency: true },
    });
    const currency = building?.currency ?? "TRY";
    const categoryLabel = EXPENSE_CATEGORY_LABELS[category] ?? category;
    const amountStr =
      amount != null && !Number.isNaN(Number(amount)) && Number(amount) > 0
        ? `${Number(amount).toFixed(2)} ${currency}`
        : null;

    await createForUsers(
      residents.map((r) => r.id),
      {
        type: NOTIFICATION_TYPES.EXPENSE_ADDED,
        title: EXPENSE_ADDED_RESIDENT.title,
        body: EXPENSE_ADDED_RESIDENT.body({
          title,
          month: targetMonth,
          year: targetYear,
          amountStr,
          categoryLabel,
          splitMonths,
        }),
        data: {
          expenseId,
          buildingId,
          month: String(targetMonth),
          year: String(targetYear),
          route: "/resident-dashboard",
        },
      }
    );
  } catch (err) {
    console.error("[expense] notify residents failed", {
      buildingId,
      expenseId: payload?.expenseId,
      message: err?.message,
    });
  }
}
