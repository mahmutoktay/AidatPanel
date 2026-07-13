import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/illustration_gradients.dart';

/// Welcome sayfa illüstrasyonları — CustomPaint, Lottie/Hero yok.
enum WelcomeIllustrationKind {
  greeting,
  multiProperty,
  dekont,
  notifications,
  transparency,
}

class WelcomeIllustration extends StatelessWidget {
  const WelcomeIllustration({
    super.key,
    required this.kind,
  });

  final WelcomeIllustrationKind kind;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark;
    final background = AppColors.dashboardBackground;

    return CustomPaint(
      painter: switch (kind) {
        WelcomeIllustrationKind.greeting => _GreetingBuildingsPainter(
            isDark: isDark,
            backgroundColor: background,
          ),
        WelcomeIllustrationKind.multiProperty => _SiteGroupPainter(
            isDark: isDark,
            backgroundColor: background,
          ),
        WelcomeIllustrationKind.dekont => _DekontPainter(isDark: isDark),
        WelcomeIllustrationKind.notifications =>
          _BellPainter(isDark: isDark),
        WelcomeIllustrationKind.transparency =>
          _ChecklistPainter(isDark: isDark),
      },
      child: const SizedBox.expand(),
    );
  }
}

// ─── Ortak bina yardımcıları ───────────────────────────────────────────────

void _paintBuildingBody(
  Canvas canvas,
  Rect rect,
  List<Color> gradient, {
  required bool isDark,
  double radius = 8,
  int windowRows = 3,
  int windowCols = 2,
  bool door = false,
}) {
  final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
  final bodyPaint = Paint()
    ..shader = IllustrationGradients.verticalBody(rect, gradient);
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

  _paintWindows(canvas, rect, isDark, windowRows, windowCols);
  if (door) _paintDoor(canvas, rect, isDark);
}

void _paintWindows(
  Canvas canvas,
  Rect rect,
  bool isDark,
  int rows,
  int cols,
) {
  const windowGapH = 10.0;
  const windowGapV = 12.0;
  const windowW = 11.0;
  const windowH = 11.0;
  const topPad = 18.0;
  const sidePad = 10.0;

  final totalW = cols * windowW + (cols - 1) * windowGapH;
  final startX = rect.left + (rect.width - totalW) / 2;

  for (var row = 0; row < rows; row++) {
    for (var col = 0; col < cols; col++) {
      final wx = startX + col * (windowW + windowGapH);
      final wy = rect.top + topPad + row * (windowH + windowGapV);
      if (wy + windowH > rect.bottom - sidePad - (cols > 0 ? 16 : 0)) continue;

      final winRect = Rect.fromLTWH(wx, wy, windowW, windowH);
      final winPaint = Paint()
        ..color = Colors.white.withValues(alpha: isDark ? 0.45 : 0.7);
      canvas.drawRRect(
        RRect.fromRectAndRadius(winRect, const Radius.circular(2)),
        winPaint,
      );
    }
  }
}

void _paintDoor(Canvas canvas, Rect rect, bool isDark) {
  final doorW = math.min(18.0, rect.width * 0.28);
  final doorH = math.min(28.0, rect.height * 0.22);
  final doorRect = Rect.fromLTWH(
    rect.center.dx - doorW / 2,
    rect.bottom - doorH - 4,
    doorW,
    doorH,
  );
  final doorPaint = Paint()
    ..color = Colors.white.withValues(alpha: isDark ? 0.35 : 0.55);
  canvas.drawRRect(
    RRect.fromRectAndRadius(doorRect, const Radius.circular(3)),
    doorPaint,
  );
}

// ─── Sayfa 1 — Genel karşılama ─────────────────────────────────────────────

class _GreetingBuildingsPainter extends CustomPainter {
  _GreetingBuildingsPainter({
    required this.isDark,
    required this.backgroundColor,
  });

  final bool isDark;
  final Color backgroundColor;

  @override
  void paint(Canvas canvas, Size size) {
    final groundY = size.height * 0.92;
    final cx = size.width / 2;

    final specs = <(double, double, double, List<Color>, int, int, bool)>[
      (
        cx - 118,
        100,
        70,
        IllustrationGradients.buildingBlueFor(isDark),
        3,
        2,
        false,
      ),
      (
        cx - 42,
        145,
        84,
        IllustrationGradients.buildingBlueFor(isDark),
        4,
        2,
        true,
      ),
      (
        cx + 50,
        88,
        64,
        IllustrationGradients.buildingAmberFor(isDark),
        2,
        2,
        false,
      ),
    ];

    for (final s in specs) {
      final left = s.$1;
      final h = s.$2;
      final w = s.$3;
      final top = groundY - h;
      _paintBuildingBody(
        canvas,
        Rect.fromLTWH(left, top, w, h),
        s.$4,
        isDark: isDark,
        windowRows: s.$5,
        windowCols: s.$6,
        door: s.$7,
      );
    }

    // Zemin şeridi
    final groundPaint = Paint()
      ..color = AppColors.brand.withValues(alpha: isDark ? 0.15 : 0.08);
    canvas.drawRect(
      Rect.fromLTWH(0, groundY, size.width, size.height - groundY),
      groundPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _GreetingBuildingsPainter oldDelegate) =>
      oldDelegate.isDark != isDark ||
      oldDelegate.backgroundColor != backgroundColor;
}

// ─── Sayfa 2 — Site / çoklu mülk ───────────────────────────────────────────

class _SiteGroupPainter extends CustomPainter {
  _SiteGroupPainter({
    required this.isDark,
    required this.backgroundColor,
  });

