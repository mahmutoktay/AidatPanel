import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/phone_utils.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/premium_bottom_sheet.dart';
import '../../../../shared/widgets/toast_overlay.dart';
import '../../../auth/presentation/onboarding/widgets/otp_input_row.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// Sakin telefon değişimi — Firebase Phone Auth ile yeni numarayı doğrular.
/// Başarıda `true` döner; iptalde null.
class PhoneChangeOtpSheet {
  PhoneChangeOtpSheet._();

  static Future<bool?> show(
    BuildContext context, {
    required String phone10,
  }) {
    return PremiumBottomSheetScaffold.show<bool>(
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
      await ref
          .read(authStateProvider.notifier)
          .startResidentFirebasePhone(widget.phone10);
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

  Future<void> _submit() async {
    if (_code.length != 6 || _submitting) return;
    setState(() => _submitting = true);
    try {
      await ref
          .read(authStateProvider.notifier)
          .verifyResidentPhoneChangeFirebaseOtp(code: _code);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _submitting = false);
      final msg = ref.read(authStateProvider).error ??
          context.t.features.auth.onboarding.otpInvalid;
      ref.read(toastProvider.notifier).show(msg, type: ToastType.error);
    }
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
          const SizedBox(height: AppSizes.spacingM),
          TextButton(
            onPressed: (_resendSeconds > 0 || _sending)
                ? null
                : () async {
                    setState(() => _sending = true);
                    try {
                      await ref
                          .read(authStateProvider.notifier)
                          .resendResidentFirebasePhone(widget.phone10);
                      if (!mounted) return;
                      setState(() {
                        _resendSeconds = 60;
                        _sending = false;
                      });
                      _tickResend();
                    } catch (_) {
                      if (!mounted) return;
                      setState(() => _sending = false);
                      final msg = ref.read(authStateProvider).error ??
                          t.phoneOtpSendFailed;
                      ref
                          .read(toastProvider.notifier)
                          .show(msg, type: ToastType.error);
                    }
                  },
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
