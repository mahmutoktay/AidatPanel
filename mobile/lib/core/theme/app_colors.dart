import 'package:flutter/material.dart';

import 'app_color_palette.dart';
import 'app_sizes.dart';

/// Monokrom marka (siyah) + anlamlı durum renkleri.
/// Nötr renkler aktif paletten gelir; tema değişiminde [applyPalette] çağrılır.
class AppColors {
  static AppColorPalette _palette = AppColorPalette.light;

  static void applyPalette(AppColorPalette palette) {
    _palette = palette;
  }

  static bool get isDark => identical(_palette, AppColorPalette.dark);

  // Ana marka — palet tabanlı
  static Color get primary => _palette.primary;
  static Color get primaryLight => _palette.primaryLight;

  static const Color accent = Color(0xFFFF6600);

  static Color get paymentCta => _palette.paymentCta;
  static Color get paymentCtaForeground => _palette.paymentCtaForeground;

  // Durum renkleri — metin / rozet vurgusu (tema bağımsız)
  static const Color success = Color(0xFF16A34A);
  static const Color successLight = Color(0xFF10B981);
  static const Color error = Color(0xFFDC2626);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF2563EB);

  // Nötr renkler — palet tabanlı
  static Color get background => _palette.background;
  static Color get surface => _palette.surface;
  static Color get fill => _palette.fill;
  static Color get dashboardBackground => _palette.dashboardBackground;
  static Color get sheetBackground => _palette.sheetBackground;

  // Grafik vurgu renkleri (fl_chart)
  static const Color chartGreen = Color(0xFF4CAF50);
  static const Color chartRed = Color(0xFFF44336);
  static const Color chartBlue = Color(0xFF2196F3);
  static const Color chartYellow = Color(0xFFFFC107);
  static const Color chartOrange = Color(0xFFFF9800);

  static const double borderOpacity = 0.6;

  static Color get border => _palette.border;
  static Color get borderColor => border;

  static Color get textPrimary => _palette.textPrimary;
  static Color get textSecondary => _palette.textSecondary;
  static Color get textDisabled => _palette.textDisabled;

  // Durum badge arka planları — palet tabanlı
  static Color get successBg => _palette.successBg;
  static Color get errorBg => _palette.errorBg;
  static Color get warningBg => _palette.warningBg;
  static Color get infoBg => _palette.infoBg;

  static const Color expenseAccent = Color(0xFF9333EA);
  static Color get expenseAccentBg => _palette.expenseAccentBg;

  static Color get systemMuted => _palette.systemMuted;

  // Profil/ayarlar alias
  static Color get ink => primary;
  static Color get muted => textSecondary;
  static Color get line => border;

  static Color get inkDark => _palette.inkDark;

  static Color get actionButton => _palette.actionButton;
  static Color get actionButtonForeground => _palette.actionButtonForeground;
  static Color get mutedText => _palette.mutedText;

  static const Color statusGreen = Color(0xFF2FB872);
  static Color get statusGreenBg => _palette.statusGreenBg;
  static const Color statusRed = Color(0xFFF0463C);
  static Color get statusRedBg => _palette.statusRedBg;
  static const Color statusAmber = Color(0xFFF2A93D);
  static Color get statusAmberBg => _palette.statusAmberBg;
  static const Color statusBlue = Color(0xFF3D7CF2);
  static Color get statusBlueBg => _palette.statusBlueBg;
  static Color get lineLight => _palette.lineLight;

  static Color get datePickerHeaderForeground =>
      _palette.datePickerHeaderForeground;
  static Color get datePickerSelectedDayForeground =>
      _palette.datePickerSelectedDayForeground;

  static BorderSide get cardBorderSide => BorderSide(
        color: border,
        width: AppSizes.cardBorderWidth,
      );

  static Border get cardBorder => Border.fromBorderSide(cardBorderSide);
}