  final bool isDark;
  final Color backgroundColor;

  @override
  void paint(Canvas canvas, Size size) {
    final groundY = size.height * 0.9;
    final startX = size.width * 0.08;
    final gap = size.width * 0.02;

    final buildings = <(double, double, List<Color>, int)>[
      (58, 110, IllustrationGradients.buildingGrayFor(isDark), 3),
      (72, 150, IllustrationGradients.buildingBlueFor(isDark), 4),
      (64, 125, IllustrationGradients.buildingAmberFor(isDark), 3),
      (68, 140, IllustrationGradients.buildingBlueFor(isDark), 4),
      (55, 95, IllustrationGradients.buildingGrayFor(isDark), 2),
    ];

    var x = startX;
    for (var i = 0; i < buildings.length; i++) {
      final b = buildings[i];
      final w = b.$1;
      final h = b.$2;
      final top = groundY - h;
      _paintBuildingBody(
        canvas,
        Rect.fromLTWH(x, top, w, h),
        b.$3,
        isDark: isDark,
        windowRows: b.$4,
        windowCols: 2,
        door: i == 1,
        radius: 6,
      );
      x += w + gap;
    }

    // Site etiketi bandı
    final bandRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width / 2, groundY + 10),
        width: size.width * 0.55,
        height: 8,
      ),
      const Radius.circular(4),
    );
    canvas.drawRRect(
      bandRect,
      Paint()..color = AppColors.accent.withValues(alpha: 0.45),
    );
  }

  @override
  bool shouldRepaint(covariant _SiteGroupPainter oldDelegate) =>
      oldDelegate.isDark != isDark ||
      oldDelegate.backgroundColor != backgroundColor;
}

// ─── Sayfa 3 — Dekont / OCR ────────────────────────────────────────────────

class _DekontPainter extends CustomPainter {
  _DekontPainter({required this.isDark});

  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final docW = size.width * 0.42;
    final docH = size.height * 0.62;
    final docRect = Rect.fromCenter(
      center: Offset(cx, cy),
      width: docW,
      height: docH,
    );
    final docRRect =
        RRect.fromRectAndRadius(docRect, const Radius.circular(12));

