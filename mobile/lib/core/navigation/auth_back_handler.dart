import 'package:flutter/material.dart';

import 'app_back_navigation.dart';

/// Login / onboarding / splash için geri tuşu.
///
/// [onStepBack] true dönerse (ör. onboarding önceki adım) olay tüketilir.
/// Stack boşsa dashboard ile aynı çift basış + uyarı sonrası arka plana alınır.
class AuthBackHandler extends StatelessWidget {
  const AuthBackHandler({
    super.key,
    required this.child,
    this.onStepBack,
    this.exitHintMessage,
    this.onExitHint,
  });

  final Widget child;

  /// Önceki auth adımına dönülebildiyse `true`.
  final bool Function()? onStepBack;

  final String? exitHintMessage;
  final void Function(String message)? onExitHint;

  @override
  Widget build(BuildContext context) {
    return BackButtonListener(
      onBackButtonPressed: () async =>
          AppBackNavigation.handleAuthBackPressed(
        context,
        onStepBack: onStepBack,
        exitHintMessage: exitHintMessage,
        onExitHint: onExitHint,
      ),
      child: child,
    );
  }
}
