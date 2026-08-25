import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/app_typography.dart';
import 'code_input_cell_style.dart';

/// 6 haneli OTP girişi — dikdörtgen hücreler, border + gölge, backspace desteği.
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
      node.addListener(_onFocusChanged);
      return node;
    });
  }

  void _onFocusChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.removeListener(_onFocusChanged);
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
        // Genişlik yüksekliğin biraz altında → dikey dikdörtgen hücreler
        final cellWidth =
            ((constraints.maxWidth - totalGaps) / _length).clamp(40.0, 52.0);
        final fontSize = cellWidth >= 46 ? 22.0 : 18.0;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(_length, (i) {
            final focused = _focusNodes[i].hasFocus;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeInOut,
              width: cellWidth,
              height: CodeInputCellStyle.height,
              alignment: Alignment.center,
              decoration: CodeInputCellStyle.decoration(focused: focused),
              child: TextField(
                controller: _controllers[i],
                focusNode: _focusNodes[i],
                enabled: widget.enabled,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                textAlignVertical: TextAlignVertical.center,
                maxLength: 1,
                cursorHeight: fontSize,
                style: AppTypography.h3.copyWith(
                  fontSize: fontSize,
                  height: 1.0,
                  leadingDistribution: TextLeadingDistribution.even,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                strutStyle: StrutStyle(
                  fontSize: fontSize,
                  height: 1.0,
                  forceStrutHeight: true,
                  leadingDistribution: TextLeadingDistribution.even,
                ),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  counterText: '',
                  isCollapsed: true,
                  contentPadding: EdgeInsets.zero,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  filled: false,
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
