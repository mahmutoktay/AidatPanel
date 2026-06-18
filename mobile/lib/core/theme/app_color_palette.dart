import 'package:flutter/material.dart';

/// Açık ve koyu tema için nötr / yüzey renk paleti.
class AppColorPalette {
  const AppColorPalette({
    required this.primary,
    required this.primaryLight,
    required this.background,
    required this.surface,
    required this.fill,
    required this.dashboardBackground,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textDisabled,
    required this.successBg,
    required this.errorBg,
    required this.warningBg,
    required this.infoBg,
    required this.expenseAccentBg,
    required this.systemMuted,
    required this.inkDark,
    required this.actionButton,
    required this.actionButtonForeground,
    required this.mutedText,
    required this.statusGreenBg,
    required this.statusRedBg,
    required this.statusAmberBg,
    required this.statusBlueBg,
    required this.lineLight,
    required this.paymentCta,
    required this.paymentCtaForeground,
    required this.datePickerHeaderForeground,
    required this.datePickerSelectedDayForeground,
  });

  final Color primary;
  final Color primaryLight;
  final Color background;
  final Color surface;
  final Color fill;
  final Color dashboardBackground;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color textDisabled;
  final Color successBg;
  final Color errorBg;
  final Color warningBg;
  final Color infoBg;
  final Color expenseAccentBg;
  final Color systemMuted;
  final Color inkDark;
  final Color actionButton;
  final Color actionButtonForeground;
  final Color mutedText;
  final Color statusGreenBg;
  final Color statusRedBg;
  final Color statusAmberBg;
  final Color statusBlueBg;
  final Color lineLight;
  final Color paymentCta;
  final Color paymentCtaForeground;
  final Color datePickerHeaderForeground;
  final Color datePickerSelectedDayForeground;

  Color get sheetBackground => dashboardBackground;

  static const light = AppColorPalette(
    primary: Color(0xFF111111),
    primaryLight: Color(0xFF333333),
    background: Color(0xFFFFFFFF),
    surface: Color(0xFFFFFFFF),
    fill: Color(0xFFF3F4F6),
    dashboardBackground: Color(0xFFF5F4F0),
    border: Color(0x99111111),
    textPrimary: Color(0xFF111111),
    textSecondary: Color(0xFF6B7280),
    textDisabled: Color(0xFF9CA3AF),
    successBg: Color(0xFFDCFCE7),
    errorBg: Color(0xFFFEE2E2),
    warningBg: Color(0xFFFEF3C7),
    infoBg: Color(0xFFDBEAFE),
    expenseAccentBg: Color(0xFFF3E8FF),
    systemMuted: Color(0xFF4B5563),
    inkDark: Color(0xFF161B22),
    actionButton: Color(0xFF12181F),
    actionButtonForeground: Color(0xFFFFFFFF),
    mutedText: Color(0xFF8A93A6),
    statusGreenBg: Color(0xFFE7F8EF),
    statusRedBg: Color(0xFFFDEAE9),
    statusAmberBg: Color(0xFFFDF3E3),
    statusBlueBg: Color(0xFFEAF1FF),
    lineLight: Color(0xFFECEEF2),
    paymentCta: Color(0xFFFFE4B5),
    paymentCtaForeground: Color(0xFF78350F),
    datePickerHeaderForeground: Color(0xFFFFFFFF),
    datePickerSelectedDayForeground: Color(0xFFFFFFFF),
  );

  static const dark = AppColorPalette(
    primary: Color(0xFFF3F4F6),
    primaryLight: Color(0xFFE5E7EB),
    background: Color(0xFF141414),
    surface: Color(0xFF141414),
    fill: Color(0xFF1F1F1F),
    dashboardBackground: Color(0xFF0A0A0A),
    border: Color(0x99F3F4F6),
    textPrimary: Color(0xFFF3F4F6),
    textSecondary: Color(0xFF9CA3AF),
    textDisabled: Color(0xFF6B7280),
    successBg: Color(0x3316A34A),
    errorBg: Color(0x33DC2626),
    warningBg: Color(0x33F59E0B),
    infoBg: Color(0x332563EB),
    expenseAccentBg: Color(0x339333EA),
    systemMuted: Color(0xFF9CA3AF),
    inkDark: Color(0xFFF3F4F6),
    actionButton: Color(0xFFF3F4F6),
    actionButtonForeground: Color(0xFF111111),
    mutedText: Color(0xFF9CA3AF),
    statusGreenBg: Color(0x332FB872),
    statusRedBg: Color(0x33F0463C),
    statusAmberBg: Color(0x33F2A93D),
    statusBlueBg: Color(0x333D7CF2),
    lineLight: Color(0xFF2A2A2A),
    paymentCta: Color(0xFF3D2E14),
    paymentCtaForeground: Color(0xFFFFE4B5),
    datePickerHeaderForeground: Color(0xFF111111),
    datePickerSelectedDayForeground: Color(0xFF111111),
  );
}
