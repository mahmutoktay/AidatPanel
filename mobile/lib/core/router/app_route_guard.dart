import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/domain/entities/user_entity.dart' show UserRole;
import '../../features/auth/presentation/providers/auth_provider.dart';

class AppRouteGuard {
  static String? handleRedirect(GoRouterState state, Ref ref) {
    final authState = ref.read(authStateProvider);
    final loc = state.matchedLocation;
    final path = state.uri.path;

    final isAuthRoute =
        loc == '/login' ||
        loc == '/sign-up' ||
        loc == '/register' ||
        loc == '/join' ||
        loc == '/forgot-password' ||
        loc == '/reset-password' ||
        loc == '/';

    if (!authState.isAuthenticated && !isAuthRoute) {
      return '/login';
    }

    if (authState.isAuthenticated &&
        authState.user != null &&
        isAuthRoute &&
        loc != '/') {
      return authState.user!.role == UserRole.manager
          ? '/manager-dashboard'
          : '/resident-dashboard';
    }

    if (loc == '/tickets/new') {
      return '/tickets/create';
    }

    if (authState.isAuthenticated &&
        loc == '/tickets/create' &&
        authState.user?.role == UserRole.manager) {
      return '/manager-dashboard';
    }

    if (authState.isAuthenticated &&
        authState.user?.role == UserRole.manager &&
        (path == '/payment' || path == '/dekonts')) {
      return '/manager-dashboard';
    }

    if (authState.isAuthenticated &&
        authState.user?.role == UserRole.resident &&
        path == '/manager/dekonts') {
      return '/resident-dashboard';
    }

    // Eski URL uyumu → dashboard alt route'ları (root navigator).
    if (path == '/manager/tickets') return '/manager-dashboard/tickets';
    if (path == '/manager/expenses') return '/manager-dashboard/expenses';
    if (path == '/manager/dekonts') return '/manager-dashboard/dekonts';
    if (path == '/notifications') {
      if (authState.user?.role == UserRole.manager) {
        return '/manager-dashboard/notifications';
      }
      if (authState.user?.role == UserRole.resident) {
        return '/resident-dashboard/notifications';
      }
    }
    if (path == '/payment') return '/resident-dashboard/payment';
    if (path == '/dekonts' && authState.user?.role == UserRole.resident) {
      return '/resident-dashboard/dekonts';
    }
    if (path == '/manager/saved-ibans') {
      return '/manager-dashboard/saved-ibans';
    }

    return null;
  }
}
