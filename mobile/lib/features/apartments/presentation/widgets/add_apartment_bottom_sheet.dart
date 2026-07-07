import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/utils/user_error_message.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/minimal_form_widgets.dart';
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
  final _floorController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _numberController.dispose();
    _floorController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final number = _numberController.text.trim();
    final floorRaw = _floorController.text.trim();
    final floor = floorRaw.isEmpty ? null : int.tryParse(floorRaw);

    try {
      await ref
          .read(apartmentsStoreProvider(widget.buildingId).notifier)
          .addApartment(number: number, floor: floor);
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
        scrollable: false,
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
            MinimalTextField(
              controller: _floorController,
              label: t.floorOptional,
              icon: Icons.stairs_outlined,
              enabled: !_saving,
              keyboardType:
                  const TextInputType.numberWithOptions(signed: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^-?\d*')),
              ],
              validator: (v) {
                if (v == null || v.trim().isEmpty) return null;
                final n = int.tryParse(v.trim());
                if (n == null) return t.fieldRequired;
                if (n < -5 || n > 200) return t.fieldRequired;
                return null;
              },
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
