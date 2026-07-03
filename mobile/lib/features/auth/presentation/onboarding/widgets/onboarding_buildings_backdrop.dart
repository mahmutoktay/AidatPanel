import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'onboarding_buildings_illustration.dart';

/// Tüm onboarding adımlarında ekranın altında sabit dekoratif bina silüeti.
class OnboardingBuildingsBackdrop extends StatelessWidget {
  const OnboardingBuildingsBackdrop({super.key});

  static const double preferredHeight = 240;
  static const double minHeight = 120;
  static const double maxScreenFraction = 0.28;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final height = math.max(
      minHeight,
      math.min(preferredHeight, screenHeight * maxScreenFraction),
    );

    return IgnorePointer(
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: OnboardingBuildingsIllustration(height: height),
      ),
    );
  }
}
