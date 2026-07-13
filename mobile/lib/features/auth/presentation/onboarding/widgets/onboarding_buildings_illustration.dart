import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

/// Adım 1 alt dekor — marka renkleriyle bütünleşen gradient bina silüeti.
class OnboardingBuildingsIllustration extends StatelessWidget {
  const OnboardingBuildingsIllustration({
    super.key,
    this.height = 268,
  });

  final double height;

  @override
  Widget build(BuildContext context) {
    final background = AppColors.dashboardBackground;

    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _BuildingsPainter(
          isDark: AppColors.isDark,
          backgroundColor: background,
        ),
      ),
    );
  }
}

class _BuildingsPainter extends CustomPainter {
  _BuildingsPainter({
    required this.isDark,
    required this.backgroundColor,
  });

  final bool isDark;
  final Color backgroundColor;

  List<_BuildingSpec> get _buildings {
    final primary = AppColors.brand;
    final primaryLight = AppColors.brandSoft;
    final accent = AppColors.accent;
    final muted = AppColors.textSecondary;

    if (isDark) {
      return [
        _BuildingSpec(
          width: 72,
          height: 112,
          leftOffset: 0.10,
          gradient: [
            primaryLight.withValues(alpha: 0.55),
            primary.withValues(alpha: 0.85),
          ],
          windowRows: 3,
          windowCols: 2,
        ),
        _BuildingSpec(
          width: 84,
          height: 158,
          leftOffset: 0.26,
          gradient: [
            primaryLight.withValues(alpha: 0.75),
            primary,
          ],
          windowRows: 4,
          windowCols: 2,
        ),
        _BuildingSpec(
          width: 66,
          height: 98,
          leftOffset: 0.48,
          gradient: [
            accent.withValues(alpha: 0.65),
            accent.withValues(alpha: 0.95),
          ],
          windowRows: 2,
          windowCols: 2,
        ),
        _BuildingSpec(
          width: 76,
          height: 138,
          leftOffset: 0.64,
          gradient: [
            muted.withValues(alpha: 0.45),
            muted.withValues(alpha: 0.75),
          ],
          windowRows: 3,
          windowCols: 2,
        ),
      ];
    }

    return [
      _BuildingSpec(
        width: 72,
        height: 112,
        leftOffset: 0.10,
        gradient: [
          primaryLight.withValues(alpha: 0.55),
          primary,
        ],
        windowRows: 3,
        windowCols: 2,
      ),
      _BuildingSpec(
        width: 84,
        height: 158,
        leftOffset: 0.26,
        gradient: [
          primary.withValues(alpha: 0.72),
          primary,
        ],
        windowRows: 4,
        windowCols: 2,
      ),
      _BuildingSpec(
        width: 66,
        height: 98,
        leftOffset: 0.48,
        gradient: [
          accent.withValues(alpha: 0.75),
          accent,
        ],
        windowRows: 2,
        windowCols: 2,
      ),
      _BuildingSpec(
        width: 76,
        height: 138,
        leftOffset: 0.64,
        gradient: [
          primaryLight.withValues(alpha: 0.35),
          muted.withValues(alpha: 0.65),
        ],
        windowRows: 3,
        windowCols: 2,
      ),
    ];
  }

  @override
  void paint(Canvas canvas, Size size) {
    _paintAmbientGlow(canvas, size);
    _paintTopFade(canvas, size);

    final groundY = size.height;
    final baseWidth = size.width * 0.92;
    final startX = (size.width - baseWidth) / 2;

    for (final spec in _buildings) {
      final left = startX + baseWidth * spec.leftOffset;
      final top = groundY - spec.height;
      _paintBuilding(canvas, left, top, spec, groundY);
    }

    _paintBottomFade(canvas, size);
  }

