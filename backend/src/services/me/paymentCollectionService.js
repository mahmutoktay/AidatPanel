import { HttpError } from "../../utils/httpError.js";
import { buildPaymentReference, findActiveUserById } from "./profileHelpers.js";
import { resolveEffectiveBuildingConfig } from "../../utils/effectiveBuildingConfig.js";

/**
 * Sakinin havale / dekont ödeme ekranı için tahsilat bilgisi (IBAN yalnızca okuma).
 * Site varsayılan IBAN bina override yoksa kullanılır.
 */
export async function getMyPaymentCollectionService(userId) {
  const user = await findActiveUserById(userId, {
    apartment: {
      select: {
        number: true,
        building: {
          select: {
            id: true,
            name: true,
            siteId: true,
            blockLabel: true,
            address: true,
            addressExtra: true,
            city: true,
            dueAmount: true,
            dueDay: true,
            currency: true,
            collectionIban: true,
            collectionAccountTitle: true,
            paymentReferenceTemplate: true,
            collectionVerifiedAt: true,
            site: {
              select: {
                id: true,
                name: true,
                address: true,
                city: true,
                dueAmount: true,
                dueDay: true,
                currency: true,
                collectionIban: true,
                collectionAccountTitle: true,
                paymentReferenceTemplate: true,
                collectionVerifiedAt: true,
              },
            },
          },
        },
      },
    },
  });

  if (!user?.apartment) {
    throw new HttpError(404, "Ödeme bilgisi için daire ataması gerekli.");
  }

  const { apartment } = user;
  const effective = resolveEffectiveBuildingConfig(apartment.building);
  const apartmentNumber = String(apartment.number);
  const paymentReference = buildPaymentReference(
    effective.effectivePaymentReferenceTemplate,
    apartmentNumber
  );

  const displayName =
    effective.siteName && effective.blockLabel
      ? `${effective.siteName} — ${effective.blockLabel}`
      : effective.siteName
        ? `${effective.siteName} — ${effective.name}`
        : effective.name;

  return {
    buildingId: effective.id,
    buildingName: displayName,
    siteId: effective.siteId,
    siteName: effective.siteName,
    apartmentNumber,
    collectionIban: effective.effectiveCollectionIban,
    collectionAccountTitle: effective.effectiveCollectionAccountTitle,
    paymentReferenceTemplate: effective.effectivePaymentReferenceTemplate,
    paymentReference,
    isCollectionConfigured: effective.isCollectionConfigured,
  };
}
