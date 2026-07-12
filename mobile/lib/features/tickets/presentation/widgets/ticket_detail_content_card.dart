import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/theme/dashboard_screen_style.dart';
import '../../domain/entities/ticket_entity.dart';
import '../utils/ticket_labels.dart';
import '../utils/ticket_status_style.dart';

String resolveTicketAttachmentUrl(String raw) {
  final trimmed = raw.trim();
  if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
    return trimmed;
  }
  final path = trimmed.startsWith('/') ? trimmed : '/$trimmed';
  return '${ApiConstants.baseUrl}$path';
}

/// Tek talep kartı: ikon + tarih + durum (tek satır), ardından düz açıklama.
class TicketDetailContentCard extends StatelessWidget {
  final TicketEntity ticket;
  final bool showStatusChip;

  const TicketDetailContentCard({
    super.key,
    required this.ticket,
    this.showStatusChip = true,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = ticketStatusColor(ticket.status);
    final date =
        '${ticket.createdAt.day}.${ticket.createdAt.month}.${ticket.createdAt.year}';
    final attachmentUrl = ticket.attachmentUrl?.trim();
    final hasAttachment =
        attachmentUrl != null && attachmentUrl.isNotEmpty;
    final resolvedAttachmentUrl =
        hasAttachment ? resolveTicketAttachmentUrl(attachmentUrl) : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.cardPadding),
      decoration: DashboardScreenStyle.whiteCard().copyWith(
        border: Border.all(
          color: statusColor.withValues(alpha: 0.15),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _categoryIcon(ticket.category),
                  color: statusColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSizes.spacingS),
              Text(
                date,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textDisabled,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (showStatusChip)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    ticket.status.label(context).toUpperCase(),
                    style: AppTypography.caption.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                      fontSize: 10,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSizes.spacingS),
          Text(
            ticket.description,
            style: AppTypography.body1.copyWith(
              color: AppColors.textPrimary,
              height: 1.45,
            ),
          ),
          if (hasAttachment && resolvedAttachmentUrl != null) ...[
            const SizedBox(height: AppSizes.spacingM),
            Align(
              alignment: Alignment.centerLeft,
              child: _AttachmentThumbnail(url: resolvedAttachmentUrl),
            ),
          ],
        ],
      ),
    );
  }

  IconData _categoryIcon(TicketCategory category) {
    switch (category) {
      case TicketCategory.complaint:
        return Icons.report_problem_outlined;
      case TicketCategory.request:
        return Icons.handyman_outlined;
      case TicketCategory.malfunction:
        return Icons.build_circle_outlined;
      case TicketCategory.other:
        return Icons.more_horiz_rounded;
    }
  }
}

class _AttachmentThumbnail extends StatelessWidget {
  final String url;

  const _AttachmentThumbnail({required this.url});

  void _openFullScreen(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.92),
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(AppSizes.spacingM),
          child: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 5,
                  child: CachedNetworkImage(
                    imageUrl: url,
                    fit: BoxFit.contain,
                    placeholder: (context, url) => const SizedBox(
                      width: 48,
                      height: 48,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    errorWidget: (context, url, error) => Icon(
                      Icons.broken_image_outlined,
                      color: AppColors.textDisabled,
                      size: 48,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  icon: const Icon(Icons.close, color: Colors.white, size: 28),
                  style: IconButton.styleFrom(
                    minimumSize: const Size(48, 48),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openFullScreen(context),
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.border.withValues(alpha: 0.5),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.cover,
              placeholder: (context, url) => ColoredBox(
                color: AppColors.fill,
                child: const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
              errorWidget: (context, url, error) => ColoredBox(
                color: AppColors.fill,
                child: Icon(
                  Icons.broken_image_outlined,
                  color: AppColors.textDisabled,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
