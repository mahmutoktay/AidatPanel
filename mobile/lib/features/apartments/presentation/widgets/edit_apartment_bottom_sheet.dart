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
import '../../domain/entities/apartment_entity.dart';

/// Daire numarası ve katı düzenler.
class EditApartmentBottomSheet extends ConsumerStatefulWidget {
  final ApartmentEntity apartment;

  const EditApartmentBottomSheet({super.key, required this.apartment});

  static Future<void> show(
    BuildContext context, {
    required ApartmentEntity apartment,
  }) {
    return PremiumBottomSheetScaffold.show<void>(
      context: context,
      builder: (_) => EditApartmentBottomSheet(apartment: apartment),
    );
  }

  @override
  ConsumerState<EditApartmentBottomSheet> createState() =>
      _EditApartmentBottomSheetState();
}

class _EditApartmentBottomSheetState
    extends ConsumerState<EditApartmentBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _numberController;
  int? _floor;
  bool _saving = false;

  static const int _floorMin = -5;
  static const int _floorQuickMax = 15;
  static const int _floorManualMax = 200;

  @override
  void initState() {
    super.initState();
    _numberController =
        TextEditingController(text: widget.apartment.apartmentNumber);
    _floor = widget.apartment.floor;
  }

  @override
  void dispose() {
    _numberController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final number = _numberController.text.trim();
    final original = widget.apartment;
    final payloadNumber = number == original.apartmentNumber ? null : number;
    final payloadFloor = _floor == original.floor ? null : _floor;

    if (payloadNumber == null && payloadFloor == null) {
      if (mounted) Navigator.of(context).pop();
      return;
    }

    try {
      await ref
          .read(apartmentsStoreProvider(original.buildingId).notifier)
          .editApartment(
            apartmentId: original.id,
            number: payloadNumber,
            floor: payloadFloor,
          );
      if (!mounted) return;
      Navigator.of(context).pop();
      ref.read(toastProvider.notifier).show(
            context.t.common.apartmentUpdated,
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
            context.t.common.apartmentUpdateFailed,
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
        title: t.editApartment,
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
          primaryLabel: t.save,
          onPrimary: _saving ? null : _save,
          primaryLoading: _saving,
          icon: Icons.save_outlined,
          secondaryLabel: t.cancelBtn,
          onSecondary: _saving ? null : () => Navigator.of(context).pop(),
          secondaryEnabled: !_saving,
        ),
      ),
    );
  }
}
