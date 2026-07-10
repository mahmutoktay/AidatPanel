import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/ticket_entity.dart';

/// Liste kartı, detay rozeti ve stepper için ortak durum renkleri.
Color ticketStatusColor(TicketStatus status) {
  switch (status) {
    case TicketStatus.open:
      return AppColors.warning;
    case TicketStatus.inProgress:
      return AppColors.info;
    case TicketStatus.resolved:
      return AppColors.success;
    case TicketStatus.closed:
      return AppColors.error;
  }
}
