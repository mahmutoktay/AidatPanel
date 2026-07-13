import 'package:flutter/material.dart';

import 'auth_form_styles.dart';

/// Password input field with visibility toggle
class PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final bool obscureText;
  final VoidCallback onToggleVisibility;
  final String labelText;
  final String? hintText;
  final bool enabled;
  final Function(String)? onChanged;
  final FocusNode? focusNode;
  final Widget? passwordCriteria;
  final String? helperText;
  final Color? borderColor;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final Iterable<String>? autofillHints;
  final bool whiteBackground;

  const PasswordField({
    super.key,
    required this.controller,
    required this.obscureText,
    required this.onToggleVisibility,
    required this.labelText,
    this.hintText,
    this.enabled = true,
    this.onChanged,
    this.focusNode,
    this.passwordCriteria,
    this.helperText,
    this.borderColor,
    this.textInputAction,
    this.onSubmitted,
    this.autofillHints,
    this.whiteBackground = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          enabled: enabled,
          obscureText: obscureText,
          onChanged: onChanged,
          focusNode: focusNode,
          textInputAction: textInputAction,
          onSubmitted: onSubmitted,
          autofillHints: autofillHints,
          decoration: _buildDecoration(),
        ),
        ...?passwordCriteria != null ? [passwordCriteria!] : null,
      ],
    );
  }

  InputDecoration _buildDecoration() {
    if (whiteBackground) {
      return AuthFormStyles.whiteField(
        labelText: labelText,
        hintText: hintText ?? '••••••••',
        prefixIcon: const Icon(Icons.lock_outlined),
        suffixIcon: IconButton(
          icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility),
          onPressed: onToggleVisibility,
        ),
        helperText: helperText,
      );
    }

    return InputDecoration(
      labelText: labelText,
      hintText: hintText ?? '••••••••',
      prefixIcon: const Icon(Icons.lock_outlined),
      suffixIcon: IconButton(
        icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility),
        onPressed: onToggleVisibility,
      ),
      helperText: helperText,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 17,
      ),
      border: borderColor != null
          ? OutlineInputBorder(borderSide: BorderSide(color: borderColor!))
          : null,
      enabledBorder: borderColor != null
          ? OutlineInputBorder(borderSide: BorderSide(color: borderColor!))
          : null,
      focusedBorder: borderColor != null
          ? OutlineInputBorder(borderSide: BorderSide(color: borderColor!))
          : null,
    );
  }
}
