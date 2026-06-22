import 'package:flutter/material.dart';

import 'app_brand_colors.dart';

/// Açık ve koyu tema — logo renkleri (turuncu + lacivert) tabanlı palet.
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
    required this.navSelected,
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
  final Color navSelected;

  Color get sheetBackground => dashboardBackground;

  static const light = AppColorPalette(
    primary: AppBrandColors.panelNavy,
    primaryLight: Color(0xFF003D8F),
    background: Color(0xFFFFFFFF),
    surface: Color(0xFFFFFFFF),
    fill: Color(0xFFEEF2F8),
    dashboardBackground: Color(0xFFF5F7FB),
    border: Color(0x6600235B),
    textPrimary: Color(0xFF00235B),
    textSecondary: Color(0xFF5C6B80),
    textDisabled: Color(0xFF9AA8B8),
    successBg: Color(0xFFDCFCE7),
    errorBg: Color(0xFFFEE2E2),
    warningBg: Color(0xFFFFF3E6),
    infoBg: Color(0xFFE8F0FE),
    expenseAccentBg: Color(0xFFF3E8FF),
    systemMuted: Color(0xFF5C6B80),
    inkDark: AppBrandColors.panelNavy,
    actionButton: AppBrandColors.aidatOrange,
    actionButtonForeground: Color(0xFFFFFFFF),
    mutedText: Color(0xFF7A8A9E),
    statusGreenBg: Color(0xFFE7F8EF),
    statusRedBg: Color(0xFFFDEAE9),
    statusAmberBg: Color(0xFFFFF0E0),
    statusBlueBg: Color(0xFFE8F0FE),
    lineLight: Color(0xFFE2E8F2),
    paymentCta: Color(0xFFFFE8D9),
    paymentCtaForeground: Color(0xFF9A3412),
    datePickerHeaderForeground: Color(0xFFFFFFFF),
    datePickerSelectedDayForeground: Color(0xFFFFFFFF),
    navSelected: AppBrandColors.aidatOrange,
  );

  static const dark = AppColorPalette(
    primary: AppBrandColors.panelNavyOnDark,
    primaryLight: Color(0xFF8BB8E8),
    background: Color(0xFF0F1624),
    surface: Color(0xFF141D2E),
    fill: Color(0xFF1C2840),
    dashboardBackground: Color(0xFF0A0F18),
    border: Color(0x666BA3E0),
    textPrimary: Color(0xFFF0F4FA),
    textSecondary: Color(0xFF9BB0C9),
    textDisabled: Color(0xFF6B7F96),
    successBg: Color(0x3316A34A),
    errorBg: Color(0x33DC2626),
    warningBg: Color(0x33FF6600),
    infoBg: Color(0x336BA3E0),
    expenseAccentBg: Color(0x339333EA),
    systemMuted: Color(0xFF9BB0C9),
    inkDark: Color(0xFFF0F4FA),
    actionButton: AppBrandColors.aidatOrange,
    actionButtonForeground: Color(0xFFFFFFFF),
    mutedText: Color(0xFF9BB0C9),
    statusGreenBg: Color(0x332FB872),
    statusRedBg: Color(0x33F0463C),
    statusAmberBg: Color(0x33FF6600),
    statusBlueBg: Color(0x336BA3E0),
    lineLight: Color(0xFF243044),
    paymentCta: Color(0xFF3D2610),
    paymentCtaForeground: Color(0xFFFFB380),
    datePickerHeaderForeground: Color(0xFF0A0F18),
    datePickerSelectedDayForeground: Color(0xFF0A0F18),
    navSelected: AppBrandColors.aidatOrange,
  );
}
