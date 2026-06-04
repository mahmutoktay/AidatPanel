import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

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
  final SubscriptionEntity? subscription;
  final bool backendUnavailable;
  final String? error;

  const SubscriptionState({
    this.isLoading = false,
    this.subscription,
    this.backendUnavailable = false,
    this.error,
  });

  SubscriptionState copyWith({
    bool? isLoading,
    SubscriptionEntity? subscription,
    bool? backendUnavailable,
    String? error,
    bool clearSubscription = false,
    bool clearError = false,
  }) {
    return SubscriptionState(
      isLoading: isLoading ?? this.isLoading,
      subscription:
          clearSubscription ? null : (subscription ?? this.subscription),
      backendUnavailable: backendUnavailable ?? this.backendUnavailable,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class SubscriptionNotifier extends StateNotifier<SubscriptionState> {
  SubscriptionNotifier(this._repository) : super(const SubscriptionState());

  final SubscriptionRepository _repository;

  Future<void> load() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final sub = await _repository.getMySubscription();
      state = state.copyWith(
        isLoading: false,
        subscription: sub,
        backendUnavailable: sub == null,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: userFacingError(e),
        backendUnavailable: true,
      );
    }
  }
}

final subscriptionNotifierProvider =
    StateNotifierProvider<SubscriptionNotifier, SubscriptionState>((ref) {
  return SubscriptionNotifier(ref.watch(subscriptionRepositoryProvider));
});
