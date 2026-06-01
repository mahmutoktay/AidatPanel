import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/domain/entities/user_entity.dart' show UserRole;
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/reset_password_screen.dart';
import '../../features/auth/presentation/screens/sign_up_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/dashboard/presentation/screens/manager_dashboard_screen.dart';
import '../../features/dashboard/presentation/screens/resident_dashboard_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/tickets/presentation/screens/create_ticket_screen.dart';
import '../../features/tickets/presentation/screens/manager_tickets_screen.dart';
import '../../features/tickets/presentation/screens/ticket_detail_screen.dart';
import '../../features/expenses/presentation/screens/manager_expenses_screen.dart';
import '../../features/dekont/presentation/screens/dekont_detail_screen.dart';
import '../../features/dekont/presentation/screens/make_payment_screen.dart';
import '../../features/dekont/presentation/screens/manager_dekonts_screen.dart';
import '../../features/dekont/presentation/screens/my_dekonts_screen.dart';
import '../../features/buildings/presentation/screens/saved_ibans_screen.dart';
import '../../features/profile/presentation/screens/profile_details_screen.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

/// Tam ekran alt sayfalar root navigator'da açılır (dashboard iç navigator'ına sıkışmaz).
List<RouteBase> _managerDashboardChildRoutes() => [
  GoRoute(
    path: 'tickets',
    name: 'manager_dashboard_tickets',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) => const ManagerTicketsScreen(),
  ),
  GoRoute(
    path: 'expenses',
    name: 'manager_dashboard_expenses',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) => const ManagerExpensesScreen(),
  ),
  GoRoute(
    path: 'dekonts',
    name: 'manager_dashboard_dekonts',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) => const ManagerDekontsScreen(),
  ),
  GoRoute(
    path: 'notifications',
    name: 'manager_dashboard_notifications',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) => const NotificationsScreen(),
  ),
  GoRoute(
    path: 'saved-ibans',
    name: 'manager_saved_ibans',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) => const SavedIbansScreen(),
  ),
  GoRoute(
    path: 'profile',
    name: 'manager_profile',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) => const ProfileDetailsScreen(),
  ),
];

List<RouteBase> _residentDashboardChildRoutes() => [
  GoRoute(
    path: 'payment',
    name: 'resident_dashboard_payment',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) {
      final dueId = state.uri.queryParameters['dueId'];
      return MakePaymentScreen(preselectedDueId: dueId);
    },
  ),
  GoRoute(
    path: 'dekonts',
    name: 'resident_dashboard_dekonts',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) => const MyDekontsScreen(),
  ),
  GoRoute(
    path: 'notifications',
    name: 'resident_dashboard_notifications',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) => const NotificationsScreen(),
  ),
  GoRoute(
    path: 'profile',
    name: 'resident_profile',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) => const ProfileDetailsScreen(),
  ),
];

/// Auth state değişince [GoRouter] redirect’inin yeniden çalışması için gerekli.
final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshListenable = ValueNotifier<int>(0);
  ref.listen<AuthState>(authStateProvider, (previous, next) {
    refreshListenable.value++;
  });
  ref.onDispose(refreshListenable.dispose);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    refreshListenable: refreshListenable,
    initialLocation: '/',
    redirect: (context, state) {
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
    },
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        pageBuilder: (context, state) {
          return CustomTransitionPage<void>(
            key: state.pageKey,
            child: const SplashScreen(),
            transitionDuration: const Duration(milliseconds: 200),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  final tween = Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).chain(CurveTween(curve: Curves.easeOutCubic));
                  return SlideTransition(
                    position: animation.drive(tween),
                    child: child,
                  );
                },
          );
        },
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) {
          return const LoginScreen();
        },
      ),
      GoRoute(
        path: '/sign-up',
        name: 'sign_up',
        builder: (context, state) {
          final role = state.uri.queryParameters['role'];
          return SignUpScreen(initialIsManager: role == 'manager');
        },
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) {
          return const SignUpScreen(initialIsManager: true);
        },
      ),
      GoRoute(
        path: '/join',
        name: 'join',
        builder: (context, state) {
          return const SignUpScreen();
        },
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot_password',
        builder: (context, state) {
          return const ForgotPasswordScreen();
        },
      ),
      GoRoute(
        path: '/reset-password',
        name: 'reset_password',
        builder: (context, state) {
          final email = state.extra is String ? state.extra as String : null;
          return ResetPasswordScreen(prefilledEmail: email);
        },
      ),
      GoRoute(
        path: '/manager-dashboard',
        name: 'manager_dashboard',
        builder: (context, state) {
          return const ManagerDashboardScreen();
        },
        routes: _managerDashboardChildRoutes(),
      ),
      GoRoute(
        path: '/resident-dashboard',
        name: 'resident_dashboard',
        builder: (context, state) {
          return const ResidentDashboardScreen();
        },
        routes: _residentDashboardChildRoutes(),
      ),
      GoRoute(
        path: '/notifications',
        redirect: (context, state) {
          final auth = ref.read(authStateProvider);
          if (auth.user?.role == UserRole.manager) {
            return '/manager-dashboard/notifications';
          }
          if (auth.user?.role == UserRole.resident) {
            return '/resident-dashboard/notifications';
          }
          return '/login';
        },
      ),
      GoRoute(
        path: '/tickets/create',
        name: 'create_ticket',
        builder: (context, state) => const CreateTicketScreen(),
      ),
      GoRoute(
        path: '/tickets/:ticketId',
        name: 'ticket_detail',
        redirect: (context, state) {
          final id = state.pathParameters['ticketId'];
          if (id == 'new' || id == 'create') return '/tickets/create';
          return null;
        },
        builder: (context, state) {
          final id = state.pathParameters['ticketId']!;
          return TicketDetailScreen(ticketId: id);
        },
      ),
      GoRoute(
        path: '/manager/tickets',
        redirect: (context, state) => '/manager-dashboard/tickets',
      ),
      GoRoute(
        path: '/manager/expenses',
        redirect: (context, state) => '/manager-dashboard/expenses',
      ),
      GoRoute(
        path: '/manager/dekonts',
        redirect: (context, state) => '/manager-dashboard/dekonts',
      ),
      GoRoute(
        path: '/payment',
        redirect: (context, state) {
          final auth = ref.read(authStateProvider);
          if (auth.user?.role == UserRole.resident) {
            final q = state.uri.query;
            return '/resident-dashboard/payment${q.isEmpty ? '' : '?$q'}';
          }
          return '/manager-dashboard';
        },
      ),
      GoRoute(
        path: '/dekonts',
        name: 'my_dekonts',
        redirect: (context, state) {
          final auth = ref.read(authStateProvider);
          if (auth.user?.role == UserRole.resident) {
            return '/resident-dashboard/dekonts';
          }
          return '/manager-dashboard';
        },
      ),
      GoRoute(
        path: '/dekonts/:dekontId',
        name: 'dekont_detail',
        builder: (context, state) {
          final id = state.pathParameters['dekontId']!;
          return DekontDetailScreen(dekontId: id);
        },
      ),
      GoRoute(
        path: '/manager/saved-ibans',
        redirect: (context, state) => '/manager-dashboard/saved-ibans',
      ),
    ],
  );
});
