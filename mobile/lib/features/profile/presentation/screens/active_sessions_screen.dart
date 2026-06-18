import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/theme/dashboard_screen_style.dart';
import '../../../../shared/widgets/async_error_widget.dart';
import '../../../../shared/widgets/dashboard_secondary_scaffold.dart';
import '../../../../shared/widgets/premium_bottom_sheet.dart';
import '../../../../shared/widgets/toast_overlay.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/sessions_notifier.dart';
import '../theme/profile_settings_ui.dart';
import '../widgets/session_list_tile.dart';

class ActiveSessionsScreen extends ConsumerStatefulWidget {
  const ActiveSessionsScreen({super.key});

  @override
  ConsumerState<ActiveSessionsScreen> createState() =>
      _ActiveSessionsScreenState();
}

class _ActiveSessionsScreenState extends ConsumerState<ActiveSessionsScreen> {
  String? _revokingSessionId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sessionsNotifierProvider.notifier).loadSessions();
    });
  }

  Future<bool?> _showConfirmSheet({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    final t = context.t;
    return PremiumBottomSheetScaffold.show<bool>(
      context: context,
      builder: (sheetContext) => PremiumBottomSheetScaffold(
        scrollable: false,
        header: _SessionsConfirmHeader(
          icon: icon,
          iconColor: iconColor,
          title: title,
          subtitle: subtitle,
        ),
        body: const SizedBox.shrink(),
        actions: PremiumSheetActions(
          primaryLabel: t.common.confirm,
          onPrimary: () => Navigator.pop(sheetContext, true),
          secondaryLabel: t.common.cancelBtn,
          onSecondary: () => Navigator.pop(sheetContext, false),
        ),
      ),
    );
  }

  Future<void> _confirmRemoveSession(String sessionId) async {
    final t = context.t;
    final confirmed = await _showConfirmSheet(
      icon: Icons.logout_rounded,
      iconColor: ProfileSettingsUi.danger,
      title: t.common.removeSession,
      subtitle: t.common.removeSessionConfirm,
    );
    if (confirmed != true || !mounted) return;

    setState(() => _revokingSessionId = sessionId);
    final ok = await ref
        .read(sessionsNotifierProvider.notifier)
        .revokeSession(sessionId);
    if (!mounted) return;
    setState(() => _revokingSessionId = null);

    ref.read(toastProvider.notifier).show(
          ok
              ? t.common.sessionRemoved
              : ref.read(sessionsNotifierProvider).error!,
          type: ok ? ToastType.success : ToastType.error,
        );
  }

  Future<void> _confirmRevokeAllOthers() async {
    final t = context.t;
    final confirmed = await _showConfirmSheet(
      icon: Icons.phonelink_erase_rounded,
      iconColor: ProfileSettingsUi.danger,
      title: t.common.removeAllOtherSessions,
      subtitle: t.common.removeAllOtherSessionsConfirm,
    );
    if (confirmed != true || !mounted) return;

    await ref.read(authStateProvider.notifier).logoutAllDevices(ref);
    if (!mounted) return;

    final authState = ref.read(authStateProvider);
    final hasError = authState.error != null;
    ref.read(toastProvider.notifier).show(
          hasError ? authState.error! : t.common.logoutAllDevicesSuccess,
          type: hasError ? ToastType.error : ToastType.success,
        );

    if (!hasError) {
      await ref.read(sessionsNotifierProvider.notifier).loadSessions();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final state = ref.watch(sessionsNotifierProvider);
    final otherCount = state.otherSessions.length;
    final authLoading = ref.watch(authStateProvider).isLoading;
    final showBottomAction = otherCount > 0;

    return DashboardSecondaryScaffold(
      title: t.common.logoutAllDevices,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _buildBody(context, state, showBottomAction),
          ),
          if (showBottomAction)
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.dashboardScreenPaddingHorizontal,
                  0,
                  AppSizes.dashboardScreenPaddingHorizontal,
                  AppSizes.spacingM,
                ),
                child: OutlinedButton(
                  onPressed: authLoading || state.isRevoking
                      ? null
                      : _confirmRevokeAllOthers,
                  style: ProfileSettingsUi.dangerOutlinedButton,
                  child: authLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(t.common.removeAllOtherSessions),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    SessionsState state,
    bool showBottomAction,
  ) {
    final t = context.t;

    if (state.isLoading && state.sessions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.sessions.isEmpty) {
      return AsyncErrorWidget(
        message: state.error!,
        onRetry: () =>
            ref.read(sessionsNotifierProvider.notifier).loadSessions(),
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(sessionsNotifierProvider.notifier).loadSessions(),
      child: ListView.separated(
        padding: EdgeInsets.fromLTRB(
          AppSizes.dashboardScreenPaddingHorizontal,
          AppSizes.spacingM,
          AppSizes.dashboardScreenPaddingHorizontal,
          showBottomAction ? AppSizes.spacingL : AppSizes.spacingXL,
        ),
        itemCount: state.sessions.isEmpty ? 2 : state.sessions.length + 1,
        separatorBuilder: (context, index) {
          if (index == 0) return const SizedBox(height: AppSizes.spacingM);
          return const SizedBox(height: AppSizes.spacingM);
        },
        itemBuilder: (context, index) {
          if (index == 0) {
            return _SessionsInfoCard(message: t.common.sessionsScreenHint);
          }

          if (state.sessions.isEmpty) {
            return _SessionsEmptyCard(message: t.common.noOtherSessions);
          }

          final session = state.sessions[index - 1];
          return SessionListTile(
            session: session,
            isRemoving: _revokingSessionId == session.id,
            onRemove: session.isCurrent
                ? null
                : () => _confirmRemoveSession(session.id),
          );
        },
      ),
    );
  }
}

class _SessionsInfoCard extends StatelessWidget {
  const _SessionsInfoCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.spacingM),
      decoration: DashboardScreenStyle.whiteCard(
        color: AppColors.primary.withValues(alpha: 0.04),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.devices_rounded,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: AppSizes.spacingS),
          Expanded(
            child: Text(
              message,
              style: ProfileSettingsUi.handle.copyWith(
                color: AppColors.inkDark,
                height: 1.45,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionsEmptyCard extends StatelessWidget {
  const _SessionsEmptyCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spacingL,
        vertical: AppSizes.spacingXL,
      ),
      decoration: DashboardScreenStyle.whiteCard(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.fill,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.verified_user_outlined,
              color: AppColors.primary,
              size: 30,
            ),
          ),
          const SizedBox(height: AppSizes.spacingM),
          Text(
            message,
            style: ProfileSettingsUi.handle.copyWith(
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SessionsConfirmHeader extends StatelessWidget {
  const _SessionsConfirmHeader({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.spacingL,
        AppSizes.spacingM,
        AppSizes.spacingL,
        AppSizes.spacingS,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: ProfileSettingsUi.title),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: ProfileSettingsUi.handle.copyWith(fontSize: 13),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
