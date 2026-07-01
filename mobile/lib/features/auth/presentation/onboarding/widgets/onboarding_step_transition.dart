import 'package:flutter/material.dart';

/// Adım geçişi süresi — yalnızca içerik solması (butonlar animasyon dışında).
const Duration onboardingStepTransitionDuration = Duration(milliseconds: 400);

/// Adımlar arası geçiş — içerik solar/belirir; kaydırma/ölçek yok.
Widget onboardingStepTransition(Widget child, Animation<double> animation) {
  return FadeTransition(
    opacity: CurvedAnimation(
      parent: animation,
      curve: Curves.easeInOutCubic,
    ),
    child: child,
  );
}
