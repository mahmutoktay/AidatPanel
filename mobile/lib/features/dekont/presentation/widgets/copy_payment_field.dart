import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/iban_utils.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/theme/dashboard_screen_style.dart';
import '../../../../shared/widgets/toast_overlay.dart';

class CopyPaymentField extends ConsumerWidget {
  final String label;
  final String? value;
  final bool monospace;

  const CopyPaymentField({
    super.key,
    required this.label,
    required this.value,
    this.monospace = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t.features.dekont;
    final display = value?.trim().isNotEmpty == true ? value!.trim() : '—';
    final copyValue = value?.trim().isNotEmpty == true
        ? (monospace ? IbanUtils.normalize(value!) : value!.trim())
        : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.spacingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        boxShadow: DashboardScreenStyle.cardShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSizes.spacingXS),
                Text(
                  monospace && copyValue != null
                      ? IbanUtils.formatDisplay(copyValue)
                      : display,
                  style: AppTypography.body2.copyWith(
                    color: AppColors.textPrimary,
                    fontFeatures: monospace
                        ? const [FontFeature.tabularFigures()]
                        : null,
                  ),
                ),
              ],
            ),
          ),
          if (copyValue != null) ...[
            const SizedBox(width: AppSizes.spacingS),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: copyValue));
                  ref.read(toastProvider.notifier).show(
                        t.copied,
                        type: ToastType.success,
                      );
                },
                borderRadius:
                    BorderRadius.circular(DashboardScreenStyle.iconBoxRadius),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.fill,
                    borderRadius: BorderRadius.circular(
                      DashboardScreenStyle.iconBoxRadius,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.copy_outlined,
                    color: AppColors.textPrimary,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
