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

  static Future<Package?> findPackage(String productId) async {
    if (!isConfigured) return null;
    final offerings = await Purchases.getOfferings();
    final current = offerings.current;
    if (current == null) return null;

    for (final package in current.availablePackages) {
      if (package.storeProduct.identifier == productId) {
        return package;
      }
    }
    return null;
  }

  static Future<void> purchaseProduct(String productId) async {
    if (!isConfigured) {
      throw StateError('RevenueCat yapılandırılmamış.');
    }

    final package = await findPackage(productId);
    if (package != null) {
      await Purchases.purchase(PurchaseParams.package(package));
      return;
    }

    final products = await Purchases.getProducts([productId]);
    if (products.isEmpty) {
      throw StateError('Ürün mağazada bulunamadı.');
    }
    await Purchases.purchase(PurchaseParams.storeProduct(products.first));
  }

  static bool matchesMonthly(String productId) =>
      productId == SubscriptionConstants.monthlyProductId ||
      productId.toLowerCase().contains('month');

  static bool matchesAnnual(String productId) =>
      productId == SubscriptionConstants.annualProductId ||
      productId.toLowerCase().contains('annual') ||
      productId.toLowerCase().contains('year');
}