    // Kağıt gradyanı
    canvas.drawRRect(
      docRRect,
      Paint()..shader = IllustrationGradients.paperFill(docRect, isDark),
    );
    canvas.drawRRect(
      docRRect,
      Paint()
        ..color = AppColors.brand.withValues(alpha: isDark ? 0.35 : 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Metin çizgileri
    final linePaint = Paint()
      ..color = AppColors.brand.withValues(alpha: isDark ? 0.45 : 0.28)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final lineLeft = docRect.left + docW * 0.14;
    final lineRight = docRect.right - docW * 0.14;
    for (var i = 0; i < 5; i++) {
      final y = docRect.top + docH * (0.28 + i * 0.1);
      final end = i == 2 ? lineLeft + (lineRight - lineLeft) * 0.55 : lineRight;
      canvas.drawLine(Offset(lineLeft, y), Offset(end, y), linePaint);
    }

    // Tarama ışını (metin bölgesi ortası)
    final beamRect = Rect.fromLTWH(
      docRect.left,
      docRect.top + docH * 0.42,
      docW,
      docH * 0.12,
    );
    canvas.drawRect(
      beamRect,
      Paint()..shader = IllustrationGradients.scanBeamHorizontal(beamRect),
    );

    // Onay rozeti
    final badgeR = docW * 0.16;
    final badgeCenter = Offset(docRect.right - badgeR * 0.2, docRect.top + badgeR * 0.3);
    final badgeRect = Rect.fromCircle(center: badgeCenter, radius: badgeR);
    canvas.drawCircle(
      badgeCenter,
      badgeR,
      Paint()..shader = IllustrationGradients.successBadge(badgeRect, isDark),
    );
    // Check mark
    final check = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final path = Path()
      ..moveTo(badgeCenter.dx - badgeR * 0.35, badgeCenter.dy)
      ..lineTo(badgeCenter.dx - badgeR * 0.08, badgeCenter.dy + badgeR * 0.28)
      ..lineTo(badgeCenter.dx + badgeR * 0.38, badgeCenter.dy - badgeR * 0.28);
    canvas.drawPath(path, check);
  }

  @override
  bool shouldRepaint(covariant _DekontPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}

// ─── Sayfa 4 — Bildirim zili ───────────────────────────────────────────────

class _BellPainter extends CustomPainter {
  _BellPainter({required this.isDark});

  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final bellW = size.width * 0.32;
    final bellH = size.height * 0.42;

    final bellTop = Offset(cx, cy - bellH * 0.45);
    final bellBottom = cy + bellH * 0.25;
    final left = cx - bellW / 2;
    final right = cx + bellW / 2;

    final bellPath = Path()
      ..moveTo(left + bellW * 0.15, bellTop.dy + bellH * 0.15)
      ..quadraticBezierTo(left, bellTop.dy + bellH * 0.5, left, bellBottom)
      ..lineTo(right, bellBottom)
      ..quadraticBezierTo(
        right,
        bellTop.dy + bellH * 0.5,
        right - bellW * 0.15,
        bellTop.dy + bellH * 0.15,
      )
      ..quadraticBezierTo(cx, bellTop.dy - 4, left + bellW * 0.15, bellTop.dy + bellH * 0.15)
      ..close();

    final bounds = bellPath.getBounds();
    canvas.drawPath(
      bellPath,
      Paint()..shader = IllustrationGradients.bellBody(bounds, isDark),
    );

    // Tokmak
    final clapper = Paint()..color = const Color(0xFF92400E);
    canvas.drawCircle(
      Offset(cx, bellBottom + bellH * 0.08),
      bellW * 0.1,
      clapper,
    );

    // Ses dalgaları (düz)
    final wavePaint = Paint()
      ..color = AppColors.brand.withValues(alpha: isDark ? 0.55 : 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    for (final side in [-1.0, 1.0]) {
      for (var i = 1; i <= 2; i++) {
        final r = bellW * (0.55 + i * 0.22);
        canvas.drawArc(
          Rect.fromCircle(center: Offset(cx, cy - bellH * 0.05), radius: r),
          side < 0 ? math.pi * 0.7 : -math.pi * 0.3,
          math.pi * 0.35,
          false,
          wavePaint,
        );
      }
    }

    // Kırmızı bildirim noktası
    canvas.drawCircle(
      Offset(cx + bellW * 0.32, bellTop.dy + bellH * 0.08),
      bellW * 0.12,
      Paint()..color = AppColors.error,
    );
  }

  @override
  bool shouldRepaint(covariant _BellPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}

// ─── Sayfa 5 — Şeffaflık / checklist ───────────────────────────────────────

class _ChecklistPainter extends CustomPainter {
  _ChecklistPainter({required this.isDark});

  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final boardW = size.width * 0.4;
    final boardH = size.height * 0.58;
    final boardRect = Rect.fromCenter(
      center: Offset(cx, cy + 8),
      width: boardW,
      height: boardH,
    );
    final boardRRect =
        RRect.fromRectAndRadius(boardRect, const Radius.circular(10));

    canvas.drawRRect(
      boardRRect,
      Paint()..shader = IllustrationGradients.paperFill(boardRect, isDark),
    );
    canvas.drawRRect(
      boardRRect,
      Paint()
        ..color = AppColors.brand.withValues(alpha: isDark ? 0.35 : 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Ataç / klips (düz)
    final clipW = boardW * 0.28;
    final clipRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(cx, boardRect.top),
        width: clipW,
        height: 22,
      ),
      const Radius.circular(6),
    );
    canvas.drawRRect(
      clipRect,
      Paint()..color = AppColors.accent,
    );

    // Satırlar + onay daireleri
    for (var i = 0; i < 3; i++) {
      final y = boardRect.top + boardH * (0.28 + i * 0.2);
      final lineLeft = boardRect.left + boardW * 0.28;
      final lineRight = boardRect.right - boardW * 0.12;
      canvas.drawLine(
        Offset(lineLeft, y),
        Offset(lineRight, y),
        Paint()
          ..color = AppColors.brand.withValues(alpha: isDark ? 0.4 : 0.25)
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round,
      );

      if (i < 2) {
        final badgeCenter = Offset(boardRect.left + boardW * 0.14, y);
        final badgeR = boardW * 0.08;
        final badgeRect = Rect.fromCircle(center: badgeCenter, radius: badgeR);
        canvas.drawCircle(
          badgeCenter,
          badgeR,
          Paint()
            ..shader =
                IllustrationGradients.successBadge(badgeRect, isDark),
        );
        final check = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round;
        final path = Path()
          ..moveTo(badgeCenter.dx - badgeR * 0.35, badgeCenter.dy)
          ..lineTo(
            badgeCenter.dx - badgeR * 0.05,
            badgeCenter.dy + badgeR * 0.3,
          )
          ..lineTo(
            badgeCenter.dx + badgeR * 0.4,
            badgeCenter.dy - badgeR * 0.3,
          );
        canvas.drawPath(path, check);
      } else {
        // Bekleyen kutu
        final box = Rect.fromCenter(
          center: Offset(boardRect.left + boardW * 0.14, y),
          width: boardW * 0.14,
          height: boardW * 0.14,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(box, const Radius.circular(3)),
          Paint()
            ..color = AppColors.brand.withValues(alpha: 0.35)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ChecklistPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}
