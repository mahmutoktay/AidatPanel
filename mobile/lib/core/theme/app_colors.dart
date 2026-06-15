import 'package:flutter/material.dart';

import 'app_sizes.dart';

/// Monokrom marka (siyah) + anlamlı durum renkleri.

class AppColors {
  // Ana marka renkleri — siyah-beyaz

  static const Color primary = Color(0xFF111111);

  static const Color primaryLight = Color(0xFF333333);

  static const Color accent = Color(0xFFF59E0B);

  /// Ödeme Yap CTA — hafif sarımsı turuncu zemin, koyu metin.
  static const Color paymentCta = Color(0xFFFFE4B5);

  static const Color paymentCtaForeground = Color(0xFF78350F);

  // Durum renkleri — metin / rozet vurgusu

  static const Color success = Color(0xFF16A34A);

  static const Color successLight = Color(0xFF10B981);

  static const Color error = Color(0xFFDC2626);

  static const Color warning = Color(0xFFF59E0B);

  static const Color info = Color(0xFF2563EB);

  // Nötr renkler

  static const Color background = Color(0xFFFFFFFF);

  static const Color surface = Color(0xFFFFFFFF);

  static const Color fill = Color(0xFFF3F4F6);

  /// Dashboard arka planı (mockup #F5F5F7).
  static const Color dashboardBackground = Color(0xFFF5F5F7);

  // Grafik vurgu renkleri (fl_chart)
  static const Color chartGreen = Color(0xFF4CAF50);
  static const Color chartRed = Color(0xFFF44336);
  static const Color chartBlue = Color(0xFF2196F3);
  static const Color chartYellow = Color(0xFFFFC107);
  static const Color chartOrange = Color(0xFFFF9800);

  /// Çerçeve opaklığı — [primary] üzerinde; tüm kart/form kenarlıkları.
  static const double borderOpacity = 0.6;

  /// Kart, kutu ve form çerçeveleri — siyah, hafif saydam (primary × borderOpacity).
  static const Color border = Color(0x99111111);

  static const Color borderColor = border;

  static const Color textPrimary = Color(0xFF111111);

  static const Color textSecondary = Color(0xFF6B7280);

  static const Color textDisabled = Color(0xFF9CA3AF);

  // Durum badge arka planları

  static const Color successBg = Color(0xFFDCFCE7);

  static const Color errorBg = Color(0xFFFEE2E2);

  static const Color warningBg = Color(0xFFFEF3C7);

  static const Color infoBg = Color(0xFFDBEAFE);

  /// Profil/ayarlar ekranları için alias (geriye uyum).

  static const Color ink = primary;

  static const Color muted = textSecondary;

  static const Color line = border;

  /// Bina listesi / dashboard durum paleti (mockup).
  static const Color inkDark = Color(0xFF161B22);
  static const Color mutedText = Color(0xFF8A93A6);
  static const Color statusGreen = Color(0xFF2FB872);
  static const Color statusGreenBg = Color(0xFFE7F8EF);
  static const Color statusRed = Color(0xFFF0463C);
  static const Color statusRedBg = Color(0xFFFDEAE9);
  static const Color statusAmber = Color(0xFFF2A93D);
  static const Color statusAmberBg = Color(0xFFFDF3E3);
  static const Color statusBlue = Color(0xFF3D7CF2);
  static const Color statusBlueBg = Color(0xFFEAF1FF);
  static const Color lineLight = Color(0xFFECEEF2);

  /// Kart / kutu çerçevesi — renk + kalınlık tek kaynak.
  static const BorderSide cardBorderSide = BorderSide(
    color: border,
    width: AppSizes.cardBorderWidth,
  );

  static const Border cardBorder = Border.fromBorderSide(cardBorderSide);
}
