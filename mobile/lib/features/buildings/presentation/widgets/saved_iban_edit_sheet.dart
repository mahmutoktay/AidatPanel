import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/utils/user_error_message.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/iban_utils.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/premium_bottom_sheet.dart';
import '../../../../shared/widgets/toast_overlay.dart';
import '../../data/buildings_store.dart';
import '../../domain/entities/saved_iban_item.dart';
import '../utils/collection_usage_label.dart';
import 'building_collection_fields.dart';

/// Kayıtlı IBAN düzenleme — eşleşen tüm bina ve sitelere `PATCH .../collection`.
class SavedIbanEditSheet extends ConsumerStatefulWidget {
  final SavedIbanItem item;

  const SavedIbanEditSheet({super.key, required this.item});

  static Future<bool?> show(
    BuildContext context, {
    required SavedIbanItem item,
  }) {
    return PremiumBottomSheetScaffold.show<bool>(
      context: context,
      builder: (_) => SavedIbanEditSheet(item: item),
    );
  }

  @override
  ConsumerState<SavedIbanEditSheet> createState() => _SavedIbanEditSheetState();
}

class _SavedIbanEditSheetState extends ConsumerState<SavedIbanEditSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _ibanController;
  late final TextEditingController _accountTitleController;
  late final TextEditingController _referenceTemplateController;
  late final TextEditingController _labelController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.item.preset;
    _ibanController = TextEditingController(
      text: IbanUtils.formatDisplay(p.collectionIban),
    );
    _accountTitleController =
        TextEditingController(text: p.collectionAccountTitle ?? '');
    _referenceTemplateController =
        TextEditingController(text: p.paymentReferenceTemplate ?? '');
    _labelController =
        TextEditingController(text: p.collectionIbanLabel ?? '');
  }

  @override
  void dispose() {
    _ibanController.dispose();
    _accountTitleController.dispose();
    _referenceTemplateController.dispose();
    _labelController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final ibanRaw = _ibanController.text.trim();
    if (ibanRaw.isNotEmpty && !IbanUtils.isValidTrIban(ibanRaw)) return;

    setState(() => _saving = true);
    final t = context.t.features.buildings.collection;
    try {
      final iban = ibanRaw.isEmpty ? '' : IbanUtils.normalize(ibanRaw);
      final title = _accountTitleController.text.trim();
      final template = _referenceTemplateController.text.trim();
      final label = _labelController.text.trim();

      final count = await ref
          .read(buildingRepositoryProvider)
          .patchBuildingsMatchingCollection(
            matchIban: widget.item.ibanKey,
            collectionIban: iban,
            collectionAccountTitle: title,
            collectionIbanLabel: label,
            updateIbanLabel: true,
            paymentReferenceTemplate: template,
          );
      await ref.read(buildingsStoreProvider.notifier).refreshBuildings();
      ref.invalidate(collectionPresetsProvider);

      if (!mounted) return;
      ref.read(toastProvider.notifier).show(
            count > 0
                ? t.savedIbansUpdateSuccess.replaceAll('{count}', '$count')
                : t.saveSuccess,
            type: ToastType.success,
          );
      Navigator.of(context).pop(true);
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
    final placeNames = CollectionUsageLabel.flatPlaceNames(widget.item);

    return Form(
      key: _formKey,
      child: PremiumBottomSheetScaffold(
        title: t.editSavedIbanTitle,
        showCloseButton: true,
        closeEnabled: !_saving,
        onClose: () => Navigator.pop(context),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              placeNames != null
                  ? t.savedIbansUpdateHint.replaceAll('{names}', placeNames)
                  : t.savedIbansOrphanHint,
              style: AppTypography.body1.copyWith(
                color: AppColors.mutedText,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: AppSizes.spacingM),
            BuildingCollectionFields(
              ibanController: _ibanController,
              accountTitleController: _accountTitleController,
              referenceTemplateController: _referenceTemplateController,
              labelController: _labelController,
              manualOnly: true,
            ),
          ],
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
