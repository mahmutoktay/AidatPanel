import { HttpError } from "../../utils/httpError.js";
import { buildPaymentReference, findActiveUserById } from "./profileHelpers.js";
<<<<<<< HEAD
import { resolveEffectiveBuildingConfig } from "../../utils/effectiveBuildingConfig.js";
=======
import { resolveEffectiveBuildingConfig } from "../buildingConfigService.js";
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6

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
<<<<<<< HEAD
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
=======
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
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
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
<<<<<<< HEAD
  const effective = resolveEffectiveBuildingConfig(apartment.building);
=======
  const building = apartment.building;
  const effective = await resolveEffectiveBuildingConfig(building);
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
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
<<<<<<< HEAD
    buildingId: effective.id,
    buildingName: displayName,
    siteId: effective.siteId,
=======
    buildingId: building.id,
    buildingName: effective.displayName,
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
    siteName: effective.siteName,
    apartmentNumber,
    collectionIban: effective.effectiveCollectionIban,
    collectionAccountTitle: effective.effectiveCollectionAccountTitle,
    paymentReferenceTemplate: effective.effectivePaymentReferenceTemplate,
    paymentReference,
<<<<<<< HEAD
    isCollectionConfigured: effective.isCollectionConfigured,
=======
    isCollectionConfigured: Boolean(effective.effectiveCollectionIban),
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
  };
}
