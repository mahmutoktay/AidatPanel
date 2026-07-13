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
import 'building_collection_fields.dart';

/// Yeni kayıtlı IBAN ekleme.
class SavedIbanAddSheet extends ConsumerStatefulWidget {
  const SavedIbanAddSheet({super.key});

  static Future<bool?> show(BuildContext context) {
    return PremiumBottomSheetScaffold.show<bool>(
      context: context,
      builder: (_) => const SavedIbanAddSheet(),
    );
  }

  @override
  ConsumerState<SavedIbanAddSheet> createState() => _SavedIbanAddSheetState();
}

class _SavedIbanAddSheetState extends ConsumerState<SavedIbanAddSheet> {
  final _formKey = GlobalKey<FormState>();
  final _ibanController = TextEditingController();
  final _accountTitleController = TextEditingController();
  final _referenceTemplateController = TextEditingController();
  final _labelController = TextEditingController();
  bool _saving = false;

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
    if (!IbanUtils.isValidTrIban(ibanRaw)) return;

    setState(() => _saving = true);
    final t = context.t.features.buildings.collection;
    try {
      await ref.read(buildingRepositoryProvider).addCollectionPreset(
            collectionIban: ibanRaw,
            collectionAccountTitle: _accountTitleController.text.trim(),
            collectionIbanLabel: _labelController.text.trim(),
            paymentReferenceTemplate: _referenceTemplateController.text.trim(),
          );
      ref.invalidate(collectionPresetsProvider);

      if (!mounted) return;
      ref.read(toastProvider.notifier).show(
            t.savedIbansAddSuccess,
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

    return Form(
      key: _formKey,
      child: PremiumBottomSheetScaffold(
        title: t.savedIbansAddTitle,
        showCloseButton: true,
        closeEnabled: !_saving,
        onClose: () => Navigator.pop(context),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              t.savedIbansAddHint,
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
