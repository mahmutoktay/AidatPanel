import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/toast_overlay.dart';
import '../../../buildings/data/buildings_store.dart';
import '../../../buildings/domain/entities/building_entity.dart';
import '../providers/dues_cache_refresh.dart';
import '../providers/dues_provider.dart';
import '../widgets/dues_quick_amount_card.dart';

/// Bina detayından aidat tutarı / günü güncelleme alt sayfasını açar.
Future<void> showBuildingDueAmountUpdateSheet(
  BuildContext context,
  WidgetRef ref,
  BuildingEntity building, {
  bool isLoading = false,
}) async {
  final amountController = TextEditingController();
  var selectedDueDay = building.dueDay;
  var affectCurrent = false;

  await DuesAmountUpdateSheet.show(
    context,
    amountController: amountController,
    selectedDueDay: selectedDueDay,
    affectCurrent: affectCurrent,
    isLoading: isLoading,
    hintAmount: building.dueAmount?.toStringAsFixed(0),
    currencySymbol: '₺',
    onDueDayChanged: (value) => selectedDueDay = value,
    onAffectCurrentChanged: (value) => affectCurrent = value,
    onSubmit: () => _submitBuildingDueAmountUpdate(
      context: context,
      ref: ref,
      building: building,
      amountController: amountController,
      selectedDueDay: selectedDueDay,
      affectCurrent: affectCurrent,
    ),
  );

  amountController.dispose();
}

Future<void> _submitBuildingDueAmountUpdate({
  required BuildContext context,
  required WidgetRef ref,
  required BuildingEntity building,
  required TextEditingController amountController,
  required int? selectedDueDay,
  required bool affectCurrent,
}) async {
  final toast = ref.read(toastProvider.notifier);
  void validationToast(String msg) {
    toast.show(msg, type: ToastType.info);
  }

  final amountText = amountController.text
      .trim()
      .replaceAll(',', '.')
      .replaceAll(' ', '');
  final dueDay = selectedDueDay;

  double? parsedAmount;
  if (amountText.isNotEmpty) {
    parsedAmount = double.tryParse(amountText);
    if (parsedAmount == null || parsedAmount <= 0) {
      validationToast(context.t.common.dueAmountInvalidPositive);
      return;
    }
  }

  final hasAmount = parsedAmount != null && parsedAmount > 0;
  final hasDueDay = dueDay != null;
  if (!hasAmount && !hasDueDay) {
    validationToast(context.t.common.dueUpdateNeedAmountOrDay);
    return;
  }

  late final double resolvedAmount;
  if (hasAmount) {
    resolvedAmount = parsedAmount;
  } else {
    final stored = building.dueAmount;
    if (stored == null || stored <= 0) {
      validationToast(context.t.common.dueUpdateNeedStoredAmount);
      return;
    }
    resolvedAmount = stored;
  }

  final ok = await ref.read(duesNotifierProvider.notifier).updateBuildingDueAmount(
        buildingId: building.id,
        dueAmount: resolvedAmount,
        dueDay: dueDay,
        currency: 'TRY',
        affectCurrent: affectCurrent,
      );

  if (!context.mounted) return;
  toast.show(
    ok
        ? context.t.common.dueAmountUpdated
        : context.t.common.dueAmountUpdateFailed,
    type: ok ? ToastType.success : ToastType.error,
  );
  if (ok) {
    amountController.clear();
    if (context.mounted) {
      Navigator.of(context).maybePop();
    }
    await ref.read(buildingsStoreProvider.notifier).refreshBuildings();
    if (!context.mounted) return;
    await invalidateDuesRelatedCaches(ref);
  }
}
