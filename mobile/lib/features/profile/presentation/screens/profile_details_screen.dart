import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/input_validators.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/profile_avatar.dart';
import '../../../../shared/widgets/profile_avatar_actions.dart';
import '../../../../shared/widgets/toast_overlay.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/profile_notifier.dart';
import '../theme/profile_settings_ui.dart';
import '../widgets/delete_account_sheet.dart';

/// Ayarlar → Profil bilgileri.
///
/// FAZ 4: `GET /me` ile yükleme, `PUT /me` ile ad + telefon güncelleme.
/// Stil: Ayarlar sekmesi ile birebir aynı dil — çerçevesiz satırlar,
/// gruplar arasında ince ayraç, ortak hero blok. Düzenleme aksiyonu
/// ayrı bir sheet açmaz; "Düzenle"ye basılınca aynı ekrandaki ad ve
/// telefon satırları inline TextField'a dönüşür, altta sabit "Kaydet"
/// butonu görünür.
class ProfileDetailsScreen extends ConsumerStatefulWidget {
  const ProfileDetailsScreen({super.key});

  @override
  ConsumerState<ProfileDetailsScreen> createState() =>
      _ProfileDetailsScreenState();
}

class _ProfileDetailsScreenState extends ConsumerState<ProfileDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _editing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileNotifierProvider.notifier).loadProfile();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
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

    final phone = _phoneController.text.trim();
    final ok = await ref.read(profileNotifierProvider.notifier).saveProfile(
          name: _nameController.text.trim(),
          phone: phone.isEmpty ? null : phone,
        );
    if (!mounted) return;

    if (ok) {
      ref.read(toastProvider.notifier).show(
            t.features.profile.profileUpdated,
            type: ToastType.success,
          );
      setState(() => _editing = false);
    } else {
      final error = ref.read(profileNotifierProvider).error;
      ref.read(toastProvider.notifier).show(
            error ?? t.features.profile.profileUpdateFailed,
            type: ToastType.error,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileNotifierProvider);
    final authUser = ref.watch(authStateProvider).user;
    final user = profileState.user ?? authUser;

    return PopScope(
      canPop: !profileState.isSaving,
      child: Scaffold(
        backgroundColor: ProfileSettingsUi.background,
        appBar: _buildAppBar(context, user, profileState),
        body: _buildBody(context, profileState, user),
        bottomNavigationBar: _editing && user != null
            ? _buildSaveBar(context, profileState)
            : null,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    UserEntity? user,
    ProfileState profileState,
  ) {
    final t = context.t;
    final showEdit = user != null && !profileState.isLoading && !_editing;

    return AppBar(
      backgroundColor: ProfileSettingsUi.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: Icon(
          _editing ? Icons.close : Icons.arrow_back,
          color: ProfileSettingsUi.ink,
        ),
        onPressed: profileState.isSaving
            ? null
            : (_editing ? _cancelEdit : () => Navigator.of(context).pop()),
      ),
      title: Text(
        _editing ? t.features.profile.editTitle : t.features.profile.title,
        style: ProfileSettingsUi.title,
      ),
      actions: [
        if (showEdit)
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: TextButton.icon(
              onPressed: _enterEdit,
              icon: const Icon(Icons.edit_outlined, size: 20),
              label: Text(
                t.common.edit,
                style: ProfileSettingsUi.fieldValue.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: TextButton.styleFrom(
                minimumSize: const Size(48, 48),
                foregroundColor: ProfileSettingsUi.ink,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBody(
    BuildContext context,
    ProfileState profileState,
    UserEntity? user,
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

    final roleLabel =
        user.role == UserRole.manager ? t.common.manager : t.common.resident;
    final languageLabel = user.language == 'en' ? 'English' : t.common.turkish;

    final content = Form(
      key: _formKey,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: ProfileSettingsUi.screenPadding,
        children: [
          _ProfileHero(
            user: user,
            editing: _editing,
            onAvatarTap: () => handleProfileAvatarTap(context, ref),
          ),
          const SizedBox(height: 20),
          const _GroupDivider(),
          const SizedBox(height: 4),

          // Kişisel — düzenlenebilir alanlar
          if (_editing) ...[
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
              icon: Icons.phone_outlined,
              label: t.features.profile.phone,
              controller: _phoneController,
              enabled: !profileState.isSaving,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.telephoneNumberNational],
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
          ] else ...[
            _InfoTile(
              icon: Icons.person_outline,
              label: t.features.profile.fullName,
              value: user.name,
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

          const SizedBox(height: 4),
          const _GroupDivider(),
          const SizedBox(height: 4),

          // Hesap — sadece okunabilir alanlar
          _InfoTile(
            icon: Icons.email_outlined,
            label: t.features.profile.email,
            value: user.email.isNotEmpty
                ? user.email
                : t.features.profile.notProvided,
            isEmpty: user.email.isEmpty,
            locked: true,
          ),
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

          if (!_editing) ...[
            const SizedBox(height: 4),
            const _GroupDivider(),
            const SizedBox(height: 4),
            _DangerTile(
              icon: Icons.delete_outline,
              label: t.common.deleteAccount,
              onTap: () => DeleteAccountSheet.show(context),
            ),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );

    if (_editing) return content;

    return RefreshIndicator(
      onRefresh: () => ref.read(profileNotifierProvider.notifier).loadProfile(),
      child: content,
    );
  }

  Widget _buildSaveBar(BuildContext context, ProfileState profileState) {
    final t = context.t;
    final saving = profileState.isSaving;

    return SafeArea(
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

/// Ayarlar sekmesindekiyle birebir hero — avatar + isim + handle.
class _ProfileHero extends StatelessWidget {
  final UserEntity user;
  final bool editing;
  final VoidCallback onAvatarTap;

  const _ProfileHero({
    required this.user,
    required this.editing,
    required this.onAvatarTap,
  });

  String _handle() {
    if (user.email.isNotEmpty) {
      final at = user.email.indexOf('@');
      final name = at > 0 ? user.email.substring(0, at) : user.email;
      return '@$name';
    }
    if (user.phone != null && user.phone!.isNotEmpty) {
      return _formatPhone(user.phone!);
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final handle = _handle();

    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            ProfileAvatar(
              size: ProfileSettingsUi.avatarSize,
              userName: user.name,
              onTap: onAvatarTap,
            ),
            Material(
              color: ProfileSettingsUi.ink,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: onAvatarTap,
                customBorder: const CircleBorder(),
                child: const Padding(
                  padding: EdgeInsets.all(6),
                  child: Icon(
                    Icons.photo_camera_outlined,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          user.name,
          style: ProfileSettingsUi.name,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (handle.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            handle,
            style: ProfileSettingsUi.handle,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        if (editing) ...[
          const SizedBox(height: 6),
          Text(
            t.features.profile.editPhotoHint,
            style: ProfileSettingsUi.handle.copyWith(fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

/// Ayarlar sekmesindeki gruplar arası ince ayraç ile aynı.
class _GroupDivider extends StatelessWidget {
  const _GroupDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Divider(height: 1, color: ProfileSettingsUi.line),
    );
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
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: ProfileSettingsUi.iconSize,
            color: ProfileSettingsUi.ink,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: ProfileSettingsUi.fieldLabel),
                const SizedBox(height: 2),
                Text(
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
              ],
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
      color: ProfileSettingsUi.background,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: ProfileSettingsUi.rowHeight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
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
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  size: 22,
                  color: AppColors.error.withValues(alpha: 0.55),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Düzenleme modunda `_InfoTile` ile aynı yerleşimde inline alan —
/// leading icon + label (üstte) + TextField (altta). Çerçeve yok;
/// ayarlar dilini koruyacak şekilde altta yalnız ince ayırıcı.
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 22),
            child: Icon(
              icon,
              size: ProfileSettingsUi.iconSize,
              color: ProfileSettingsUi.ink,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: ProfileSettingsUi.fieldLabel),
                const SizedBox(height: 2),
                TextFormField(
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
                    isDense: true,
                    prefixText: prefixText,
                    helperText: helperText,
                    counterText: '',
                    suffixIcon: showClearSuffix &&
                            enabled &&
                            controller.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            color: ProfileSettingsUi.muted,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 40,
                              minHeight: 40,
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
                      minWidth: 40,
                      minHeight: 40,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 0,
                    ),
                    border: const UnderlineInputBorder(
                      borderSide: BorderSide(color: ProfileSettingsUi.line),
                    ),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: ProfileSettingsUi.line),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: ProfileSettingsUi.ink,
                        width: 1.4,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
