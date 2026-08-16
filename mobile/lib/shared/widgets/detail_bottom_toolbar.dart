import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Detay ekranı alt araç çubuğu aksiyonu.
class DetailToolbarAction {
  const DetailToolbarAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
    this.showDividerBefore = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  /// Mod değiştiren aksiyonları (ör. çoklu seç) diğerlerinden ayırmak için.
  final bool showDividerBefore;
}

/// Bina / site / daire detay alt araç çubuğu — ortak görünüm.
class DetailBottomToolbar extends StatelessWidget {
  const DetailBottomToolbar({
    super.key,
    required this.actions,
  });

  final List<DetailToolbarAction> actions;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 0,
      color: AppColors.surface,
      child: SafeArea(
        top: false,
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: AppColors.borderColor.withValues(alpha: 0.35),
              ),
            ),
          ),
          child: Row(
            children: [
              for (final action in actions) ...[
                if (action.showDividerBefore) const _ToolbarDivider(),
                _ToolbarActionButton(action: action),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ToolbarDivider extends StatelessWidget {
  const _ToolbarDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: SizedBox(
        width: 1,
        child: ColoredBox(
          color: AppColors.borderColor.withValues(alpha: 0.45),
        ),
      ),
    );
  }
}

class _ToolbarActionButton extends StatelessWidget {
  const _ToolbarActionButton({required this.action});

  final DetailToolbarAction action;

  @override
  Widget build(BuildContext context) {
    final actionColor = action.color ?? AppColors.inkDark;

    return Expanded(
      child: InkWell(
        onTap: action.onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(action.icon, size: 22, color: actionColor),
            const SizedBox(height: 4),
            Text(
              action.label,
              style: AppTypography.caption.copyWith(
                color: actionColor,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
