import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/utils/iban_utils.dart';
import '../../../../core/utils/user_error_message.dart';
import '../../../../features/profile/presentation/theme/profile_settings_ui.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/theme/dashboard_screen_style.dart';
import '../../../../shared/widgets/async_error_widget.dart';
import '../../../../shared/widgets/dashboard_secondary_scaffold.dart';
import '../../../../shared/widgets/selection_mode_widgets.dart';
import '../../../../shared/widgets/toast_overlay.dart';
import '../../data/buildings_store.dart';
import '../../domain/entities/saved_iban_item.dart';
import '../providers/saved_ibans_provider.dart';
import '../utils/collection_preset_display.dart';
import '../widgets/delete_saved_iban_dialog.dart';
import '../widgets/saved_iban_add_sheet.dart';
import '../widgets/saved_iban_edit_sheet.dart';

/// Ayarlar → Kayıtlı IBAN'larım (yönetici).
class SavedIbansScreen extends ConsumerStatefulWidget {
  const SavedIbansScreen({super.key});

  @override
  ConsumerState<SavedIbansScreen> createState() => _SavedIbansScreenState();
}

class _SavedIbansScreenState extends ConsumerState<SavedIbansScreen> {
  bool _selectionMode = false;
  final Set<String> _selectedIbanKeys = <String>{};

  void _exitSelectionMode() {
    setState(() {
      _selectionMode = false;
      _selectedIbanKeys.clear();
    });
  }

  void _toggleSelection(SavedIbanItem item) {
    setState(() {
      if (_selectedIbanKeys.contains(item.ibanKey)) {
        _selectedIbanKeys.remove(item.ibanKey);
      } else {
        _selectedIbanKeys.add(item.ibanKey);
      }
    });
  }

  Future<void> _refreshLists() async {
    ref.invalidate(savedIbansListProvider);
    ref.invalidate(collectionPresetsProvider);
    await ref.read(buildingsStoreProvider.notifier).refreshBuildings();
  }

  Future<void> _openAdd() async {
    final added = await SavedIbanAddSheet.show(context);
    if (added == true && mounted) {
      _exitSelectionMode();
      await _refreshLists();
    }
  }

  Future<void> _openEdit(SavedIbanItem item) async {
    final saved = await SavedIbanEditSheet.show(context, item: item);
    if (saved == true && mounted) {
      _exitSelectionMode();
      await _refreshLists();
    }
  }

  Future<void> _confirmDeleteSelected(List<SavedIbanItem> allItems) async {
    if (_selectedIbanKeys.isEmpty) {
      ref
          .read(toastProvider.notifier)
          .show(
            context.t.features.buildings.collection.savedIbansPickFirst,
            type: ToastType.info,
          );
      return;
    }
    final selected = allItems
        .where((i) => _selectedIbanKeys.contains(i.ibanKey))
        .toList();
    final deleted = await DeleteSavedIbanDialog.show(context, items: selected);
    if (deleted == true && mounted) {
      _exitSelectionMode();
      await _refreshLists();
    }
  }

