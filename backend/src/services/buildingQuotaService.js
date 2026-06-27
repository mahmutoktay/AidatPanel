import { prisma } from "../config/db.js";
import {
  PLAN_BUILDING_LIMITS,
  DEFAULT_BUILDING_LIMIT,
} from "../constants/subscriptionConstants.js";
import { HttpError } from "../utils/httpError.js";

export async function countManagerBuildings(managerId) {
  return prisma.building.count({ where: { managerId } });
}

export function resolveBuildingLimit(subscription) {
  // Abonelik yoksa veya aktif değilse default limit (1)
  if (!subscription || subscription.status !== "ACTIVE") {
    return DEFAULT_BUILDING_LIMIT;
  }

  // Plan adına göre limit belirle (lowercase)
  const plan = (subscription.plan ?? "").toLowerCase();
  const limit = PLAN_BUILDING_LIMITS[plan];

  // Bilinen bir plan değilse default limit
  if (limit === undefined) {
    return DEFAULT_BUILDING_LIMIT;
  }

  return limit;
}

export async function assertCanAddBuilding(managerId) {
  const subscription = await prisma.subscription.findUnique({
    where: { userId: managerId },
  });
  const limit = resolveBuildingLimit(subscription);

  if (limit == null) return; // null = sınırsız

  const count = await countManagerBuildings(managerId);
  if (count >= limit) {
    throw new HttpError(
      403,
      `Bina kotanız doldu (${count}/${limit}). Yeni bina eklemek için aboneliğinizi yükseltin.`
    );
  }
}

export async function getBuildingUsage(managerId) {
  const buildings = await countManagerBuildings(managerId);
  const subscription = await prisma.subscription.findUnique({
    where: { userId: managerId },
  });
  const limit = resolveBuildingLimit(subscription);
  return { buildings, limit };
}
