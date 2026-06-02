import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_button_styles.dart';
import '../../../../core/utils/user_error_message.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/app_select_field.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/toast_overlay.dart';
import '../../../buildings/data/buildings_store.dart';
import '../providers/notifications_provider.dart';

/// Yönetici duyuru formu → `POST /buildings/:id/announcements` (B5).
class AnnouncementFormSheet extends ConsumerStatefulWidget {
  const AnnouncementFormSheet({super.key});

  static Future<bool?> show(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AnnouncementFormSheet(),
    );
  }

  @override
  ConsumerState<AnnouncementFormSheet> createState() =>
      _AnnouncementFormSheetState();
}

class _AnnouncementFormSheetState extends ConsumerState<AnnouncementFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  String? _buildingId;
  bool _submitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _openAddBuilding() {
    Navigator.of(context).pop();
    context.push('/manager-dashboard/add-building');
  }

  @override
  Widget build(BuildContext context) {
    final buildingsAsync = ref.watch(buildingsStoreProvider);
    final buildings = buildingsAsync.valueOrNull ?? const [];
    final t = context.t.features.notifications;
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    final isLoadingBuildings =
        buildingsAsync.isLoading && buildings.isEmpty;
    final loadFailed = buildingsAsync.hasError && buildings.isEmpty;

    if (_buildingId == null && buildings.isNotEmpty) {
      _buildingId = buildings.first.id;
    }

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.spacingM,
              AppSizes.spacingS,
              AppSizes.spacingM,
              AppSizes.spacingM,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: AppSizes.spacingM),
                      decoration: BoxDecoration(
                        color: AppColors.borderColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Text(
                    t.sendTitle,
                    style: AppTypography.h4.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSizes.spacingM),
                  if (isLoadingBuildings)
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: AppSizes.spacingXL,
                      ),
                      child: Center(
                        child: SizedBox(
                          width: 32,
                          height: 32,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    )
                  else if (loadFailed)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        EmptyStateWidget(
                          icon: Icons.cloud_off_outlined,
                          title: context.t.features.auth.splashConnectionError,
                          subtitle: buildingsAsync.error != null
                              ? userFacingError(buildingsAsync.error!)
                              : context.t.features.auth.splashConnectionHint,
                        ),
                        const SizedBox(height: AppSizes.spacingL),
                        SizedBox(
                          height: AppSizes.buttonHeightPrimary,
                          child: ElevatedButton.icon(
                            onPressed: () => ref
                                .read(buildingsStoreProvider.notifier)
                                .loadBuildings(),
                            style: AppButtonStyles.elevatedPrimary(),
                            icon: const Icon(Icons.refresh, size: 22),
                            label: Text(context.t.common.tryAgain),
                          ),
                        ),
                      ],
                    )
                  else if (buildings.isEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        EmptyStateWidget(
                          icon: Icons.apartment_outlined,
                          title: t.noBuilding,
                        ),
                        const SizedBox(height: AppSizes.spacingL),
                        SizedBox(
                          height: AppSizes.buttonHeightPrimary,
                          child: ElevatedButton.icon(
                            onPressed: _openAddBuilding,
                            style: AppButtonStyles.elevatedPrimary(),
                            icon: const Icon(Icons.add_business),
                            label: Text(context.t.common.addBuilding),
                          ),
                        ),
                      ],
                    )
                  else ...[
                    AppSelectField<String>(
                      label: context.t.common.buildingName,
                      value: _buildingId,
                      options: [
                        for (final b in buildings)
                          AppSelectOption(value: b.id, label: b.name),
                      ],
                      onChanged: (id) => setState(() => _buildingId = id),
                    ),
                    const SizedBox(height: AppSizes.spacingM),
                    TextFormField(
                      controller: _titleController,
                      maxLength: 120,
                      decoration: InputDecoration(labelText: t.fieldTitle),
                      validator: (v) {
                        final s = v?.trim() ?? '';
                        if (s.isEmpty) return t.fieldRequired;
                        if (s.length > 120) return t.titleTooLong;
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSizes.spacingM),
                    TextFormField(
                      controller: _bodyController,
                      maxLines: 5,
                      maxLength: 2000,
                      decoration: InputDecoration(labelText: t.fieldBody),
                      validator: (v) {
                        final s = v?.trim() ?? '';
                        if (s.isEmpty) return t.fieldRequired;
                        if (s.length > 2000) return t.bodyTooLong;
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSizes.spacingXL),
                    ElevatedButton(
                      onPressed: _submitting ? null : _submit,
                      child: _submitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : Text(t.sendButton),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final id = _buildingId;
    if (id == null) return;

    setState(() => _submitting = true);
    final result = await ref
        .read(notificationsNotifierProvider.notifier)
        .sendAnnouncement(
          id,
          title: _titleController.text.trim(),
          body: _bodyController.text.trim(),
        );
    if (!mounted) return;
    setState(() => _submitting = false);

    if (result != null) {
      ref.read(toastProvider.notifier).show(
            context.t.features.notifications.sendSuccess,
            type: ToastType.success,
          );
      Navigator.of(context).pop(true);
    } else {
      final err = ref.read(notificationsNotifierProvider).error;
      ref.read(toastProvider.notifier).show(
            err ?? context.t.features.notifications.sendFailed,
            type: ToastType.error,
          );
    }
  }
}
