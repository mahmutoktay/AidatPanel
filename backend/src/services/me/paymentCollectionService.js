import { HttpError } from "../../utils/httpError.js";
import { buildPaymentReference, findActiveUserById } from "./profileHelpers.js";

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
            collectionIban: true,
            collectionAccountTitle: true,
            paymentReferenceTemplate: true,
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
  const apartmentNumber = String(apartment.number);
  const paymentReference = buildPaymentReference(
    building.paymentReferenceTemplate,
    apartmentNumber
  );

  return {
    buildingId: building.id,
    buildingName: building.name,
    apartmentNumber,
    collectionIban: building.collectionIban,
    collectionAccountTitle: building.collectionAccountTitle,
    paymentReferenceTemplate: building.paymentReferenceTemplate,
    paymentReference,
    isCollectionConfigured: Boolean(building.collectionIban),
  };
}
