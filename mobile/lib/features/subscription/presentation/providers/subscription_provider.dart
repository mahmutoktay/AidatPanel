import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../../../core/constants/subscription_constants.dart';
import '../../../../core/subscription/revenue_cat_service.dart';
import '../../../../core/utils/user_error_message.dart';
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
  final String? error;
  final String? successMessage;

  const SubscriptionState({
    this.isLoading = false,
    this.isPurchasing = false,
    this.subscription,
    this.error,
    this.successMessage,
  });

  bool get purchasesEnabled => RevenueCatService.isConfigured && !isPurchasing;

  SubscriptionState copyWith({
    bool? isLoading,
    bool? isPurchasing,
    SubscriptionEntity? subscription,
    String? error,
    String? successMessage,
    bool clearSubscription = false,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return SubscriptionState(
      isLoading: isLoading ?? this.isLoading,
      isPurchasing: isPurchasing ?? this.isPurchasing,
      subscription:
          clearSubscription ? null : (subscription ?? this.subscription),
      error: clearError ? null : (error ?? this.error),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
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
    state = state.copyWith(isLoading: true, clearError: true, clearSuccess: true);
    try {
      final sub = await _repository.getMySubscription();
      state = state.copyWith(
        isLoading: false,
        subscription: sub,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: userFacingError(e),
      );
    }
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
      clearSuccess: true,
    );
    try {
      await RevenueCatService.purchaseProduct(productId);
      await load();
      state = state.copyWith(
        isPurchasing: false,
        successMessage: 'purchase_success',
      );
    } on PlatformException catch (e) {
      final code = PurchasesErrorHelper.getErrorCode(e);
      if (code == PurchasesErrorCode.purchaseCancelledError) {
        state = state.copyWith(
          isPurchasing: false,
          error: 'purchase_cancelled',
        );
        return;
      }
      state = state.copyWith(
        isPurchasing: false,
        error: userFacingError(e),
      );
    } catch (e) {
      state = state.copyWith(
        isPurchasing: false,
        error: userFacingError(e),
      );
    }
  }
}

final subscriptionNotifierProvider =
    NotifierProvider<SubscriptionNotifier, SubscriptionState>(
  SubscriptionNotifier.new,
);
