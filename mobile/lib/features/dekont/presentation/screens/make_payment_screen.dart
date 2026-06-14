import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/month_labels.dart';
import '../../../../core/utils/upload_file_utils.dart';
import '../../../../core/theme/app_button_styles.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/api_user_message.dart';
import '../../../../core/utils/user_error_message.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/document_preview_screen.dart';
import '../../../../shared/widgets/toast_overlay.dart';
import '../../../dues/domain/entities/due_entity.dart';
import '../../../dues/presentation/providers/dues_provider.dart';
import '../../../dues/presentation/widgets/due_breakdown_section.dart';
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

    final bytes = picked.path != null ? await File(picked.path!).readAsBytes() : null;
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
                    const SizedBox(height: AppSizes.spacingM),
                    if (paymentState.pickedFileName == null)
                      _buildDropzone(context, busy)
                    else
                      _buildPickedFileItem(context, paymentState, busy),
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

  Widget _buildDropzone(BuildContext context, bool busy) {
    final t = context.t.features.dekont;
    return InkWell(
      onTap: busy ? null : _pickFile,
      borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          vertical: AppSizes.spacingM,
          horizontal: AppSizes.spacingM,
        ),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.25),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                color: AppColors.primary,
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
                    t.pickFile,
                    style: AppTypography.body1.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    t.uploadHint,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
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

  Widget _buildPickedFileItem(BuildContext context, MakePaymentState state, bool busy) {
    final filename = state.pickedFileName!;
    final ext = filename.split('.').last.toLowerCase();
    final isImage = ['jpg', 'jpeg', 'png'].contains(ext);
    final sizeBytes = state.pickedFileBytes?.length ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(
          color: AppColors.borderColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        child: Row(
          children: [
            // Preview thumbnail
            if (isImage && state.pickedFilePath != null)
              Image.file(
                File(state.pickedFilePath!),
                width: 64,
                height: 64,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _buildFileIcon(Icons.image_outlined, AppColors.textSecondary),
              )
            else if (ext == 'pdf')
              _buildFileIcon(Icons.picture_as_pdf_outlined, Colors.red[700]!)
            else
              _buildFileIcon(Icons.description_outlined, AppColors.primary),
            
            const SizedBox(width: AppSizes.spacingM),
            
            // File Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSizes.spacingS),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      filename,
                      style: AppTypography.body1.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (sizeBytes > 0) ...[
                      const SizedBox(height: 2),
                      Text(
                        _formatFileSize(sizeBytes),
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            IconButton(
              onPressed: busy || state.pickedFileBytes == null
                  ? null
                  : () => _openPickedPreview(state),
              icon: const Icon(Icons.visibility_outlined),
              color: AppColors.primary,
              tooltip: context.t.features.dekont.viewDekont,
              constraints: const BoxConstraints(
                minWidth: AppSizes.minTouchTarget,
                minHeight: AppSizes.minTouchTarget,
              ),
            ),

            // Delete button
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: busy
                    ? null
                    : () => ref.read(makePaymentNotifierProvider.notifier).clearPickedReceipt(),
                borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(AppSizes.cardRadius),
                ),
                child: Container(
                  width: AppSizes.minTouchTarget,
                  height: 64,
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.delete_outline,
                    color: AppColors.error,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileIcon(IconData icon, Color color) {
    return Container(
      width: 64,
      height: 64,
      color: color.withValues(alpha: 0.08),
      child: Icon(
        icon,
        color: color,
        size: 28,
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
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
    final monthLabel = localizedMonthName(context, due.month);
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
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${due.amount.toStringAsFixed(2)} ${due.currency}',
              style: AppTypography.body2,
            ),
            DueBreakdownSection(
              breakdown: due.breakdown,
              currency: due.currency,
            ),
          ],
        ),
      ),
    );
  }
}