  void _paintAmbientGlow(Canvas canvas, Size size) {
    final glowRect = Rect.fromLTWH(0, size.height * 0.3, size.width, size.height * 0.7);
    final glowColor = isDark
        ? AppColors.brandSoft.withValues(alpha: 0.12)
        : AppColors.brand.withValues(alpha: 0.08);
    final glowPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, 1.1),
        radius: 1.15,
        colors: [
          glowColor,
          backgroundColor.withValues(alpha: 0),
        ],
      ).createShader(glowRect);
    canvas.drawRect(glowRect, glowPaint);
  }

  void _paintTopFade(Canvas canvas, Size size) {
    final fadeRect = Rect.fromLTWH(0, 0, size.width, size.height * 0.42);
    final fadePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          backgroundColor,
          backgroundColor.withValues(alpha: 0),
        ],
      ).createShader(fadeRect);
    canvas.drawRect(fadeRect, fadePaint);
  }

  void _paintBottomFade(Canvas canvas, Size size) {
    final fadeRect = Rect.fromLTWH(0, size.height * 0.55, size.width, size.height * 0.45);
    final fadePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          backgroundColor.withValues(alpha: 0),
          backgroundColor.withValues(alpha: 0.55),
          backgroundColor,
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(fadeRect);
    canvas.drawRect(fadeRect, fadePaint);
  }

  void _paintBuilding(
    Canvas canvas,
    double left,
    double top,
    _BuildingSpec spec,
    double groundY,
  ) {
    final height = groundY - top;
    final rect = Rect.fromLTWH(left, top, spec.width, height);
    const radius = Radius.circular(8);

    final bodyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: spec.gradient,
      ).createShader(rect);

    final rrect = RRect.fromRectAndRadius(rect, radius);
    canvas.drawRRect(rrect, bodyPaint);

    final highlightPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: isDark ? 0.14 : 0.22),
          Colors.transparent,
        ],
      ).createShader(rect);
    canvas.drawRRect(rrect, highlightPaint);

    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: isDark ? 0.08 : 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRRect(rrect, borderPaint);

    _paintWindows(canvas, rect, spec);
    _paintRoofAccent(canvas, rect);
  }

  void _paintRoofAccent(Canvas canvas, Rect rect) {
    final roofRect = Rect.fromLTWH(
      rect.left + 4,
      rect.top + 4,
      rect.width - 8,
      math.min(10, rect.height * 0.08),
    );
    final roofPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.white.withValues(alpha: 0.28),
          Colors.white.withValues(alpha: 0.04),
        ],
      ).createShader(roofRect);
    canvas.drawRRect(
      RRect.fromRectAndRadius(roofRect, const Radius.circular(4)),
      roofPaint,
    );
  }

  void _paintWindows(Canvas canvas, Rect rect, _BuildingSpec spec) {
    const windowGapH = 10.0;
    const windowGapV = 12.0;
    const windowW = 11.0;
    const windowH = 11.0;
    const topPad = 18.0;
    const sidePad = 10.0;

    final totalW = spec.windowCols * windowW + (spec.windowCols - 1) * windowGapH;
    final startX = rect.left + (rect.width - totalW) / 2;

    for (var row = 0; row < spec.windowRows; row++) {
      for (var col = 0; col < spec.windowCols; col++) {
        final wx = startX + col * (windowW + windowGapH);
        final wy = rect.top + topPad + row * (windowH + windowGapV);
        if (wy + windowH > rect.bottom - sidePad) continue;

        final winRect = Rect.fromLTWH(wx, wy, windowW, windowH);
        final winPaint = Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: isDark ? 0.55 : 0.75),
              Colors.white.withValues(alpha: isDark ? 0.18 : 0.35),
            ],
          ).createShader(winRect);
        canvas.drawRRect(
          RRect.fromRectAndRadius(winRect, const Radius.circular(2)),
          winPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BuildingsPainter oldDelegate) =>
      oldDelegate.isDark != isDark ||
      oldDelegate.backgroundColor != backgroundColor;
}

class _BuildingSpec {
  const _BuildingSpec({
    required this.width,
    required this.height,
    required this.leftOffset,
    required this.gradient,
    required this.windowRows,
    required this.windowCols,
  });

  final double width;
  final double height;
  final double leftOffset;
  final List<Color> gradient;
  final int windowRows;
  final int windowCols;
}
