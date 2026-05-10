import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/strings.g.dart';
import '../../../apartments/data/apartments_store.dart';
import '../../../apartments/domain/entities/apartment_entity.dart';
import '../../../apartments/presentation/widgets/delete_apartment_dialog.dart';
import '../../../apartments/presentation/widgets/edit_apartment_bottom_sheet.dart';
import '../../domain/entities/building_entity.dart';

class BuildingResidentsScreen extends ConsumerWidget {
  final BuildingEntity building;

  const BuildingResidentsScreen({super.key, required this.building});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncApartments = ref.watch(apartmentsStoreProvider(building.id));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(context.t.common.buildingDetail),
        centerTitle: true,
      ),
      body: asyncApartments.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: AppSizes.spacingM),
              Text(
                e.toString(),
                style: AppTypography.body1
                    .copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.spacingM),
              ElevatedButton(
                onPressed: () => ref
                    .read(apartmentsStoreProvider(building.id).notifier)
                    .loadApartments(),
                child: Text(context.t.features.buildings.tekrarDene),
              ),
            ],
          ),
        ),
        data: (residents) => SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.spacingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(building),
              const SizedBox(height: AppSizes.spacingL),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.t.common.residents,
                    style: AppTypography.h3
                        .copyWith(color: AppColors.textPrimary),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.spacingM,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${residents.length} ${context.t.common.apartmentsBadge}',
                      style: AppTypography.caption.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.spacingM),
              if (residents.isEmpty)
                _buildEmptyState(context)
              else
                ...residents.asMap().entries.map(
                      (entry) => _buildResidentCard(
                          context, entry.key + 1, entry.value),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildingEntity building) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spacingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.apartment,
                    color: Colors.white, size: 28),
              ),
              const SizedBox(width: AppSizes.spacingM),
              Expanded(
                child: Text(
                  building.name,
                  style: AppTypography.h3.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacingM),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.location_on_outlined,
                  size: 18, color: Colors.white.withValues(alpha: 0.7)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  building.displayAddress,
                  style: AppTypography.body2.copyWith(color: Colors.white.withValues(alpha: 0.7)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResidentCard(
      BuildContext context, int index, ApartmentEntity apt) {
    // ApartmentEntity.isOccupied: backend'den dönen `resident` objesinin
    // null olup olmadığına bakar. Telefon paylaşmamış sakinler de "boş"
    // görünmesin diye `apt.phone != null` yerine bunu kullanıyoruz.
    final isOccupied = apt.isOccupied;
    final statusInfo = _getStatusInfo(context, apt.paymentStatus);

    // Boş daire kartı için soluk bir görünüm: yönetici tarafında "burada
    // henüz sakin yok" mesajının ilk bakışta okunabilmesi için arka plan
    // ve kenarlık tonu hafifçe değiştiriliyor.
    final cardColor = isOccupied
        ? AppColors.surface
        : AppColors.background.withValues(alpha: 0.6);
    final borderColor = isOccupied
        ? AppColors.borderColor
        : AppColors.borderColor.withValues(alpha: 0.5);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.spacingM),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isOccupied
                        ? AppColors.primaryLight.withValues(alpha: 0.15)
                        : AppColors.borderColor.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: isOccupied
                      ? Text(
                          '$index',
                          style: AppTypography.body1.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        )
                      : Icon(
                          Icons.person_off_outlined,
                          size: 22,
                          color: AppColors.textSecondary,
                        ),
                ),
                const SizedBox(width: AppSizes.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatApartmentLabel(context, apt.apartmentNumber),
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isOccupied
                            ? apt.residentName
                            : context.t.common.emptyApartmentText,
                        style: AppTypography.body1.copyWith(
                          color: isOccupied
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.w700,
                          fontStyle: isOccupied
                              ? FontStyle.normal
                              : FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isOccupied)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusInfo.bgColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusInfo.label,
                      style: AppTypography.caption.copyWith(
                        color: statusInfo.color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.borderColor.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      context.t.common.vacantBadge,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                _buildApartmentActionsMenu(context, apt),
              ],
            ),
            // Alt satır:
            //  - Dolu + telefon var  -> telefon ikonu + numara
            //  - Dolu + telefon yok  -> "Telefon paylaşılmadı" rozeti
            //  - Boş                 -> sadece aylık aidat (planlanmış)
            const SizedBox(height: AppSizes.spacingM),
            Container(height: 1, color: borderColor),
            const SizedBox(height: AppSizes.spacingM),
            Row(
              children: [
                if (isOccupied && apt.phone != null) ...[
                  Icon(Icons.phone_outlined,
                      size: 18, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      _formatPhone(apt.phone!),
                      style: AppTypography.body2.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ] else if (isOccupied && apt.phone == null) ...[
                  Icon(Icons.phone_disabled_outlined,
                      size: 18, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      context.t.common.phoneNotShared,
                      style: AppTypography.body2.copyWith(
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ] else ...[
                  Icon(Icons.event_busy_outlined,
                      size: 18, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      context.t.common.noResidentAssigned,
                      style: AppTypography.body2.copyWith(
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                Text(
                  '₺${apt.monthlyDues.toStringAsFixed(0)}${context.t.common.perMonth}',
                  style: AppTypography.body2
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Daire kartının sağ üst köşesinde "..." menu.
  /// Düzenle → bottom sheet, Sil → onay dialog'u.
  Widget _buildApartmentActionsMenu(
      BuildContext context, ApartmentEntity apt) {
    return PopupMenuButton<_ApartmentAction>(
      tooltip: '',
      icon: const Icon(
        Icons.more_vert,
        color: AppColors.textSecondary,
        size: 24,
      ),
      padding: EdgeInsets.zero,
      onSelected: (action) {
        switch (action) {
          case _ApartmentAction.edit:
            EditApartmentBottomSheet.show(context, apartment: apt);
            break;
          case _ApartmentAction.delete:
            DeleteApartmentDialog.show(context, apartment: apt);
            break;
        }
      },
      itemBuilder: (_) => [
        PopupMenuItem(
          value: _ApartmentAction.edit,
          child: Row(
            children: [
              const Icon(Icons.edit_outlined,
                  size: 22, color: AppColors.primary),
              const SizedBox(width: AppSizes.spacingS),
              Text(
                context.t.common.editApartment,
                style:
                    AppTypography.body1.copyWith(color: AppColors.textPrimary),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: _ApartmentAction.delete,
          child: Row(
            children: [
              const Icon(Icons.delete_outline,
                  size: 22, color: AppColors.error),
              const SizedBox(width: AppSizes.spacingS),
              Text(
                context.t.common.deleteApartment,
                style: AppTypography.body1.copyWith(color: AppColors.error),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spacingXL),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        children: [
          Icon(Icons.people_outline,
              size: 56, color: AppColors.textSecondary),
          const SizedBox(height: AppSizes.spacingM),
          Text(
            context.t.common.noApartmentsYet,
            style:
                AppTypography.body1.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  String _formatApartmentLabel(BuildContext context, String apartmentNumber) {
    final match =
        RegExp(r'(\d+)([A-Za-z]?)').firstMatch(apartmentNumber);
    if (match == null) return apartmentNumber;
    final floor = match.group(1);
    final letter = match.group(2);
    if (letter != null && letter.isNotEmpty) {
      return '$floor. ${context.t.common.floorLabel} • ${context.t.common.apartmentLabel} $letter';
    }
    return '$floor. ${context.t.common.floorLabel}';
  }

  String _formatPhone(String phone) {
    final clean = phone.replaceAll(RegExp(r'[^\d+]'), '');
    if (clean.startsWith('+90') && clean.length == 13) {
      return '+90 ${clean.substring(3, 6)} ${clean.substring(6, 9)} ${clean.substring(9, 11)} ${clean.substring(11)}';
    }
    return phone;
  }

  _StatusInfo _getStatusInfo(BuildContext context, PaymentStatus status) {
    switch (status) {
      case PaymentStatus.paid:
        return _StatusInfo(
          label: context.t.common.paidStatus,
          color: AppColors.success,
          bgColor: AppColors.success.withValues(alpha: 0.12),
        );
      case PaymentStatus.pending:
        return _StatusInfo(
          label: context.t.common.pendingStatus,
          color: AppColors.warning,
          bgColor: AppColors.warning.withValues(alpha: 0.12),
        );
      case PaymentStatus.overdue:
        return _StatusInfo(
          label: context.t.common.overdueStatus,
          color: AppColors.error,
          bgColor: AppColors.error.withValues(alpha: 0.12),
        );
    }
  }
}

class _StatusInfo {
  final String label;
  final Color color;
  final Color bgColor;

  _StatusInfo({
    required this.label,
    required this.color,
    required this.bgColor,
  });
}

enum _ApartmentAction { edit, delete }
