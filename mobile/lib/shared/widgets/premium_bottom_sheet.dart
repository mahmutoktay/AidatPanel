import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/theme/app_typography.dart';
import '../../features/profile/presentation/theme/profile_settings_ui.dart';
import 'minimal_form_widgets.dart';

/// Premium bottom sheet kabuğu — tüm modal sheet'ler için ortak iskelet.
class PremiumBottomSheetScaffold extends StatelessWidget {
  const PremiumBottomSheetScaffold({
    super.key,
    this.title,
    this.titleWidget,
    this.showCloseButton = false,
    this.closeEnabled = true,
    this.onClose,
    this.header,
    this.child,
    this.body,
    this.actions,
    this.maxHeightFactor = 0.92,
    this.backgroundColor = AppColors.sheetBackground,
    this.scrollable = true,
    this.padding = const EdgeInsets.symmetric(horizontal: AppSizes.spacingL),
  }) : assert(
          child != null || body != null,
          'child veya body gerekli',
        );

  final String? title;
  final Widget? titleWidget;
  final bool showCloseButton;
  final bool closeEnabled;
  final VoidCallback? onClose;
  final Widget? header;
  final Widget? child;
  final Widget? body;
  final Widget? actions;
  final double maxHeightFactor;
  final Color backgroundColor;
  final bool scrollable;
  final EdgeInsets padding;

  static const double topRadius = 28;

  static Future<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      builder: (ctx) {
        final bottomInset = MediaQuery.viewInsetsOf(ctx).bottom;
        return Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: builder(ctx),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * maxHeightFactor;
    final content = child ?? body!;

    Widget bodyWidget = content;
    if (scrollable) {
      bodyWidget = SingleChildScrollView(
        padding: padding,
        child: content,
      );
    } else {
      bodyWidget = Padding(
        padding: padding,
        child: content,
      );
    }

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(topRadius),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.inkDark.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSizes.spacingS),
            const Center(child: PremiumSheetHandle()),
            if (header != null) ...[
              header!,
            ] else if (title != null || titleWidget != null || showCloseButton) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.spacingL,
                  AppSizes.spacingM,
                  AppSizes.spacingS,
                  AppSizes.spacingS,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: titleWidget ??
                          (title != null
                              ? Text(
                                  title!,
                                  style: AppTypography.h3.copyWith(
                                    color: AppColors.inkDark,
                                    fontWeight: FontWeight.w800,
                                  ),
                                )
                              : const SizedBox.shrink()),
                    ),
                    if (showCloseButton)
                      IconButton(
                        onPressed: closeEnabled
                            ? (onClose ?? () => Navigator.pop(context))
                            : null,
                        icon: const Icon(Icons.close_rounded),
                        tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                        style: IconButton.styleFrom(
                          minimumSize: const Size(
                            AppSizes.minTouchTarget,
                            AppSizes.minTouchTarget,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
            if (scrollable)
              Flexible(child: bodyWidget)
            else
              bodyWidget,
            ?actions,
          ],
        ),
      ),
    );
  }
}

/// Standart sürükleme tutamacı.
class PremiumSheetHandle extends StatelessWidget {
  const PremiumSheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.lineLight,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

/// Birincil + opsiyonel ikincil aksiyon butonları.
class PremiumSheetActions extends StatelessWidget {
  const PremiumSheetActions({
    super.key,
    required this.primaryLabel,
    this.onPrimary,
    this.primaryLoading = false,
    this.primaryEnabled = true,
    this.secondaryLabel,
    this.onSecondary,
    this.secondaryEnabled = true,
    this.dangerPrimary = false,
    this.icon,
  });

