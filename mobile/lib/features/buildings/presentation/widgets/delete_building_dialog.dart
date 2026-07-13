import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/utils/user_error_message.dart';
import '../../../../features/profile/presentation/theme/profile_settings_ui.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/minimal_form_widgets.dart';
import '../../../../shared/widgets/premium_bottom_sheet.dart';
import '../../../../shared/widgets/toast_overlay.dart';
import '../../data/buildings_store.dart';
import '../../domain/entities/building_entity.dart';

/// Bina silmek için tip-to-confirm bottom sheet.
class DeleteBuildingDialog extends ConsumerStatefulWidget {
  final BuildingEntity building;

  const DeleteBuildingDialog({super.key, required this.building});

  /// `true` döner: silindi; `false`/`null`: iptal veya hata.
  static Future<bool?> show(
    BuildContext context, {
    required BuildingEntity building,
  }) {
    return PremiumBottomSheetScaffold.show<bool>(
      context: context,
      isDismissible: true,
      builder: (_) => DeleteBuildingDialog(building: building),
    );
  }

  @override
  ConsumerState<DeleteBuildingDialog> createState() =>
      _DeleteBuildingDialogState();
}

class _DeleteBuildingDialogState extends ConsumerState<DeleteBuildingDialog> {
  final _controller = TextEditingController();
  bool _deleting = false;
  bool _attempted = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _matches => _controller.text.trim() == widget.building.name.trim();

  void _fillPhrase(String phrase) {
    _controller.text = phrase;
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: _controller.text.length),
    );
    setState(() {
      _attempted = false;
    });
  }

  Future<void> _delete() async {
    if (!_matches) {
      setState(() => _attempted = true);
      return;
    }
    setState(() => _deleting = true);
    try {
      await ref.read(buildingsStoreProvider.notifier).removeBuilding(
            widget.building.id,
          );
      if (!mounted) return;
      Navigator.of(context).pop(true);
      ref.read(toastProvider.notifier).show(
            context.t.common.buildingDeleted,
            type: ToastType.success,
          );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _deleting = false);
      ref.read(toastProvider.notifier).show(
            userFacingError(e),
            type: ToastType.error,
            duration: const Duration(seconds: 6),
          );
    } catch (_) {
      if (!mounted) return;
      setState(() => _deleting = false);
      ref.read(toastProvider.notifier).show(
            context.t.common.buildingDeleteFailed,
            type: ToastType.error,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final canSubmit = _matches && !_deleting;
    final phrase = widget.building.name;

    return PopScope(
      canPop: !_deleting,
      child: PremiumBottomSheetScaffold(
        title: t.common.deleteBuilding,
        scrollable: true,
        body: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              t.common.deleteBuildingHeader,
              style: ProfileSettingsUi.handle.copyWith(fontSize: 14),
            ),
            const SizedBox(height: AppSizes.spacingL),
            Text(
              t.common.deleteBuildingTypeHint,
              style: ProfileSettingsUi.fieldLabelUppercase,
            ),
            const SizedBox(height: AppSizes.spacingS),
            _PhrasePreview(
              phrase: phrase,
              onTap: _deleting ? null : () => _fillPhrase(phrase),
            ),
            const SizedBox(height: AppSizes.spacingM),
            MinimalTextField(
              controller: _controller,
              label: t.common.deleteBuildingTypeFieldLabel,
              hint: phrase,
              icon: Icons.edit_note_rounded,
              enabled: !_deleting,
              onChanged: (_) => setState(() {}),
            ),
            if (_attempted && !_matches) ...[
              const SizedBox(height: AppSizes.spacingXS),
              Text(
                context.t.common.buildingNameMismatch,
                style: ProfileSettingsUi.fieldLabel.copyWith(
                  color: ProfileSettingsUi.danger,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
        actions: PremiumSheetActions(
          primaryLabel: t.common.delete,
          onPrimary: _delete,
          primaryLoading: _deleting,
          primaryEnabled: canSubmit,
          dangerPrimary: true,
          icon: Icons.delete_outline,
          secondaryLabel: t.common.cancelBtn,
          onSecondary:
              _deleting ? null : () => Navigator.of(context).pop(false),
          secondaryEnabled: !_deleting,
        ),
      ),
    );
  }
}

class _PhrasePreview extends StatelessWidget {
  final String phrase;
  final VoidCallback? onTap;

  const _PhrasePreview({required this.phrase, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ProfileSettingsUi.danger.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(ProfileSettingsUi.fieldRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ProfileSettingsUi.fieldRadius),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: AppSizes.minTouchTarget,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: SelectableText(
                    phrase,
                    style: ProfileSettingsUi.fieldValue.copyWith(
                      color: ProfileSettingsUi.danger,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.touch_app_outlined,
                  size: 20,
                  color: ProfileSettingsUi.danger,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
