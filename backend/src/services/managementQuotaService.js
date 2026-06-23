import { prisma } from "../config/db.js";
import { HttpError } from "../utils/httpError.js";

const DEFAULT_LIMIT = Number(process.env.MANAGEMENT_UNITS_LIMIT) || 50;

/**
 * YB = tekil bina (siteId null) + site sayısı.
 * Site içi binalar ek kota tüketmez.
 */
export async function countManagementUnits(managerId) {
  const [standaloneBuildings, sites] = await Promise.all([
    prisma.building.count({ where: { managerId, siteId: null } }),
    prisma.site.count({ where: { managerId } }),
  ]);
  return standaloneBuildings + sites;
}

export async function getManagementQuotaUsage(managerId) {
  const used = await countManagementUnits(managerId);
  return {
    managementUnits: used,
    limit: DEFAULT_LIMIT,
  };
}

/**
 * Yeni tekil bina veya yeni site oluşturmadan önce kota kontrolü.
 * Site altı bina eklerken çağrılmaz.
 */
export async function assertCanAddManagementUnit(managerId) {
  const used = await countManagementUnits(managerId);
  if (used >= DEFAULT_LIMIT) {
    throw new HttpError(
      403,
      "Yönetim birimi limitine ulaştınız. Yeni site veya tekil bina ekleyemezsiniz."
    );
  }
}
