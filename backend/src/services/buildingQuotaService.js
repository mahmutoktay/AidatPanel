import { prisma } from "../config/db.js";
import {
  BUILDING_LIMIT_BASIC,
  BUILDING_LIMIT_BUSINESS,
  BUILDING_LIMIT_NONE,
  isBusinessPlan,
  isEntitledStatus,
} from "../constants/subscriptionConstants.js";
import { HttpError } from "../utils/httpError.js";

export async function countManagerBuildings(managerId) {
  return prisma.building.count({ where: { managerId } });
}

/**
 * @returns {number|null} null = sınırsız; 0 = abonelik yok (yeni bina yok)
 */
export function resolveBuildingLimit(subscription) {
  if (!subscription || !isEntitledStatus(subscription.status)) {
    return BUILDING_LIMIT_NONE;
  }
  if (isBusinessPlan(subscription.plan)) {
    return BUILDING_LIMIT_BUSINESS;
  }
  return BUILDING_LIMIT_BASIC;
}

export async function assertCanAddBuilding(managerId) {
  const subscription = await prisma.subscription.findUnique({
    where: { userId: managerId },
  });
  const limit = resolveBuildingLimit(subscription);

  if (limit === 0) {
    throw new HttpError(
      403,
      "Yeni bina eklemek için abonelik gerekli. Lütfen Temel veya Business planına abone olun."
    );
  }

  if (limit == null) return;

  const count = await countManagerBuildings(managerId);
  if (count >= limit) {
    throw new HttpError(
      403,
      `Bina kotanız doldu (${count}/${limit}). Daha fazla bina için Business planına yükseltin.`
    );
  }
}

export async function getBuildingUsage(managerId) {
  const buildings = await countManagerBuildings(managerId);
  const limit = resolveBuildingLimit(
    await prisma.subscription.findUnique({ where: { userId: managerId } })
  );
  return { buildings, limit };
}
