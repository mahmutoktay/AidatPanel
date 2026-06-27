import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/theme/app_typography.dart';

/// Çoklu seçim aksiyon FAB'ı — sağ-alt, köşeden içeride.
const selectionActionFabLocation = _SelectionActionFabLocation();

class _SelectionActionFabLocation extends FloatingActionButtonLocation {
  const _SelectionActionFabLocation();

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    const inset = AppSizes.spacingM;
    final fabSize = scaffoldGeometry.floatingActionButtonSize;
    final scaffoldSize = scaffoldGeometry.scaffoldSize;
    final bottomInset = scaffoldGeometry.minInsets.bottom;

    return Offset(
      scaffoldSize.width - fabSize.width - inset,
      scaffoldSize.height - fabSize.height - bottomInset - inset,
    );
  }
}

/// Seçim modunda sağ-altta görünen extended FAB (Sil / Çıkar).
class SelectionActionFab extends StatelessWidget {
  final VoidCallback onPressed;
  final Color backgroundColor;
  final IconData icon;
  final String label;

  const SelectionActionFab({
    super.key,
    required this.onPressed,
    required this.backgroundColor,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onPressed,
      backgroundColor: backgroundColor,
      foregroundColor: backgroundColor == AppColors.actionButton
          ? AppColors.actionButtonForeground
          : Colors.white,
      elevation: 0,
      highlightElevation: 0,
      icon: Icon(icon),
      label: Text(
        label,
        style: AppTypography.button.copyWith(fontWeight: FontWeight.w800),
      ),
    );
  }
}

/// Liste başlığının yanına oturan kompakt "Seç" tetikleyici.
///
/// Eski büyük outline butonun yerini alır. Sade text-butonu hissini
/// koruyarak yine 48dp dokunma alanını sağlar.
class SelectionTriggerButton extends StatelessWidget {
  final VoidCallback onTap;
  final String label;
  final IconData icon;

  const SelectionTriggerButton({
    super.key,
    required this.onTap,
    required this.label,
    this.icon = Icons.checklist_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
        child: Container(
          constraints: const BoxConstraints(minHeight: AppSizes.minTouchTarget),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.spacingS,
            vertical: 6,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTypography.body2.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Çoklu seçim sırasında AppBar'ın altında ince bir bilgi şeridi.
///
/// "Silmek istediğiniz öğeleri seçin" gibi tek satırlık yumuşak bir hint
/// gösterir. Renk tonu hafif primary tonludur; ekran ana içeriğinden
/// belirgin biçimde ayrılır ama dikkati dağıtmaz.
class SelectionHintBanner extends StatelessWidget {
  final String message;
  final IconData icon;

  const SelectionHintBanner({
    super.key,
    required this.message,
    this.icon = Icons.touch_app_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spacingM,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        border: Border(
          bottom: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.12),
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: AppTypography.caption.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
