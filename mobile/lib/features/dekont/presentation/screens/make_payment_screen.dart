import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/app_currency_format.dart';
import '../../../../core/utils/month_labels.dart';
import '../../../../core/utils/upload_file_utils.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/api_user_message.dart';
import '../../../../core/utils/user_error_message.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/theme/dashboard_screen_style.dart';
import '../../../../shared/widgets/dashboard_secondary_scaffold.dart';
import '../../../../shared/widgets/document_preview_screen.dart';
import '../../../../shared/widgets/toast_overlay.dart';
import '../../../dues/domain/entities/due_entity.dart';
import '../../../dues/presentation/providers/dues_provider.dart';
import '../../../dues/presentation/utils/dues_ui_helpers.dart';
import '../../../profile/presentation/theme/profile_settings_ui.dart';
import '../providers/dekont_provider.dart';
import '../providers/share_intent_provider.dart';
import '../widgets/copy_payment_field.dart';

class MakePaymentScreen extends ConsumerStatefulWidget {
  final String? preselectedDueId;

  const MakePaymentScreen({super.key, this.preselectedDueId});

  @override
  ConsumerState<MakePaymentScreen> createState() => _MakePaymentScreenState();
}

class _MakePaymentScreenState extends ConsumerState<MakePaymentScreen> {
  bool _requested = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(makePaymentNotifierProvider.notifier).ensureIdleOnScreen();
      ref.read(makePaymentNotifierProvider.notifier).loadPaymentInfo();
      if (widget.preselectedDueId != null) {
        ref
            .read(makePaymentNotifierProvider.notifier)
            .selectDue(widget.preselectedDueId);
      }

