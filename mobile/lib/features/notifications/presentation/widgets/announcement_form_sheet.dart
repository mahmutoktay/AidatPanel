import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/user_error_message.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/providers/navigation_provider.dart';
import '../../../../shared/widgets/building_picker_sheet.dart';
import '../../../../shared/widgets/minimal_form_widgets.dart';
import '../../../../shared/widgets/premium_bottom_sheet.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/toast_overlay.dart';
import '../../../buildings/data/buildings_store.dart';
import '../../../buildings/domain/entities/building_entity.dart';
import '../../../dashboard/presentation/providers/dashboard_filter_scope_provider.dart';
import '../../../sites/data/sites_store.dart';
import '../providers/notifications_provider.dart';

/// Yönetici duyuru formu → `POST /buildings/:id/announcements` (B5).
/// "Tüm Binalar" seçilirse her bina için sırayla gönderilir.
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
  bool _allBuildings = false;
  bool _initializedDefault = false;
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

  void _initDefaultBuilding(List<BuildingEntity> buildings) {
    if (_initializedDefault || buildings.isEmpty) return;
    _initializedDefault = true;

    final scope = ref.read(dashboardFilterScopeProvider);
    if (scope.isAll) {
      _allBuildings = true;
      _buildingId = null;
      return;
    }
    if (scope.isBuilding &&
        scope.buildingId != null &&
        buildings.any((b) => b.id == scope.buildingId)) {
      _buildingId = scope.buildingId;
      _allBuildings = false;
      return;
    }

    final selectedId = ref.read(selectedBuildingIdProvider);
    if (selectedId != null && buildings.any((b) => b.id == selectedId)) {
      _buildingId = selectedId;
      _allBuildings = false;
      return;
    }
    // Otomatik first yok — kullanıcı picker ile seçer (K6/K11).
  }

  @override
  Widget build(BuildContext context) {
    final buildingsAsync = ref.watch(buildingsStoreProvider);
    final buildings = buildingsAsync.value ?? const [];
    final t = context.t.features.notifications;
    final isLoadingBuildings =
        buildingsAsync.isLoading && buildings.isEmpty;
    final loadFailed = buildingsAsync.hasError && buildings.isEmpty;

    _initDefaultBuilding(buildings);

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
                onPrimary: _submitting ? null : () => _submit(buildings),
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

    final dashboardT = context.t.features.dashboard;
    String? pickerValue;
    if (_allBuildings) {
      pickerValue = dashboardT.allBuildings;
    } else if (_buildingId != null) {
      for (final b in buildings) {
        if (b.id == _buildingId) {
          pickerValue = b.name;
          break;
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MinimalPickerField(
          label: context.t.common.buildingName,
          value: pickerValue,
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
    final sites = ref.read(sitesStoreProvider).value ?? const [];
    final result = await BuildingPickerSheet.show(
      context,
      buildings: buildings,
      sites: sites,
      selectedBuildingId: _allBuildings ? null : _buildingId,
      selectedIsAll: _allBuildings,
      includeAllOption: true,
      enableSiteGrouping: sites.isNotEmpty,
    );
    if (result.cancelled) return;
    if (result.isAllBuildings) {
      setState(() {
        _allBuildings = true;
        _buildingId = null;
      });
      return;
    }
    if (result.buildingId == null) return;
    setState(() {
      _allBuildings = false;
      _buildingId = result.buildingId;
    });
  }

  Future<void> _submit(List<BuildingEntity> buildings) async {
    final t = context.t.features.notifications;
    if (!_allBuildings && _buildingId == null) {
      ref.read(toastProvider.notifier).show(
            t.fieldRequired,
            type: ToastType.error,
          );
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    final targetIds = _allBuildings
        ? buildings.map((b) => b.id).toList(growable: false)
        : <String>[_buildingId!];
    if (targetIds.isEmpty) {
      ref.read(toastProvider.notifier).show(
            t.noBuilding,
            type: ToastType.error,
          );
      return;
    }

    final body = _bodyController.text.trim();
    setState(() => _submitting = true);

    var okCount = 0;
    for (final id in targetIds) {
      final result = await ref
          .read(notificationsNotifierProvider.notifier)
          .sendAnnouncement(id, body: body);
      if (result != null) okCount++;
    }

    if (!mounted) return;
    setState(() => _submitting = false);

    if (okCount == targetIds.length) {
      ref.read(toastProvider.notifier).show(
            _allBuildings && targetIds.length > 1
                ? t.sendSuccessAll
                : t.sendSuccess,
            type: ToastType.success,
          );
      Navigator.of(context).pop(true);
      return;
    }

    if (okCount > 0) {
      ref.read(toastProvider.notifier).show(
            t.sendPartialFailed
                .replaceAll('{ok}', '$okCount')
                .replaceAll('{total}', '${targetIds.length}'),
            type: ToastType.warning,
          );
      Navigator.of(context).pop(true);
      return;
    }

    final err = ref.read(notificationsNotifierProvider).error;
    ref.read(toastProvider.notifier).show(
          err ?? t.sendFailed,
          type: ToastType.error,
        );
  }
}
