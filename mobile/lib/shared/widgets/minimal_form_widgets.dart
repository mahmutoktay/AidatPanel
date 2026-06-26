import 'package:flutter/material.dart';
import 'action_chevron.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizes.dart';
import '../../features/profile/presentation/theme/profile_settings_ui.dart';
import 'app_back_button.dart';

/// Bölüm başlığı — uppercase gri, geniş letter-spacing.
class MinimalSectionLabel extends StatelessWidget {
  final String title;
  final String? subtitle;

  const MinimalSectionLabel({super.key, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title.toUpperCase(), style: ProfileSettingsUi.fieldLabelUppercase),
        if (subtitle != null) ...[
          const SizedBox(height: AppSizes.spacingXS),
          Text(
            subtitle!,
            style: ProfileSettingsUi.handle.copyWith(fontSize: 14),
          ),
        ],
      ],
    );
  }
}

/// Tek katmanlı floating-label metin alanı.
class MinimalTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String label;
  final String? hint;
  final IconData icon;
  final Color? iconColor;
  final bool required;
  final int maxLines;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final Widget? suffix;
  final bool enabled;
  final TextCapitalization textCapitalization;
  final TextInputAction? textInputAction;
  final bool autofocus;
  final FocusNode? focusNode;

  /// Yan yana alanlarda etiket hizası için minimum satır sayısı (varsayılan 1).
  final int labelMinLines;

  const MinimalTextField({
    super.key,
    this.controller,
    required this.label,
    this.hint,
    required this.icon,
    this.iconColor,
    this.required = false,
    this.maxLines = 1,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.suffix,
    this.enabled = true,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction,
    this.autofocus = false,
    this.focusNode,
    this.labelMinLines = 1,
  });

  @override
  State<MinimalTextField> createState() => _MinimalTextFieldState();
}

class _MinimalTextFieldState extends State<MinimalTextField> {
  late final FocusNode _internalFocusNode;
  bool _hasFocus = false;

  FocusNode get _focusNode => widget.focusNode ?? _internalFocusNode;

  @override
  void initState() {
    super.initState();
    _internalFocusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    if (widget.focusNode == null) {
      _internalFocusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() => _hasFocus = _focusNode.hasFocus);
  }

  String get _displayLabel => widget.required
      ? '${widget.label.toUpperCase()} *'
      : widget.label.toUpperCase();

  double get _fieldLabelSlotHeight {
    final style = ProfileSettingsUi.fieldLabelUppercase;
    final fontSize = style.fontSize ?? 11;
    final lineHeight = style.height ?? 1.2;
    return fontSize * lineHeight * widget.labelMinLines;
  }

  Widget _buildLabel() {
    final label = Text(
      _displayLabel,
      style: ProfileSettingsUi.fieldLabelUppercase,
      maxLines: widget.labelMinLines,
      overflow: TextOverflow.ellipsis,
    );

    if (widget.labelMinLines <= 1) return label;

    return SizedBox(
      height: _fieldLabelSlotHeight,
      child: Align(alignment: Alignment.centerLeft, child: label),
    );
  }

  @override
  Widget build(BuildContext context) {
    final focused = _hasFocus && widget.enabled;
    final iconColor = focused
        ? ProfileSettingsUi.ink
        : (widget.iconColor ?? ProfileSettingsUi.muted);

    final field = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      constraints: const BoxConstraints(minHeight: AppSizes.minTouchTarget),
      decoration: BoxDecoration(
        color: ProfileSettingsUi.background,
        borderRadius: BorderRadius.circular(ProfileSettingsUi.fieldRadius),
        border: Border.all(
          color: focused ? ProfileSettingsUi.ink : Colors.transparent,
          width: ProfileSettingsUi.fieldFocusBorderWidth,
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spacingM,
        vertical: AppSizes.spacingS,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            widget.icon,
            size: ProfileSettingsUi.fieldIconSize,
            color: widget.enabled ? iconColor : ProfileSettingsUi.muted,
          ),
          const SizedBox(width: AppSizes.spacingS),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildLabel(),
                const SizedBox(height: 2),
                TextFormField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  enabled: widget.enabled,
                  autofocus: widget.autofocus,
                  maxLines: widget.maxLines,
                  keyboardType: widget.keyboardType,
                  inputFormatters: widget.inputFormatters,
                  validator: widget.validator,
                  onChanged: widget.onChanged,
                  textCapitalization: widget.textCapitalization,
                  textInputAction: widget.textInputAction,
                  style: ProfileSettingsUi.fieldValue,
                  cursorColor: ProfileSettingsUi.ink,
                  decoration: InputDecoration(
                    filled: false,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    hintText: widget.hint,
                    hintStyle: ProfileSettingsUi.fieldPlaceholder,
                    errorStyle: ProfileSettingsUi.fieldLabel.copyWith(
                      color: ProfileSettingsUi.danger,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (widget.suffix != null) ...[
            const SizedBox(width: AppSizes.spacingXS),
            widget.suffix!,
          ],
        ],
      ),
    );

    if (!widget.enabled) {
      return Opacity(
        opacity: ProfileSettingsUi.fieldDisabledOpacity,
        child: field,
      );
    }
    return field;
  }
}

/// Dokunulabilir seçim alanı (şehir, ilçe, kayıtlı IBAN).
class MinimalPickerField extends StatelessWidget {
  final String label;
  final String? value;
  final String hint;
  final IconData icon;
  final Color? iconColor;
  final bool required;
  final bool enabled;
  final VoidCallback? onTap;

