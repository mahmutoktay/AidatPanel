import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../../../core/constants/subscription_constants.dart';
import '../../../../core/subscription/revenue_cat_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/subscription_remote_datasource.dart';
import '../../data/repositories/subscription_repository_impl.dart';
import '../../domain/entities/subscription_entity.dart';
import '../../domain/repositories/subscription_repository.dart';

final subscriptionRemoteDataSourceProvider =
    Provider<SubscriptionRemoteDataSource>((ref) {
      return SubscriptionRemoteDataSourceImpl(
        dioClient: ref.watch(dioClientProvider),
      );
    });

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  return SubscriptionRepositoryImpl(
    remote: ref.watch(subscriptionRemoteDataSourceProvider),
  );
});

class SubscriptionState {
  final bool isLoading;
  final bool isPurchasing;
  final SubscriptionEntity? subscription;
  final SubscriptionStorePrices storePrices;
  final String? error;
  final String? purchaseError;
  final String? successMessage;

  const SubscriptionState({
    this.isLoading = false,
    this.isPurchasing = false,
    this.subscription,
    this.storePrices = SubscriptionStorePrices.empty,
    this.error,
    this.purchaseError,
    this.successMessage,
  });

  bool get purchasesEnabled =>
      RevenueCatService.isConfigured && !isPurchasing && !isLoading;

  SubscriptionState copyWith({
    bool? isLoading,
    bool? isPurchasing,
    SubscriptionEntity? subscription,
    SubscriptionStorePrices? storePrices,
    String? error,
    String? purchaseError,
    String? successMessage,
    bool clearSubscription = false,
    bool clearError = false,
    bool clearPurchaseError = false,
    bool clearSuccess = false,
  }) {
    return SubscriptionState(
      isLoading: isLoading ?? this.isLoading,
      isPurchasing: isPurchasing ?? this.isPurchasing,
      subscription: clearSubscription
          ? null
          : (subscription ?? this.subscription),
      storePrices: storePrices ?? this.storePrices,
      error: clearError ? null : (error ?? this.error),
      purchaseError: clearPurchaseError
          ? null
          : (purchaseError ?? this.purchaseError),
      successMessage: clearSuccess
          ? null
          : (successMessage ?? this.successMessage),
    );
  }
}

class SubscriptionNotifier extends Notifier<SubscriptionState> {
  SubscriptionRepository get _repository =>
      ref.read(subscriptionRepositoryProvider);

  @override
  SubscriptionState build() => const SubscriptionState();

  Future<void> load() async {
    if (state.isLoading) return;
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccess: true,
    );

    // Backend'den abonelik bilgisini al
    SubscriptionEntity? sub;
    try {
      sub = await _repository.getMySubscription();
    } catch (e) {
      debugPrint('[Subscription] Backend subscription fetch failed: $e');
    }

    // RevenueCat'ten fiyatları al (başarısız olursa fallback kullan)
    SubscriptionStorePrices prices = SubscriptionStorePrices.empty;
    if (RevenueCatService.isConfigured) {
      try {
        prices = await RevenueCatService.fetchStorePrices();
      } catch (e) {
        debugPrint('[Subscription] RevenueCat fetch failed (non-fatal): $e');
        // Fiyat yoksa fallback string'ler kullanılacak
      }
    }

    state = state.copyWith(
      isLoading: false,
      subscription: sub,
      storePrices: prices,
      clearError: true,
    );
  }

  Future<void> purchaseMonthly() =>
      _purchase(SubscriptionConstants.monthlyProductId);

  Future<void> purchaseAnnual() =>
      _purchase(SubscriptionConstants.annualProductId);

  Future<void> _purchase(String productId) async {
    if (state.isPurchasing) return;
    if (!RevenueCatService.isConfigured) {
      state = state.copyWith(error: 'purchases_unavailable');
      return;
    }

    state = state.copyWith(
      isPurchasing: true,
      clearError: true,
      clearPurchaseError: true,
      clearSuccess: true,
    );
    try {
      await RevenueCatService.purchaseProduct(productId);
      await _loadWithPolling();
      state = state.copyWith(
        isPurchasing: false,
        successMessage: 'purchase_success',
      );
    } on PlatformException catch (e) {
      final code = PurchasesErrorHelper.getErrorCode(e);
      debugPrint('[RevenueCat] Satın alma PlatformException (code: $code): $e');
      if (code == PurchasesErrorCode.purchaseCancelledError) {
        state = state.copyWith(
          isPurchasing: false,
          purchaseError: 'purchase_cancelled',
        );
        return;
      }
      state = state.copyWith(
        isPurchasing: false,
        purchaseError: _purchaseErrorKey(code),
      );
    } on StateError catch (e) {
      debugPrint('[RevenueCat] Satın alma StateError: $e');
      state = state.copyWith(isPurchasing: false, purchaseError: e.message);
    } catch (e, st) {
      debugPrint('[RevenueCat] Satın alma beklenmeyen hata: $e\n$st');
      state = state.copyWith(
        isPurchasing: false,
        purchaseError: 'purchase_failed',
      );
    }
  }

  Future<void> _loadWithPolling() async {
    const maxAttempts = 3;
    const delay = Duration(milliseconds: 1500);

<<<<<<< HEAD
    // Fiyatları polling öncesinde bir kere çek, her denemede tekrar isteme.
=======
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
    final prices = RevenueCatService.isConfigured
        ? await RevenueCatService.fetchStorePrices()
        : SubscriptionStorePrices.empty;

    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      if (attempt > 1) {
        await Future.delayed(delay);
      }

<<<<<<< HEAD
      // Sadece subscription'ı backend'den çek.
=======
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
      try {
        state = state.copyWith(
          isLoading: true,
          clearError: true,
          clearSuccess: true,
        );
        final sub = await _repository.getMySubscription();

        if (sub != null) {
          state = state.copyWith(
            isLoading: false,
            subscription: sub,
            storePrices: prices,
            clearError: true,
          );
          debugPrint(
            '[Subscription] Polling: subscription found on attempt $attempt',
          );
          return;
        }

<<<<<<< HEAD
        // Henüz kayıt yok.
=======
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
        state = state.copyWith(
          isLoading: false,
          storePrices: prices,
          clearError: true,
        );
        debugPrint(
          '[Subscription] Polling: no subscription yet (attempt $attempt/$maxAttempts)',
        );
      } catch (_) {
        state = state.copyWith(isLoading: false, clearError: true);
        debugPrint(
          '[Subscription] Polling: error on attempt $attempt, retrying...',
        );
      }
    }

    debugPrint('[Subscription] Polling exhausted, falling back to load()');
    await load();
  }
}

String _purchaseErrorKey(PurchasesErrorCode code) {
  switch (code) {
    case PurchasesErrorCode.productNotAvailableForPurchaseError:
    case PurchasesErrorCode.productAlreadyPurchasedError:
      return 'purchase_product_not_found';
    case PurchasesErrorCode.storeProblemError:
    case PurchasesErrorCode.purchaseNotAllowedError:
    case PurchasesErrorCode.purchaseInvalidError:
      return 'purchase_store_error';
    default:
      return 'purchase_failed';
  }
}

final subscriptionNotifierProvider =
    NotifierProvider<SubscriptionNotifier, SubscriptionState>(
      SubscriptionNotifier.new,
    );
