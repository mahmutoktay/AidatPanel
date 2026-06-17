import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/utils/user_error_message.dart';
import '../../../../core/utils/iban_utils.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/premium_bottom_sheet.dart';
import '../../../../shared/widgets/toast_overlay.dart';
import '../../data/buildings_store.dart';
import '../../domain/entities/building_entity.dart';
import 'building_collection_fields.dart';

/// Mevcut bina — `PATCH /buildings/:id/collection`.
class EditBuildingCollectionBottomSheet extends ConsumerStatefulWidget {
  final BuildingEntity building;

  const EditBuildingCollectionBottomSheet({super.key, required this.building});

  static Future<void> show(
    BuildContext context, {
    required BuildingEntity building,
  }) {
    return PremiumBottomSheetScaffold.show<void>(
      context: context,
      builder: (_) => EditBuildingCollectionBottomSheet(building: building),
    );
  }

  @override
  ConsumerState<EditBuildingCollectionBottomSheet> createState() =>
      _EditBuildingCollectionBottomSheetState();
}

class _EditBuildingCollectionBottomSheetState
    extends ConsumerState<EditBuildingCollectionBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _ibanController;
  late final TextEditingController _accountTitleController;
  late final TextEditingController _referenceTemplateController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final b = widget.building;
    _ibanController = TextEditingController(
      text: b.collectionIban != null
          ? IbanUtils.formatDisplay(b.collectionIban!)
          : '',
    );
    _accountTitleController =
        TextEditingController(text: b.collectionAccountTitle ?? '');
    _referenceTemplateController =
        TextEditingController(text: b.paymentReferenceTemplate ?? '');
  }

  @override
  void dispose() {
    _ibanController.dispose();
    _accountTitleController.dispose();
    _referenceTemplateController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final ibanRaw = _ibanController.text.trim();
    if (ibanRaw.isNotEmpty && !IbanUtils.isValidTrIban(ibanRaw)) {
      return;
    }

    setState(() => _saving = true);
    try {
      await ref.read(buildingsStoreProvider.notifier).patchBuildingCollection(
            id: widget.building.id,
            collectionIban: ibanRaw.isEmpty ? '' : IbanUtils.normalize(ibanRaw),
            collectionAccountTitle: _accountTitleController.text.trim(),
            paymentReferenceTemplate:
                _referenceTemplateController.text.trim(),
          );
      if (!mounted) return;
      ref.read(toastProvider.notifier).show(
            context.t.features.buildings.collection.saveSuccess,
            type: ToastType.success,
          );
      Navigator.of(context).pop();
    } on ApiException catch (e) {
      if (!mounted) return;
      ref.read(toastProvider.notifier).show(
            userFacingError(e),
            type: ToastType.error,
          );
    } catch (_) {
      if (!mounted) return;
      ref.read(toastProvider.notifier).show(
            context.t.common.unexpectedError,
            type: ToastType.error,
          );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.buildings.collection;

    return Form(
      key: _formKey,
      child: PremiumBottomSheetScaffold(
        title: t.editSheetTitle,
        showCloseButton: true,
        closeEnabled: !_saving,
        onClose: () => Navigator.pop(context),
        body: BuildingCollectionFields(
          ibanController: _ibanController,
          accountTitleController: _accountTitleController,
          referenceTemplateController: _referenceTemplateController,
        ),
        actions: PremiumSheetActions(
          primaryLabel: context.t.common.save,
          onPrimary: _saving ? null : _save,
          primaryLoading: _saving,
        ),
      ),
    );
  }
}
