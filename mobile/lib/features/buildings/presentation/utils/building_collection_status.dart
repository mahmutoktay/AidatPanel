import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/strings.g.dart';

/// Bina listesi sıralama seçenekleri.
enum BuildingListSort { byOverdue, byCollectionRate, byName }

/// Tahsilat oranına göre sağlık seviyesi.
enum BuildingHealthLevel { healthy, warning, critical }

/// Tahsilat oranından türetilen renk ve arka plan.
class BuildingCollectionStatus {
  final BuildingHealthLevel level;
  final Color color;
  final Color backgroundColor;

  const BuildingCollectionStatus({
    required this.level,
    required this.color,
    required this.backgroundColor,
  });

  static BuildingCollectionStatus fromRate(double rate) {
    if (rate >= 80) {
      return BuildingCollectionStatus(
        level: BuildingHealthLevel.healthy,
        color: AppColors.statusGreen,
        backgroundColor: AppColors.statusGreenBg,
      );
    }
    if (rate >= 40) {
      return BuildingCollectionStatus(
        level: BuildingHealthLevel.warning,
        color: AppColors.statusAmber,
        backgroundColor: AppColors.statusAmberBg,
      );
    }
    return BuildingCollectionStatus(
      level: BuildingHealthLevel.critical,
      color: AppColors.statusRed,
      backgroundColor: AppColors.statusRedBg,
    );
  }
}

/// Alt durum rozeti — gecikmiş / bekleyen / tamam.
class BuildingStatusChip {
  final String label;
  final Color color;
  final Color backgroundColor;
  final String emoji;

  const BuildingStatusChip({
    required this.label,
    required this.color,
    required this.backgroundColor,
    required this.emoji,
  });
}

BuildingStatusChip resolveBuildingStatusChip(
  BuildContext context, {
  required int overdueCount,
  required int pendingCount,
}) {
  final t = context.t.features.buildings.list;
  if (overdueCount > 0) {
    return BuildingStatusChip(
      label: t.unitsOverdue.replaceAll('{count}', '$overdueCount'),
      color: AppColors.statusRed,
      backgroundColor: AppColors.statusRedBg,
      emoji: '⚠',
    );
  }
  if (pendingCount > 0) {
    return BuildingStatusChip(
      label: t.unitsWaiting.replaceAll('{count}', '$pendingCount'),
      color: AppColors.statusAmber,
      backgroundColor: AppColors.statusAmberBg,
      emoji: '⏳',
    );
  }
  return BuildingStatusChip(
    label: t.allPaymentsComplete,
    color: AppColors.statusGreen,
    backgroundColor: AppColors.statusGreenBg,
    emoji: '✓',
  );
}

String buildingListSortLabel(BuildContext context, BuildingListSort sort) {
  final t = context.t.features.buildings.list;
  return switch (sort) {
    BuildingListSort.byOverdue => t.sortByOverdue,
    BuildingListSort.byCollectionRate => t.sortByCollectionRate,
    BuildingListSort.byName => t.sortByName,
  };
}
