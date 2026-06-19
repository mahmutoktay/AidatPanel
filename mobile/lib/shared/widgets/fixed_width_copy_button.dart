import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_button_styles.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/theme/app_typography.dart';

/// Sabit genişlikli kopyala butonu — "Kopyala" ↔ "Kopyalandı" geçişinde layout kaymaz.
class FixedWidthCopyButton extends StatefulWidget {
  const FixedWidthCopyButton({
    super.key,
    required this.textToCopy,
    required this.copyLabel,
    required this.copiedLabel,
    this.style,
    this.revertAfter = const Duration(seconds: 2),
    this.height = AppSizes.buttonHeightPrimary,
    this.iconSize = 20,
    this.onCopied,
  });

  final String textToCopy;
  final String copyLabel;
  final String copiedLabel;
  final ButtonStyle? style;
  final Duration revertAfter;
  final double height;
  final double iconSize;
  final VoidCallback? onCopied;

  @override
  State<FixedWidthCopyButton> createState() => _FixedWidthCopyButtonState();
}

class _FixedWidthCopyButtonState extends State<FixedWidthCopyButton> {
  static const _animationDuration = Duration(milliseconds: 200);
  static const _horizontalPadding = 16.0;
  static const _iconGap = 8.0;

  bool _copied = false;
  Timer? _revertTimer;

  @override
  void dispose() {
    _revertTimer?.cancel();
    super.dispose();
  }

  double _measureLabelWidth(String label) {
    final painter = TextPainter(
      text: TextSpan(
        text: label,
        style: AppTypography.button.copyWith(fontWeight: FontWeight.w700),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    return painter.width;
  }

  Future<void> _onPressed() async {
    if (_copied) return;
    await Clipboard.setData(ClipboardData(text: widget.textToCopy));
    if (!mounted) return;
    widget.onCopied?.call();
    setState(() => _copied = true);
    _revertTimer?.cancel();
    _revertTimer = Timer(widget.revertAfter, () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final textStyle =
        AppTypography.button.copyWith(fontWeight: FontWeight.w700);
    final maxTextWidth = [
      _measureLabelWidth(widget.copyLabel),
      _measureLabelWidth(widget.copiedLabel),
    ].reduce((a, b) => a > b ? a : b);

    final fixedWidth = maxTextWidth +
        widget.iconSize +
        _iconGap +
        (_horizontalPadding * 2);

    final style = widget.style ?? AppButtonStyles.elevatedPrimary();

    return SizedBox(
      width: fixedWidth,
      height: widget.height,
      child: ElevatedButton(
        onPressed: _onPressed,
        style: style.copyWith(
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: _horizontalPadding),
          ),
        ),
        child: AnimatedSwitcher(
          duration: _animationDuration,
          switchInCurve: Curves.easeInOut,
          switchOutCurve: Curves.easeInOut,
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: child,
          ),
          child: _copied
              ? Row(
                  key: const ValueKey('copied'),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_rounded,
                      size: widget.iconSize,
                    ),
                    const SizedBox(width: _iconGap),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          widget.copiedLabel,
                          style: textStyle,
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ],
                )
              : Row(
                  key: const ValueKey('copy'),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.copy_rounded,
                      size: widget.iconSize,
                    ),
                    const SizedBox(width: _iconGap),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          widget.copyLabel,
                          style: textStyle,
                          maxLines: 1,
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
