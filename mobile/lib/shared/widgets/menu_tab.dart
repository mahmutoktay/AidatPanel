import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/locale_provider.dart';
import '../../core/providers/theme_mode_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/theme/app_typography.dart';
import '../../features/auth/domain/entities/user_entity.dart';
import '../../features/buildings/data/buildings_store.dart';
import '../../features/buildings/domain/entities/building_entity.dart';
import '../../features/notifications/presentation/widgets/announcement_form_sheet.dart';
import '../../features/profile/presentation/widgets/change_password_bottom_sheet.dart';
import '../../features/reports/presentation/widgets/report_download_sheet.dart';
import '../../l10n/strings.g.dart';
import '../providers/navigation_provider.dart';
import 'dashboard/dashboard_app_bar.dart';
import 'settings/settings_sheet_actions.dart';
import 'settings/settings_ui_widgets.dart';

class MenuTab extends ConsumerWidget {
  final UserRole role;

  const MenuTab({super.key, required this.role});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final faz2 = t.features.faz2;

    return ColoredBox(
      color: AppColors.dashboardBackground,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: AppSizes.screenBodyScrollPadding.copyWith(
          top: AppSizes.spacingS,
          bottom: AppSizes.spacingXL,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              t.common.menuSubtitle,
              style: AppTypography.body1.copyWith(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: AppSizes.spacingL),
            if (role == UserRole.manager) ...[
              _buildManagerMenu(context, ref, t, faz2),
            ] else ...[
              _buildResidentMenu(context, ref, t, faz2),
            ],
            if (kDebugMode) ...[
              const SizedBox(height: AppSizes.spacingM),
              const SettingsSurfaceCard(children: [TokenTestSettingsTile()]),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildManagerMenu(
    BuildContext context,
    WidgetRef ref,
    dynamic t,
    dynamic faz2,
  ) {
    final common = t.common;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MenuSectionTitle(title: common.menuSectionFinance),
        SettingsSurfaceCard(
          children: [
            SettingsTile(
              icon: Icons.receipt_outlined,
              title: common.dues,
              onTap: () => ref.read(managerTabIndexProvider.notifier).update(2),
            ),
            SettingsTile(
              icon: Icons.receipt_long_outlined,
              title: faz2.expenses,
              onTap: () => context.push('/manager-dashboard/expenses'),
            ),
            SettingsTile(
              icon: Icons.rate_review_outlined,
              title: common.menuReviewDekonts,
              onTap: () => context.push('/manager-dashboard/dekonts'),
            ),
            SettingsTile(
              icon: Icons.warning_amber_rounded,
              title: common.menuOverdueApartments,
              onTap: () => context.push('/manager-dashboard/overdue-apartments'),
            ),
            SettingsTile(
              icon: Icons.picture_as_pdf_outlined,
              title: common.menuDownloadReport,
              onTap: () => _pickBuildingForReport(context, ref),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.spacingM),
        MenuSectionTitle(title: common.menuSectionBuildings),
        SettingsSurfaceCard(
          children: [
            SettingsTile(
              icon: Icons.apartment_outlined,
              title: common.buildings,
              onTap: () => ref.read(managerTabIndexProvider.notifier).update(1),
            ),
            SettingsTile(
              icon: Icons.add_home_work_outlined,
              title: common.menuAddBuilding,
              onTap: () => context.push('/manager-dashboard/add-building'),
            ),
            SettingsTile(
              icon: Icons.qr_code_2_outlined,
              title: common.menuInviteCode,
              onTap: () => context.push('/manager-dashboard/invite-code'),
            ),
            SettingsTile(
              icon: Icons.account_balance_wallet_outlined,
              title: t.features.buildings.collection.savedIbansTitle,
              onTap: () => context.push('/manager-dashboard/saved-ibans'),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.spacingM),
        MenuSectionTitle(title: common.menuSectionCommunication),
        SettingsSurfaceCard(
          children: [
            SettingsTile(
              icon: Icons.assignment_outlined,
              title: faz2.tickets,
              onTap: () => context.push('/manager-dashboard/tickets'),
            ),
            SettingsTile(
              icon: Icons.campaign_outlined,
              title: common.menuSendAnnouncement,
              onTap: () => AnnouncementFormSheet.show(context),
            ),
            SettingsTile(
              icon: Icons.notifications_outlined,
              title: common.notifications,
              onTap: () => context.push('/manager-dashboard/notifications'),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.spacingM),
        MenuSectionTitle(title: common.menuSectionAccount),
        SettingsSurfaceCard(
          children: [
            SettingsTile(
              icon: Icons.person_outline,
              title: common.menuMyProfile,
              onTap: () => context.push('/manager-dashboard/profile'),
            ),
            SettingsTile(
              icon: Icons.devices_outlined,
              title: common.menuActiveSessions,
              onTap: () => context.push('/manager-dashboard/profile/sessions'),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.spacingM),
        MenuSectionTitle(title: common.menuSectionSettings),
        SettingsSurfaceCard(
          children: [
            SettingsTile(
              icon: Icons.lock_outline,
              title: common.changePassword,
              onTap: () => ChangePasswordBottomSheet.show(context),
            ),
            SettingsTile(
              icon: Icons.language_outlined,
              title: common.language,
              trailing: ref.watch(localeProvider) == AppLocale.tr
                  ? 'Türkçe'
                  : 'English',
              onTap: () => showLanguageSheet(context, ref),
            ),
            SettingsTile(
              icon: Icons.dark_mode_outlined,
              title: common.theme,
              trailing: themePreferenceLabel(
                context,
                ref.watch(themeModeProvider),
              ),
              onTap: () => showThemeSheet(context, ref),
            ),
            SettingsTile(
              icon: Icons.notifications_outlined,
              title: common.notifications,
              onTap: () => context.push('/manager-dashboard/notifications'),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.spacingM),
        MenuSectionTitle(title: common.menuSectionSubscription),
        SettingsSurfaceCard(
          children: [
            SettingsTile(
              icon: Icons.card_membership_outlined,
              title: t.features.subscription.title,
              onTap: () => context.push('/manager-dashboard/subscription'),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.spacingM),
        MenuSectionTitle(title: common.menuSectionLegal),
        _legalSection(context, common),
      ],
    );
  }

  Widget _buildResidentMenu(
    BuildContext context,
    WidgetRef ref,
    dynamic t,
    dynamic faz2,
  ) {
    final common = t.common;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MenuSectionTitle(title: common.menuSectionPayments),
        SettingsSurfaceCard(
          children: [
            SettingsTile(
              icon: Icons.receipt_outlined,
              title: common.dues,
              onTap: () => ref.read(residentTabIndexProvider.notifier).update(1),
            ),
            SettingsTile(
              icon: Icons.payment_outlined,
              title: common.makePayment,
              onTap: () => context.push('/resident-dashboard/payment'),
            ),
            SettingsTile(
              icon: Icons.description_outlined,
              title: common.menuMyDekonts,
              onTap: () => context.push('/resident-dashboard/dekonts'),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.spacingM),
        MenuSectionTitle(title: common.menuSectionSupport),
        SettingsSurfaceCard(
          children: [
            SettingsTile(
              icon: Icons.support_agent_outlined,
              title: common.issues,
              onTap: () => ref.read(residentTabIndexProvider.notifier).update(2),
            ),
            SettingsTile(
              icon: Icons.add_comment_outlined,
              title: common.menuCreateTicket,
              onTap: () => context.push('/tickets/create'),
            ),
            SettingsTile(
              icon: Icons.notifications_outlined,
              title: common.notifications,
              onTap: () => context.push('/resident-dashboard/notifications'),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.spacingM),
        MenuSectionTitle(title: common.menuSectionAccount),
        SettingsSurfaceCard(
          children: [
            SettingsTile(
              icon: Icons.person_outline,
              title: common.menuMyProfile,
              onTap: () => context.push('/resident-dashboard/profile'),
            ),
            SettingsTile(
              icon: Icons.devices_outlined,
              title: common.menuActiveSessions,
              onTap: () => context.push('/resident-dashboard/profile/sessions'),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.spacingM),
        MenuSectionTitle(title: common.menuSectionSettings),
        SettingsSurfaceCard(
          children: [
            SettingsTile(
              icon: Icons.lock_outline,
              title: common.changePassword,
              onTap: () => ChangePasswordBottomSheet.show(context),
            ),
            SettingsTile(
              icon: Icons.language_outlined,
              title: common.language,
              trailing: ref.watch(localeProvider) == AppLocale.tr
                  ? 'Türkçe'
                  : 'English',
              onTap: () => showLanguageSheet(context, ref),
            ),
            SettingsTile(
              icon: Icons.dark_mode_outlined,
              title: common.theme,
              trailing: themePreferenceLabel(
                context,
                ref.watch(themeModeProvider),
              ),
              onTap: () => showThemeSheet(context, ref),
            ),
            SettingsTile(
              icon: Icons.notifications_outlined,
              title: common.notifications,
              onTap: () => context.push('/resident-dashboard/notifications'),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.spacingM),
        MenuSectionTitle(title: common.menuSectionLegal),
        _legalSection(context, common),
      ],
    );
  }

  Widget _legalSection(BuildContext context, dynamic common) {
    return SettingsSurfaceCard(
      children: [
        SettingsTile(
          icon: Icons.privacy_tip_outlined,
          title: common.privacyPolicy,
          onTap: () => context.push('/legal/privacy'),
        ),
        SettingsTile(
          icon: Icons.shield_outlined,
          title: common.kvkk,
          onTap: () => context.push('/legal/kvkk'),
        ),
        SettingsTile(
          icon: Icons.help_outline,
          title: common.helpSupport,
          onTap: () => context.push('/legal/help'),
        ),
        SettingsTile(
          icon: Icons.info_outline,
          title: common.about,
          onTap: () => showAppAboutDialog(context),
        ),
      ],
    );
  }

  Future<void> _pickBuildingForReport(BuildContext context, WidgetRef ref) async {
    final buildingsAsync = ref.read(buildingsStoreProvider);
    final buildings = buildingsAsync.value ?? const <BuildingEntity>[];

    if (buildings.isEmpty) {
      await ref.read(buildingsStoreProvider.notifier).loadBuildings();
    }

    if (!context.mounted) return;

    final loaded = ref.read(buildingsStoreProvider).value ?? const <BuildingEntity>[];
    if (loaded.isEmpty) {
      ref.read(managerTabIndexProvider.notifier).update(1);
      return;
    }

    if (loaded.length == 1) {
      await ReportDownloadSheet.show(context, building: loaded.first);
      return;
    }

    if (!context.mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSizes.spacingM),
                child: Text(
                  context.t.common.menuDownloadReport,
                  style: AppTypography.h4.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: loaded.length,
                  itemBuilder: (_, index) {
                    final building = loaded[index];
                    return ListTile(
                      minTileHeight: AppSizes.minTouchTarget,
                      leading: const Icon(Icons.apartment_outlined),
                      title: Text(
                        building.name,
                        style: AppTypography.body1.copyWith(fontSize: 16),
                      ),
                      onTap: () async {
                        Navigator.pop(sheetContext);
                        if (!context.mounted) return;
                        await ReportDownloadSheet.show(
                          context,
                          building: building,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
