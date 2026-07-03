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
import '../../data/sites_store.dart';
import '../../domain/entities/site_entity.dart';

/// Site silmek için tip-to-confirm bottom sheet'i.
/// Kullanıcı, site adını aynen yazana kadar "Sil" butonu pasiftir.
class DeleteSiteDialog extends ConsumerStatefulWidget {
  final SiteEntity site;

  const DeleteSiteDialog({super.key, required this.site});

  /// `true` döner: silindi; `false`/`null`: iptal veya hata.
  static Future<bool?> show(
    BuildContext context, {
    required SiteEntity site,
  }) {
    return PremiumBottomSheetScaffold.show<bool>(
      context: context,
      isDismissible: true,
      builder: (_) => DeleteSiteDialog(site: site),
    );
  }

  @override
  ConsumerState<DeleteSiteDialog> createState() =>
      _DeleteSiteDialogState();
}

class _DeleteSiteDialogState extends ConsumerState<DeleteSiteDialog> {
  final _controller = TextEditingController();
  bool _deleting = false;
  bool _attempted = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _matches => _controller.text.trim() == widget.site.name.trim();

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
      await ref.read(sitesStoreProvider.notifier).removeSite(
            widget.site.id,
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
    final phrase = widget.site.name;

    return PopScope(
      canPop: !_deleting,
      child: PremiumBottomSheetScaffold(
        scrollable: true,
        header: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSizes.spacingL,
            AppSizes.spacingM,
            AppSizes.spacingL,
            AppSizes.spacingS,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: ProfileSettingsUi.danger.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: ProfileSettingsUi.danger,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.common.deleteBuilding,
                      style: ProfileSettingsUi.title,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      t.common.deleteBuildingHeader,
                      style: ProfileSettingsUi.handle.copyWith(fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
              label: t.common.deleteBuilding,
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
          secondaryLabel: t.common.cancelBtn,
          onSecondary: _deleting ? null : () => Navigator.of(context).pop(false),
          secondaryEnabled: !_deleting,
        ),
      ),
    );
  }
}

/// Doğrulama cümlesini/site adını gösteren — tıklanınca input'a yazan — kompakt kırmızı kart.
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
