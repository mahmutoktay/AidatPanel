import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/upload_file_utils.dart';
import '../../../../core/theme/app_button_styles.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/api_user_message.dart';
import '../../../../core/utils/user_error_message.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/toast_overlay.dart';
import '../../../dues/domain/entities/due_entity.dart';
import '../../../dues/presentation/providers/dues_provider.dart';
import '../providers/dekont_provider.dart';
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
    });
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: UploadFileUtils.allowedExtensions.toList(),
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final picked = result.files.single;
    if (!mounted) return;

    final t = context.t.features.dekont;
    final name = picked.name;

    List<int>? bytes = picked.bytes;
    if (bytes == null || bytes.isEmpty) {
      final path = picked.path;
      if (path != null) {
        final fileError = UploadFileUtils.validateReceiptFile(path);
        if (fileError != null) {
          ref.read(toastProvider.notifier).show(
                _uploadValidationMessage(t, fileError),
                type: ToastType.error,
              );
          return;
        }
        bytes = await File(path).readAsBytes();
      }
    }

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
      await context.push('/dekonts/${dekont.id}');
      if (mounted) {
        ref.read(makePaymentNotifierProvider.notifier).ensureIdleOnScreen();
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

    return PopScope(
      canPop: !busy,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          title: Text(t.makePaymentTitle),
          centerTitle: true,
          actions: [
            TextButton(
              onPressed: () => context.push('/dekonts'),
              child: Text(t.viewDekonts),
            ),
          ],
        ),
        body: paymentState.isLoadingInfo
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: AppSizes.screenBodyScrollPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (paymentState.collection != null &&
                        !paymentState.collection!.isCollectionConfigured)
                      Container(
                        margin: const EdgeInsets.only(
                          bottom: AppSizes.spacingM,
                        ),
                        padding: const EdgeInsets.all(AppSizes.spacingM),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.12),
                          borderRadius:
                              BorderRadius.circular(AppSizes.cardRadius),
                          border: Border.all(color: AppColors.warning),
                        ),
                        child: Text(
                          t.collectionNotConfigured,
                          style: AppTypography.body2.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    Text(
                      t.paymentInfoTitle,
                      style: AppTypography.h3.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacingM),
                    if (paymentState.collection != null) ...[
                      CopyPaymentField(
                        label: t.ibanLabel,
                        value: paymentState.collection!.collectionIban,
                        monospace: true,
                      ),
                      CopyPaymentField(
                        label: t.accountTitleLabel,
                        value:
                            paymentState.collection!.collectionAccountTitle,
                      ),
                      CopyPaymentField(
                        label: t.referenceLabel,
                        value: paymentState.collection!.paymentReference,
                      ),
                    ] else if (paymentState.error != null)
                      Text(
                        userFacingError(paymentState.error!),
                        style: AppTypography.body2.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    const SizedBox(height: AppSizes.spacingL),
                    Text(
                      t.selectDue,
                      style: AppTypography.h3.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacingS),
                    Text(
                      t.selectDueHint,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacingM),
                    if (duesState.isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (pendingDues.isEmpty)
                      Text(
                        t.noPendingDues,
                        style: AppTypography.body2.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      )
                    else
                      RadioGroup<String>(
                        groupValue: paymentState.selectedDueId,
                        onChanged: (id) {
                          if (id != null) {
                            ref
                                .read(makePaymentNotifierProvider.notifier)
                                .selectDue(id);
                          }
                        },
                        child: Column(
                          children: [
                            for (final due in pendingDues)
                              _DueRadioTile(
                                due: due,
                                selectedId: paymentState.selectedDueId,
                              ),
                          ],
                        ),
                      ),
                    const SizedBox(height: AppSizes.spacingL),
                    Text(
                      t.uploadSectionTitle,
                      style: AppTypography.h3.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacingS),
                    Text(
                      t.uploadHint,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacingM),
                    OutlinedButton.icon(
                      onPressed: busy ? null : _pickFile,
                      style: AppButtonStyles.outlinedPrimary(),
                      icon: const Icon(Icons.attach_file),
                      label: Text(t.pickFile),
                    ),
                    if (paymentState.pickedFileName != null) ...[
                      const SizedBox(height: AppSizes.spacingS),
                      Text(
                        paymentState.pickedFileName!,
                        style: AppTypography.body2,
                      ),
                    ],
                    const SizedBox(height: AppSizes.spacingL),
                    SizedBox(
                      height: AppSizes.buttonHeightPrimary,
                      child: ElevatedButton(
                        onPressed: busy ||
                                paymentState.pickedFileBytes == null
                            ? null
                            : _upload,
                        style: AppButtonStyles.elevatedSuccess(),
                        child: busy
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: AppSizes.spacingS),
                                  Text(t.upload, style: AppTypography.button),
                                ],
                              )
                            : Text(t.upload, style: AppTypography.button),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _DueRadioTile extends StatelessWidget {
  final DueEntity due;
  final String? selectedId;

  const _DueRadioTile({
    required this.due,
    required this.selectedId,
  });

  @override
  Widget build(BuildContext context) {
    final monthLabel = DateFormat.MMMM().format(
      DateTime(due.year, due.month),
    );
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.spacingS),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(
          color: selectedId == due.id
              ? AppColors.primary
              : AppColors.primary.withValues(alpha: 0.14),
        ),
      ),
      child: RadioListTile<String>(
        value: due.id,
        title: Text(
          '$monthLabel ${due.year}',
          style: AppTypography.body1.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${due.amount.toStringAsFixed(2)} ${due.currency}',
          style: AppTypography.body2,
        ),
      ),
    );
  }
}
