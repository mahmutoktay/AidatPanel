import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/app_typography.dart';

/// 6 haneli OTP girişi — esnek hücre genişliği, backspace ile önceki hücreye geçiş.
class OtpInputRow extends StatefulWidget {
  const OtpInputRow({
    super.key,
    required this.onChanged,
    this.onCompleted,
    this.enabled = true,
  });

  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onCompleted;
  final bool enabled;

  @override
  State<OtpInputRow> createState() => _OtpInputRowState();
}

class _OtpInputRowState extends State<OtpInputRow> {
  static const _length = 6;
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(_length, (_) => TextEditingController());
    _focusNodes = List.generate(_length, (_) {
      final node = FocusNode();
      node.onKeyEvent = _onKeyEvent;
      return node;
    });
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

  String get _value => _controllers.map((c) => c.text).join();

  void _notify() {
    final v = _value;
    widget.onChanged(v);
    if (v.length == _length) {
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

    if (_controllers[index].text.isNotEmpty) {
      _controllers[index].clear();
      _notify();
      return KeyEventResult.handled;
    }
    if (index > 0) {
      _controllers[index - 1].clear();
      _focusNodes[index - 1].requestFocus();
      _notify();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _onChanged(int index, String value) {
    if (value.length > 1) {
      _fillFromPaste(value);
      return;
    }
    if (value.isNotEmpty && index < _length - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    _notify();
  }

  void _fillFromPaste(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    for (var i = 0; i < _length; i++) {
      _controllers[i].text = i < digits.length ? digits[i] : '';
    }
    _notify();
    if (digits.length >= _length) {
      _focusNodes[_length - 1].unfocus();
    } else if (digits.isNotEmpty) {
      _focusNodes[digits.length.clamp(0, _length - 1)].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final gap = AppSizes.spacingXS;
        final totalGaps = gap * (_length - 1);
        final cellWidth =
            ((constraints.maxWidth - totalGaps) / _length).clamp(40.0, 56.0);
        final fontSize = cellWidth >= 48 ? 22.0 : 18.0;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(_length, (i) {
            return SizedBox(
              width: cellWidth,
              height: 56,
              child: TextField(
                controller: _controllers[i],
                focusNode: _focusNodes[i],
                enabled: widget.enabled,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                textAlignVertical: TextAlignVertical.center,
                maxLength: 1,
                style: AppTypography.h3.copyWith(
                  fontSize: fontSize,
                  height: 1.1,
                  fontWeight: FontWeight.w700,
                ),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  counterText: '',
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.inputRadius),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.inputRadius),
                    borderSide:
                        BorderSide(color: AppColors.brand, width: 2),
                  ),
                ),
                onChanged: (v) => _onChanged(i, v),
              ),
            );
          }),
        );
      },
    );
  }
}
