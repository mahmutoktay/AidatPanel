import 'package:flutter/material.dart';
import '../../../../shared/widgets/action_chevron.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/app_date_format.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/input_validators.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/dashboard_secondary_scaffold.dart';
import '../../../../shared/widgets/profile_avatar.dart';
import '../../../../shared/widgets/profile_avatar_actions.dart';
import '../../../../shared/widgets/toast_overlay.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../subscription/domain/entities/subscription_entity.dart';
import '../../../subscription/presentation/providers/subscription_provider.dart';
import '../providers/profile_notifier.dart';
import '../theme/profile_settings_ui.dart';
import '../widgets/delete_account_sheet.dart';
import '../widgets/logout_all_devices_tile.dart';

/// Ayarlar → Profil bilgileri.
///
/// FAZ 4: `GET /me` ile yükleme, `PUT /me` ile ad + telefon güncelleme.
/// Görünüm: Ayarlar sekmesi ile aynı kart tabanlı dashboard dili.
class ProfileDetailsScreen extends ConsumerStatefulWidget {
  const ProfileDetailsScreen({super.key});

  @override
  ConsumerState<ProfileDetailsScreen> createState() =>
      _ProfileDetailsScreenState();
}

class _ProfileDetailsScreenState extends ConsumerState<ProfileDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _editing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileNotifierProvider.notifier).loadProfile();
      final user = ref.read(authStateProvider).user;
      if (user?.role == UserRole.manager) {
        ref.read(subscriptionNotifierProvider.notifier).load();
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  UserEntity? get _currentUser =>
      ref.read(profileNotifierProvider).user ??
      ref.read(authStateProvider).user;

  static String _phoneDigits(String? phone) {
    if (phone == null) return '';
    final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length <= 10) return digits;
    return digits.substring(digits.length - 10);
  }

  void _enterEdit() {
    final user = _currentUser;
    if (user == null) return;
    _nameController.text = user.name;
    _emailController.text = user.email ?? '';
    _phoneController.text = _phoneDigits(user.phone);
    setState(() => _editing = true);
  }

  void _cancelEdit() {
    FocusScope.of(context).unfocus();
    setState(() => _editing = false);
  }

  Future<void> _save() async {
    final t = context.t;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();

    final user = _currentUser;
    if (user == null) return;

    final phone = _phoneController.text.trim();
    final newEmail = _emailController.text.trim();

    if (phone.isEmpty && newEmail.isEmpty) {
      ref
          .read(toastProvider.notifier)
          .show(
            t.features.profile.contactRequired,
            type: ToastType.error,
          );
      return;
    }

    final isEmailChanged = newEmail != (user.email ?? '');
    final isPhoneChanged = phone != _phoneDigits(user.phone);

    String? currentPassword;
    if (isEmailChanged || isPhoneChanged) {
      currentPassword = await _showPasswordDialog(context);
      if (currentPassword == null || currentPassword.isEmpty) {
        return; // User cancelled or didn't enter password
      }
    }

    final ok = await ref
        .read(profileNotifierProvider.notifier)
        .saveProfile(
          name: _nameController.text.trim(),
          email: newEmail.isEmpty ? null : newEmail,
          phone: phone.isEmpty ? null : phone,
          currentPassword: currentPassword,
        );
    if (!mounted) return;

    if (ok) {
      ref
          .read(toastProvider.notifier)
          .show(t.features.profile.profileUpdated, type: ToastType.success);
      setState(() => _editing = false);
    } else {
      final error = ref.read(profileNotifierProvider).error;
      ref
          .read(toastProvider.notifier)
          .show(
            error ?? t.features.profile.profileUpdateFailed,
            type: ToastType.error,
          );
    }
  }

  Future<String?> _showPasswordDialog(BuildContext context) async {
    final t = context.t;
    final controller = TextEditingController();
    bool obscure = true;

    return showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: ProfileSettingsUi.background,
          title: Text(t.features.profile.securityVerificationTitle, style: ProfileSettingsUi.title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                t.features.profile.securityVerificationMessage,
                style: ProfileSettingsUi.fieldValue,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                obscureText: obscure,
                autofocus: true,
                cursorColor: ProfileSettingsUi.ink,
                decoration: InputDecoration(
                  labelText: t.features.auth.password,
                  labelStyle: ProfileSettingsUi.fieldLabel,
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscure ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () => setState(() => obscure = !obscure),
                    color: ProfileSettingsUi.muted,
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: ProfileSettingsUi.ink,
                      width: 1.4,
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                t.common.cancel,
                style: TextStyle(color: ProfileSettingsUi.muted),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(controller.text),
              style: ProfileSettingsUi.primaryButton,
              child: Text(t.common.confirm),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileNotifierProvider);
    final authUser = ref.watch(authStateProvider.select((state) => state.user));
    final user = profileState.user ?? authUser;
    final subscriptionState = ref.watch(subscriptionNotifierProvider);

    return DashboardSecondaryScaffold(
      title: _editing ? context.t.features.profile.editTitle : context.t.features.profile.title,
      canPop: !profileState.isSaving,
      leading: _editing
          ? IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: _cancelEdit,
            )
          : null,
      actions: [
        if (user != null && !_editing && !profileState.isSaving)
          TextButton.icon(
            onPressed: _enterEdit,
            icon: const Icon(Icons.edit_outlined, size: 20),
            label: Text(context.t.common.edit),
          ),
      ],
      body: _buildBody(context, profileState, user, subscriptionState),
      bottomNavigationBar: _editing && user != null
          ? _buildSaveBar(context, profileState)
          : null,
    );
  }

  Widget _buildBody(
    BuildContext context,
    ProfileState profileState,
    UserEntity? user,
    SubscriptionState subscriptionState,
  ) {
    final t = context.t;

    if (profileState.isLoading && user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (user == null) {
      return Center(
        child: Padding(
          padding: ProfileSettingsUi.screenPadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                profileState.error ?? t.common.unexpectedError,
                style: ProfileSettingsUi.handle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: () =>
                      ref.read(profileNotifierProvider.notifier).loadProfile(),
                  style: ProfileSettingsUi.primaryButton,
                  child: Text(t.common.tryAgain),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final roleLabel = user.role == UserRole.manager
        ? t.common.manager
        : t.common.resident;
    final languageLabel = user.language == 'en' ? 'English' : t.common.turkish;

    final content = Form(
      key: _formKey,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: AppSizes.screenBodyScrollPadding.copyWith(
          top: AppSizes.spacingS,
          bottom: AppSizes.spacingXL,
        ),
        children: [
          _ProfileHero(
            editing: _editing,
            onAvatarTap: () => handleProfileAvatarTap(context, ref),
            userName: user.name,
            createdAt: user.createdAt,
            showSubscription: user.role == UserRole.manager,
            subscription: subscriptionState.subscription,
            subscriptionLoading: subscriptionState.isLoading,
          ),
          const SizedBox(height: AppSizes.spacingM),
          _ProfileSectionHeader(title: t.features.profile.sectionPersonal),
          const SizedBox(height: AppSizes.spacingS),
          _ProfileSurfaceCard(
            children: _editing
                ? [
                    _InlineField(
                      icon: Icons.person_outline,
                      label: t.features.profile.fullName,
                      controller: _nameController,
                      enabled: !profileState.isSaving,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.name],
                      validator: (value) => InputValidators.validateName(value),
                    ),
                    _InlineField(
                      icon: Icons.email_outlined,
                      label: t.features.profile.email,
                      controller: _emailController,
                      enabled: !profileState.isSaving,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      validator: (value) {
                        final raw = value?.trim() ?? '';
                        if (raw.isEmpty) return null;
                        final key = InputValidators.validateEmail(raw);
                        if (key == 'email_required') return null;
                        if (key == null) return null;
                        return t.validation.emailInvalid;
                      },
                      showClearSuffix: true,
                      onChanged: (_) => setState(() {}),
                    ),
                    _InlineField(
                      icon: Icons.phone_outlined,
                      label: t.features.profile.phone,
                      controller: _phoneController,
                      enabled: !profileState.isSaving,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [
                        AutofillHints.telephoneNumberNational,
                      ],
                      maxLength: 10,
                      prefixText: '+90 ',
                      helperText: t.features.profile.phoneOptionalHint,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      showClearSuffix: true,
                      onChanged: (_) => setState(() {}),
                      onSubmitted: (_) => _save(),
                      validator: (value) {
                        final raw = value?.trim() ?? '';
                        if (raw.isEmpty) return null;
                        final key = InputValidators.validatePhone(raw);
                        if (key == null) return null;
                        return t.validation.phoneInvalid;
                      },
                    ),
                  ]
                : [
                    _InfoTile(
                      icon: Icons.person_outline,
                      label: t.features.profile.fullName,
                      value: user.name,
                    ),
                    _InfoTile(
                      icon: Icons.email_outlined,
                      label: t.features.profile.email,
                      value: (user.email != null && user.email!.isNotEmpty)
                          ? user.email!
                          : t.features.profile.notProvided,
                      isEmpty: user.email == null || user.email!.isEmpty,
                    ),
                    _InfoTile(
                      icon: Icons.phone_outlined,
                      label: t.features.profile.phone,
                      value: (user.phone != null && user.phone!.isNotEmpty)
                          ? _formatPhone(user.phone!)
                          : t.features.profile.notProvided,
                      isEmpty: user.phone == null || user.phone!.isEmpty,
                    ),
                  ],
          ),
          const SizedBox(height: AppSizes.spacingM),
          _ProfileSectionHeader(title: t.features.profile.sectionAccount),
          const SizedBox(height: AppSizes.spacingS),
          _ProfileSurfaceCard(
            children: [
              _InfoTile(
                icon: Icons.badge_outlined,
                label: t.features.profile.role,
                value: roleLabel,
                locked: true,
              ),
              _InfoTile(
                icon: Icons.language_outlined,
                label: t.features.profile.languagePref,
                value: languageLabel,
                locked: true,
              ),
            ],
          ),
          if (!_editing) ...[
            const SizedBox(height: AppSizes.spacingM),
            _ProfileSurfaceCard(children: const [LogoutAllDevicesTile()]),
            const SizedBox(height: AppSizes.spacingM),
            _ProfileSurfaceCard(
              children: [
                _DangerTile(
                  icon: Icons.delete_outline,
                  label: t.common.deleteAccount,
                  onTap: () => DeleteAccountSheet.show(context),
                ),
              ],
            ),
          ],
        ],
      ),
    );

    if (_editing) return content;

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(profileNotifierProvider.notifier).loadProfile();
        if (user.role == UserRole.manager) {
          await ref.read(subscriptionNotifierProvider.notifier).load();
        }
      },
      child: content,
    );
  }

  Widget _buildSaveBar(BuildContext context, ProfileState profileState) {
    final t = context.t;
    final saving = profileState.isSaving;

    return ColoredBox(
      color: AppColors.dashboardBackground,
      child: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        child: SizedBox(
          height: ProfileSettingsUi.buttonHeight,
          child: ElevatedButton(
            onPressed: saving ? null : _save,
            style: ProfileSettingsUi.primaryButton,
            child: saving
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: Colors.white,
                    ),
                  )
                : Text(t.common.save),
          ),
        ),
      ),
    );
  }
}

