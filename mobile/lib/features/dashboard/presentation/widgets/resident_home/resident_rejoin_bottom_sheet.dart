import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/network/api_exception.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_sizes.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/utils/user_error_message.dart';
import '../../../../profile/presentation/theme/profile_settings_ui.dart';
import '../../../../../l10n/strings.g.dart';
import '../../../../../shared/utils/auth_validators.dart';
import '../../../../../shared/widgets/premium_bottom_sheet.dart';
import '../../../../../shared/widgets/toast_overlay.dart';
import '../../../../auth/presentation/onboarding/widgets/invite_code_input_row.dart';
import '../../../../auth/presentation/providers/auth_provider.dart';

/// Oturum açık, daire bağlantısı olmayan sakin — davet kodu ile binaya katılım.
class ResidentRejoinBottomSheet extends ConsumerStatefulWidget {
  const ResidentRejoinBottomSheet({
    super.key,
    this.initialCode,
  });

  final String? initialCode;

  static Future<bool?> show(
    BuildContext context, {
    String? initialCode,
  }) {
    return PremiumBottomSheetScaffold.show<bool>(
      context: context,
      isDismissible: false,
      builder: (_) => ResidentRejoinBottomSheet(initialCode: initialCode),
    );
  }

  @override
  ConsumerState<ResidentRejoinBottomSheet> createState() =>
      _ResidentRejoinBottomSheetState();
}

class _ResidentRejoinBottomSheetState
    extends ConsumerState<ResidentRejoinBottomSheet> {
  String _inviteCode = '';
  String? _buildingLabel;
  bool _validating = false;
  bool _submitting = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialCode?.trim();
    if (initial != null && initial.isNotEmpty) {
      _inviteCode = AuthValidators.normalizeInviteCode(initial);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _validateCode(_inviteCode);
      });
    }
  }

  bool get _canSubmit =>
      !_validating &&
      !_submitting &&
      AuthValidators.isValidInviteCode(_inviteCode) &&
      _buildingLabel != null;

  Future<void> _validateCode(String code) async {
    if (!AuthValidators.isValidInviteCode(code)) {
      setState(() {
        _buildingLabel = null;
        _errorText = context.t.features.auth.invalidInviteCodeFormat;
      });
      return;
    }

    setState(() {
      _validating = true;
      _errorText = null;
      _buildingLabel = null;
    });

    try {
      final label = await ref.read(authStateProvider.notifier).validateInviteCode(
            AuthValidators.normalizeInviteCode(code),
          );
      if (!mounted) return;
      setState(() {
        _validating = false;
        _buildingLabel = label;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _validating = false;
        _buildingLabel = null;
        _errorText = userFacingError(e);
      });
    }
  }

  Future<void> _submit() async {
    if (!_canSubmit) return;

    setState(() {
      _submitting = true;
      _errorText = null;
    });

    try {
      await ref.read(authStateProvider.notifier).rejoinWithInviteCode(
            inviteCode: AuthValidators.normalizeInviteCode(_inviteCode),
            ref: ref,
          );
      if (!mounted) return;
      ref.read(toastProvider.notifier).show(
            context.t.features.dashboard.rejoinSuccess,
            type: ToastType.success,
          );
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _errorText = userFacingError(e);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _errorText = userFacingError(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.dashboard;

    return PremiumBottomSheetScaffold(
      scrollable: false,
      header: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.spacingL,
          AppSizes.spacingM,
          AppSizes.spacingL,
          AppSizes.spacingS,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.brand.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.qr_code_2_rounded,
                color: AppColors.brand,
                size: 26,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.rejoinSheetTitle, style: ProfileSettingsUi.title),
                  const SizedBox(height: 4),
                  Text(
                    t.rejoinSheetSubtitle,
                    style: ProfileSettingsUi.handle.copyWith(fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InviteCodeInputRow(
            initialCode: widget.initialCode,
            enabled: !_submitting,
            onChanged: (value) {
              setState(() {
                _inviteCode = value;
                _buildingLabel = null;
                _errorText = null;
              });
            },
            onCompleted: _validateCode,
          ),
          if (_validating) ...[
            const SizedBox(height: AppSizes.spacingM),
            const Center(child: CircularProgressIndicator()),
          ],
          if (_buildingLabel != null && !_validating) ...[
            const SizedBox(height: AppSizes.spacingM),
            PremiumSheetMetaRow(
              icon: Icons.apartment_outlined,
              iconColor: AppColors.brand,
              label: t.rejoinBuildingLabel,
              value: _buildingLabel!,
            ),
          ],
          if (_errorText != null) ...[
            const SizedBox(height: AppSizes.spacingM),
            Text(
              _errorText!,
              style: AppTypography.body2.copyWith(color: AppColors.error),
            ),
          ],
        ],
      ),
      actions: PremiumSheetActions(
        primaryLabel: t.joinBuildingCta,
        icon: Icons.login_rounded,
        primaryLoading: _submitting,
        primaryEnabled: _canSubmit,
        onPrimary: _submit,
        secondaryLabel: context.t.common.cancelBtn,
        onSecondary: _submitting ? null : () => Navigator.of(context).pop(false),
      ),
    );
  }
}
