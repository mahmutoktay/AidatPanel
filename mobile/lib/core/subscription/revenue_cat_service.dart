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
      // Abonelik SDK hatası oturum açmayı engellememeli.
      if (kDebugMode) {
        debugPrint('[RevenueCat] logIn başarısız: $e\n$st');
      }
    }
  }

  static Future<void> logOut() async {
    if (!isConfigured) return;
    try {
      await Purchases.logOut();
    } catch (_) {
      // Zaten anonim kullanıcı olabilir.
    }
  }

  static bool matchesMonthly(String productId) =>
      productId == SubscriptionConstants.monthlyProductId ||
      productId.startsWith('${SubscriptionConstants.monthlyProductId}:') ||
      productId.toLowerCase().contains('month');

  static bool matchesAnnual(String productId) =>
      productId == SubscriptionConstants.annualProductId ||
      productId.startsWith('${SubscriptionConstants.annualProductId}:') ||
      productId.toLowerCase().contains('annual') ||
      productId.toLowerCase().contains('year');

  static bool _storeIdMatches(String storeId, String productId) {
    if (storeId == productId) return true;
    if (storeId.startsWith('$productId:')) return true;
    if (matchesMonthly(productId) && matchesMonthly(storeId)) return true;
    if (matchesAnnual(productId) && matchesAnnual(storeId)) return true;
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

  static Future<Package?> findPackage(String productId) async {
    if (!isConfigured) return null;
    final offerings = await Purchases.getOfferings();
    final offering = _resolveOffering(offerings);
    if (offering == null) return null;

    if (matchesMonthly(productId) && offering.monthly != null) {
      return offering.monthly;
    }
    if (matchesAnnual(productId) && offering.annual != null) {
      return offering.annual;
    }

    for (final package in offering.availablePackages) {
      if (_storeIdMatches(package.storeProduct.identifier, productId)) {
        return package;
      }
    }
    return null;
  }

  static List<String> _productIdCandidates(String productId) {
    final ids = <String>{productId};
    if (matchesMonthly(productId)) {
      ids.add(SubscriptionConstants.monthlyProductId);
    }
    if (matchesAnnual(productId)) {
      ids.add(SubscriptionConstants.annualProductId);
    }
    return ids.toList();
  }

  static Future<void> _purchaseStoreProduct(StoreProduct product) async {
    if (Platform.isAndroid) {
      final option = product.defaultOption ??
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

    final products = await Purchases.getProducts(_productIdCandidates(productId));
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
