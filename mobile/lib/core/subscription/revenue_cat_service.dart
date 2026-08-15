import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../constants/subscription_constants.dart';

/// RevenueCat SDK — yalnızca mobil (Android/iOS); anahtar yoksa no-op.
abstract final class RevenueCatService {
  static const String androidApiKey = String.fromEnvironment(
    'REVENUECAT_ANDROID_KEY',
  );
  static const String iosApiKey = String.fromEnvironment('REVENUECAT_IOS_KEY');

  static const List<String> _offeringFallbackIds = ['default', 'aidatpanel'];

  static bool get isSupportedPlatform =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  static bool get isConfigured {
    if (!isSupportedPlatform) return false;
    if (Platform.isAndroid) return androidApiKey.isNotEmpty;
    return iosApiKey.isNotEmpty;
  }

  static Future<void> configure() async {
    if (!isConfigured) return;

    try {
      await Purchases.setLogLevel(kDebugMode ? LogLevel.debug : LogLevel.info);
      final configuration = Platform.isAndroid
          ? PurchasesConfiguration(androidApiKey)
          : PurchasesConfiguration(iosApiKey);
      await Purchases.configure(configuration);
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('[RevenueCat] configure başarısız: $e\n$st');
      }
    }
  }

  static Future<void> logIn(String userId) async {
    if (!isConfigured || userId.isEmpty) return;
    try {
      await Purchases.logIn(userId);
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('[RevenueCat] logIn başarısız: $e\n$st');
      }
    }
  }

  static Future<void> logOut() async {
    if (!isConfigured) return;
    try {
      await Purchases.logOut();
    } catch (_) {}
  }

  static bool _storeIdMatches(String storeId, String productId) {
    if (storeId == productId) return true;
    if (storeId.startsWith('$productId:')) return true;
    return false;
  }

  static Offering? _resolveOffering(Offerings offerings) {
    final current = offerings.current;
    if (current != null && current.availablePackages.isNotEmpty) {
      return current;
    }
    for (final id in _offeringFallbackIds) {
      final offering = offerings.all[id];
      if (offering != null && offering.availablePackages.isNotEmpty) {
        return offering;
      }
    }
    for (final offering in offerings.all.values) {
      if (offering.availablePackages.isNotEmpty) return offering;
    }
    return current;
  }

  static Package? _findPackageInOffering(Offering offering, String productId) {
    for (final package in offering.availablePackages) {
      if (_storeIdMatches(package.storeProduct.identifier, productId)) {
        return package;
      }
    }
    return null;
  }

  /// Mağaza fiyatları — Temel + Business, aylık/yıllık.
  static Future<SubscriptionStorePrices> fetchStorePrices() async {
    if (!isConfigured) return SubscriptionStorePrices.empty;

    try {
      final offerings = await Purchases.getOfferings();
      final offering = _resolveOffering(offerings);
      if (offering == null) return SubscriptionStorePrices.empty;

      StoreProduct? monthly;
      StoreProduct? annual;
      StoreProduct? businessMonthly;
      StoreProduct? businessAnnual;

      for (final package in offering.availablePackages) {
        final id = package.storeProduct.identifier;
        final product = package.storeProduct;
        if (monthly == null &&
            _storeIdMatches(id, SubscriptionConstants.monthlyProductId)) {
          monthly = product;
        } else if (annual == null &&
            _storeIdMatches(id, SubscriptionConstants.annualProductId)) {
          annual = product;
        } else if (businessMonthly == null &&
            _storeIdMatches(
              id,
              SubscriptionConstants.businessMonthlyProductId,
            )) {
          businessMonthly = product;
        } else if (businessAnnual == null &&
            _storeIdMatches(
              id,
              SubscriptionConstants.businessAnnualProductId,
            )) {
          businessAnnual = product;
        }
      }

      return SubscriptionStorePrices(
        monthlyPriceString: monthly?.priceString,
        annualPriceString: annual?.priceString,
        businessMonthlyPriceString: businessMonthly?.priceString,
        businessAnnualPriceString: businessAnnual?.priceString,
        monthlyPrice: monthly?.price,
        annualPrice: annual?.price,
        businessMonthlyPrice: businessMonthly?.price,
        businessAnnualPrice: businessAnnual?.price,
        currencyCode:
            monthly?.currencyCode ??
            annual?.currencyCode ??
            businessMonthly?.currencyCode ??
            businessAnnual?.currencyCode,
      );
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('[RevenueCat] fetchStorePrices başarısız: $e\n$st');
      }
      return SubscriptionStorePrices.empty;
    }
  }

  static Future<Package?> findPackage(String productId) async {
    if (!isConfigured) return null;
    final offerings = await Purchases.getOfferings();
    final offering = _resolveOffering(offerings);
    if (offering == null) return null;
    return _findPackageInOffering(offering, productId);
  }

  static Future<void> _purchaseStoreProduct(StoreProduct product) async {
    if (Platform.isAndroid) {
      final option =
          product.defaultOption ??
          (product.subscriptionOptions != null &&
                  product.subscriptionOptions!.isNotEmpty
              ? product.subscriptionOptions!.first
              : null);
      if (option != null) {
        await Purchases.purchase(PurchaseParams.subscriptionOption(option));
        return;
      }
    }
    await Purchases.purchase(PurchaseParams.storeProduct(product));
  }

  static Future<void> purchaseProduct(String productId) async {
    if (!isConfigured) {
      throw StateError('purchases_unavailable');
    }

    final package = await findPackage(productId);
    if (package != null) {
      await Purchases.purchase(PurchaseParams.package(package));
      return;
    }

    final products = await Purchases.getProducts([productId]);
    if (products.isEmpty) {
      throw StateError('purchase_product_not_found');
    }

    for (final product in products) {
      if (_storeIdMatches(product.identifier, productId)) {
        await _purchaseStoreProduct(product);
        return;
      }
    }
    await _purchaseStoreProduct(products.first);
  }
}

/// RevenueCat / Play Store fiyat bilgisi.
class SubscriptionStorePrices {
  const SubscriptionStorePrices({
    this.monthlyPriceString,
    this.annualPriceString,
    this.businessMonthlyPriceString,
    this.businessAnnualPriceString,
    this.monthlyPrice,
    this.annualPrice,
    this.businessMonthlyPrice,
    this.businessAnnualPrice,
    this.currencyCode,
  });

  static const empty = SubscriptionStorePrices();

  final String? monthlyPriceString;
  final String? annualPriceString;
  final String? businessMonthlyPriceString;
  final String? businessAnnualPriceString;
  final double? monthlyPrice;
  final double? annualPrice;
  final double? businessMonthlyPrice;
  final double? businessAnnualPrice;
  final String? currencyCode;

  bool get hasAnyPrice =>
      monthlyPriceString != null ||
      annualPriceString != null ||
      businessMonthlyPriceString != null ||
      businessAnnualPriceString != null;

  double? get annualEquivalentAmount {
    if (monthlyPrice == null) return null;
    return monthlyPrice! * 12;
  }

  double? get savingsAmount {
    final equivalent = annualEquivalentAmount;
    if (equivalent == null || annualPrice == null) return null;
    final savings = equivalent - annualPrice!;
    return savings > 0 ? savings : null;
  }

  double? get businessAnnualEquivalentAmount {
    if (businessMonthlyPrice == null) return null;
    return businessMonthlyPrice! * 12;
  }

  double? get businessSavingsAmount {
    final equivalent = businessAnnualEquivalentAmount;
    if (equivalent == null || businessAnnualPrice == null) return null;
    final savings = equivalent - businessAnnualPrice!;
    return savings > 0 ? savings : null;
  }
}
