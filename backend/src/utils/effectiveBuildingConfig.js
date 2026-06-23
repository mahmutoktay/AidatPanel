/**
 * Site varsayılanları + bina override → efektif yapılandırma.
 * Mevcut Building alanları korunur; yanıta `effective*` alanları eklenir.
 */
export function resolveEffectiveBuildingConfig(building) {
  const site = building.site ?? null;

  const dueAmount =
    building.dueAmount != null ? building.dueAmount : site?.dueAmount ?? null;
  const dueDay = building.dueDay ?? site?.dueDay ?? 1;
  const currency = building.currency ?? site?.currency ?? "TRY";
  const collectionIban =
    building.collectionIban ?? site?.collectionIban ?? null;
  const collectionAccountTitle =
    building.collectionAccountTitle ?? site?.collectionAccountTitle ?? null;
  const paymentReferenceTemplate =
    building.paymentReferenceTemplate ?? site?.paymentReferenceTemplate ?? null;
  const collectionVerifiedAt =
    building.collectionVerifiedAt ?? site?.collectionVerifiedAt ?? null;

  const address = building.address?.trim()
    ? building.address
    : site?.address ?? building.address;
  const city = building.city?.trim() ? building.city : site?.city ?? building.city;

  const displayAddress = [address, building.addressExtra, city]
    .filter((part) => part && String(part).trim().length > 0)
    .join(", ");

  return {
    ...building,
    siteId: building.siteId ?? null,
    blockLabel: building.blockLabel ?? null,
    addressExtra: building.addressExtra ?? null,
    siteName: site?.name ?? null,
    effectiveDueAmount: dueAmount,
    effectiveDueDay: dueDay,
    effectiveCurrency: currency,
    effectiveCollectionIban: collectionIban,
    effectiveCollectionAccountTitle: collectionAccountTitle,
    effectivePaymentReferenceTemplate: paymentReferenceTemplate,
    effectiveCollectionVerifiedAt: collectionVerifiedAt,
    isCollectionConfigured: Boolean(collectionIban),
    effectiveAddress: address,
    effectiveCity: city,
    effectiveDisplayAddress: displayAddress,
  };
}
