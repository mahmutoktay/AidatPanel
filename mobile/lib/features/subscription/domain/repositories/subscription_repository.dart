import '../entities/subscription_entity.dart';

abstract class SubscriptionRepository {
  /// `GET /me/subscription` — kayıt yoksa null döner.
  Future<SubscriptionEntity?> getMySubscription();
}
