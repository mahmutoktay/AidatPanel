import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/utils/user_error_message.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../features/profile/presentation/theme/profile_settings_ui.dart';
import '../../../../features/sites/data/sites_store.dart';
import '../../../../features/sites/domain/entities/site_entity.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/theme/dashboard_screen_style.dart';
import '../../../../shared/widgets/async_error_widget.dart';
import '../../../../shared/widgets/dashboard_secondary_scaffold.dart';
import '../../../../shared/widgets/toast_overlay.dart';
import '../../../apartments/data/apartments_store.dart';
import '../../../apartments/domain/entities/apartment_entity.dart';
import '../../data/buildings_store.dart';
import '../../data/invite_code_store.dart';
import '../../domain/entities/building_entity.dart';
import '../../utils/invite_code_helpers.dart';
import '../utils/apartment_ui_utils.dart';
import '../widgets/invite_code_result_view.dart';
import '../widgets/invite_confirm_dialogs.dart';
import '../widgets/invite_selectable_tile.dart';
import '../widgets/invite_step_indicator.dart';

/// Davet kodu üretme akışı: Site (varsa) → Bina → Daire → Kod.
class InviteCodeScreen extends ConsumerStatefulWidget {
  const InviteCodeScreen({super.key});

  @override
  ConsumerState<InviteCodeScreen> createState() => _InviteCodeScreenState();
}

class _InviteCodeScreenState extends ConsumerState<InviteCodeScreen> {
  int _step = 0;
  SiteEntity? _selectedSite;
  bool _standaloneMode = false;
  BuildingEntity? _selectedBuilding;
  ApartmentEntity? _selectedApartment;
  String? _generatedCode;
  DateTime? _activeExpiresAt;

  bool get _hasSiteStep {
    final sites = ref.watch(sitesStoreProvider);
    return sites.maybeWhen(data: (list) => list.isNotEmpty, orElse: () => false);
  }