  Future<void> _confirmDeleteOne(SavedIbanItem item) async {
    final deleted = await DeleteSavedIbanDialog.show(context, items: [item]);
    if (deleted == true && mounted) {
      await _refreshLists();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.buildings.collection;
    final async = ref.watch(savedIbansListProvider);

    final selectedCount = _selectedIbanKeys.length;
    final items = async.asData?.value;
    final hasItems = items != null && items.isNotEmpty;

    return DashboardSecondaryScaffold(
      title: _selectionMode
          ? '$selectedCount ${context.t.common.selectedCountLabel}'
          : t.savedIbansTitle,
      canPop: !_selectionMode,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _exitSelectionMode();
      },
      onBack: () {
        if (_selectionMode) {
          _exitSelectionMode();
        } else {
          Navigator.of(context).pop();
        }
      },
      actions: [
        if (!_selectionMode && hasItems)
          IconButton(
            tooltip: t.savedIbansSelectMode,
            icon: const Icon(Icons.checklist_rounded),
            onPressed: () => setState(() {
              _selectionMode = true;
              _selectedIbanKeys.clear();
            }),
          ),
      ],
      floatingActionButton: _buildFloatingActionButton(
        context,
        selectedCount: selectedCount,
        allItems: items ?? const [],
      ),
      floatingActionButtonLocation: selectionActionFabLocation,
      body: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => AsyncErrorWidget(
            message: userFacingError(error),
            onRetry: () => ref.invalidate(savedIbansListProvider),
          ),
          data: (items) {
            if (items.isEmpty) {
              return _SavedIbansEmptyBody(message: t.savedIbansEmpty);
            }

            final showFab = !_selectionMode || selectedCount > 0;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_selectionMode)
                  SelectionHintBanner(
                    message: context.t.common.selectionDeleteIbanHint,
                  ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(savedIbansListProvider);
                      ref.invalidate(collectionPresetsProvider);
                      await ref.read(savedIbansListProvider.future);
                    },
                    child: ListView.separated(
                      padding: showFab
                          ? const EdgeInsets.fromLTRB(
                              AppSizes.dashboardScreenPaddingHorizontal,
                              AppSizes.spacingL,
                              AppSizes.dashboardScreenPaddingHorizontal,
                              96,
                            )
                          : AppSizes.screenBodyScrollPadding,
                      itemCount: items.length,
                      separatorBuilder: (context, _) =>
                          const SizedBox(height: AppSizes.spacingM),
                      itemBuilder: (_, i) {
                        final item = items[i];
                        final selected = _selectedIbanKeys.contains(
                          item.ibanKey,
                        );
                        return _SavedIbanListTile(
                          item: item,
                          selectionMode: _selectionMode,
                          selected: selected,
                          onTap: () {
                            if (_selectionMode) {
                              _toggleSelection(item);
                            } else {
                              _openEdit(item);
                            }
                          },
                          onLongPress: () {
                            if (!_selectionMode) {
                              setState(() {
                                _selectionMode = true;
                                _selectedIbanKeys
                                  ..clear()
                                  ..add(item.ibanKey);
                              });
                            }
                          },
                          onDelete: () => _confirmDeleteOne(item),
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
    );
  }
  Widget? _buildFloatingActionButton(
    BuildContext context, {
    required int selectedCount,
    required List<SavedIbanItem> allItems,
  }) {
    final t = context.t.features.buildings.collection;

    if (_selectionMode) {
      if (selectedCount == 0) return null;
      return SelectionActionFab(
        onPressed: () => _confirmDeleteSelected(allItems),
        backgroundColor: AppColors.error,
        icon: Icons.delete_outline_rounded,
        label: '${context.t.common.delete} ($selectedCount)',
      );
    }

    return SelectionActionFab(
      onPressed: _openAdd,
      backgroundColor: AppColors.actionButton,
      icon: Icons.add,
      label: t.savedIbansAddTitle,
    );
  }
}

class _SavedIbansEmptyBody extends StatelessWidget {
  final String message;

  const _SavedIbansEmptyBody({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSizes.screenBodyScrollPadding,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSizes.spacingXL),
          decoration: DashboardScreenStyle.whiteCard(),
          child: Text(
            message,
            style: ProfileSettingsUi.handle.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class _SavedIbanListTile extends StatelessWidget {
  final SavedIbanItem item;
  final bool selectionMode;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onDelete;

  const _SavedIbanListTile({
    required this.item,
    required this.selectionMode,
    required this.selected,
    required this.onTap,
    required this.onLongPress,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.buildings.collection;
    final detailStyle = ProfileSettingsUi.fieldLabel.copyWith(
      height: 1.35,
    );
    final details = CollectionPresetDisplay.detailLines(context, item.preset);
    final buildingLabel = item.buildings.isEmpty
        ? t.savedIbansNoBuildingMatch
        : t.savedIbansBuildingNames.replaceAll(
            '{names}',
            item.buildings.map((b) => b.name).join(', '),
          );

    final cardRadius = BorderRadius.circular(DashboardScreenStyle.cardRadius);
    final cardDecoration = BoxDecoration(
      color: selected
          ? AppColors.brand.withValues(alpha: 0.08)
          : AppColors.surface,
      borderRadius: cardRadius,
      boxShadow: DashboardScreenStyle.cardShadow,
      border: selected
          ? Border.all(color: AppColors.brand, width: 2)
          : null,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: cardRadius,
        child: Container(
          constraints: const BoxConstraints(minHeight: AppSizes.minTouchTarget),
          padding: const EdgeInsets.all(AppSizes.spacingM),
          decoration: cardDecoration,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _SavedIbanLeadingIcon(
                selectionMode: selectionMode,
                selected: selected,
              ),
              const SizedBox(width: AppSizes.spacingS),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        IbanUtils.formatDisplay(item.preset.collectionIban),
                        style: ProfileSettingsUi.fieldValue.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                      ),
                    ),
                    ...details.map(
                      (line) => Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(line, style: detailStyle),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(buildingLabel, style: detailStyle),
                    ),
                  ],
                ),
              ),
              if (!selectionMode) _SavedIbanDeleteButton(onDelete: onDelete),
            ],
          ),
        ),
      ),
    );
  }
}

/// Sol ikon — dar yuva; kart satırı zaten 48dp dokunma sağlar.
class _SavedIbanLeadingIcon extends StatelessWidget {
  final bool selectionMode;
  final bool selected;

  const _SavedIbanLeadingIcon({
    required this.selectionMode,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppSizes.listRowIconWidth,
      child: Icon(
        selectionMode
            ? (selected ? Icons.check_circle : Icons.radio_button_unchecked)
            : Icons.account_balance_outlined,
        color: selectionMode
            ? (selected ? AppColors.brand : AppColors.textSecondary)
            : AppColors.brand,
        size: AppSizes.listRowIconSize,
      ),
    );
  }
}

class _SavedIbanDeleteButton extends StatelessWidget {
  final VoidCallback onDelete;

  const _SavedIbanDeleteButton({required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: context.t.common.delete,
      child: InkWell(
        onTap: onDelete,
        borderRadius: BorderRadius.circular(8),
        child: const SizedBox(
          width: AppSizes.listRowActionWidth,
          height: AppSizes.minTouchTarget,
          child: Center(
            child: Icon(
              Icons.delete_outline,
              color: AppColors.error,
              size: AppSizes.listRowIconSize,
            ),
          ),
        ),
      ),
    );
  }
}

