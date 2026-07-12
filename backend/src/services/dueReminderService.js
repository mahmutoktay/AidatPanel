import { NOTIFICATION_TYPES } from "../constants/notificationConstants.js";
import { NOTIFICATION_CODES } from "../constants/notificationCatalog.js";
import { prisma } from "../config/db.js";
import { assertManagerOwnsBuilding } from "../utils/access.js";
import { createForUsers } from "./notificationService.js";
import { runPool } from "../utils/asyncPool.js";
import { resolveListTake } from "../utils/listQuery.js";
import { computeDuePaymentTotals } from "../utils/duePaymentTotals.js";
import { currencyDisplay } from "../utils/currencyDisplay.js";

const REMIND_CONCURRENCY = Math.max(
  1,
  Number(process.env.DUE_REMIND_CONCURRENCY) || 8
);

const REMIND_COOLDOWN_MS = 24 * 60 * 60 * 1000;

/**
 * @param {string} residentId
 * @param {string} dueId
 */
async function wasRemindedRecently(residentId, dueId) {
  const since = new Date(Date.now() - REMIND_COOLDOWN_MS);
  const recent = await prisma.notification.findFirst({
    where: {
      userId: residentId,
      type: NOTIFICATION_TYPES.DUE_REMINDER,
      createdAt: { gte: since },
      data: {
        path: ["dueId"],
        equals: dueId,
      },
    },
    select: { id: true },
  });
  return recent != null;
}

/**
 * Binadaki PENDING/OVERDUE aidatlar için sakinlere hatırlatma (in-app + FCM).
 * Tutar: sakinin seçilen aidatlardaki kalan borcu (ödemeler düşülmüş).
 * POST /api/v1/buildings/:buildingId/dues/remind
 */
export async function remindBuildingDuesService(
  buildingId,
  managerId,
  { month, year, dueIds }
) {
  const building = await assertManagerOwnsBuilding(buildingId, managerId);

  const where = {
    apartment: { buildingId },
    status: { in: ["PENDING", "OVERDUE"] },
  };

  if (month != null && year != null) {
    where.month = parseInt(String(month), 10);
    where.year = parseInt(String(year), 10);
  }

  if (dueIds?.length) {
    where.id = { in: dueIds };
  }

  const dues = await prisma.due.findMany({
    where,
    include: {
      apartment: {
        select: {
          id: true,
          number: true,
          resident: { select: { id: true } },
        },
      },
      payments: { select: { amount: true } },
    },
    orderBy: [{ year: "asc" }, { month: "asc" }, { id: "asc" }],
    take: resolveListTake(),
  });

  if (dues.length === 0) {
    return {
      reminded: 0,
      skippedCooldown: 0,
      pushSent: 0,
      pushFailed: 0,
      pushSkipped: 0,
    };
  }

  /** @type {Map<string, typeof dues>} */
  const duesByResident = new Map();
  for (const due of dues) {
    const residentId = due.apartment?.resident?.id;
    if (!residentId) continue;
    const list = duesByResident.get(residentId);
    if (list) list.push(due);
    else duesByResident.set(residentId, [due]);
  }

  const jobs = [...duesByResident.entries()];
  let skippedCooldown = 0;

  const outcomes = await runPool(
    jobs,
    REMIND_CONCURRENCY,
    async ([residentId, residentDues]) => {
      const primaryDue = residentDues[0];
      if (await wasRemindedRecently(residentId, primaryDue.id)) {
        skippedCooldown += 1;
        return {
          skipped: true,
          pushSent: 0,
          pushFailed: 0,
          pushSkipped: 0,
        };
      }

      let remaining = 0;
      for (const d of residentDues) {
        remaining += computeDuePaymentTotals(d).remainingAmount;
      }
      remaining = Math.max(0, Math.round(remaining * 100) / 100);
      if (remaining <= 0) {
        skippedCooldown += 1;
        return {
          skipped: true,
          pushSent: 0,
          pushFailed: 0,
          pushSkipped: 0,
        };
      }

      const amount = remaining.toFixed(2);
      const currency = currencyDisplay(
        primaryDue.currency ?? building.currency
      );

      return createForUsers([residentId], {
        type: NOTIFICATION_TYPES.DUE_REMINDER,
        code: NOTIFICATION_CODES.DUE_REMINDER_RESIDENT,
        params: {
          month: primaryDue.month,
          year: primaryDue.year,
          amount,
          currency,
        },
        data: {
          dueId: primaryDue.id,
          buildingId,
          apartmentId: primaryDue.apartmentId,
          month: String(primaryDue.month),
          year: String(primaryDue.year),
          route: "/resident-dashboard",
        },
      });
    }
  );

  let reminded = 0;
  let pushSent = 0;
  let pushFailed = 0;
  let pushSkipped = 0;
  for (const result of outcomes) {
    if (result?.skipped) continue;
    reminded += 1;
    pushSent += result.pushSent ?? 0;
    pushFailed += result.pushFailed ?? 0;
    pushSkipped += result.pushSkipped ?? 0;
  }

  return {
    reminded,
    skippedCooldown,
    pushSent,
    pushFailed,
    pushSkipped,
  };
}

/** Test ve dış kullanım için export */
export { wasRemindedRecently, REMIND_COOLDOWN_MS };
