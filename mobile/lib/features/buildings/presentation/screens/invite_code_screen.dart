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

/// Davet kodu üretme akışı (3 adım): Bina → Daire → Kod.
class InviteCodeScreen extends ConsumerStatefulWidget {
  const InviteCodeScreen({super.key});

  @override
  ConsumerState<InviteCodeScreen> createState() => _InviteCodeScreenState();
}

class _InviteCodeScreenState extends ConsumerState<InviteCodeScreen> {
  int _step = 0;
  BuildingEntity? _selectedBuilding;
  ApartmentEntity? _selectedApartment;
  String? _generatedCode;
  DateTime? _activeExpiresAt;

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
            InviteStepIndicator(currentStep: _step),
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
    switch (_step) {
      case 0:
        final buildingsAsync = ref.watch(buildingsStoreProvider);
        return buildingsAsync.when(
          loading: () => const Center(
            key: ValueKey('step-0-loading'),
            child: CircularProgressIndicator(),
          ),
          error: (e, _) => AsyncErrorWidget(
            key: const ValueKey('step-0-error'),
            message: userFacingError(e),
            onRetry: () => ref.read(buildingsStoreProvider.notifier).loadBuildings(),
          ),
          data: (buildings) => _BuildingPickerStep(
            key: const ValueKey('step-0'),
            buildings: buildings,
            onPick: _onBuildingPicked,
          ),
        );
      case 1:
        final asyncApts =
            ref.watch(apartmentsStoreProvider(_selectedBuilding!.id));
        return asyncApts.when(
          loading: () => const Center(
            key: ValueKey('step-1-loading'),
            child: CircularProgressIndicator(),
          ),
          error: (e, _) => AsyncErrorWidget(
            key: const ValueKey('step-1-error'),
            message: userFacingError(e),
            onRetry: () => ref
                .read(apartmentsStoreProvider(_selectedBuilding!.id).notifier)
                .loadApartments(),
          ),
          data: (apartments) => _ApartmentPickerStep(
            key: const ValueKey('step-1'),
            building: _selectedBuilding!,
            apartments: apartments,
            onPick: _onApartmentSelected,
            activeCodes: ref.watch(inviteCodeStoreProvider),
          ),
        );
      case 2:
        return InviteCodeResultView(
          key: const ValueKey('step-2'),
          code: _generatedCode!,
          building: _selectedBuilding!,
          apartment: _selectedApartment!,
          expiresAt: _activeExpiresAt!,
          onCopy: () => _copyCode(_generatedCode!),
          onShare: () => _shareCode(),
          onRevoke: _confirmRevoke,
          onPickAnother: _resetFlow,
          onGoHome: () => context.pop(),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  // ---------- AKIŞ ----------
  void _onBuildingPicked(BuildingEntity b) {
    ref.invalidate(apartmentsStoreProvider(b.id));
    setState(() {
      _selectedBuilding = b;
      _selectedApartment = null;
      _step = 1;
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
      _step = 2;
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
      _step = 2;
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
        _resetFlow();
      },
    );
  }

  void _resetFlow() {
    setState(() {
      _step = 0;
      _selectedBuilding = null;
      _selectedApartment = null;
      _generatedCode = null;
      _activeExpiresAt = null;
    });
  }

  void _onBackPressed() {
    if (_step == 0) {
      context.pop();
    } else if (_step == 1) {
      setState(() {
        _step = 0;
        _selectedBuilding = null;
      });
    } else {
      setState(() {
        _step = 1;
        _selectedApartment = null;
        _generatedCode = null;
        _activeExpiresAt = null;
      });
    }
  }

  // ---------- AKSİYONLAR ----------
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

// ============================================================================
//  ADIM 1: BİNA SEÇİMİ
// ============================================================================
class _BuildingPickerStep extends StatelessWidget {
  final List<BuildingEntity> buildings;
  final ValueChanged<BuildingEntity> onPick;

  const _BuildingPickerStep({
    super.key,
    required this.buildings,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: AppSizes.screenBodyScrollPadding.copyWith(
        top: AppSizes.spacingM,
      ),
      itemCount: buildings.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.spacingM),
            child: DashboardSectionTitle(
              title: context.t.common.whichBuildingForCode,
            ),
          );
        }
        final b = buildings[index - 1];
        return InviteSelectableTile(
          icon: Icons.apartment_rounded,
          iconColor: AppColors.primary,
          title: b.name,
          subtitle: InviteCodeHelpers.buildingListSubtitle(b),
          onTap: () => onPick(b),
        );
      },
    );
  }
}

// ============================================================================
//  ADIM 2: DAİRE SEÇİMİ
// ============================================================================
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
                    building.siteName!.isNotEmpty) ...[
                  Text(
                    building.siteName!,
                    style: ProfileSettingsUi.fieldLabel.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  building.name,
                  style: ProfileSettingsUi.fieldValue.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (InviteCodeHelpers.buildingListSubtitle(building).isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    InviteCodeHelpers.buildingListSubtitle(building),
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
