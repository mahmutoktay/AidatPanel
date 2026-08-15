/// RevenueCat / mağaza ürün kimlikleri — backend ile eşleşmeli.
abstract final class SubscriptionConstants {
  static const String monthlyProductId = 'aidatpanel_monthly';
  static const String annualProductId = 'aidatpanel_annual';
  static const String businessMonthlyProductId = 'aidatpanel_business_monthly';
  static const String businessAnnualProductId = 'aidatpanel_business_annual';

  static const int basicBuildingLimit = 20;

  static const List<String> allProductIds = [
    monthlyProductId,
    annualProductId,
    businessMonthlyProductId,
    businessAnnualProductId,
  ];
}