      final pendingFile = ref.read(pendingDekontFileProvider);
      if (pendingFile != null) {
        ref.read(makePaymentNotifierProvider.notifier).setPickedReceipt(
              fileName: pendingFile['fileName'],
              fileBytes: pendingFile['fileBytes'],
              filePath: pendingFile['filePath'],
            );
        ref.read(pendingDekontFileProvider.notifier).update(null);
      }
    });
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: UploadFileUtils.allowedExtensions.toList(),
    );
    if (result == null || result.files.isEmpty) return;
    final picked = result.files.single;
    if (!mounted) return;

    final t = context.t.features.dekont;
    final name = picked.name;

    final bytes =
        picked.path != null ? await File(picked.path!).readAsBytes() : null;
    if (bytes == null || bytes.isEmpty) {
      ref.read(toastProvider.notifier).show(
            t.fileNotFound,
            type: ToastType.error,
          );
      return;
    }

    final validationError = UploadFileUtils.validateReceiptBytes(bytes, name);
    if (validationError != null) {
      ref.read(toastProvider.notifier).show(
            _uploadValidationMessage(t, validationError),
            type: ToastType.error,
          );
      return;
    }

    ref.read(makePaymentNotifierProvider.notifier).setPickedReceipt(
          fileName: name,
          fileBytes: bytes,
          filePath: picked.path,
        );
  }

  String _uploadValidationMessage(dynamic t, String key) {
    switch (key) {
      case 'fileTooLarge':
        return t.fileTooLarge;
      case 'fileEmpty':
        return t.fileEmpty;
      case 'fileNotFound':
        return t.fileNotFound;
      case 'invalidExtension':
        return t.invalidExtension;
      default:
        return t.uploadFailed;
    }
  }

  Future<void> _upload() async {
    final t = context.t.features.dekont;
    final dekont =
        await ref.read(makePaymentNotifierProvider.notifier).upload();
    if (!mounted) return;
    if (dekont != null) {
      final wasDuplicate =
          ref.read(makePaymentNotifierProvider).uploadWasDuplicate;
      final wasRecovered =
          ref.read(makePaymentNotifierProvider).uploadWasRecovered;
      ref.read(makePaymentNotifierProvider.notifier).endUploadSession();
      final toastMessage = wasDuplicate
          ? t.errorUploadDuplicate
          : wasRecovered
              ? t.uploadRecoveredExisting
              : t.uploadSuccess;
      ref.read(toastProvider.notifier).show(
            toastMessage,
            type: wasDuplicate ? ToastType.info : ToastType.success,
          );
      if (!wasDuplicate) {
        await context.push('/dekonts/${dekont.id}');
      }
    } else {
      final err = ref.read(makePaymentNotifierProvider).error;
      if (err != null) {
        ref.read(toastProvider.notifier).show(
              userFacingError(
                err,
                context: ApiMessageContext.dekont,
              ),
              type: ToastType.error,
            );
      }
    }

    if (mounted) {
      ref.read(makePaymentNotifierProvider.notifier).ensureIdleOnScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_requested) {
      _requested = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(duesNotifierProvider.notifier).loadMyDues();
      });
    }

    final paymentState = ref.watch(makePaymentNotifierProvider);
    final duesState = ref.watch(duesNotifierProvider);
    final t = context.t.features.dekont;
    final pendingDues = duesState.dues
        .where(
          (d) => d.status == DueStatus.pending || d.status == DueStatus.overdue,
        )
        .toList();
    final busy = paymentState.isUploading;
    final canSubmit = !busy &&
        paymentState.pickedFileBytes != null &&
        paymentState.selectedDueId != null;

    return PopScope(
      canPop: !busy,
      child: Scaffold(
        backgroundColor: AppColors.dashboardBackground,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _MakePaymentTopBar(
              onBack: busy ? null : () => Navigator.of(context).maybePop(),
              onDekonts: busy ? null : () => context.push('/dekonts'),
            ),
            Expanded(
              child: paymentState.isLoadingInfo
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: AppSizes.screenBodyScrollPadding.copyWith(
                        top: AppSizes.spacingS,
                        bottom: AppSizes.spacingXL,
                      ),
                      children: [
                        if (paymentState.collection != null &&
                            !paymentState.collection!.isCollectionConfigured)
                          Padding(
                            padding: DashboardScreenStyle.listItemPadding,
                            child: DashboardSurfaceCard(
                              padding:
                                  const EdgeInsets.all(AppSizes.spacingM),
                              child: Text(
                                t.collectionNotConfigured,
                                style: AppTypography.body2.copyWith(
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        DashboardSectionTitle(title: t.paymentInfoTitle),
                        const SizedBox(height: AppSizes.spacingS),
                        if (paymentState.collection != null) ...[
                          CopyPaymentField(
                            label: t.ibanLabel,
                            value: paymentState.collection!.collectionIban,
                            monospace: true,
                          ),
                          const SizedBox(height: AppSizes.spacingS),
                          CopyPaymentField(
                            label: t.accountTitleLabel,
                            value:
                                paymentState.collection!.collectionAccountTitle,
                          ),
                          const SizedBox(height: AppSizes.spacingS),
                          CopyPaymentField(
                            label: t.referenceLabel,
                            value: paymentState.collection!.paymentReference,
                          ),
                        ] else if (paymentState.error != null)
                          DashboardSurfaceCard(
                            child: Text(
                              userFacingError(paymentState.error!),
                              style: AppTypography.body2.copyWith(
                                color: AppColors.error,
                              ),
                            ),
                          ),
                        const SizedBox(height: AppSizes.spacingM),
                        DashboardSectionTitle(title: t.selectDue),
                        const SizedBox(height: AppSizes.spacingXS),
                        Text(
                          t.selectDueHint,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        if (duesState.isLoading)
                          const Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: AppSizes.spacingL,
                            ),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else if (pendingDues.isEmpty)
                          DashboardSurfaceCard(
                            child: Text(
                              t.noPendingDues,
                              style: AppTypography.body2.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: pendingDues.length,
                            itemBuilder: (_, i) {
                              final due = pendingDues[i];
                              return Padding(
                                padding: DashboardScreenStyle.listItemPadding,
                                child: _DueSelectableCard(
                                  due: due,
                                  selected:
                                      paymentState.selectedDueId == due.id,
                                  enabled: !busy,
                                  onTap: () => ref
                                      .read(makePaymentNotifierProvider.notifier)
                                      .selectDue(due.id),
                                ),
                              );
                            },
                          ),
                        const SizedBox(height: AppSizes.spacingM),
                        DashboardSectionTitle(title: t.uploadSectionTitle),
                        const SizedBox(height: AppSizes.spacingS),
                        if (paymentState.pickedFileName == null)
                          _FilePickCard(
                            busy: busy,
                            onTap: _pickFile,
                          )
                        else
                          _FilePickCard(
                            busy: busy,
                            fileName: paymentState.pickedFileName!,
                            onTap: busy ? null : _pickFile,
                            onClear: busy
                                ? null
                                : () => ref
                                    .read(makePaymentNotifierProvider.notifier)
                                    .clearPickedReceipt(),
                            onPreview: busy ||
                                    paymentState.pickedFileBytes == null
                                ? null
                                : () => _openPickedPreview(paymentState),
                          ),
                      ],
                    ),
            ),
          ],
        ),
        bottomNavigationBar: _buildSubmitBar(
          context,
          busy: busy,
          canSubmit: canSubmit,
        ),
      ),
    );
  }

  Widget _buildSubmitBar(
    BuildContext context, {
    required bool busy,
    required bool canSubmit,
  }) {
    final t = context.t.features.dekont;
    return ColoredBox(
      color: AppColors.dashboardBackground,
      child: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        child: SizedBox(
          height: ProfileSettingsUi.buttonHeight,
          child: Material(
          color: AppColors.primary,
          borderRadius:
              BorderRadius.circular(ProfileSettingsUi.radiusPill),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: !busy && canSubmit ? _upload : null,
            child: SizedBox(
              height: ProfileSettingsUi.buttonHeight,
              width: double.infinity,
              child: Center(
                child: busy
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        t.upload,
                        style: AppTypography.button.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ),
        ),
        ),
      ),
    );
  }

  Future<void> _openPickedPreview(MakePaymentState state) async {
    final bytes = state.pickedFileBytes;
    final filename = state.pickedFileName;
    if (bytes == null || filename == null) return;

    final ext = filename.split('.').last.toLowerCase();
    final mimeType = ext == 'pdf'
        ? 'application/pdf'
        : ext == 'png'
            ? 'image/png'
            : 'image/jpeg';

    await DocumentPreviewScreen.open(
      context,
      bytes: Uint8List.fromList(bytes),
      fileName: filename,
      mimeType: mimeType,
    );
  }
}

