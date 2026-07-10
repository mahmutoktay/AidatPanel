import 'package:flutter/material.dart';

/// Bina/site kartları için ortak görsel sabitler (liste kartları, detay yüzeyleri).
/// Radius DashboardScreenStyle ile hizalı (18).
abstract final class BuildingSummaryCard {
  static const cardRadius = 18.0;
  static const statusStripWidth = 6.0;

  static List<BoxShadow> get cardShadow => const [];
}