  int get _buildingStep => _hasSiteStep ? 1 : 0;
  int get _apartmentStep => _hasSiteStep ? 2 : 1;
  int get _codeStep => _hasSiteStep ? 3 : 2;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _step == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _onBackPressed();
      },
      child: DashboardSecondaryScaffold(
        title: context.t.common.createInviteCode,
        onBack: _onBackPressed,
        body: Column(
          children: [
            InviteStepIndicator(
              currentStep: _step,
              includeSiteStep: _hasSiteStep,
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                switchInCurve: Curves.easeInOut,
                switchOutCurve: Curves.easeInOut,
                child: _buildStepContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    if (_hasSiteStep && _step == 0) {
      final sitesAsync = ref.watch(sitesStoreProvider);
      return sitesAsync.when(
        loading: () => const Center(
          key: ValueKey('step-site-loading'),
          child: CircularProgressIndicator(),
        ),
        error: (e, _) => AsyncErrorWidget(
          key: const ValueKey('step-site-error'),
          message: userFacingError(e),
          onRetry: () => ref.read(sitesStoreProvider.notifier).loadSites(),
        ),
        data: (sites) => _SitePickerStep(
          key: const ValueKey('step-site'),
          sites: sites,
          onSitePick: _onSitePicked,
          onStandalonePick: _onStandalonePicked,
        ),
      );
    }

    if (_step == _buildingStep) {
      if (_selectedSite != null) {
        final buildingsAsync =
            ref.watch(siteBuildingsProvider(_selectedSite!.id));
        return buildingsAsync.when(
          loading: () => const Center(
            key: ValueKey('step-building-loading'),
            child: CircularProgressIndicator(),
          ),
          error: (e, _) => AsyncErrorWidget(
            key: const ValueKey('step-building-error'),
            message: userFacingError(e),
            onRetry: () => ref.invalidate(siteBuildingsProvider(_selectedSite!.id)),
          ),
          data: (buildings) => _BuildingPickerStep(
            key: const ValueKey('step-building-site'),
            buildings: buildings,
            site: _selectedSite,
            onPick: _onBuildingPicked,
          ),
        );
      }

      final provider = _standaloneMode
          ? standaloneBuildingsStoreProvider
          : buildingsStoreProvider;
      final buildingsAsync = ref.watch(provider);
      return buildingsAsync.when(
        loading: () => const Center(
          key: ValueKey('step-building-loading'),
          child: CircularProgressIndicator(),
        ),
        error: (e, _) => AsyncErrorWidget(
          key: const ValueKey('step-building-error'),
          message: userFacingError(e),
          onRetry: () {
            if (_standaloneMode) {
              ref.read(standaloneBuildingsStoreProvider.notifier).loadBuildings();
            } else {
              ref.read(buildingsStoreProvider.notifier).loadBuildings();
            }
          },
        ),
        data: (buildings) => _BuildingPickerStep(
          key: ValueKey('step-building-${_standaloneMode ? 'standalone' : 'all'}'),
          buildings: buildings,
          site: _selectedSite,
          onPick: _onBuildingPicked,
        ),
      );
    }

    if (_step == _apartmentStep) {
      final asyncApts =
          ref.watch(apartmentsStoreProvider(_selectedBuilding!.id));
      return asyncApts.when(
        loading: () => const Center(
          key: ValueKey('step-apartment-loading'),
          child: CircularProgressIndicator(),
        ),
        error: (e, _) => AsyncErrorWidget(
          key: const ValueKey('step-apartment-error'),
          message: userFacingError(e),
          onRetry: () => ref
              .read(apartmentsStoreProvider(_selectedBuilding!.id).notifier)
              .loadApartments(),
        ),
        data: (apartments) => _ApartmentPickerStep(
          key: const ValueKey('step-apartment'),
          building: _selectedBuilding!,
          apartments: apartments,
          onPick: _onApartmentSelected,
          activeCodes: ref.watch(inviteCodeStoreProvider),
        ),
      );
    }

    if (_step == _codeStep) {
      return InviteCodeResultView(
        key: const ValueKey('step-code'),
        code: _generatedCode!,
        building: _selectedBuilding!,
        apartment: _selectedApartment!,
        expiresAt: _activeExpiresAt!,
        onCopy: () => _copyCode(_generatedCode!),
        onShare: () => _shareCode(),
        onRevoke: _confirmRevoke,
        onPickAnother: _resetToApartmentStep,
        onGoHome: () => context.pop(),
      );
    }

    return const SizedBox.shrink();
  }

  void _onSitePicked(SiteEntity site) {
    setState(() {
      _selectedSite = site;
      _standaloneMode = false;
      _selectedBuilding = null;
      _step = _buildingStep;
    });
  }

  void _onStandalonePicked() {
    setState(() {
      _selectedSite = null;
      _standaloneMode = true;
      _selectedBuilding = null;
      _step = _buildingStep;
    });
  }

  void _onBuildingPicked(BuildingEntity b) {
    ref.invalidate(apartmentsStoreProvider(b.id));
    setState(() {
      _selectedBuilding = b;
      _selectedApartment = null;
      _step = _apartmentStep;
    });
  }

  void _onApartmentSelected(ApartmentEntity apt) {
    final active = ref.read(inviteCodeStoreProvider.notifier).activeFor(apt.id);
    if (active != null) {
      _showActiveCode(apt, active);
      return;
    }
    if (apt.phone != null) {
      OccupiedApartmentConfirmDialog.show(
        context,
        apartment: apt,
        onConfirm: () => _generateAndShow(apt),
      );
    } else {
      _generateAndShow(apt);
    }
  }

  void _showActiveCode(ApartmentEntity apt, ActiveInviteCode active) {
    setState(() {
      _selectedApartment = apt;
      _generatedCode = active.code;
      _activeExpiresAt = active.expiresAt;
      _step = _codeStep;
    });
  }

  Future<void> _generateAndShow(ApartmentEntity apt) async {
    final active = await ref
        .read(inviteCodeStoreProvider.notifier)
        .generateInviteCode(apt.id);
    if (!mounted) return;
    if (active == null) {
      ref.read(toastProvider.notifier).show(
            context.t.common.loadFailed,
            type: ToastType.error,
          );
      return;
    }
    setState(() {
      _selectedApartment = apt;
      _generatedCode = active.code;
      _activeExpiresAt = active.expiresAt;
      _step = _codeStep;
    });
  }

  void _confirmRevoke() {
    final apt = _selectedApartment!;
    RevokeInviteCodeDialog.show(
      context,
      onConfirm: () {
        ref.read(inviteCodeStoreProvider.notifier).revoke(apt.id);
        ref
            .read(toastProvider.notifier)
            .show(context.t.common.codeRevoked, type: ToastType.success);
        _resetToApartmentStep();
      },
    );
  }

  void _resetToApartmentStep() {
    setState(() {
      _step = _apartmentStep;
      _selectedApartment = null;
      _generatedCode = null;
      _activeExpiresAt = null;
    });
  }

  void _onBackPressed() {
    if (_step == 0) {
      context.pop();
      return;
    }
    if (_step == _codeStep) {
      setState(() {
        _step = _apartmentStep;
        _selectedApartment = null;
        _generatedCode = null;
        _activeExpiresAt = null;
      });
      return;
    }
    if (_step == _apartmentStep) {
      setState(() {
        _step = _buildingStep;
        _selectedApartment = null;
        _selectedBuilding = null;
      });
      return;
    }
    if (_step == _buildingStep) {
      if (_hasSiteStep) {
        setState(() {
          _step = 0;
          _selectedSite = null;
          _standaloneMode = false;
          _selectedBuilding = null;
        });
      } else {
        context.pop();
      }
    }
  }

  void _copyCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    ref
        .read(toastProvider.notifier)
        .show('${context.t.common.codeCopied}: $code', type: ToastType.success);
  }

  Future<void> _shareCode() async {
    final message = InviteCodeHelpers.buildShareMessage(
      code: _generatedCode!,
      building: _selectedBuilding!,
      apartment: _selectedApartment!,
      expiresAt: _activeExpiresAt!,
    );

    try {
      final box = context.findRenderObject() as RenderBox?;
      await SharePlus.instance.share(
        ShareParams(
          text: message,
          subject: 'AidatPanel Davet Kodu',
          sharePositionOrigin: box != null
              ? box.localToGlobal(Offset.zero) & box.size
              : null,
        ),
      );
    } catch (_) {
      Clipboard.setData(ClipboardData(text: message));
      if (mounted) {
        ref
            .read(toastProvider.notifier)
            .show(context.t.common.clipboardCopied, type: ToastType.info);
      }
    }
  }
}

class _SitePickerStep extends StatelessWidget {
  final List<SiteEntity> sites;
  final ValueChanged<SiteEntity> onSitePick;
  final VoidCallback onStandalonePick;

  const _SitePickerStep({
    super.key,
    required this.sites,
    required this.onSitePick,
    required this.onStandalonePick,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: AppSizes.screenBodyScrollPadding.copyWith(
        top: AppSizes.spacingM,
      ),
      itemCount: sites.length + 2,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.spacingM),
            child: DashboardSectionTitle(
              title: context.t.common.whichSiteForCode,
            ),
          );
        }
        if (index == 1) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.spacingS),
            child: InviteSelectableTile(
              icon: Icons.home_work_outlined,
              iconColor: AppColors.accent,
              title: context.t.common.inviteStandaloneBuildings,
              subtitle: context.t.common.whichBuildingForCode,
              onTap: onStandalonePick,
            ),
          );
        }
        final site = sites[index - 2];
        return InviteSelectableTile(
          icon: Icons.domain_rounded,
          iconColor: AppColors.primary,
          title: site.name,
          subtitle: site.displayAddress,
          onTap: () => onSitePick(site),
        );
      },
    );
  }
}

