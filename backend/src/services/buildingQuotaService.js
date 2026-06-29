import { prisma } from "../config/db.js";
import { BUILDING_LIMIT_ACTIVE } from "../constants/subscriptionConstants.js";
import { HttpError } from "../utils/httpError.js";

export async function countManagerBuildings(managerId) {
  return prisma.building.count({ where: { managerId } });
}

export function resolveBuildingLimit(subscription) {
  if (!subscription || subscription.status !== "ACTIVE") {
    return BUILDING_LIMIT_ACTIVE;
  }
  return BUILDING_LIMIT_ACTIVE;
}

export async function assertCanAddBuilding(managerId) {
  const limit = resolveBuildingLimit(
    await prisma.subscription.findUnique({ where: { userId: managerId } })
  );
  if (limit == null) return;

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
  const limit = resolveBuildingLimit(
    await prisma.subscription.findUnique({ where: { userId: managerId } })
  );
  return { buildings, limit };
}
