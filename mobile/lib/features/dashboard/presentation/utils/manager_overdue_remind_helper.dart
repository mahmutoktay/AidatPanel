import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/user_error_message.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/toast_overlay.dart';
import '../../../dues/presentation/providers/dues_provider.dart';
import '../../domain/entities/manager_dashboard_entities.dart';

Future<void> remindOverdueApartment({
  required BuildContext context,
  required WidgetRef ref,
  required ManagerOverdueApartmentItem item,
  required ValueChanged<String?> onLoadingChanged,
}) async {
  onLoadingChanged(item.dueId);
  try {
    final reminded = await ref.read(duesRepositoryProvider).remindBuildingDues(
          item.buildingId,
          dueIds: [item.dueId],
        );
    if (!context.mounted) return;
    final t = context.t.features.dashboard;
    if (reminded > 0) {
      ref.read(toastProvider.notifier).show(
            t.remindSent,
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
    onLoadingChanged(null);
  }
}
