import 'package:flutter/material.dart';

/// Açık ve koyu tema renk paleti.
///
/// Logo lacivert (`#082860`) + turuncu (`#F86000`) ile
/// [resources/AIDATPANEL.md] slate/amber doküman paletinin harmanı.
class AppColorPalette {
  const AppColorPalette({
    required this.primary,
    required this.primaryLight,
    required this.accent,
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
  final Color accent;
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

  /// Açık tema — lacivert primary, turuncu accent, slate nötrler.
  static const light = AppColorPalette(
    primary: Color(0xFF0B2F6B),
    primaryLight: Color(0xFF2D5FA8),
    accent: Color(0xFFF86000),
    background: Color(0xFFF8FAFC),
    surface: Color(0xFFFFFFFF),
    fill: Color(0xFFEEF2F7),
    dashboardBackground: Color(0xFFF3F5F9),
    border: Color(0xFFE2E8F0),
    textPrimary: Color(0xFF0F172A),
    textSecondary: Color(0xFF475569),
    textDisabled: Color(0xFF94A3B8),
    successBg: Color(0xFFDCFCE7),
    errorBg: Color(0xFFFEE2E2),
    warningBg: Color(0xFFFEF3C7),
    infoBg: Color(0xFFDBEAFE),
    expenseAccentBg: Color(0xFFF3E8FF),
    systemMuted: Color(0xFF64748B),
    inkDark: Color(0xFF0B2F6B),
    actionButton: Color(0xFF0B2F6B),
    actionButtonForeground: Color(0xFFFFFFFF),
    mutedText: Color(0xFF64748B),
    statusGreenBg: Color(0xFFE7F8EF),
    statusRedBg: Color(0xFFFDEAE9),
    statusAmberBg: Color(0xFFFDF3E3),
    statusBlueBg: Color(0xFFEAF1FF),
    lineLight: Color(0xFFE2E8F0),
    paymentCta: Color(0xFFFFE8D6),
    paymentCtaForeground: Color(0xFF9A3B00),
    datePickerHeaderForeground: Color(0xFFFFFFFF),
    datePickerSelectedDayForeground: Color(0xFFFFFFFF),
  );

  /// Koyu tema — lacivert-siyah yüzeyler; aksiyon / vurgu turuncu.
  static const dark = AppColorPalette(
    primary: Color(0xFFE8EEF8),
    primaryLight: Color(0xFFB8C9E8),
    accent: Color(0xFFF86000),
    background: Color(0xFF121A2A),
    surface: Color(0xFF121A2A),
    fill: Color(0xFF1A2438),
    dashboardBackground: Color(0xFF0A101C),
    border: Color(0xFF2A3548),
    textPrimary: Color(0xFFE8EEF8),
    textSecondary: Color(0xFF94A3B8),
    textDisabled: Color(0xFF64748B),
    successBg: Color(0x3316A34A),
    errorBg: Color(0x33DC2626),
    warningBg: Color(0x33F59E0B),
    infoBg: Color(0x332563EB),
    expenseAccentBg: Color(0x339333EA),
    systemMuted: Color(0xFF94A3B8),
    inkDark: Color(0xFFE8EEF8),
    actionButton: Color(0xFFF86000),
    actionButtonForeground: Color(0xFFFFFFFF),
    mutedText: Color(0xFF94A3B8),
    statusGreenBg: Color(0x332FB872),
    statusRedBg: Color(0x33F0463C),
    statusAmberBg: Color(0x33F2A93D),
    statusBlueBg: Color(0x333D7CF2),
    lineLight: Color(0xFF243044),
    paymentCta: Color(0xFF4A2408),
    paymentCtaForeground: Color(0xFFFFE4B5),
    datePickerHeaderForeground: Color(0xFF0B2F6B),
    datePickerSelectedDayForeground: Color(0xFF0B2F6B),
  );
}
