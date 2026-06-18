import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/sessions_remote_datasource.dart';
import '../../domain/repositories/sessions_repository.dart';
import '../../data/repositories/sessions_repository_impl.dart';
import '../../domain/entities/session_entity.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/utils/user_error_message.dart';

final sessionsRemoteDataSourceProvider =
    Provider<SessionsRemoteDataSource>((ref) {
  return SessionsRemoteDataSourceImpl(
    dioClient: ref.watch(dioClientProvider),
  );
});

final sessionsRepositoryProvider = Provider<SessionsRepository>((ref) {
  return SessionsRepositoryImpl(
    remoteDataSource: ref.watch(sessionsRemoteDataSourceProvider),
  );
});

class SessionsState {
  final bool isLoading;
  final bool isRevoking;
  final bool isRevokingAll;
  final List<SessionEntity> sessions;
  final String? error;

  const SessionsState({
    this.isLoading = false,
    this.isRevoking = false,
    this.isRevokingAll = false,
    this.sessions = const [],
    this.error,
  });

  SessionsState copyWith({
    bool? isLoading,
    bool? isRevoking,
    bool? isRevokingAll,
    List<SessionEntity>? sessions,
    String? error,
    bool clearError = false,
  }) {
    return SessionsState(
      isLoading: isLoading ?? this.isLoading,
      isRevoking: isRevoking ?? this.isRevoking,
      isRevokingAll: isRevokingAll ?? this.isRevokingAll,
      sessions: sessions ?? this.sessions,
      error: clearError ? null : (error ?? this.error),
    );
  }

  List<SessionEntity> get otherSessions =>
      sessions.where((session) => !session.isCurrent).toList();
}

class SessionsNotifier extends Notifier<SessionsState> {
  SessionsRepository get _repository => ref.read(sessionsRepositoryProvider);

  @override
  SessionsState build() => const SessionsState();

  Future<void> loadSessions() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final sessions = await _repository.getSessions();
      state = state.copyWith(
        isLoading: false,
        sessions: sessions,
        clearError: true,
      );
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: userFacingError(e),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: userFacingError(e),
      );
    }
  }

  Future<bool> revokeSession(String sessionId) async {
    if (state.isRevoking) return false;
    state = state.copyWith(isRevoking: true, clearError: true);
    try {
      await _repository.revokeSession(sessionId);
      await loadSessions();
      state = state.copyWith(isRevoking: false);
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(
        isRevoking: false,
        error: userFacingError(e),
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isRevoking: false,
        error: userFacingError(e),
      );
      return false;
    }
  }
}

final sessionsNotifierProvider =
    NotifierProvider<SessionsNotifier, SessionsState>(SessionsNotifier.new);
