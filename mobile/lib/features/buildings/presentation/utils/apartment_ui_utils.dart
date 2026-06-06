import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/strings.g.dart';
import '../../../apartments/domain/entities/apartment_entity.dart';

class StatusInfo {
  final String label;
  final Color color;
  final Color bgColor;

  StatusInfo({
    required this.label,
    required this.color,
    required this.bgColor,
  });
}

class ApartmentUiUtils {
  static String formatApartmentLabel(BuildContext context, String apartmentNumber) {
    final match = RegExp(r'(\d+)([A-Za-z]?)').firstMatch(apartmentNumber);
    if (match == null) return apartmentNumber;
    final floor = match.group(1);
    final letter = match.group(2);
    if (letter != null && letter.isNotEmpty) {
      return '$floor. ${context.t.common.floorLabel} • ${context.t.common.apartmentLabel} $letter';
    }
    return '$floor. ${context.t.common.floorLabel}';
  }

  static String formatPhone(String phone) {
    final clean = phone.replaceAll(RegExp(r'[^\d+]'), '');
    if (clean.startsWith('+90') && clean.length == 13) {
      return '+90 ${clean.substring(3, 6)} ${clean.substring(6, 9)} ${clean.substring(9, 11)} ${clean.substring(11)}';
    }
    return phone;
  }

  static StatusInfo getStatusInfo(BuildContext context, PaymentStatus status) {
    switch (status) {
      case PaymentStatus.paid:
        return StatusInfo(
          label: context.t.common.paidStatus,
          color: AppColors.success,
          bgColor: AppColors.success.withValues(alpha: 0.12),
        );
      case PaymentStatus.pending:
        return StatusInfo(
          label: context.t.common.pendingStatus,
          color: AppColors.warning,
          bgColor: AppColors.warning.withValues(alpha: 0.12),
        );
      case PaymentStatus.overdue:
        return StatusInfo(
          label: context.t.common.overdueStatus,
          color: AppColors.error,
          bgColor: AppColors.error.withValues(alpha: 0.12),
        );
    }
  }

  static String initialsFromName(String name) {
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts.isNotEmpty ? parts[0][0].toUpperCase() : '?';
  }

  static String formatShortDate(DateTime d) {
    final day = d.day.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');
    return '$day.$month.${d.year}';
  }
}
