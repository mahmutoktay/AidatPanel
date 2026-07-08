import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/user_error_message.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/toast_overlay.dart';
import '../../../dues/domain/entities/due_remind_result.dart';
import '../../../dues/domain/entities/due_entity.dart';
import '../../../dues/presentation/providers/dues_provider.dart';
import '../../domain/entities/manager_dashboard_entities.dart';

DueEntity? findDueById(
  Map<String, List<DueEntity>> allDues,
  String dueId,
  String buildingId,
) {
  for (final due in allDues[buildingId] ?? const <DueEntity>[]) {
    if (due.id == dueId) return due;
  }
  return null;
}

Map<String, List<String>> groupOverdueDueIdsByBuilding(
  Map<String, List<DueEntity>> allDues, {
  Set<String>? buildingIds,
}) {
  final grouped = <String, List<String>>{};

  for (final entry in allDues.entries) {
    if (buildingIds != null && !buildingIds.contains(entry.key)) continue;

    final overdueIds = entry.value
        .where((due) => due.status == DueStatus.overdue && due.resident != null)
        .map((due) => due.id)
        .toList(growable: false);
    if (overdueIds.isNotEmpty) {
      grouped[entry.key] = overdueIds;
    }
  }

  return grouped;
}

int overdueDueCount(Map<String, List<String>> dueIdsByBuilding) {
  return dueIdsByBuilding.values.fold<int>(0, (sum, ids) => sum + ids.length);
}

Future<void> remindOverdueDuesByBuilding({
  required BuildContext context,
  required WidgetRef ref,
  required Map<String, List<String>> dueIdsByBuilding,
  required ValueChanged<bool> onLoadingChanged,
}) async {
  if (overdueDueCount(dueIdsByBuilding) == 0) return;

  onLoadingChanged(true);
  try {
    var reminded = 0;
    var skippedCooldown = 0;
    for (final entry in dueIdsByBuilding.entries) {
      final result = await ref.read(duesRepositoryProvider).remindBuildingDues(
            entry.key,
            dueIds: entry.value,
          );
      reminded += result.reminded;
      skippedCooldown += result.skippedCooldown;
    }

    if (!context.mounted) return;
    final t = context.t.features.dashboard;
    if (reminded > 0) {
      ref.read(toastProvider.notifier).show(
            t.remindAllSent.replaceAll('{count}', '$reminded'),
            type: ToastType.info,
          );
    } else if (skippedCooldown > 0) {
      ref.read(toastProvider.notifier).show(
            t.remindCooldown,
            type: ToastType.info,
          );
    } else {
      ref.read(toastProvider.notifier).show(
            t.remindNoRecipient,
            type: ToastType.info,
          );
    }
  } catch (error) {
    if (!context.mounted) return;
    ref.read(toastProvider.notifier).show(
          userFacingError(error),
          type: ToastType.error,
        );
  } finally {
    onLoadingChanged(false);
  }
}

void _showRemindResultToast({
  required WidgetRef ref,
  required DueRemindResult result,
  required String remindSent,
  required String remindCooldown,
  required String remindNoRecipient,
}) {
  if (result.reminded > 0) {
    ref.read(toastProvider.notifier).show(
          remindSent,
          type: ToastType.info,
        );
  } else if (result.skippedCooldown > 0) {
    ref.read(toastProvider.notifier).show(
          remindCooldown,
          type: ToastType.info,
        );
  } else {
    ref.read(toastProvider.notifier).show(
          remindNoRecipient,
          type: ToastType.info,
        );
  }
}

Future<void> remindOverdueApartment({
  required BuildContext context,
  required WidgetRef ref,
  required ManagerOverdueApartmentItem item,
  required ValueChanged<String?> onLoadingChanged,
}) async {
  onLoadingChanged(item.dueId);
  try {
    final result = await ref.read(duesRepositoryProvider).remindBuildingDues(
          item.buildingId,
          dueIds: [item.dueId],
        );
    if (!context.mounted) return;
    final t = context.t.features.dashboard;
    _showRemindResultToast(
      ref: ref,
      result: result,
      remindSent: t.remindSent,
      remindCooldown: t.remindCooldown,
      remindNoRecipient: t.remindNoRecipient,
    );
  } catch (error) {
    if (!context.mounted) return;
    ref.read(toastProvider.notifier).show(
          userFacingError(error),
          type: ToastType.error,
        );
  } finally {
    onLoadingChanged(null);
  }
}

Future<void> remindAllOverdueApartments({
  required BuildContext context,
  required WidgetRef ref,
  required List<ManagerOverdueApartmentItem> items,
  required ValueChanged<bool> onLoadingChanged,
}) async {
  if (items.isEmpty) return;

  final dueIdsByBuilding = <String, List<String>>{};
  for (final item in items) {
    dueIdsByBuilding.putIfAbsent(item.buildingId, () => []).add(item.dueId);
  }

  return remindOverdueDuesByBuilding(
    context: context,
    ref: ref,
    dueIdsByBuilding: dueIdsByBuilding,
    onLoadingChanged: onLoadingChanged,
  );
}
