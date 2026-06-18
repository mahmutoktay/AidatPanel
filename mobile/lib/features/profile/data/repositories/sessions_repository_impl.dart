import '../../domain/entities/session_entity.dart';
import '../../domain/repositories/sessions_repository.dart';
import '../datasources/sessions_remote_datasource.dart';

class SessionsRepositoryImpl implements SessionsRepository {
  final SessionsRemoteDataSource _remoteDataSource;

  SessionsRepositoryImpl({required SessionsRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<List<SessionEntity>> getSessions() async {
    final models = await _remoteDataSource.getSessions();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> revokeSession(String sessionId) async {
    await _remoteDataSource.revokeSession(sessionId);
  }
}
