import { prisma } from "../config/db.js";
import { logger } from "../config/logger.js";
import { NOTIFICATION_TYPES } from "../constants/notificationConstants.js";
import { NOTIFICATION_CODES } from "../constants/notificationCatalog.js";
import { EXPENSE_CATEGORY_LABELS } from "../constants/reportLabels.js";
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
        code: NOTIFICATION_CODES.EXPENSE_ADDED_RESIDENT,
        params: {
          title,
          month: targetMonth,
          year: targetYear,
          amountStr: amountStr ?? "",
          categoryLabel,
          splitMonths,
        },
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
    logger.error({
      type: "expense_notify_failed",
      buildingId,
      expenseId: payload?.expenseId,
      err: err?.message,
    });
  }
}
