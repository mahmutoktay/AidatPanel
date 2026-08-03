import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/app_typography.dart';

/// Davet kodu girişi — `AP3-B12-A9F0` formatında 3 segment.
/// Backspace boş segmentte bir önceki segmente geçer.
class InviteCodeInputRow extends StatefulWidget {
  const InviteCodeInputRow({
    super.key,
    required this.onChanged,
    this.onCompleted,
    this.enabled = true,
    this.initialCode,
  });

  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onCompleted;
  final bool enabled;
  final String? initialCode;

  @override
  State<InviteCodeInputRow> createState() => _InviteCodeInputRowState();
}

class _InviteCodeInputRowState extends State<InviteCodeInputRow> {
  static const _lengths = [3, 3, 4];
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(3, (_) => TextEditingController());
    _focusNodes = List.generate(3, (_) {
      final node = FocusNode();
      node.onKeyEvent = _onKeyEvent;
      return node;
    });
    final initial = widget.initialCode?.trim();
    if (initial != null && initial.isNotEmpty) {
      _applyRaw(initial, notify: false);
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _joined {
    final a = _controllers[0].text;
    final b = _controllers[1].text;
    final c = _controllers[2].text;
    if (a.isEmpty && b.isEmpty && c.isEmpty) return '';
    return '$a-$b-$c'.toUpperCase();
  }

  void _notify() {
    final v = _joined;
    widget.onChanged(v);
    final compact = v.replaceAll('-', '');
    if (compact.length == 10) {
      widget.onCompleted?.call(v);
    }
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey != LogicalKeyboardKey.backspace) {
      return KeyEventResult.ignored;
    }
    final index = _focusNodes.indexOf(node);
    if (index < 0) return KeyEventResult.ignored;

    final text = _controllers[index].text;
    final selection = _controllers[index].selection;
    final atStart = !selection.isValid ||
        selection.baseOffset <= 0 && selection.extentOffset <= 0;

    if (text.isNotEmpty && !atStart) {
      return KeyEventResult.ignored;
    }
    if (text.isNotEmpty && atStart) {
      // İmleç başta ve karakter var — TextField kendi silmesini yapsın;
      // boşaldıktan sonraki backspace için handled değil.
      return KeyEventResult.ignored;
    }
    if (index > 0) {
      final prev = _controllers[index - 1];
      if (prev.text.isNotEmpty) {
        prev.text = prev.text.substring(0, prev.text.length - 1);
        prev.selection = TextSelection.collapsed(offset: prev.text.length);
      }
      _focusNodes[index - 1].requestFocus();
      _notify();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  /// Kod biçimi `AP` + hex (örn. `APB-794-11FF`).
  /// Sabit önekteki `P` hex değildir; filtre yalnızca `0-9A-F` olsaydı
  /// elle girişte `P` reddedilirdi. Deep link bu alandan geçmez.
  static final RegExp _allowedChars = RegExp(r'[0-9A-FpP]');
  static final RegExp _stripDisallowed = RegExp(r'[^0-9A-FP]');

  String _sanitize(String raw) =>
      raw.toUpperCase().replaceAll(_stripDisallowed, '');

  void _applyRaw(String raw, {bool notify = true}) {
    final cleaned = _sanitize(raw);
    var offset = 0;
    for (var i = 0; i < 3; i++) {
      final len = _lengths[i];
      final end = (offset + len).clamp(0, cleaned.length);
      _controllers[i].text =
          offset < cleaned.length ? cleaned.substring(offset, end) : '';
      offset += len;
    }
    if (notify) _notify();
  }

  void _onChanged(int index, String value) {
    final upper = _sanitize(value);
    if (upper.length > _lengths[index]) {
      // Yapıştırma veya fazla karakter — tüm satıra dağıt.
      final before = _controllers
          .take(index)
          .map((c) => c.text)
          .join();
      _applyRaw(before + upper);
      final filled = _joined.replaceAll('-', '').length;
      final focusIdx = filled >= 10
          ? 2
          : filled < 3
              ? 0
              : filled < 6
                  ? 1
                  : 2;
      _focusNodes[focusIdx].requestFocus();
      return;
    }
    if (_controllers[index].text != upper) {
      _controllers[index].value = TextEditingValue(
        text: upper,
        selection: TextSelection.collapsed(offset: upper.length),
      );
    }
    if (upper.length >= _lengths[index] && index < 2) {
      _focusNodes[index + 1].requestFocus();
    }
    _notify();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final dashWidth = 12.0;
        final gaps = AppSizes.spacingXS * 2 + dashWidth * 2;
        final available = constraints.maxWidth - gaps;
        // Oranlar: 3 : 3 : 4
        final unit = available / 10;
        final widths = [unit * 3, unit * 3, unit * 4];

        Widget segment(int i) {
          return SizedBox(
            width: widths[i],
            height: 56,
            child: TextField(
              controller: _controllers[i],
              focusNode: _focusNodes[i],
              enabled: widget.enabled,
              textAlign: TextAlign.center,
              textAlignVertical: TextAlignVertical.center,
              textCapitalization: TextCapitalization.characters,
              style: AppTypography.h3.copyWith(
                fontSize: 18,
                height: 1.1,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
              inputFormatters: [
                // `AP` öneki + hex; `P` sabit önekte zorunlu (bkz. _sanitize).
                FilteringTextInputFormatter.allow(_allowedChars),
                LengthLimitingTextInputFormatter(_lengths[i]),
                _UpperCaseTextFormatter(),
              ],
              decoration: InputDecoration(
                counterText: '',
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                isDense: true,
                hintText: i == 0
                    ? 'AP3'
                    : i == 1
                        ? 'B12'
                        : 'A9F0',
                hintStyle: AppTypography.body2.copyWith(
                  color: AppColors.textSecondary.withValues(alpha: 0.45),
                  letterSpacing: 1,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.inputRadius),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.inputRadius),
                  borderSide: BorderSide(color: AppColors.brand, width: 2),
                ),
              ),
              onChanged: (v) => _onChanged(i, v),
            ),
          );
        }

        Widget dash() => SizedBox(
              width: dashWidth,
              child: Text(
                '-',
                textAlign: TextAlign.center,
                style: AppTypography.h3.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            segment(0),
            dash(),
            segment(1),
            dash(),
            segment(2),
          ],
        );
      },
    );
  }
}

class _UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
