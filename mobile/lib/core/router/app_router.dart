import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../main.dart' show MyApp;
import 'app_route_guard.dart';
import '../../features/auth/domain/entities/user_entity.dart' show UserRole;
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/reset_password_screen.dart';
import '../../features/auth/presentation/screens/sign_up_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/dashboard/presentation/screens/manager_dashboard_screen.dart';
import '../../features/dashboard/presentation/screens/manager_overdue_apartments_screen.dart';
import '../../features/dashboard/presentation/screens/resident_dashboard_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/tickets/presentation/screens/create_ticket_screen.dart';
import '../../features/tickets/presentation/screens/manager_tickets_screen.dart';
import '../../features/tickets/presentation/screens/ticket_detail_screen.dart';
import '../../features/expenses/presentation/screens/expense_form_screen.dart';
import '../../features/expenses/presentation/screens/manager_expenses_screen.dart';
import '../../features/expenses/domain/entities/expense_entity.dart';
import '../../features/expenses/presentation/screens/expense_detail_screen.dart';
import '../../features/dekont/presentation/screens/dekont_detail_screen.dart';
import '../../features/dekont/presentation/screens/make_payment_screen.dart';
import '../../features/dekont/presentation/screens/manager_dekonts_screen.dart';
import '../../features/dekont/presentation/screens/my_dekonts_screen.dart';
import '../../features/buildings/presentation/screens/saved_ibans_screen.dart';
import '../../features/buildings/presentation/screens/add_building_screen.dart';
import '../../features/buildings/presentation/screens/building_residents_screen.dart';
import '../../features/buildings/presentation/screens/invite_code_screen.dart';
import '../../features/buildings/data/buildings_store.dart';
import '../../features/buildings/domain/entities/building_entity.dart';
import '../../features/profile/presentation/screens/profile_details_screen.dart';
import '../../features/profile/presentation/screens/active_sessions_screen.dart';
import '../../features/subscription/presentation/screens/subscription_screen.dart';
import '../../features/subscription/presentation/providers/subscription_provider.dart';
import '../../features/sites/presentation/screens/add_site_screen.dart';
import '../../features/sites/presentation/screens/site_detail_screen.dart';
import '../../features/sites/presentation/screens/add_site_building_screen.dart';
import '../../features/sites/presentation/screens/site_expenses_screen.dart';
import '../../features/reports/presentation/screens/site_report_screen.dart';
import '../../features/reports/domain/entities/report_entity.dart';
import '../../features/profile/presentation/screens/legal_document_screen.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/utils/user_error_message.dart';
import '../../l10n/strings.g.dart';
import '../../shared/widgets/empty_state_widget.dart';
import '../../shared/widgets/toast_overlay.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

/// Tam ekran alt sayfalar root navigator'da açılır (dashboard iç navigator'ına sıkışmaz).
List<RouteBase> _managerDashboardChildRoutes(Ref ref) => [
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
    path: 'expenses/form',
    name: 'manager_expense_form',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) {
      final buildingId = state.uri.queryParameters['buildingId'] ?? '';
      final expense = state.extra as ExpenseEntity?;
      return ExpenseFormScreen(buildingId: buildingId, expense: expense);
    },
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
    path: 'add-building',
    name: 'manager_add_building',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) => const AddBuildingScreen(),
  ),
  GoRoute(
    path: 'add-site',
    name: 'manager_add_site',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) => const AddSiteScreen(),
  ),
  GoRoute(
    path: 'sites/:siteId',
    name: 'manager_site_detail',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) => SiteDetailScreen(
      siteId: state.pathParameters['siteId']!,
    ),
  ),
  GoRoute(
    path: 'sites/:siteId/add-building',
    name: 'manager_add_site_building',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) => AddSiteBuildingScreen(
      siteId: state.pathParameters['siteId']!,
    ),
  ),
  GoRoute(
    path: 'sites/:siteId/expenses',
    name: 'manager_site_expenses',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) => SiteExpensesScreen(
      siteId: state.pathParameters['siteId']!,
    ),
  ),
  GoRoute(
    path: 'sites/:siteId/report',
    name: 'manager_site_report',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) {
      final typeParam = state.uri.queryParameters['type'] ?? 'monthly';
      final type = typeParam == 'annual'
          ? ReportType.annual
          : ReportType.monthly;
      return SiteReportScreen(
        siteId: state.pathParameters['siteId']!,
        siteName: state.uri.queryParameters['name'] ?? '',
        type: type,
      );
    },
  ),
  GoRoute(
    path: 'invite-code',
    name: 'manager_invite_code',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) => const InviteCodeScreen(),
  ),
  GoRoute(
    path: 'buildings/:buildingId',
    name: 'manager_building_residents',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) => _BuildingResidentsRoute(
      buildingId: state.pathParameters['buildingId']!,
    ),
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
  GoRoute(
    path: 'profile/sessions',
    name: 'manager_profile_sessions',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) => const ActiveSessionsScreen(),
  ),
  GoRoute(
    path: 'overdue-apartments',
    name: 'manager_overdue_apartments',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) => ManagerOverdueApartmentsScreen(
      initialBuildingId: state.uri.queryParameters['buildingId'],
    ),
  ),
  GoRoute(
    path: 'subscription',
    name: 'manager_subscription',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) => SubscriptionScreen(
      onBuyMonthly: () {
        ref.read(subscriptionNotifierProvider.notifier).purchaseMonthly();
      },
      onBuyYearly: () {
        ref.read(subscriptionNotifierProvider.notifier).purchaseAnnual();
      },
    ),
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
  GoRoute(
    path: 'profile/sessions',
    name: 'resident_profile_sessions',
    parentNavigatorKey: rootNavigatorKey,
    builder: (context, state) => const ActiveSessionsScreen(),
  ),
];

