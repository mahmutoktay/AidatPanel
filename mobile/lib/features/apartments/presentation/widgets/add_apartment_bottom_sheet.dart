import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/utils/user_error_message.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/minimal_form_widgets.dart';
import '../../../../shared/widgets/number_grid_selector.dart';
import '../../../../shared/widgets/premium_bottom_sheet.dart';
import '../../../../shared/widgets/toast_overlay.dart';
import '../../data/apartments_store.dart';

/// Yeni daire ekleme formu.
class AddApartmentBottomSheet extends ConsumerStatefulWidget {
  final String buildingId;

  const AddApartmentBottomSheet({super.key, required this.buildingId});

  static Future<void> show(
    BuildContext context, {
    required String buildingId,
  }) {
    return PremiumBottomSheetScaffold.show<void>(
      context: context,
      builder: (_) => AddApartmentBottomSheet(buildingId: buildingId),
    );
  }

  @override
  ConsumerState<AddApartmentBottomSheet> createState() =>
      _AddApartmentBottomSheetState();
}

class _AddApartmentBottomSheetState extends ConsumerState<AddApartmentBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _numberController = TextEditingController();
  int? _floor;
  bool _saving = false;

  static const int _floorMin = -5;
  static const int _floorQuickMax = 15;
  static const int _floorManualMax = 200;

  @override
  void dispose() {
    _numberController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final number = _numberController.text.trim();

    try {
      await ref
          .read(apartmentsStoreProvider(widget.buildingId).notifier)
          .addApartment(number: number, floor: _floor);
      if (!mounted) return;
      Navigator.of(context).pop();
      ref.read(toastProvider.notifier).show(
            context.t.common.apartmentCreated,
            type: ToastType.success,
          );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ref.read(toastProvider.notifier).show(
            userFacingError(e),
            type: ToastType.error,
          );
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ref.read(toastProvider.notifier).show(
            context.t.common.errorKeys.apartmentCreateFailed,
            type: ToastType.error,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t.common;

    return Form(
      key: _formKey,
      child: PremiumBottomSheetScaffold(
        title: t.addApartment,
        scrollable: true,
        body: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MinimalTextField(
              controller: _numberController,
              label: t.apartmentNumberLabel,
              icon: Icons.door_front_door_outlined,
              required: true,
              enabled: !_saving,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? t.fieldRequired : null,
            ),
            const SizedBox(height: AppSizes.spacingM),
            Text(
              t.floorOptional,
              style: AppTypography.body2.copyWith(
                color: AppColors.inkDark,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSizes.spacingS),
            NumberGridSelector(
              min: _floorMin,
              maxQuickPick: _floorQuickMax,
              gridColumns: 5,
              manualMax: _floorManualMax,
              selected: _floor,
              onQuickPick: (value) => setState(() => _floor = value),
              onManualConfirm: (value) => setState(() => _floor = value),
            ),
          ],
        ),
        actions: PremiumSheetActions(
          primaryLabel: t.addApartment,
          onPrimary: _saving ? null : _save,
          primaryLoading: _saving,
          icon: Icons.add_rounded,
          secondaryLabel: t.cancelBtn,
          onSecondary: _saving ? null : () => Navigator.of(context).pop(),
          secondaryEnabled: !_saving,
        ),
      ),
    );
  }
}
