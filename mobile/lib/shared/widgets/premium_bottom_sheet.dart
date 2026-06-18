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
        padding: padding.copyWith(bottom: AppSizes.spacingL),
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
        minimum: const EdgeInsets.only(bottom: AppSizes.spacingS),
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
        AppSizes.spacingL,
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

/// Sheet içi ikon sütunu hizası — ayırıcı indent değeri.
const double premiumSheetIconIndent = 56;

/// Sheet listelerinde ikon hizasından başlayan ince ayırıcı.
class PremiumSheetDivider extends StatelessWidget {
  const PremiumSheetDivider({super.key, this.indent = premiumSheetIconIndent});

  final double indent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.spacingS),
      child: Divider(
        height: 1,
        thickness: 1,
        color: AppColors.line.withValues(alpha: 0.35),
        indent: indent,
      ),
    );
  }
}

/// Sheet bilgi satırı — ikon + uppercase etiket + değer.
class PremiumSheetMetaRow extends StatelessWidget {
  const PremiumSheetMetaRow({
    super.key,
    required this.label,
    required this.value,
    this.icon = Icons.info_outline_rounded,
    this.iconColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color? iconColor;

  static const double _iconBoxSize = 44;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = iconColor ?? AppColors.mutedText;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: _iconBoxSize,
          height: _iconBoxSize,
          decoration: BoxDecoration(
            color: effectiveColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: effectiveColor, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: ProfileSettingsUi.fieldLabelUppercase.copyWith(
                  fontSize: 11,
                  letterSpacing: 0.8,
                  color: AppColors.mutedText,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: ProfileSettingsUi.fieldValue.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  height: 1.25,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
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

  static const double _iconBoxSize = 44;

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor =
        danger ? ProfileSettingsUi.danger : (iconColor ?? AppColors.inkDark);
    final effectiveBg = iconBackground ??
        effectiveIconColor.withValues(alpha: danger ? 0.1 : 0.1);

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
            padding: const EdgeInsets.symmetric(vertical: AppSizes.spacingXS),
            child: Row(
              children: [
                Container(
                  width: _iconBoxSize,
                  height: _iconBoxSize,
                  decoration: BoxDecoration(
                    color: effectiveBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    icon,
                    size: 22,
                    color: effectiveIconColor,
                  ),
                ),
                const SizedBox(width: 12),
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
                ?trailing,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Picker / aksiyon listesi — şeffaf, sheet zemini üzerinde satırlar.
class PremiumActionSheetList extends StatelessWidget {
  const PremiumActionSheetList({
    super.key,
    required this.children,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) const PremiumSheetDivider(),
          children[i],
        ],
      ],
    );
  }
}

/// Bilgi bloğu — şeffaf, meta satırlar.
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
    return Column(
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
          if (i > 0) const PremiumSheetDivider(),
          children[i],
        ],
      ],
    );
  }
}

/// Bilgi satırı — [PremiumSheetMetaRow] kısayolu.
class PremiumInfoRow extends StatelessWidget {
  const PremiumInfoRow({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.iconColor,
  });

  final String label;
  final String value;
  final IconData? icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return PremiumSheetMetaRow(
      label: label,
      value: value,
      icon: icon ?? Icons.info_outline_rounded,
      iconColor: iconColor,
    );
  }
}

/// Bölüm kutusu — açıklama / uyarı metni.
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
        color: backgroundColor ?? AppColors.fill.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(ProfileSettingsUi.fieldRadius),
        border: Border.all(
          color: borderColor ?? AppColors.line.withValues(alpha: 0.35),
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
