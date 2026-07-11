import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/utils/app_currency_format.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/premium_bottom_sheet.dart';
import '../../../buildings/presentation/utils/apartment_ui_utils.dart';
import '../../domain/entities/due_entity.dart';
import '../providers/dues_provider.dart';
import '../utils/dues_ui_helpers.dart';

/// Elden ödeme veya dekont inceleme — detay sheet ve swipe için ortak akış.
Future<bool> collectDuePayment({
  required BuildContext context,
  required WidgetRef ref,
  required DueEntity due,
  required String buildingId,
}) async {
  final t = context.t.features.dues;
  final common = context.t.common;

  final choice = await PremiumBottomSheetScaffold.show<String>(
    context: context,
    builder: (_) => PremiumBottomSheetScaffold(
      scrollable: false,
      title: t.collectPayment,
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PremiumActionSheetTile(
            icon: Icons.payments_outlined,
            label: t.transactions.sourceManual,
            iconColor: AppColors.success,
            iconBackground: AppColors.successBg,
            onTap: () => Navigator.pop(context, 'manual'),
          ),
          const SizedBox(height: AppSizes.spacingXS),
          PremiumActionSheetTile(
            icon: Icons.receipt_long_outlined,
            label: t.reviewDekont,
            iconColor: AppColors.statusBlue,
            iconBackground: AppColors.statusBlueBg,
            onTap: () => Navigator.pop(context, 'dekont'),
          ),
        ],
      ),
    ),
  );

  if (!context.mounted || choice == null) return false;

  if (choice == 'dekont') {
    context.push('/manager-dashboard/dekonts');
    return false;
  }

  final apartmentLabel = ApartmentUiUtils.formatApartmentLabel(
    context,
    due.apartmentNumber,
  );
  final periodLabel = '${monthName(context, due.month)} ${due.year}';
  final remainingLabel = AppCurrencyFormat.format(
    due.remainingAmount > 0 ? due.remainingAmount : due.amount,
  );

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(t.collectPaymentConfirmTitle),
      content: Text(
        t.collectPaymentConfirmBody
            .replaceAll('{apartment}', apartmentLabel)
            .replaceAll('{period}', periodLabel)
            .replaceAll('{amount}', remainingLabel),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(common.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(t.collectPayment),
        ),
      ],
    ),
  );

  if (confirmed != true || !context.mounted) return false;

  await ref.read(duesNotifierProvider.notifier).updateStatus(
        buildingId: buildingId,
        dueId: due.id,
        status: DueStatus.paid,
      );

  if (!context.mounted) return false;

  final error = ref.read(duesNotifierProvider).error;
  if (error != null) return false;

  return true;
}
