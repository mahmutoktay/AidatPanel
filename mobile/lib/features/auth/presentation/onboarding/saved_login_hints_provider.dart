import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/saved_login_hint.dart';
import '../../domain/entities/user_entity.dart';
import '../providers/auth_provider.dart';

final savedLoginHintsProvider =
    FutureProvider<Map<UserRole, SavedLoginHint?>>((ref) async {
  final repo = ref.watch(authRepositoryProvider);
  final manager = await repo.getSavedLoginHint(UserRole.manager);
  final resident = await repo.getSavedLoginHint(UserRole.resident);
  return {
    UserRole.manager: manager,
    UserRole.resident: resident,
  };
});
