import { HttpError } from "../../utils/httpError.js";
import { buildPaymentReference, findActiveUserById } from "./profileHelpers.js";
import { resolveEffectiveBuildingConfig } from "../buildingConfigService.js";

/**
 * Sakinin havale / dekont ödeme ekranı için tahsilat bilgisi (IBAN yalnızca okuma).
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
            blockLabel: true,
            collectionIban: true,
            collectionAccountTitle: true,
            paymentReferenceTemplate: true,
            dueAmount: true,
            dueDay: true,
            currency: true,
            address: true,
            city: true,
            siteId: true,
            site: {
              select: {
                name: true,
                collectionIban: true,
                collectionAccountTitle: true,
                paymentReferenceTemplate: true,
                dueAmount: true,
                dueDay: true,
                currency: true,
                address: true,
                city: true,
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
  const building = apartment.building;
  const effective = await resolveEffectiveBuildingConfig(building);
  const apartmentNumber = String(apartment.number);
  const paymentReference = buildPaymentReference(
    effective.effectivePaymentReferenceTemplate,
    apartmentNumber
  );

  return {
    buildingId: building.id,
    buildingName: effective.displayName,
    siteName: effective.siteName,
    apartmentNumber,
    collectionIban: effective.effectiveCollectionIban,
    collectionAccountTitle: effective.effectiveCollectionAccountTitle,
    paymentReferenceTemplate: effective.effectivePaymentReferenceTemplate,
    paymentReference,
    isCollectionConfigured: Boolean(effective.effectiveCollectionIban),
  };
}
