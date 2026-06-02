import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../models/subscription_model.dart';

abstract class SubscriptionRemoteDataSource {
  Future<SubscriptionModel?> fetchMySubscription();
}

class SubscriptionRemoteDataSourceImpl implements SubscriptionRemoteDataSource {
  final DioClient _dioClient;

  SubscriptionRemoteDataSourceImpl({required DioClient dioClient})
      : _dioClient = dioClient;

  @override
  Future<SubscriptionModel?> fetchMySubscription() async {
    try {
      final response = await _dioClient.get(ApiConstants.subscription);
      final data = response.data['data'];
      if (data == null) return null;
      if (data is Map<String, dynamic>) {
        if (data.isEmpty) return null;
        return SubscriptionModel.fromJson(data);
      }
      return null;
    } on ApiException catch (e) {
      if (e.statusCode == 404 || e.statusCode == 501) return null;
      rethrow;
    }
  }
}