class _BuildingPickerStep extends StatelessWidget {
  final List<BuildingEntity> buildings;
  final SiteEntity? site;
  final ValueChanged<BuildingEntity> onPick;

  const _BuildingPickerStep({
    super.key,
    required this.buildings,
    required this.site,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: AppSizes.screenBodyScrollPadding.copyWith(
        top: AppSizes.spacingM,
      ),
      itemCount: buildings.length + (site != null ? 2 : 1),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.spacingM),
            child: site != null
                ? _InviteSiteBanner(site: site!)
                : DashboardSectionTitle(
                    title: context.t.common.whichBuildingForCode,
                  ),
          );
        }
        if (site != null && index == 1) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.spacingM),
            child: DashboardSectionTitle(
              title: context.t.common.whichBuildingForCode,
            ),
          );
        }
        final offset = site != null ? 2 : 1;
        final b = buildings[index - offset];
        return InviteSelectableTile(
          icon: Icons.apartment_rounded,
          iconColor: AppColors.primary,
          title: b.displayName,
          subtitle: b.displayAddress,
          onTap: () => onPick(b),
        );
      },
    );
  }
}

class _InviteSiteBanner extends StatelessWidget {
  final SiteEntity site;

  const _InviteSiteBanner({required this.site});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spacingM),
      decoration: DashboardScreenStyle.whiteCard(),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.domain_rounded,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  site.name,
                  style: ProfileSettingsUi.fieldValue.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (site.displayAddress.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    site.displayAddress,
                    style: ProfileSettingsUi.fieldLabel.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ApartmentPickerStep extends StatelessWidget {
  final BuildingEntity building;
  final List<ApartmentEntity> apartments;
  final Map<String, ActiveInviteCode> activeCodes;
  final ValueChanged<ApartmentEntity> onPick;

  const _ApartmentPickerStep({
    super.key,
    required this.building,
    required this.apartments,
    required this.activeCodes,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    if (apartments.isEmpty) {
      final emptyItems = <Widget>[
        _InviteBuildingBanner(building: building),
        const SizedBox(height: AppSizes.spacingL),
        DashboardSectionTitle(title: context.t.common.whichApartmentForCode),
        const SizedBox(height: AppSizes.spacingM),
        _InviteEmptyApartmentsState(message: context.t.common.noApartmentsInBuilding),
      ];
      return ListView.builder(
        padding: AppSizes.screenBodyScrollPadding.copyWith(
          top: AppSizes.spacingM,
        ),
        itemCount: emptyItems.length,
        itemBuilder: (_, i) => emptyItems[i],
      );
    }

    const headerCount = 3;
    return ListView.builder(
      padding: AppSizes.screenBodyScrollPadding.copyWith(
        top: AppSizes.spacingM,
      ),
      itemCount: apartments.length + headerCount,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.spacingL),
            child: _InviteBuildingBanner(building: building),
          );
        }
        if (index == 1) {
          return DashboardSectionTitle(
            title: context.t.common.whichApartmentForCode,
          );
        }
        if (index == 2) {
          return const SizedBox(height: AppSizes.spacingM);
        }
        final apt = apartments[index - headerCount];
        return _buildApartmentTile(context, apt);
      },
    );
  }

  Widget _buildApartmentTile(BuildContext context, ApartmentEntity apt) {
    final isOccupied = apt.isOccupied;
    final activeCode = activeCodes[apt.id];
    final hasActiveCode = activeCode != null && !activeCode.isExpired;
    final apartmentLabel = ApartmentUiUtils.formatApartmentLabel(
      context,
      apt.apartmentNumber,
    );

    final tileIcon = hasActiveCode
        ? Icons.qr_code_2_rounded
        : Icons.door_front_door_outlined;
    final tileColor = hasActiveCode
        ? AppColors.accent
        : (isOccupied ? AppColors.warning : AppColors.success);
    final String subtitle;
    final String? subtitleLine2;
    if (hasActiveCode) {
      final lines = InviteCodeHelpers.activeCodeListSubtitle(
        activeCodeLabel: context.t.common.activeCodePrefix,
        code: activeCode.code,
        remaining: activeCode.remaining,
      );
      subtitle = lines.primary;
      subtitleLine2 = lines.remaining;
    } else {
      subtitle = isOccupied
          ? '${context.t.common.residentPrefix}: ${apt.residentName}'
          : context.t.common.emptyApartment;
      subtitleLine2 = null;
    }

    return InviteSelectableTile(
      icon: tileIcon,
      iconColor: tileColor,
      title: apartmentLabel,
      subtitle: subtitle,
      subtitleLine2: subtitleLine2,
      trailing: _InviteStatusBadge(
        hasActiveCode: hasActiveCode,
        isOccupied: isOccupied,
      ),
      onTap: () => onPick(apt),
    );
  }
}