  final String primaryLabel;
  final VoidCallback? onPrimary;
  final bool primaryLoading;
  final bool primaryEnabled;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  final bool secondaryEnabled;
  final bool dangerPrimary;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.spacingL,
        AppSizes.spacingS,
        AppSizes.spacingL,
        AppSizes.spacingM,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: ProfileSettingsUi.buttonHeight,
            child: ElevatedButton(
              onPressed: primaryLoading || !primaryEnabled ? null : onPrimary,
              style: dangerPrimary
                  ? ElevatedButton.styleFrom(
                      backgroundColor: ProfileSettingsUi.danger,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      minimumSize: const Size(double.infinity, ProfileSettingsUi.buttonHeight),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          ProfileSettingsUi.primaryButtonRadius,
                        ),
                      ),
                      textStyle: ProfileSettingsUi.buttonLabel,
                    )
                  : ProfileSettingsUi.primaryButton,
              child: primaryLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: Colors.white,
                      ),
                    )
                  : icon != null
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(icon, size: 20),
                            const SizedBox(width: 8),
                            Text(primaryLabel),
                          ],
                        )
                      : Text(primaryLabel),
            ),
          ),
          if (secondaryLabel != null) ...[
            const SizedBox(height: AppSizes.spacingS),
            SizedBox(
              height: ProfileSettingsUi.buttonHeight,
              child: TextButton(
                onPressed: secondaryEnabled ? onSecondary : null,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.inkDark,
                  backgroundColor: AppColors.surface,
                  side: ProfileSettingsUi.cardBorderSide,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      ProfileSettingsUi.primaryButtonRadius,
                    ),
                  ),
                  textStyle: ProfileSettingsUi.fieldValue.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                child: Text(secondaryLabel!),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Menü / aksiyon listesi satırı.
class PremiumActionSheetTile extends StatelessWidget {
  const PremiumActionSheetTile({
    super.key,
    required this.icon,
    required this.label,
    this.subtitle,
    this.iconColor,
    this.iconBackground,
    this.trailing,
    this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final Color? iconColor;
  final Color? iconBackground;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor =
        danger ? ProfileSettingsUi.danger : (iconColor ?? AppColors.inkDark);
    final effectiveBg = iconBackground ??
        effectiveIconColor.withValues(alpha: danger ? 0.1 : 0.08);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ProfileSettingsUi.radiusMd),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: AppSizes.minTouchTargetComfort,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.spacingS,
              vertical: AppSizes.spacingS,
            ),
            child: Row(
              children: [
                Container(
                  width: ProfileSettingsUi.rowIconBox,
                  height: ProfileSettingsUi.rowIconBox,
                  decoration: BoxDecoration(
                    color: effectiveBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    icon,
                    size: ProfileSettingsUi.iconSize,
                    color: effectiveIconColor,
                  ),
                ),
                const SizedBox(width: AppSizes.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: ProfileSettingsUi.rowTitle.copyWith(
                          color: danger ? ProfileSettingsUi.danger : AppColors.inkDark,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: ProfileSettingsUi.handle.copyWith(fontSize: 14),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                trailing ??
                    Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.mutedText,
                      size: AppSizes.iconSize,
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Picker / aksiyon listesi — beyaz kart içinde satırlar.
class PremiumActionSheetList extends StatelessWidget {
  const PremiumActionSheetList({
    super.key,
    required this.children,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(ProfileSettingsUi.radiusLg),
        border: ProfileSettingsUi.cardBorder,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                thickness: 1,
                color: AppColors.lineLight,
                indent: AppSizes.spacingS,
                endIndent: AppSizes.spacingS,
              ),
            children[i],
          ],
        ],
      ),
    );
  }
}

/// Bilgi kartı — bildirim/talep detay satırları.
class PremiumInfoCard extends StatelessWidget {
  const PremiumInfoCard({
    super.key,
    required this.children,
    this.title,
    this.titleIcon,
  });

  final List<Widget> children;
  final String? title;
  final IconData? titleIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(ProfileSettingsUi.radiusLg),
        border: ProfileSettingsUi.cardBorder,
      ),
      padding: const EdgeInsets.all(AppSizes.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null) ...[
            Row(
              children: [
                if (titleIcon != null) ...[
                  Icon(
                    titleIcon,
                    size: 18,
                    color: AppColors.mutedText,
                  ),
                  const SizedBox(width: AppSizes.spacingXS),
                ],
                Text(
                  title!.toUpperCase(),
                  style: ProfileSettingsUi.fieldLabelUppercase,
                ),
              ],
            ),
            const SizedBox(height: AppSizes.spacingM),
          ],
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSizes.spacingS),
                child: Divider(
                  height: 1,
                  color: AppColors.line.withValues(alpha: 0.6),
                ),
              ),
            children[i],
          ],
        ],
      ),
    );
  }
}

/// Bilgi kartı satırı — label / value.
class PremiumInfoRow extends StatelessWidget {
  const PremiumInfoRow({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: ProfileSettingsUi.handle.copyWith(fontSize: 15),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: ProfileSettingsUi.fieldValue.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

/// Bölüm kutusu — açıklama metni vb.
class PremiumSectionBox extends StatelessWidget {
  const PremiumSectionBox({
    super.key,
    required this.child,
    this.backgroundColor,
    this.borderColor,
  });

  final Widget child;
  final Color? backgroundColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.spacingM),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surface,
        borderRadius: BorderRadius.circular(ProfileSettingsUi.fieldRadius),
        border: Border.all(
          color: borderColor ?? AppColors.lineLight,
        ),
      ),
      child: child,
    );
  }
}

/// Toggle satırı — SwitchListTile yerine premium switch.
class MinimalToggleRow extends StatelessWidget {
  const MinimalToggleRow({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
    this.enabled = true,
  });

  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool enabled;

  static const _duration = Duration(milliseconds: 200);

  @override
  Widget build(BuildContext context) {
    final active = enabled && onChanged != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: active ? () => onChanged!(!value) : null,
        borderRadius: BorderRadius.circular(ProfileSettingsUi.fieldRadius),
        child: Container(
          constraints: const BoxConstraints(minHeight: AppSizes.minTouchTarget),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.spacingM,
            vertical: AppSizes.spacingS,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(ProfileSettingsUi.fieldRadius),
            border: ProfileSettingsUi.cardBorder,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: ProfileSettingsUi.fieldValue.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: ProfileSettingsUi.handle.copyWith(fontSize: 14),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSizes.spacingS),
              AnimatedContainer(
                duration: _duration,
                curve: Curves.easeInOut,
                width: 52,
                height: 32,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: value && active
                      ? AppColors.inkDark
                      : AppColors.fill,
                  border: Border.all(
                    color: value && active
                        ? AppColors.inkDark
                        : AppColors.line,
                    width: 1.5,
                  ),
                ),
                child: AnimatedAlign(
                  duration: _duration,
                  curve: Curves.easeInOut,
                  alignment:
                      value ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    width: 26,
                    height: 26,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: value && active
                          ? Colors.white
                          : AppColors.mutedText,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Sticky tek buton — sheet altı için kısayol.
class PremiumStickyPrimaryButton extends StatelessWidget {
  const PremiumStickyPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return MinimalStickyActionBar(
      label: label,
      onPressed: onPressed,
      loading: loading,
      backgroundColor: AppColors.sheetBackground,
    );
  }
}
