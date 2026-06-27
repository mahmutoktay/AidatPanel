import '../../../../core/network/api_exception.dart';
import '../../domain/entities/apartment_entity.dart';
import '../datasources/apartment_remote_datasource.dart';
import 'apartment_repository.dart';

class ApartmentRepositoryImpl implements ApartmentRepository {
  final ApartmentRemoteDataSource _remoteDataSource;

  ApartmentRepositoryImpl({required ApartmentRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  @override
  Future<List<ApartmentEntity>> fetchApartments(String buildingId) async {
    try {
      final models = await _remoteDataSource.fetchApartments(buildingId);
      return models.map((m) => m.toEntity()).toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'apartments_fetch_failed');
    }
  }

  @override
  Future<ApartmentEntity> createApartment({
    required String buildingId,
    required String number,
    int? floor,
  }) async {
    try {
      final model = await _remoteDataSource.createApartment(
        buildingId: buildingId,
        number: number,
        floor: floor,
      );
      return model.toEntity();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'apartment_create_failed');
    }
  }

  @override
  Future<ApartmentEntity> updateApartment({
    required String buildingId,
    required String id,
    String? number,
    int? floor,
  }) async {
    try {
      final model = await _remoteDataSource.updateApartment(
        buildingId: buildingId,
        id: id,
        number: number,
        floor: floor,
      );
      return model.toEntity();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'apartment_update_failed');
    }
  }

  @override
  Future<void> deleteApartment({
    required String buildingId,
    required String id,
  }) async {
    try {
      await _remoteDataSource.deleteApartment(buildingId: buildingId, id: id);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'apartment_delete_failed');
    }
  }

  @override
  Future<ApartmentEntity> removeResident({
    required String buildingId,
    required String apartmentId,
  }) async {
    try {
      final model = await _remoteDataSource.removeResident(
        buildingId: buildingId,
        apartmentId: apartmentId,
      );
      return model.toEntity();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'resident_remove_failed');
    }
  }
}