/// Auth state değişince [GoRouter] redirect’inin yeniden çalışması için gerekli.
final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshListenable = ValueNotifier<int>(0);
  ref.listen<AuthState>(authStateProvider, (previous, next) {
    // Oturum sonlanınca toast bildirimi göster.
    // Normal logout → başarı mesajı, başka cihazdan çıkış / refresh başarısız → sessionExpired mesajı.
    if (previous?.isAuthenticated == true && !next.isAuthenticated) {
      if (next.showLogoutToast) {
        // GoRouter henüz yönlendirme yapmadı; toast'ı gecikmeli göster.
        Future.microtask(() {
          final message = next.isManualLogout
              ? t.common.logoutSuccess
              : t.common.sessionExpired;
          final type = next.isManualLogout ? ToastType.success : ToastType.error;
          ref
              .read(toastProvider.notifier)
              .show(message, type: type, duration: const Duration(seconds: 5));
        });
      }

      // Widget tree'yi komple yeniden başlatarak State Leak'i %100 engelle.
      // GoRouter, FcmScope, tüm provider listener'ları sıfırdan yaratılır.
      Future.microtask(() {
        final ctx = rootNavigatorKey.currentContext;
        if (ctx != null && ctx.mounted) {
          MyApp.restartApp(ctx);
        }
      });
    }
    refreshListenable.value++;
  });
  ref.onDispose(refreshListenable.dispose);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    refreshListenable: refreshListenable,
    initialLocation: '/',
    observers: [FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance)],
    redirect: (context, state) => AppRouteGuard.handleRedirect(state, ref),
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
        path: '/legal/privacy',
        name: 'legal_privacy',
        builder: (context, state) =>
            const LegalDocumentScreen(kind: LegalDocumentKind.privacy),
      ),
      GoRoute(
        path: '/legal/kvkk',
        name: 'legal_kvkk',
        builder: (context, state) =>
            const LegalDocumentScreen(kind: LegalDocumentKind.kvkk),
      ),
      GoRoute(
        path: '/legal/help',
        name: 'legal_help',
        builder: (context, state) =>
            const LegalDocumentScreen(kind: LegalDocumentKind.help),
      ),
      GoRoute(
        path: '/manager-dashboard',
        name: 'manager_dashboard',
        builder: (context, state) {
          return const ManagerDashboardScreen();
        },
        routes: _managerDashboardChildRoutes(ref),
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
        path: '/expenses/:expenseId',
        name: 'expense_detail',
        builder: (context, state) {
          final id = state.pathParameters['expenseId']!;
          final expense = state.extra as ExpenseEntity?;
          return ExpenseDetailScreen(expenseId: id, initialExpense: expense);
        },
      ),
      GoRoute(
        path: '/manager/saved-ibans',
        redirect: (context, state) => '/manager-dashboard/saved-ibans',
      ),
    ],
  );
});

class _BuildingResidentsRoute extends ConsumerWidget {
  const _BuildingResidentsRoute({required this.buildingId});

  final String buildingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final buildingsAsync = ref.watch(buildingsStoreProvider);
    return buildingsAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, _) => _BuildingResidentsFallbackScreen(
        message: userFacingError(err),
        onRetry: () =>
            ref.read(buildingsStoreProvider.notifier).loadBuildings(),
      ),
      data: (buildings) {
        BuildingEntity? building;
        for (final item in buildings) {
          if (item.id == buildingId) {
            building = item;
            break;
          }
        }
        if (building == null) {
          return _BuildingResidentsFallbackScreen(
            message: context.t.common.noResults,
            onRetry: () =>
                ref.read(buildingsStoreProvider.notifier).loadBuildings(),
          );
        }
        return BuildingResidentsScreen(building: building);
      },
    );
  }
}

/// Bina listesi yüklenemediğinde veya bina kaydı listede yokken boş ekran yerine.
class _BuildingResidentsFallbackScreen extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _BuildingResidentsFallbackScreen({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dashboardBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: Text(context.t.common.buildingDetail),
      ),
      body: SafeArea(
        child: Padding(
          padding: AppSizes.screenBodyScrollPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Center(
                  child: EmptyStateWidget(
                    icon: Icons.error_outline,
                    title: context.t.common.loadFailed,
                    subtitle: message,
                  ),
                ),
              ),
              SizedBox(
                height: AppSizes.buttonHeightPrimary,
                child: ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh, size: 22),
                  label: Text(context.t.common.tryAgain),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
