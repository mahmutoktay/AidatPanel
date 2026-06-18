import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../l10n/strings.g.dart';
import 'premium_bottom_sheet.dart';

/// `showDueDayPicker` "Gün seçin" satırı için sentinel (-1).
const int kDueDayClearSentinel = -1;

/// Aidat günü (1–28) seçimi için ortak bottom sheet.
/// İptal: `null`. Temizle (`allowClear`): [kDueDayClearSentinel].
Future<int?> showDueDayPicker(
  BuildContext context, {
  int? selectedDueDay,
  bool allowClear = true,
}) {
  final t = context.t.common;

  return PremiumBottomSheetScaffold.show<int>(
    context: context,
    builder: (ctx) => PremiumBottomSheetScaffold(
      title: t.dueDay,
      scrollable: true,
      body: PremiumActionSheetList(
        children: [
          if (allowClear)
            PremiumActionSheetTile(
              icon: Icons.event_busy_outlined,
              label: t.selectDueDay,
              trailing: selectedDueDay == null
                  ? Icon(Icons.check_rounded, color: AppColors.inkDark)
                  : null,
              onTap: () => Navigator.pop(ctx, kDueDayClearSentinel),
            ),
          for (var day = 1; day <= 28; day++)
            PremiumActionSheetTile(
              icon: Icons.calendar_today_outlined,
              label: '$day',
              trailing: selectedDueDay == day
                  ? Icon(Icons.check_rounded, color: AppColors.inkDark)
                  : null,
              onTap: () => Navigator.pop(ctx, day),
            ),
        ],
      ),
    ),
  );
}
