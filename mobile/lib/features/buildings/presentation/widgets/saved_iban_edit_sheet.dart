import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/utils/user_error_message.dart';
import '../../../../core/theme/app_button_styles.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/iban_utils.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/toast_overlay.dart';
import '../../data/buildings_store.dart';
import '../../domain/entities/saved_iban_item.dart';
import 'building_collection_fields.dart';

/// Kayıtlı IBAN düzenleme — eşleşen tüm binalara `PATCH .../collection`.
class SavedIbanEditSheet extends ConsumerStatefulWidget {
  final SavedIbanItem item;

  const SavedIbanEditSheet({super.key, required this.item});

  static Future<bool?> show(
    BuildContext context, {
    required SavedIbanItem item,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
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
    if (ibanRaw.isNotEmpty && !IbanUtils.isValidTrIban(ibanRaw)) return;

    setState(() => _saving = true);
    final t = context.t.features.buildings.collection;
    try {
      final iban = ibanRaw.isEmpty ? '' : IbanUtils.normalize(ibanRaw);
      final title = _accountTitleController.text.trim();
      final template = _referenceTemplateController.text.trim();

      final count = await ref
          .read(buildingRepositoryProvider)
          .patchBuildingsMatchingCollection(
            matchIban: widget.item.ibanKey,
            collectionIban: iban,
            collectionAccountTitle: title,
            paymentReferenceTemplate: template,
          );
      await ref.read(buildingsStoreProvider.notifier).refreshBuildings();
      ref.invalidate(collectionPresetsProvider);

      if (!mounted) return;
      ref.read(toastProvider.notifier).show(
            count > 0
                ? t.savedIbansUpdateSuccess.replaceAll(
                    '{count}',
                    '$count',
                  )
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
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final buildingNames =
        widget.item.buildings.map((b) => b.name).join(', ');

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
                      child: Text(t.editSavedIbanTitle, style: AppTypography.h2),
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
                    buildingNames.isNotEmpty
                        ? t.savedIbansUpdateHint.replaceAll(
                            '{names}',
                            buildingNames,
                          )
                        : t.savedIbansOrphanHint,
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
