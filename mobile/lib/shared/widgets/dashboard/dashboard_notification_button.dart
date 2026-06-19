import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/theme_mode_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_sizes.dart';
import '../../theme/dashboard_screen_style.dart';
import '../notification_icon_button.dart';

/// Dairesel beyaz zemin üzerinde bildirim zili — dashboard üst şerit.
class DashboardNotificationButton extends ConsumerWidget {
  const DashboardNotificationButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeModeProvider);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => openNotificationList(context, ref),
        customBorder: const CircleBorder(),
        child: Container(
          width: AppSizes.minTouchTarget,
          height: AppSizes.minTouchTarget,
          decoration: BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
            boxShadow: DashboardScreenStyle.cardShadow,
          ),
          alignment: Alignment.center,
          child: const NotificationIconBody(
            size: 24,
            badgeOffset: Offset(5, -5),
          ),
        ),
      ),
    );
  }
}
