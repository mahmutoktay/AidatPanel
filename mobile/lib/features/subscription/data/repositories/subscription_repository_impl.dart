import '../../../../core/network/api_exception.dart';
import '../../domain/entities/subscription_entity.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../datasources/subscription_remote_datasource.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final SubscriptionRemoteDataSource _remote;

  SubscriptionRepositoryImpl({required SubscriptionRemoteDataSource remote})
      : _remote = remote;

  @override
  Future<SubscriptionEntity?> getMySubscription() async {
    try {
      final model = await _remote.fetchMySubscription();
      return model?.toEntity();
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(message: 'Abonelik bilgisi alınamadı');
    }
  }
}
