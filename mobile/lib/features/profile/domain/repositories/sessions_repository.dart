import '../../domain/entities/session_entity.dart';

abstract class SessionsRepository {
  Future<List<SessionEntity>> getSessions();

  Future<void> revokeSession(String sessionId);
}
