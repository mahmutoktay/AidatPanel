import { prisma } from "../config/db.js";

function pickEffective(buildingValue, siteValue, fallback = null) {
  if (buildingValue != null && buildingValue !== "") return buildingValue;
  if (siteValue != null && siteValue !== "") return siteValue;
  return fallback;
}

/**
 * Bina + site varsayılanlarından effective tahsilat/aidat/adres çözümler.
 * @param {object} building — site ilişkisi dahil olabilir
 * @param {import("@prisma/client").PrismaClient} [db]
 */
export async function resolveEffectiveBuildingConfig(building, db = prisma) {
  let site = building.site ?? null;
  if (!site && building.siteId) {
    site = await db.site.findUnique({ where: { id: building.siteId } });
  }

  const effectiveDueAmount =
    building.dueAmount != null ? building.dueAmount : site?.dueAmount ?? null;
  const effectiveDueDay = building.dueDay ?? site?.dueDay ?? 1;
  const effectiveCurrency = building.currency ?? site?.currency ?? "TRY";
  const effectiveCollectionIban = pickEffective(
    building.collectionIban,
    site?.collectionIban,
    null
  );
  const effectiveCollectionAccountTitle = pickEffective(
    building.collectionAccountTitle,
    site?.collectionAccountTitle,
    null
  );
  const effectivePaymentReferenceTemplate = pickEffective(
    building.paymentReferenceTemplate,
    site?.paymentReferenceTemplate,
    null
  );
  const effectiveAddress = site
    ? [site.address, building.addressExtra].filter(Boolean).join(" — ") || building.address
    : building.address;
  const effectiveCity = building.city ?? site?.city ?? building.city;
  const displayName =
    building.name?.trim() ||
    building.blockLabel?.trim() ||
    building.name;

  return {
    effectiveDueAmount,
    effectiveDueDay,
    effectiveCurrency,
    effectiveCollectionIban,
    effectiveCollectionAccountTitle,
    effectivePaymentReferenceTemplate,
    effectiveAddress,
    effectiveCity,
    displayName,
    siteName: site?.name ?? null,
  };
}

export function attachEffectiveFields(building, effective) {
  return {
    ...building,
    displayName: effective.displayName,
    effectiveDueAmount: effective.effectiveDueAmount,
    effectiveDueDay: effective.effectiveDueDay,
    effectiveCurrency: effective.effectiveCurrency,
    effectiveCollectionIban: effective.effectiveCollectionIban,
    effectiveCollectionAccountTitle: effective.effectiveCollectionAccountTitle,
    effectivePaymentReferenceTemplate: effective.effectivePaymentReferenceTemplate,
    effectiveAddress: effective.effectiveAddress,
    effectiveCity: effective.effectiveCity,
    siteName: effective.siteName,
  };
}

export async function enrichBuildingWithEffective(building, db = prisma) {
  const effective = await resolveEffectiveBuildingConfig(building, db);
  return attachEffectiveFields(building, effective);
}