class _MakePaymentTopBar extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback? onDekonts;

  const _MakePaymentTopBar({
    this.onBack,
    this.onDekonts,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.dekont;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.dashboardScreenPaddingHorizontal,
          AppSizes.spacingS,
          AppSizes.dashboardScreenPaddingHorizontal,
          AppSizes.spacingS,
        ),
        child: Row(
          children: [
            _CircularIconButton(
              icon: Icons.chevron_left_rounded,
              onPressed: onBack,
            ),
            Expanded(
              child: Text(
                t.makePaymentTitle,
                textAlign: TextAlign.center,
                style: ProfileSettingsUi.title,
              ),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onDekonts,
                borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.spacingXS,
                    vertical: AppSizes.spacingXS,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        t.viewDekonts,
                        style: AppTypography.body2.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.textPrimary,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircularIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _CircularIconButton({
    required this.icon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Container(
          width: AppSizes.minTouchTarget,
          height: AppSizes.minTouchTarget,
          decoration: BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
            boxShadow: DashboardScreenStyle.cardShadow,
          ),
          alignment: Alignment.center,
          child: Icon(
            icon,
            color: AppColors.textPrimary,
            size: 24,
          ),
        ),
      ),
    );
  }
}

class _DueSelectableCard extends StatelessWidget {
  final DueEntity due;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  const _DueSelectableCard({
    required this.due,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final monthLabel = localizedMonthName(context, due.month);
    final isOverdue = due.status == DueStatus.overdue;
    final amountText = AppCurrencyFormat.format(
      due.amount,
      decimalDigits: 2,
    );

    final apartmentLabel = dueApartmentLabel(context, due);
    final subtitle = isOverdue
        ? '$apartmentLabel · ${context.t.common.overdue}'
        : apartmentLabel;

    final pillBg =
        isOverdue ? AppColors.statusRedBg : AppColors.statusGreenBg;
    final pillFg =
        isOverdue ? AppColors.statusRed : AppColors.statusGreen;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          constraints: const BoxConstraints(minHeight: AppSizes.minTouchTarget),
          width: double.infinity,
          padding: const EdgeInsets.all(AppSizes.spacingM),
          decoration: DashboardScreenStyle.whiteCard().copyWith(
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
            border: selected
                ? Border.all(color: AppColors.inkDark, width: 2)
                : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: selected ? AppColors.inkDark : AppColors.mutedText,
                size: 22,
              ),
              const SizedBox(width: AppSizes.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$monthLabel ${due.year}',
                      style: AppTypography.body1.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.inkDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSizes.spacingS),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: pillBg,
                  borderRadius: BorderRadius.circular(
                    DashboardScreenStyle.pillRadius,
                  ),
                ),
                child: Text(
                  amountText,
                  style: AppTypography.caption.copyWith(
                    color: pillFg,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilePickCard extends StatelessWidget {
  final bool busy;
  final String? fileName;
  final VoidCallback? onTap;
  final VoidCallback? onClear;
  final VoidCallback? onPreview;

  const _FilePickCard({
    required this.busy,
    this.fileName,
    this.onTap,
    this.onClear,
    this.onPreview,
  });

  bool get _hasFile => fileName != null;

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.dekont;
    final iconBg =
        _hasFile ? AppColors.statusGreenBg : AppColors.statusAmberBg;
    final iconColor =
        _hasFile ? AppColors.statusGreen : AppColors.statusAmber;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: busy ? null : onTap,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        child: CustomPaint(
          painter: _DashedRRectPainter(
            color: AppColors.lineLight,
            radius: AppSizes.cardRadius,
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.spacingM),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(
                      DashboardScreenStyle.iconBoxRadius,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.description_outlined,
                    color: iconColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSizes.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _hasFile ? fileName! : t.pickFile,
                        style: AppTypography.body1.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (!_hasFile) ...[
                        const SizedBox(height: 2),
                        Text(
                          t.uploadHint,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (onPreview != null)
                  IconButton(
                    onPressed: onPreview,
                    icon: const Icon(Icons.visibility_outlined),
                    color: AppColors.textPrimary,
                    tooltip: t.viewDekont,
                    constraints: const BoxConstraints(
                      minWidth: AppSizes.minTouchTarget,
                      minHeight: AppSizes.minTouchTarget,
                    ),
                  ),
                if (onClear != null)
                  IconButton(
                    onPressed: onClear,
                    icon: const Icon(Icons.close_rounded),
                    color: AppColors.mutedText,
                    constraints: const BoxConstraints(
                      minWidth: AppSizes.minTouchTarget,
                      minHeight: AppSizes.minTouchTarget,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedRRectPainter extends CustomPainter {
  _DashedRRectPainter({
    required this.color,
    required this.radius,
  });

  final Color color;
  final double radius;
  static const double _strokeWidth = 1.5;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth;

    final inset = _strokeWidth / 2;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        inset,
        inset,
        size.width - _strokeWidth,
        size.height - _strokeWidth,
      ),
      Radius.circular(radius),
    );

    final path = Path()..addRRect(rrect);
    const dashWidth = 6.0;
    const dashSpace = 4.0;

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = (distance + dashWidth).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRRectPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}