class _InviteBuildingBanner extends StatelessWidget {
  final BuildingEntity building;

  const _InviteBuildingBanner({required this.building});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spacingM),
      decoration: DashboardScreenStyle.whiteCard(),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.apartment_rounded,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (building.siteName != null &&
                    building.siteName!.trim().isNotEmpty) ...[
                  Text(
                    building.siteName!,
                    style: ProfileSettingsUi.fieldLabel.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                ],
                Text(
                  building.displayName,
                  style: ProfileSettingsUi.fieldValue.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (building.displayAddress.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    building.displayAddress,
                    style: ProfileSettingsUi.fieldLabel.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InviteEmptyApartmentsState extends StatelessWidget {
  final String message;

  const _InviteEmptyApartmentsState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spacingXL),
      decoration: DashboardScreenStyle.whiteCard(),
      child: Column(
        children: [
          Icon(
            Icons.door_back_door_outlined,
            size: 56,
            color: ProfileSettingsUi.muted.withValues(alpha: 0.85),
          ),
          const SizedBox(height: AppSizes.spacingM),
          Text(
            message,
            style: ProfileSettingsUi.handle.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _InviteStatusBadge extends StatelessWidget {
  final bool hasActiveCode;
  final bool isOccupied;

  const _InviteStatusBadge({
    required this.hasActiveCode,
    required this.isOccupied,
  });

  @override
  Widget build(BuildContext context) {
    final (label, color, backgroundColor) = _resolveBadge(context);
    return Container(
      constraints: const BoxConstraints(maxWidth: 96),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 13,
          height: 1.2,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
      ),
    );
  }

  (String, Color, Color) _resolveBadge(BuildContext context) {
    if (hasActiveCode) {
      return (
        context.t.common.activeCodeBadge,
        AppColors.accent,
        AppColors.accent.withValues(alpha: 0.12),
      );
    }
    if (isOccupied) {
      return (
        context.t.common.occupiedBadge,
        AppColors.warning,
        AppColors.warning.withValues(alpha: 0.12),
      );
    }
    return (
      context.t.common.emptyBadge,
      AppColors.success,
      AppColors.success.withValues(alpha: 0.12),
    );
  }
}
