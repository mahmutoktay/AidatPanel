import { NOTIFICATION_TYPES } from "../constants/notificationConstants.js";
import { DUE_REMINDER_RESIDENT } from "../constants/notificationTemplates.js";
import { prisma } from "../config/db.js";
import { assertManagerOwnsBuilding } from "../utils/access.js";
import { createForUsers } from "./notificationService.js";
import { runPool } from "../utils/asyncPool.js";
import { resolveListTake } from "../utils/listQuery.js";

const REMIND_CONCURRENCY = Math.max(
  1,
  Number(process.env.DUE_REMIND_CONCURRENCY) || 8
);

/**
 * Binadaki PENDING/OVERDUE aidatlar için sakinlere hatırlatma (in-app + FCM).
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
    },
    take: resolveListTake(),
  });

  if (dues.length === 0) {
    return { reminded: 0, pushSent: 0, pushFailed: 0, pushSkipped: 0 };
  }

  /** @type {Map<string, typeof dues[0]>} */
  const firstDueByResident = new Map();
  for (const due of dues) {
    const residentId = due.apartment?.resident?.id;
    if (!residentId || firstDueByResident.has(residentId)) {
      continue;
    }
    firstDueByResident.set(residentId, due);
  }

  const jobs = [...firstDueByResident.entries()];

  const outcomes = await runPool(jobs, REMIND_CONCURRENCY, async ([residentId, due]) => {
    const amount =
      due.amount != null ? Number(due.amount).toFixed(2) : "0.00";
    const currency = due.currency ?? building.currency ?? "TRY";

    return createForUsers([residentId], {
      type: NOTIFICATION_TYPES.DUE_REMINDER,
      title: DUE_REMINDER_RESIDENT.title,
      body: DUE_REMINDER_RESIDENT.body(due.month, due.year, amount, currency),
      data: {
        dueId: due.id,
        buildingId,
        apartmentId: due.apartmentId,
        month: String(due.month),
        year: String(due.year),
        route: "/resident-dashboard",
      },
    });
  });

  let pushSent = 0;
  let pushFailed = 0;
  let pushSkipped = 0;
  for (const result of outcomes) {
    pushSent += result.pushSent;
    pushFailed += result.pushFailed;
    pushSkipped += result.pushSkipped;
  }

  return {
    reminded: jobs.length,
    pushSent,
    pushFailed,
    pushSkipped,
  };
}
