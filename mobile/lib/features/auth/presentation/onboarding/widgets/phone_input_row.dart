import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/app_typography.dart';

/// Sakin telefon girişi — sabit `+90` + `(5XX) XXX XX XX` (tek alan, hücre yok).
///
/// [onChanged] her zaman `05XXXXXXXXX` (11 hane) veya kısmi rakam dizisi döner.
class PhoneInputRow extends StatefulWidget {
  const PhoneInputRow({
    super.key,
    required this.onChanged,
    this.onCompleted,
    this.enabled = true,
    this.initialPhone,
  });

  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onCompleted;
  final bool enabled;
  /// `05...` (11) veya kanonik `5...` (10) kabul edilir.
  final String? initialPhone;

  @override
  State<PhoneInputRow> createState() => _PhoneInputRowState();
}

class _PhoneInputRowState extends State<PhoneInputRow> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
    final initial = widget.initialPhone?.trim();
    if (initial != null && initial.isNotEmpty) {
      final national = _toNational10(initial);
      if (national != null) {
        _controller.text = _formatDisplay(national);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// Girişten 10 haneli ulusal numara (`5xxxxxxxxx`) üretir.
  static String? _toNational10(String raw) {
    var digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.startsWith('90') && digits.length >= 12) {
      digits = digits.substring(2);
    }
    if (digits.startsWith('0') && digits.length >= 11) {
      digits = digits.substring(1);
    }
    if (digits.length > 10) {
      digits = digits.substring(0, 10);
    }
    if (digits.isEmpty) return '';
    return digits;
  }

  /// `5XXXXXXXXX` → `(5XX) XXX XX XX`
  static String _formatDisplay(String national10) {
    final d = national10.replaceAll(RegExp(r'[^0-9]'), '');
    if (d.isEmpty) return '';
    final buf = StringBuffer('(');
    for (var i = 0; i < d.length && i < 10; i++) {
      if (i == 3) buf.write(') ');
      if (i == 6) buf.write(' ');
      if (i == 8) buf.write(' ');
      buf.write(d[i]);
    }
    return buf.toString();
  }

  /// Görüntüden `05...` (en fazla 11 hane).
  static String _toStorage05(String national10) {
    final d = national10.replaceAll(RegExp(r'[^0-9]'), '');
    if (d.isEmpty) return '';
    return '0$d';
  }

  void _notifyFromDisplay(String display) {
    final national = display.replaceAll(RegExp(r'[^0-9]'), '');
    final storage = _toStorage05(national);
    widget.onChanged(storage);
    if (national.length == 10 && national.startsWith('5')) {
      widget.onCompleted?.call(storage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      enabled: widget.enabled,
      keyboardType: TextInputType.phone,
      style: AppTypography.h3.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.6,
        height: 1.2,
      ),
      inputFormatters: [
        _TrMobilePhoneFormatter(),
      ],
      decoration: InputDecoration(
        hintText: '(5XX) XXX XX XX',
        hintStyle: AppTypography.body1.copyWith(
          color: AppColors.textSecondary.withValues(alpha: 0.45),
          letterSpacing: 0.4,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: AppSizes.spacingM),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '+90',
                style: AppTypography.h3.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: AppSizes.spacingS),
              Container(
                width: 1,
                height: 24,
                color: AppColors.lineLight,
              ),
              const SizedBox(width: AppSizes.spacingS),
            ],
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.spacingM,
          vertical: AppSizes.spacingM,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.inputRadius),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.inputRadius),
          borderSide: BorderSide(color: AppColors.brand, width: 2),
        ),
      ),
      onChanged: _notifyFromDisplay,
    );
  }
}

/// `(5XX) XXX XX XX` — en fazla 10 ulusal hane.
class _TrMobilePhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.startsWith('0')) {
      digits = digits.substring(1);
    }
    if (digits.startsWith('90') && digits.length > 10) {
      digits = digits.substring(2);
    }
    if (digits.length > 10) {
      digits = digits.substring(0, 10);
    }

    final formatted = _PhoneInputRowState._formatDisplay(digits);
    // İmleci sona koy — format karakterleri kaydırır.
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
