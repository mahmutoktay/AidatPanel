import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/user_error_message.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/minimal_form_widgets.dart';
import '../../../../shared/widgets/premium_bottom_sheet.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/toast_overlay.dart';
import '../../../buildings/data/buildings_store.dart';
import '../../../buildings/domain/entities/building_entity.dart';
import '../providers/notifications_provider.dart';

/// Yönetici duyuru formu → `POST /buildings/:id/announcements` (B5).
class AnnouncementFormSheet extends ConsumerStatefulWidget {
  const AnnouncementFormSheet({super.key});

  static Future<bool?> show(BuildContext context) {
    return PremiumBottomSheetScaffold.show<bool>(
      context: context,
      builder: (_) => const AnnouncementFormSheet(),
    );
  }

  @override
  ConsumerState<AnnouncementFormSheet> createState() =>
      _AnnouncementFormSheetState();
}

class _AnnouncementFormSheetState extends ConsumerState<AnnouncementFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _bodyController = TextEditingController();
  String? _buildingId;
  bool _submitting = false;

  @override
  void dispose() {
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
    final buildings = buildingsAsync.value ?? const [];
    final t = context.t.features.notifications;
    final isLoadingBuildings =
        buildingsAsync.isLoading && buildings.isEmpty;
    final loadFailed = buildingsAsync.hasError && buildings.isEmpty;

    if (_buildingId == null && buildings.isNotEmpty) {
      _buildingId = buildings.first.id;
    }

    return Form(
      key: _formKey,
      child: PremiumBottomSheetScaffold(
        title: t.sendTitle,
        body: _buildBody(
          context,
          buildings: buildings,
          isLoadingBuildings: isLoadingBuildings,
          loadFailed: loadFailed,
          buildingsAsync: buildingsAsync,
        ),
        actions: buildings.isEmpty || isLoadingBuildings || loadFailed
            ? null
            : PremiumSheetActions(
                primaryLabel: t.sendButton,
                onPrimary: _submitting ? null : _submit,
                primaryLoading: _submitting,
              ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context, {
    required List<BuildingEntity> buildings,
    required bool isLoadingBuildings,
    required bool loadFailed,
    required AsyncValue<List<BuildingEntity>> buildingsAsync,
  }) {
    final t = context.t.features.notifications;
    if (isLoadingBuildings) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSizes.spacingXL),
        child: Center(
          child: SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }
    if (loadFailed) {
      return Column(
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
          PremiumSheetActions(
            primaryLabel: context.t.common.tryAgain,
            onPrimary: () =>
                ref.read(buildingsStoreProvider.notifier).loadBuildings(),
          ),
        ],
      );
    }
    if (buildings.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          EmptyStateWidget(
            icon: Icons.apartment_outlined,
            title: t.noBuilding,
          ),
          const SizedBox(height: AppSizes.spacingL),
          PremiumSheetActions(
            primaryLabel: context.t.common.addBuilding,
            onPrimary: _openAddBuilding,
            icon: Icons.add_business,
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MinimalPickerField(
          label: context.t.common.buildingName,
          value: buildings
              .firstWhere(
                (b) => b.id == _buildingId,
                orElse: () => buildings.first,
              )
              .name,
          hint: context.t.common.buildingName,
          icon: Icons.apartment_outlined,
          required: true,
          onTap: () => _pickBuilding(context, buildings),
        ),
        const SizedBox(height: AppSizes.spacingM),
        MinimalTextField(
          controller: _bodyController,
          label: t.fieldBody,
          icon: Icons.notes_outlined,
          required: true,
          maxLines: 5,
          enabled: !_submitting,
          validator: (v) {
            final s = v?.trim() ?? '';
            if (s.isEmpty) return t.fieldRequired;
            if (s.length > 2000) return t.bodyTooLong;
            return null;
          },
        ),
      ],
    );
  }

  Future<void> _pickBuilding(
    BuildContext context,
    List<BuildingEntity> buildings,
  ) async {
    final picked = await PremiumBottomSheetScaffold.show<String>(
      context: context,
      builder: (ctx) => PremiumBottomSheetScaffold(
        title: context.t.common.buildingName,
        scrollable: true,
        body: PremiumActionSheetList(
          children: [
            for (final b in buildings)
              PremiumActionSheetTile(
                icon: Icons.apartment_outlined,
                label: b.name,
                subtitle: b.displayAddress,
                trailing: _buildingId == b.id
                    ? Icon(Icons.check_rounded, color: AppColors.inkDark)
                    : null,
                onTap: () => Navigator.pop(ctx, b.id),
              ),
          ],
        ),
      ),
    );
    if (picked != null) setState(() => _buildingId = picked);
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