  const MinimalPickerField({
    super.key,
    required this.label,
    this.value,
    required this.hint,
    required this.icon,
    this.iconColor,
    this.required = false,
    this.enabled = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null && value!.isNotEmpty;
    final displayLabel = required
        ? '${label.toUpperCase()} *'
        : label.toUpperCase();

    final content = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(ProfileSettingsUi.fieldRadius),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          constraints: const BoxConstraints(minHeight: AppSizes.minTouchTarget),
          decoration: BoxDecoration(
            color: ProfileSettingsUi.background,
            borderRadius: BorderRadius.circular(ProfileSettingsUi.fieldRadius),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.spacingM,
            vertical: AppSizes.spacingS,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: ProfileSettingsUi.fieldIconSize,
                color: enabled
                    ? (iconColor ?? ProfileSettingsUi.muted)
                    : ProfileSettingsUi.muted,
              ),
              const SizedBox(width: AppSizes.spacingS),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      displayLabel,
                      style: ProfileSettingsUi.fieldLabelUppercase,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hasValue ? value! : hint,
                      style: hasValue
                          ? ProfileSettingsUi.fieldValue
                          : ProfileSettingsUi.fieldPlaceholder,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              ActionChevron(
                direction: ChevronDirection.down,
                color: ProfileSettingsUi.muted,
                size: AppSizes.iconSize,
              ),
            ],
          ),
        ),
      ),
    );

    if (!enabled) {
      return Opacity(
        opacity: ProfileSettingsUi.fieldDisabledOpacity,
        child: content,
      );
    }
    return content;
  }
}

/// Sticky alt aksiyon çubuğu — üstte gradient fade + birincil buton.
class MinimalStickyActionBar extends StatelessWidget {
  const MinimalStickyActionBar({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.backgroundColor,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final barColor = backgroundColor ?? AppColors.dashboardBackground;
    return ColoredBox(
      color: barColor,
      child: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 20,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [barColor.withValues(alpha: 0), barColor],
                ),
              ),
            ),
            SizedBox(
              height: ProfileSettingsUi.buttonHeight,
              child: ElevatedButton(
                onPressed: loading ? null : onPressed,
                style: ProfileSettingsUi.primaryButton,
                child: loading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: Colors.white,
                        ),
                      )
                    : Text(label),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Çerçevesiz dairesel geri butonu.
class MinimalBackButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const MinimalBackButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return AppBackButton(onPressed: onPressed);
  }
}

/// Kayıtlı / Yeni IBAN segment toggle.
class CollectionIbanSegmentToggle extends StatelessWidget {
  final bool savedSelected;
  final String savedLabel;
  final String newLabel;
  final VoidCallback onSavedTap;
  final VoidCallback onNewTap;

  const CollectionIbanSegmentToggle({
    super.key,
    required this.savedSelected,
    required this.savedLabel,
    required this.newLabel,
    required this.onSavedTap,
    required this.onNewTap,
  });

  static const _duration = Duration(milliseconds: 200);

  @override
  Widget build(BuildContext context) {
    final selectedIndex = savedSelected ? 0 : 1;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: ProfileSettingsUi.fieldFill,
        borderRadius: BorderRadius.circular(ProfileSettingsUi.fieldRadius),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final segmentWidth = constraints.maxWidth / 2;
          final controlHeight = AppSizes.minTouchTargetComfort;

          return SizedBox(
            height: controlHeight,
            child: Stack(
              children: [
                AnimatedAlign(
                  alignment: selectedIndex == 0
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  duration: _duration,
                  curve: Curves.easeInOut,
                  child: Container(
                    width: segmentWidth,
                    height: controlHeight,
                    decoration: BoxDecoration(
                      color: AppColors.inkDark,
                      borderRadius: BorderRadius.circular(
                        ProfileSettingsUi.fieldRadius - 2,
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: _SegmentOption(
                        icon: Icons.history,
                        label: savedLabel,
                        selected: savedSelected,
                        onTap: onSavedTap,
                      ),
                    ),
                    Expanded(
                      child: _SegmentOption(
                        icon: Icons.add,
                        label: newLabel,
                        selected: !savedSelected,
                        onTap: onNewTap,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SegmentOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SegmentOption({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? Colors.white : ProfileSettingsUi.muted;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ProfileSettingsUi.fieldRadius - 2),
        child: SizedBox(
          height: AppSizes.minTouchTargetComfort,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: ProfileSettingsUi.fieldValue.copyWith(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Arama için sade metin alanı (sheet içi).
class MinimalSearchField extends StatelessWidget {
  final String hint;
  final ValueChanged<String> onChanged;
  final bool autofocus;

  /// Sheet içinde beyaz zemin, normal formda varsayılan.
  final bool whiteBackground;

  const MinimalSearchField({
    super.key,
    required this.hint,
    required this.onChanged,
    this.autofocus = false,
    this.whiteBackground = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: AppSizes.minTouchTarget),
      decoration: BoxDecoration(
        color: whiteBackground
            ? AppColors.surface
            : ProfileSettingsUi.fieldFill,
        borderRadius: BorderRadius.circular(ProfileSettingsUi.fieldRadius),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacingM),
      child: Row(
        children: [
          Icon(
            Icons.search,
            size: ProfileSettingsUi.fieldIconSize,
            color: ProfileSettingsUi.muted,
          ),
          const SizedBox(width: AppSizes.spacingS),
          Expanded(
            child: TextField(
              autofocus: autofocus,
              onChanged: onChanged,
              style: ProfileSettingsUi.fieldValue,
              cursorColor: ProfileSettingsUi.ink,
              decoration: InputDecoration(
                filled: false,
                isDense: true,
                border: InputBorder.none,
                hintText: hint,
                hintStyle: ProfileSettingsUi.fieldPlaceholder,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
