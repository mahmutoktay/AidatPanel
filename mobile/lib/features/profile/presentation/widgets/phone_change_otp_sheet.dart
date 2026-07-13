import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/phone_utils.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/premium_bottom_sheet.dart';
import '../../../../shared/widgets/toast_overlay.dart';
import '../../../auth/presentation/onboarding/widgets/otp_input_row.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// Sakin telefon değişimi — yeni numaraya SMS kodu doğrulama sheet'i.
class PhoneChangeOtpSheet {
  PhoneChangeOtpSheet._();

  /// Doğrulanan 6 haneli kodu döner; iptalde null.
  static Future<String?> show(
    BuildContext context, {
    required String phone10,
  }) {
    return PremiumBottomSheetScaffold.show<String>(
      context: context,
      isDismissible: true,
      builder: (ctx) => _PhoneChangeOtpSheetBody(phone10: phone10),
    );
  }
}

class _PhoneChangeOtpSheetBody extends ConsumerStatefulWidget {
  final String phone10;

  const _PhoneChangeOtpSheetBody({required this.phone10});

  @override
  ConsumerState<_PhoneChangeOtpSheetBody> createState() =>
      _PhoneChangeOtpSheetBodyState();
}

class _PhoneChangeOtpSheetBodyState
    extends ConsumerState<_PhoneChangeOtpSheetBody> {
  String _code = '';
  bool _sending = false;
  bool _submitting = false;
  int _resendSeconds = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _sendOtp());
  }

  Future<void> _sendOtp() async {
    if (_sending) return;
    setState(() => _sending = true);
    try {
      await ref.read(authStateProvider.notifier).sendOtp(
            phone: widget.phone10,
            purpose: 'resident_phone_change',
          );
      if (!mounted) return;
      setState(() {
        _resendSeconds = 60;
        _sending = false;
      });
      _tickResend();
    } catch (e) {
      if (!mounted) return;
      setState(() => _sending = false);
      final msg = ref.read(authStateProvider).error ??
          context.t.features.profile.phoneOtpSendFailed;
      ref.read(toastProvider.notifier).show(msg, type: ToastType.error);
    }
  }

  void _tickResend() {
    Future.doWhile(() async {
      await Future<void>.delayed(const Duration(seconds: 1));
      if (!mounted || _resendSeconds <= 0) return false;
      setState(() => _resendSeconds -= 1);
      return _resendSeconds > 0;
    });
  }

  void _submit() {
    if (_code.length != 6 || _submitting) return;
    setState(() => _submitting = true);
    Navigator.of(context).pop(_code);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.profile;
    final tAuth = context.t.features.auth.onboarding;
    final masked = PhoneUtils.maskDisplay(widget.phone10);

    return PremiumBottomSheetScaffold(
      maxHeightFactor: 0.72,
      scrollable: true,
      title: t.phoneOtpTitle,
      showCloseButton: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            t.phoneOtpMessage.replaceAll('{phone}', masked),
            style: AppTypography.body1.copyWith(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSizes.spacingL),
          OtpInputRow(
            enabled: !_sending && !_submitting,
            onChanged: (v) => setState(() => _code = v),
            onCompleted: (_) => _submit(),
          ),
          if (ApiConstants.isLocalBackend) ...[
            const SizedBox(height: AppSizes.spacingS),
            Text(
              tAuth.step3DevOtpHint,
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: AppSizes.spacingM),
          TextButton(
            onPressed: (_resendSeconds > 0 || _sending) ? null : _sendOtp,
            child: Text(
              _resendSeconds > 0
                  ? tAuth.step3ResendOtp.replaceAll(
                      '{time}',
                      '0:${_resendSeconds.toString().padLeft(2, '0')}',
                    )
                  : tAuth.step3ResendOtpReady,
            ),
          ),
          const SizedBox(height: AppSizes.spacingL),
        ],
      ),
      actions: PremiumSheetActions(
        primaryLabel: t.phoneOtpConfirm,
        onPrimary: _code.length == 6 && !_submitting ? _submit : null,
        primaryLoading: _sending || _submitting,
          secondaryLabel: context.t.common.cancelBtn,
        onSecondary: () => Navigator.of(context).pop(),
      ),
    );
  }
}