class _ProfileSectionHeader extends StatelessWidget {
  final String title;

  const _ProfileSectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTypography.h4.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w800,
        fontSize: 18,
      ),
    );
  }
}

class _ProfileSurfaceCard extends StatelessWidget {
  final List<Widget> children;

  const _ProfileSurfaceCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        boxShadow: const [],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

/// "+905551234567" / "5551234567" → "+90 555 123 45 67".
String _formatPhone(String phone) {
  var digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.length > 10) {
    digits = digits.substring(digits.length - 10);
  }
  if (digits.length != 10) return phone;
  final p = digits;
  return '+90 ${p.substring(0, 3)} ${p.substring(3, 6)} '
      '${p.substring(6, 8)} ${p.substring(8, 10)}';
}

/// Avatar solda; sağda abonelik özeti ve hesap oluşturulma tarihi.
class _ProfileHero extends StatelessWidget {
  final String userName;
  final bool editing;
  final VoidCallback onAvatarTap;
  final DateTime? createdAt;
  final bool showSubscription;
  final SubscriptionEntity? subscription;
  final bool subscriptionLoading;

  const _ProfileHero({
    required this.userName,
    required this.editing,
    required this.onAvatarTap,
    this.createdAt,
    this.showSubscription = false,
    this.subscription,
    this.subscriptionLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.t;

    return Padding(
      padding: const EdgeInsets.only(
        left: AppSizes.spacingXS,
        right: AppSizes.spacingM,
        top: AppSizes.spacingS,
        bottom: AppSizes.spacingM,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.bottomRight,
                children: [
                  ProfileAvatar(
                    size: ProfileSettingsUi.avatarSize,
                    userName: userName,
                    onTap: onAvatarTap,
                  ),
                  Material(
                    color: ProfileSettingsUi.ink,
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: onAvatarTap,
                      customBorder: const CircleBorder(),
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Icon(
                          Icons.photo_camera_outlined,
                          size: 14,
                          color: AppColors.actionButtonForeground,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: AppSizes.spacingM),
              Expanded(
                child: _ProfileHeroMeta(
                  showSubscription: showSubscription,
                  subscription: subscription,
                  subscriptionLoading: subscriptionLoading,
                  createdAt: createdAt,
                ),
              ),
            ],
          ),
          if (editing) ...[
            const SizedBox(height: 10),
            Text(
              t.features.profile.editPhotoHint,
              style: ProfileSettingsUi.handle.copyWith(fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }
}

class _ProfileHeroMeta extends StatelessWidget {
  final bool showSubscription;
  final SubscriptionEntity? subscription;
  final bool subscriptionLoading;
  final DateTime? createdAt;

  const _ProfileHeroMeta({
    required this.showSubscription,
    required this.subscription,
    required this.subscriptionLoading,
    required this.createdAt,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.t;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showSubscription) ...[
          if (subscriptionLoading)
            const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else if (subscription != null && subscription!.hasRecord) ...[
            Text(
              _planLabel(t, subscription!.plan),
              style: ProfileSettingsUi.fieldValue.copyWith(
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              _statusLabel(t, subscription!.status),
              style: ProfileSettingsUi.fieldLabel.copyWith(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ] else
            Text(
              t.features.subscription.noSubscription,
              style: ProfileSettingsUi.fieldValue.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          if (createdAt != null) const SizedBox(height: 10),
        ],
        if (createdAt != null)
          Text(
            t.features.profile.accountCreatedAt.replaceAll(
              '{date}',
              _formatAccountDate(createdAt!),
            ),
            style: ProfileSettingsUi.fieldLabel.copyWith(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.3,
            ),
          ),
      ],
    );
  }

  String _formatAccountDate(DateTime date) {
    final formatted = AppDateFormat.yearMonthDay(date);
    if (formatted.isEmpty) return formatted;
    return formatted.replaceRange(
      0,
      1,
      formatted.substring(0, 1).toUpperCase(),
    );
  }

  String _statusLabel(Translations t, SubscriptionStatus status) {
    switch (status) {
      case SubscriptionStatus.active:
        return t.features.subscription.statusActive;
      case SubscriptionStatus.expired:
        return t.features.subscription.statusExpired;
      case SubscriptionStatus.cancelled:
        return t.features.subscription.statusCancelled;
      case SubscriptionStatus.trial:
        return t.features.subscription.statusTrial;
      case SubscriptionStatus.unknown:
        return t.features.subscription.statusUnknown;
    }
  }

  String _planLabel(Translations t, String plan) {
    final p = plan.toLowerCase();
    if (p.contains('month')) return t.features.subscription.planMonthly;
    if (p.contains('annual') || p.contains('year')) {
      return t.features.subscription.planAnnual;
    }
    if (plan.isEmpty) return t.features.subscription.planUnknown;
    return plan;
  }
}

/// Ayarlar sekmesindeki `_SettingsTile` ile aynı dil — leading icon +
/// başlık. Profilde altında ikinci satır olarak değer; sağda kilit
/// rozeti (read-only) veya boş alan.
class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isEmpty;
  final bool locked;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.isEmpty = false,
    this.locked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spacingM,
        vertical: 6,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 40),
            child: Text(label, style: ProfileSettingsUi.fieldLabel),
          ),
          const SizedBox(height: 2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: ProfileSettingsUi.iconSize,
                color: ProfileSettingsUi.ink,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  value,
                  style: ProfileSettingsUi.fieldValue.copyWith(
                    color: isEmpty
                        ? ProfileSettingsUi.muted
                        : ProfileSettingsUi.ink,
                    fontStyle: isEmpty ? FontStyle.italic : FontStyle.normal,
                    fontWeight: isEmpty ? FontWeight.w500 : FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (locked)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Icon(
                    Icons.lock_outline,
                    size: 18,
                    color: ProfileSettingsUi.muted.withValues(alpha: 0.7),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Profil ekranının altında — Ayarlar satırları ile aynı dil, kırmızı
/// vurgulu yıkıcı aksiyon.
class _DangerTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DangerTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: ProfileSettingsUi.rowHeight,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.spacingM,
              vertical: 10,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: ProfileSettingsUi.iconSize,
                  color: AppColors.error,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style: ProfileSettingsUi.rowTitle.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ),
                const ActionChevron(
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Düzenleme modunda `_InfoTile` ile aynı yerleşim — gri dolgu/çizgi yok.
class _InlineField extends StatelessWidget {
  final IconData icon;
  final String label;
  final TextEditingController controller;
  final bool enabled;
  final TextCapitalization textCapitalization;
  final TextInputAction textInputAction;
  final TextInputType? keyboardType;
  final Iterable<String>? autofillHints;
  final int? maxLength;
  final String? prefixText;
  final String? helperText;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;
  final bool showClearSuffix;

  const _InlineField({
    required this.icon,
    required this.label,
    required this.controller,
    required this.enabled,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction = TextInputAction.next,
    this.keyboardType,
    this.autofillHints,
    this.maxLength,
    this.prefixText,
    this.helperText,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.showClearSuffix = false,
  });

  @override
  Widget build(BuildContext context) {
    const borderless = InputBorder.none;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spacingM,
        vertical: 6,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 40),
            child: Text(label, style: ProfileSettingsUi.fieldLabel),
          ),
          const SizedBox(height: 2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: ProfileSettingsUi.iconSize,
                color: ProfileSettingsUi.ink,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: controller,
                  enabled: enabled,
                  textCapitalization: textCapitalization,
                  textInputAction: textInputAction,
                  keyboardType: keyboardType,
                  autofillHints: autofillHints,
                  maxLength: maxLength,
                  inputFormatters: inputFormatters,
                  onChanged: onChanged,
                  onFieldSubmitted: onSubmitted,
                  validator: validator,
                  style: ProfileSettingsUi.fieldValue,
                  cursorColor: ProfileSettingsUi.ink,
                  decoration: InputDecoration(
                    filled: false,
                    fillColor: Colors.transparent,
                    isDense: true,
                    prefixText: prefixText,
                    prefixStyle: ProfileSettingsUi.fieldValue,
                    helperText: helperText,
                    helperStyle: ProfileSettingsUi.fieldLabel.copyWith(
                      fontSize: 12,
                    ),
                    counterText: maxLength != null ? '' : null,
                    suffixIcon:
                        showClearSuffix && enabled && controller.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            color: ProfileSettingsUi.muted,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 24,
                              minHeight: 24,
                            ),
                            visualDensity: VisualDensity.compact,
                            style: IconButton.styleFrom(
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: () {
                              controller.clear();
                              onChanged?.call('');
                            },
                          )
                        : null,
                    suffixIconConstraints: const BoxConstraints(
                      minWidth: 24,
                      minHeight: 24,
                    ),
                    contentPadding: EdgeInsets.zero,
                    border: borderless,
                    enabledBorder: borderless,
                    disabledBorder: borderless,
                    focusedBorder: borderless,
                    errorBorder: borderless,
                    focusedErrorBorder: borderless,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
