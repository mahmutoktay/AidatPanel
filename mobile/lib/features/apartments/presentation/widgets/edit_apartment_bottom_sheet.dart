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
  late final TextEditingController _floorController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _numberController =
        TextEditingController(text: widget.apartment.apartmentNumber);
    _floorController = TextEditingController(
      text: widget.apartment.floor?.toString() ?? '',
    );
  }

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

    final original = widget.apartment;
    final payloadNumber = number == original.apartmentNumber ? null : number;
    final payloadFloor = floor == original.floor ? null : floor;

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
