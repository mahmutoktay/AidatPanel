import { prisma } from "../config/db.js";
import { logger } from "../config/logger.js";
import { normalizeIban } from "../utils/iban.js";
import { buildAutoCollectionIbanLabel } from "../utils/trIbanBank.js";

/**
 * Dekont alıcı IBAN eşleşince: aynı IBAN'a sahip, etiketi boş Building/Site
 * kayıtlarına otomatik takma ad yazar. Dolu etiketlere dokunmaz.
 *
 * @param {{ managerId: string, collectionIban: string }} params
 * @returns {Promise<{ label: string|null, updatedBuildings: number, updatedSites: number }>}
 */
export async function maybeAutoFillCollectionIbanLabel({
  managerId,
  collectionIban,
}) {
  const iban = normalizeIban(collectionIban);
  const label = buildAutoCollectionIbanLabel(iban);
  if (!managerId || !iban || !label) {
    return { label: null, updatedBuildings: 0, updatedSites: 0 };
  }

  const emptyLabelWhere = {
    OR: [{ collectionIbanLabel: null }, { collectionIbanLabel: "" }],
  };

  const [buildingsResult, sitesResult] = await Promise.all([
    prisma.building.updateMany({
      where: {
        managerId,
        collectionIban: iban,
        ...emptyLabelWhere,
      },
      data: { collectionIbanLabel: label },
    }),
    prisma.site.updateMany({
      where: {
        managerId,
        collectionIban: iban,
        ...emptyLabelWhere,
      },
      data: { collectionIbanLabel: label },
    }),
  ]);

  if (buildingsResult.count > 0 || sitesResult.count > 0) {
    logger.info({
      type: "collection_iban_label_auto_fill",
      managerId,
      iban,
      label,
      updatedBuildings: buildingsResult.count,
      updatedSites: sitesResult.count,
    });
  }

  return {
    label,
    updatedBuildings: buildingsResult.count,
    updatedSites: sitesResult.count,
  };
}
