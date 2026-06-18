import 'package:flutter/material.dart';

import '../../core/theme/app_sizes.dart';
import 'minimal_form_widgets.dart';
import 'premium_bottom_sheet.dart';

/// Filtre bottom sheet alanı yapılandırması.
class PremiumFilterFieldConfig {
  final String label;
  final String? value;
  final String hint;
  final IconData icon;
  final VoidCallback onTap;

  const PremiumFilterFieldConfig({
    required this.label,
    this.value,
    required this.hint,
    required this.icon,
    required this.onTap,
  });
}

/// Premium filtre bottom sheet — [DuesAmountUpdateSheet] ile aynı görsel dil.
class PremiumFilterSheet extends StatelessWidget {
  const PremiumFilterSheet({
    super.key,
    required this.title,
    required this.applyLabel,
    required this.fields,
    this.onApply,
    this.enabled = true,
  });

  final String title;
  final String applyLabel;
  final List<PremiumFilterFieldConfig> fields;
  final VoidCallback? onApply;
  final bool enabled;

  static Future<void> show({
    required BuildContext context,
    required String title,
    required String applyLabel,
    required List<PremiumFilterFieldConfig> Function(
      BuildContext context,
      void Function(void Function()) setSheetState,
    ) fieldBuilder,
    required VoidCallback onApply,
    bool enabled = true,
  }) {
    return PremiumBottomSheetScaffold.show<void>(
      context: context,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final fields = fieldBuilder(context, setSheetState);
            return PremiumFilterSheet(
              title: title,
              applyLabel: applyLabel,
              fields: fields,
              enabled: enabled,
              onApply: enabled
                  ? () {
                      onApply();
                      Navigator.of(sheetContext).pop();
                    }
                  : null,
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PremiumBottomSheetScaffold(
      title: title,
      scrollable: true,
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < fields.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSizes.spacingM),
            MinimalPickerField(
              label: fields[i].label,
              value: fields[i].value,
              hint: fields[i].hint,
              icon: fields[i].icon,
              enabled: enabled,
              onTap: fields[i].onTap,
            ),
          ],
        ],
      ),
      actions: PremiumSheetActions(
        primaryLabel: applyLabel,
        onPrimary: onApply,
        primaryEnabled: enabled,
      ),
    );
  }
}
