import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Illüstrasyon-only gradyan paleti. UI elevasyonu / BoxShadow ile ilgisi yok.
///
/// Renk çiftleri const tutulur; [Shader] yalnızca [paint] içinde,
/// boyut ([Rect]) bilindiğinde helper’larla üretilir.
abstract final class IllustrationGradients {
  // —— Bina gövdeleri (üst açık → alt koyu) ——
  static const List<Color> buildingBlue = [
    Color(0xFF93C5FD),
    Color(0xFF1D4ED8),
  ];
  static const List<Color> buildingAmber = [
    Color(0xFFFDE68A),
    Color(0xFFD97706),
  ];
  static const List<Color> buildingGray = [
    Color(0xFFE2E8F0),
    Color(0xFF94A3B8),
  ];

  /// Koyu tema — biraz daha parlak / doygun.
  static const List<Color> buildingBlueDark = [
    Color(0xFF60A5FA),
    Color(0xFF2563EB),
  ];
  static const List<Color> buildingAmberDark = [
    Color(0xFFFCD34D),
    Color(0xFFF59E0B),
  ];
  static const List<Color> buildingGrayDark = [
    Color(0xFFCBD5E1),
    Color(0xFF64748B),
  ];

  // —— Ortak kağıt (dekont + clipboard) ——
  static const List<Color> paper = [
    Color(0xFFEFF6FF),
    Color(0xFFDBEAFE),
  ];
  static const List<Color> paperDark = [
    Color(0xFF1E3A5F),
    Color(0xFF1E293B),
  ];

  // —— Onay rozeti ——
  static const List<Color> successRadial = [
    Color(0xFF4ADE80),
    Color(0xFF15803D),
  ];
  static const List<Color> successRadialDark = [
    Color(0xFF86EFAC),
    Color(0xFF16A34A),
  ];

  // —— Bildirim zili ——
  static const List<Color> bellRadial = [
    Color(0xFFFEF08A),
    Color(0xFFD97706),
  ];
  static const List<Color> bellRadialDark = [
    Color(0xFFFEF08A),
    Color(0xFFF59E0B),
  ];

  static const Color scanBeam = Color(0xFF2563EB);

  static List<Color> buildingBlueFor(bool isDark) =>
      isDark ? buildingBlueDark : buildingBlue;

  static List<Color> buildingAmberFor(bool isDark) =>
      isDark ? buildingAmberDark : buildingAmber;

  static List<Color> buildingGrayFor(bool isDark) =>
      isDark ? buildingGrayDark : buildingGray;

  static List<Color> paperFor(bool isDark) => isDark ? paperDark : paper;

  static List<Color> successRadialFor(bool isDark) =>
      isDark ? successRadialDark : successRadial;

  static List<Color> bellRadialFor(bool isDark) =>
      isDark ? bellRadialDark : bellRadial;

  /// Dikey linear — üstten alta bina gövdesi / kağıt.
  static ui.Shader verticalBody(Rect rect, List<Color> colors) =>
      ui.Gradient.linear(rect.topCenter, rect.bottomCenter, colors);

  static ui.Shader paperFill(Rect rect, bool isDark) =>
      verticalBody(rect, paperFor(isDark));

  /// Sol-üst merkezden dışa radyal (onay rozeti).
  static ui.Shader successBadge(Rect rect, bool isDark) {
    final colors = successRadialFor(isDark);
    final radius = rect.shortestSide * 0.75;
    return ui.Gradient.radial(
      Offset(rect.left + rect.width * 0.28, rect.top + rect.height * 0.28),
      radius,
      colors,
    );
  }

  /// Sol-üst merkezden dışa radyal (zil gövdesi).
  static ui.Shader bellBody(Rect rect, bool isDark) {
    final colors = bellRadialFor(isDark);
    final radius = rect.shortestSide * 0.85;
    return ui.Gradient.radial(
      Offset(rect.left + rect.width * 0.3, rect.top + rect.height * 0.25),
      radius,
      colors,
    );
  }

  /// Yatay tarama ışını — kenarlar şeffaf, orta ~0.5 opak.
  static ui.Shader scanBeamHorizontal(Rect rect) => ui.Gradient.linear(
        rect.centerLeft,
        rect.centerRight,
        [
          scanBeam.withValues(alpha: 0),
          scanBeam.withValues(alpha: 0.5),
          scanBeam.withValues(alpha: 0),
        ],
        const [0.0, 0.5, 1.0],
      );
}
