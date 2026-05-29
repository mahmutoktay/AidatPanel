import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_button_styles.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/iban_utils.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/toast_overlay.dart';
import '../../data/buildings_store.dart';
import 'building_collection_fields.dart';

/// Yeni kayıtlı IBAN ekleme.
class SavedIbanAddSheet extends ConsumerStatefulWidget {
  const SavedIbanAddSheet({super.key});

  static Future<bool?> show(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
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
  bool _saving = false;

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
    if (!IbanUtils.isValidTrIban(ibanRaw)) return;

    setState(() => _saving = true);
    final t = context.t.features.buildings.collection;
    try {
      await ref.read(buildingRepositoryProvider).addCollectionPreset(
            collectionIban: ibanRaw,
            collectionAccountTitle: _accountTitleController.text.trim(),
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
      ref.read(toastProvider.notifier).show(e.message, type: ToastType.error);
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
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.92,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppButtonStyles.sheetTop.borderRadius,
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: AppSizes.spacingS),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.spacingL,
                  AppSizes.spacingM,
                  AppSizes.spacingL,
                  AppSizes.spacingS,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(t.savedIbansAddTitle, style: AppTypography.h2),
                    ),
                    IconButton(
                      onPressed: _saving ? null : () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.spacingL,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    t.savedIbansAddHint,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.spacingL,
                    vertical: AppSizes.spacingM,
                  ),
                  child: Form(
                    key: _formKey,
                    child: BuildingCollectionFields(
                      ibanController: _ibanController,
                      accountTitleController: _accountTitleController,
                      referenceTemplateController: _referenceTemplateController,
                      manualOnly: true,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSizes.spacingL),
                child: SizedBox(
                  width: double.infinity,
                  height: AppSizes.buttonHeightPrimary,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    style: AppButtonStyles.elevatedPrimary(),
                    child: _saving
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(context.t.common.save, style: AppTypography.button),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
