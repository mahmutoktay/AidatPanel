import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/theme/app_typography.dart';
import '../../core/notifications/notification_toast.dart';
import '../../features/notifications/presentation/providers/notifications_provider.dart';
import '../../l10n/strings.g.dart';

/// AppBar sağ üst — çan ikonu + okunmamış sayı (sağ üst köşe rozeti).
class NotificationIconButton extends ConsumerWidget {
  const NotificationIconButton({super.key});

  Future<void> _openNotifications(BuildContext context, WidgetRef ref) async {
    await ref.read(notificationsNotifierProvider.notifier).load(refresh: true);
    if (!context.mounted) return;
    await context.push('/notifications');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(notificationsNotifierProvider).unreadCount;
    final showBadge = unread > 0;
    final badgeLabel = unread > 99 ? '99+' : unread.toString();

    return Padding(
      padding: const EdgeInsets.only(right: AppSizes.spacingXS),
      child: Badge(
        isLabelVisible: showBadge,
        label: Text(
          badgeLabel,
          style: AppTypography.caption.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 10,
            height: 1,
          ),
        ),
        backgroundColor: AppColors.error,
        offset: const Offset(4, -4),
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        child: IconButton(
          tooltip: context.t.common.notifications,
          onPressed: () => _openNotifications(context, ref),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(
            minWidth: AppSizes.minTouchTarget,
            minHeight: AppSizes.minTouchTarget,
          ),
          icon: const Icon(
            Icons.notifications_outlined,
            color: AppColors.textPrimary,
            size: 26,
          ),
        ),
      ),
    );
  }
}

/// Dashboard üst şerit — büyük rol başlığı + bildirim (mockup ölçüsü).
class DashboardRoleBar extends StatelessWidget {
  final String title;

  const DashboardRoleBar({super.key, required this.title});

  /// Rol başlığı — Archivo Black: geniş, kare hatlı, kalın manşet stili.
  /// `archivoBlack` tek bir 900-ağırlık varyantta gelir.
  static TextStyle get _titleStyle => GoogleFonts.archivoBlack(
    fontSize: 38,
    height: 1.0,
    letterSpacing: 2.0,
    color: AppColors.textPrimary,
  );

  @override
  Widget build(BuildContext context) {
    const barHeight = AppSizes.minTouchTarget;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.screenPadding,
          AppSizes.spacingM,
          0,
          AppSizes.spacingS,
        ),
        child: SizedBox(
          height: barHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    title,
                    style: _titleStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textHeightBehavior: const TextHeightBehavior(
                      applyHeightToFirstAscent: false,
                      applyHeightToLastDescent: false,
                    ),
                  ),
                ),
              ),
              const NotificationIconButton(),
            ],
          ),
        ),
      ),
    );
  }
}

/// Ana sayfa — hoş geldiniz satırı (rol başlığının hemen altında).
class DashboardWelcomeLine extends StatelessWidget {
  final String userName;

  const DashboardWelcomeLine({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '${context.t.common.welcome}, ',
            style: AppTypography.body1.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          TextSpan(
            text: userName,
            style: AppTypography.h4.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// Rozet + varsa yeni bildirim toast'u (sekme değişimi / yenileme).
void prefetchNotifications(WidgetRef ref) {
  unawaited(pollAndShowNotificationToasts(ref));
}
