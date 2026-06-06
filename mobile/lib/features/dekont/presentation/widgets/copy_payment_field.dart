import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/iban_utils.dart';
import '../../../../l10n/strings.g.dart';

class CopyPaymentField extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final t = context.t.features.dekont;
    final display = value?.trim().isNotEmpty == true ? value!.trim() : '—';
    final copyValue = value?.trim().isNotEmpty == true
        ? (monospace ? IbanUtils.normalize(value!) : value!.trim())
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.spacingM),
      padding: const EdgeInsets.all(AppSizes.spacingM),
      decoration: BoxDecoration(
        color: AppColors.fill,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSizes.spacingXS),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  monospace && copyValue != null
                      ? IbanUtils.formatDisplay(copyValue)
                      : display,
                  style: AppTypography.body1.copyWith(
                    fontWeight: FontWeight.w600,
                    fontFeatures: monospace
                        ? const [FontFeature.tabularFigures()]
                        : null,
                  ),
                ),
              ),
              if (copyValue != null)
                SizedBox(
                  width: AppSizes.minTouchTarget,
                  height: AppSizes.minTouchTarget,
                  child: IconButton(
                    tooltip: t.copy,
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: copyValue));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(t.copied)),
                      );
                    },
                    icon: const Icon(Icons.copy_outlined),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
