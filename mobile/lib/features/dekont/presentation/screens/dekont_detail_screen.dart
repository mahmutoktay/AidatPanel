import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_button_styles.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/api_user_message.dart';
import '../../../../core/utils/user_error_message.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/widgets/app_select_field.dart';
import '../../../../shared/widgets/toast_overlay.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../dues/domain/entities/due_entity.dart';
import '../../../dues/presentation/providers/dues_provider.dart';
import '../../data/dekont_preview_cache.dart';
import '../../domain/entities/dekont_entity.dart';
import '../../domain/entities/dekont_status.dart';
import '../providers/dekont_provider.dart';
import '../providers/dekont_download_provider.dart';
import '../../../../shared/widgets/document_preview_screen.dart';
import '../widgets/dekont_system_info_section.dart';

class DekontDetailScreen extends ConsumerStatefulWidget {
  final String dekontId;

  const DekontDetailScreen({super.key, required this.dekontId});

  @override
  ConsumerState<DekontDetailScreen> createState() => _DekontDetailScreenState();
}

class _DekontDetailScreenState extends ConsumerState<DekontDetailScreen> {
  Uint8List? _fileBytes;
  bool _loadingFile = false;
  String? _fileError;

  Future<void> _loadFile({bool forceFromServer = false}) async {
    setState(() {
      _loadingFile = true;
      _fileError = null;
    });
    try {
      if (!forceFromServer) {
        final memoryCached = ref.read(
          dekontLocalPreviewProvider,
        )[widget.dekontId];
        if (memoryCached != null && memoryCached.isNotEmpty) {
          if (mounted) {
            setState(() {
              _fileBytes = memoryCached;
              _fileError = null;
            });
          }
          return;
        }

        final diskCached = await DekontPreviewCache.load(widget.dekontId);
        if (diskCached != null && diskCached.isNotEmpty) {
          if (mounted) {
            setState(() {
              _fileBytes = diskCached;
              _fileError = null;
            });
            ref
                .read(dekontLocalPreviewProvider.notifier)
                .upsert(widget.dekontId, diskCached);
          }
          return;
        }
      }

      final bytes = await ref
          .read(dekontRepositoryProvider)
          .getDekontFileBytes(widget.dekontId);
      if (mounted) {
        final copy = Uint8List.fromList(bytes);
        setState(() {
          _fileBytes = copy;
          _fileError = null;
        });
        ref
            .read(dekontLocalPreviewProvider.notifier)
            .upsert(widget.dekontId, copy);
        await DekontPreviewCache.save(widget.dekontId, copy);
      }
    } catch (e) {
      if (mounted) {
        if (e is ApiException && e.statusCode == 404) {
          ref.invalidate(myDekontsNotifierProvider);
          ref.invalidate(managerDekontsNotifierProvider);
        }
        final msg = userFacingError(e, context: ApiMessageContext.dekont);
        setState(() => _fileError = msg);
        ref.read(toastProvider.notifier).show(msg, type: ToastType.error);
      }
    } finally {
      if (mounted) setState(() => _loadingFile = false);
    }
  }

  Future<void> _openDekontPreview(DekontEntity dekont) async {
    if (_fileBytes == null && !_loadingFile) {
      await _loadFile();
    }
    if (!mounted) return;
    if (_fileBytes == null) return;

    await DocumentPreviewScreen.open(
      context,
      bytes: _fileBytes!,
      fileName: dekont.originalFilename,
      mimeType: dekont.mimeType,
      onShare: () => _shareFile(dekont),
      onDownload: () => _downloadDekont(dekont),
    );
  }

  Future<void> _shareFile(DekontEntity dekont) async {
    if (_fileBytes == null) {
      await _loadFile();
    }
    if (_fileBytes == null) return;
    final ext = dekont.mimeType.contains('pdf') ? 'pdf' : 'jpg';
    final file = XFile.fromData(
      _fileBytes!,
      mimeType: dekont.mimeType,
      name: '${dekont.id}.$ext',
    );
    await SharePlus.instance.share(ShareParams(files: [file]));
  }

  Future<void> _openReviewSheet(DekontEntity dekont) async {
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (sheetContext) => _ManagerReviewSheet(dekont: dekont),
    );
    if (ok == true && mounted) {
      ref.invalidate(dekontDetailProvider(widget.dekontId));
      ref
          .read(toastProvider.notifier)
          .show(
            context.t.features.dekont.reviewSuccess,
            type: ToastType.success,
          );
    }
  }

  Future<void> _downloadDekont(DekontEntity dekont) async {
    ref
        .read(toastProvider.notifier)
        .show('İndirme başlatıldı...', type: ToastType.info);

    try {
      final message = await ref
          .read(dekontDownloadProvider)
          .downloadAndSave(dekont.id, dekont.mimeType, dekont.originalFilename);

      if (!mounted) return;
      ref
          .read(toastProvider.notifier)
          .show(
            message,
            type: ToastType.success,
            duration: const Duration(seconds: 4),
          );
    } catch (e) {
      if (!mounted) return;
      ref
          .read(toastProvider.notifier)
          .show(e.toString(), type: ToastType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(dekontDetailProvider(widget.dekontId));
    final isManager =
        ref.watch(authStateProvider).user?.role == UserRole.manager;
    final t = context.t.features.dekont;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(t.detailTitle),
        centerTitle: true,
        actions: [
          if (detail.asData?.value != null)
            IconButton(
              icon: const Icon(Icons.download_rounded),
              onPressed: () => _downloadDekont(detail.asData!.value),
            ),
        ],
      ),
      body: detail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: AppSizes.screenBodyScrollPadding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  userFacingError(e, context: ApiMessageContext.dekont),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSizes.spacingM),
                FilledButton(
                  onPressed: () =>
                      ref.invalidate(dekontDetailProvider(widget.dekontId)),
                  child: Text(context.t.common.tryAgain),
                ),
              ],
            ),
          ),
        ),
        data: (dekont) {
          final date = DateFormat(
            'd MMMM yyyy, HH:mm',
          ).format(dekont.createdAt);

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(dekontDetailProvider(widget.dekontId));
              await ref.read(dekontDetailProvider(widget.dekontId).future);
              if (_fileBytes != null) {
                await _loadFile(forceFromServer: true);
              }
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: AppSizes.screenBodyScrollPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    dekont.originalFilename,
                    style: AppTypography.h4.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date,
                    style: AppTypography.body2.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacingL),
                  DekontSystemInfoSection(
                    dekont: dekont,
                    isManager: isManager,
                  ),
                  if (dekont.status == DekontStatus.rejected) ...[
                    const SizedBox(height: AppSizes.spacingL),
                    SizedBox(
                      height: AppSizes.buttonHeightPrimary,
                      child: ElevatedButton(
                        onPressed: () => context.push('/payment'),
                        style: AppButtonStyles.elevatedSuccess(),
                        child: Text(t.reupload),
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSizes.spacingL),
                  _buildFileCard(context, dekont),
                  if (_fileError != null) ...[
                    const SizedBox(height: AppSizes.spacingM),
                    Text(
                      _fileError!,
                      style: AppTypography.body2.copyWith(color: AppColors.error),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSizes.spacingS),
                    OutlinedButton(
                      onPressed: _loadFile,
                      style: AppButtonStyles.outlinedPrimary(),
                      child: Text(context.t.common.tryAgain),
                    ),
                  ],
                  if (isManager && dekont.status.needsManagerApproval) ...[
                    const SizedBox(height: AppSizes.spacingL),
                    SizedBox(
                      height: AppSizes.buttonHeightPrimary,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _openReviewSheet(dekont),
                        style: AppButtonStyles.elevatedPrimary(fullWidth: true),
                        child: Text('${t.approve} / ${t.reject}'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFileCard(BuildContext context, DekontEntity dekont) {
    final filename = dekont.originalFilename;
    final ext = filename.split('.').last.toLowerCase();
    final isPdf = ext == 'pdf';
    final sizeBytes = _fileBytes?.length ?? dekont.sizeBytes;
    final t = context.t.features.dekont;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.fill,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            _buildFileIcon(
              isPdf ? Icons.picture_as_pdf_outlined : Icons.image_outlined,
              isPdf ? Colors.red[700]! : AppColors.primary,
            ),
            const SizedBox(width: AppSizes.spacingM),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSizes.spacingS,
                ),
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
            Padding(
              padding: const EdgeInsets.only(right: AppSizes.spacingXS),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: _loadingFile
                        ? null
                        : () => _openDekontPreview(dekont),
                    icon: _loadingFile
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.visibility_outlined),
                    color: AppColors.primary,
                    tooltip: t.viewDekont,
                    constraints: const BoxConstraints(
                      minWidth: AppSizes.minTouchTarget,
                      minHeight: AppSizes.minTouchTarget,
                    ),
                  ),
                  IconButton(
                    onPressed: _loadingFile
                        ? null
                        : () => _shareFile(dekont),
                    icon: const Icon(Icons.share_outlined),
                    color: AppColors.primary,
                    tooltip: t.shareFile,
                    constraints: const BoxConstraints(
                      minWidth: AppSizes.minTouchTarget,
                      minHeight: AppSizes.minTouchTarget,
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

  Widget _buildFileIcon(IconData icon, Color color) {
    return Container(
      width: 64,
      height: 64,
      color: AppColors.surface,
      child: Icon(icon, color: color, size: 28),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }
}

class _ManagerReviewSheet extends ConsumerStatefulWidget {
  final DekontEntity dekont;

  const _ManagerReviewSheet({required this.dekont});

  @override
  ConsumerState<_ManagerReviewSheet> createState() =>
      _ManagerReviewSheetState();
}

class _ManagerReviewSheetState extends ConsumerState<_ManagerReviewSheet> {
  final _noteController = TextEditingController();
  String? _selectedDueId;
  DekontReviewDecision? _pendingDecision;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit(DekontReviewDecision decision) async {
    final t = context.t.features.dekont;
    final dueId = _selectedDueId ?? widget.dekont.dueId;
    if (decision == DekontReviewDecision.approve &&
        (dueId == null || dueId.isEmpty)) {
      ref
          .read(toastProvider.notifier)
          .show(t.selectDueForApprove, type: ToastType.info);
      return;
    }

    setState(() => _pendingDecision = decision);
    final ok = await ref
        .read(managerDekontsNotifierProvider.notifier)
        .review(
          id: widget.dekont.id,
          decision: decision,
          note: _noteController.text,
          dueId: dueId,
        );
    if (!mounted) return;
    setState(() => _pendingDecision = null);
    if (ok) {
      Navigator.of(context).pop(true);
    } else {
      ref
          .read(toastProvider.notifier)
          .show(t.reviewFailed, type: ToastType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.dekont;
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    final buildingId = widget.dekont.buildingId;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppButtonStyles.sheetTop.borderRadius,
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.spacingL,
              AppSizes.spacingM,
              AppSizes.spacingL,
              AppSizes.spacingL,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: AppSizes.spacingM),
                    decoration: BoxDecoration(
                      color: AppColors.border.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(t.reviewAction, style: AppTypography.h2),
                const SizedBox(height: AppSizes.spacingS),
                Text(
                  t.managerApprovalHint,
                  style: AppTypography.body2.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: AppSizes.spacingL),
                TextField(
                  controller: _noteController,
                  decoration: InputDecoration(labelText: t.reviewNote),
                  maxLines: 3,
                ),
                const SizedBox(height: AppSizes.spacingM),
                _BuildingDuesPicker(
                  buildingId: buildingId,
                  apartmentId: widget.dekont.apartmentId,
                  selectedDueId: _selectedDueId ?? widget.dekont.dueId,
                  onChanged: (id) => setState(() => _selectedDueId = id),
                ),
                const SizedBox(height: AppSizes.spacingL),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: AppSizes.buttonHeightSecondary,
                        child: OutlinedButton(
                          onPressed: _pendingDecision != null
                              ? null
                              : () => _submit(DekontReviewDecision.reject),
                          style: AppButtonStyles.outlinedDanger(fullWidth: true),
                          child: _pendingDecision == DekontReviewDecision.reject
                              ? const _ReviewButtonSpinner()
                              : Text(t.reject),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSizes.spacingS),
                    Expanded(
                      child: SizedBox(
                        height: AppSizes.buttonHeightSecondary,
                        child: ElevatedButton(
                          onPressed: _pendingDecision != null
                              ? null
                              : () => _submit(DekontReviewDecision.approve),
                          style: AppButtonStyles.elevatedSuccess(fullWidth: true),
                          child: _pendingDecision == DekontReviewDecision.approve
                              ? const _ReviewButtonSpinner(
                                  color: Colors.white,
                                )
                              : Text(t.approve),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BuildingDuesPicker extends ConsumerWidget {
  final String buildingId;
  final String? apartmentId;
  final String? selectedDueId;
  final ValueChanged<String?> onChanged;

  const _BuildingDuesPicker({
    required this.buildingId,
    this.apartmentId,
    this.selectedDueId,
    required this.onChanged,
  });

  static String? _resolveDropdownValue(
    List<DueEntity> dues,
    String? selectedDueId,
  ) {
    if (selectedDueId == null || selectedDueId.isEmpty) return null;
    final exists = dues.any((d) => d.id == selectedDueId);
    return exists ? selectedDueId : null;
  }

  static List<DueEntity> _filterForReview(
    List<DueEntity> dues,
    String? apartmentId,
  ) {
    if (apartmentId == null || apartmentId.isEmpty) return dues;
    final forApartment =
        dues.where((d) => d.apartmentId == apartmentId).toList();
    return forApartment.isNotEmpty ? forApartment : dues;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t.features.dekont;
    final duesAsync = ref.watch(buildingDuesForReviewProvider(buildingId));

    return duesAsync.when(
      loading: () => const LinearProgressIndicator(),
      error: (_, _) => Text(t.selectDueForApprove),
      data: (dues) {
        final reviewDues = _filterForReview(dues, apartmentId);
        if (reviewDues.isEmpty) {
          return Text(t.noPendingDues);
        }
        final effectiveValue = _resolveDropdownValue(reviewDues, selectedDueId);
        final options = <AppSelectOption<String>>[];
        final seenIds = <String>{};
        for (final d in reviewDues) {
          if (!seenIds.add(d.id)) continue;
          options.add(
            AppSelectOption(
              value: d.id,
              label:
                  '${d.month}/${d.year} — ${d.apartmentNumber} — ${d.amount}',
            ),
          );
        }
        return AppSelectField<String>(
          label: t.selectDueForApprove,
          sheetTitle: t.selectDueForApprove,
          value: effectiveValue,
          options: options,
          onChanged: onChanged,
        );
      },
    );
  }
}

final buildingDuesForReviewProvider = FutureProvider.autoDispose
    .family<List<DueEntity>, String>((ref, buildingId) async {
      final repo = ref.read(duesRepositoryProvider);
      final all = await repo.getBuildingDues(buildingId, paginated: false);
      final reviewable = all.items
          .where(
            (d) =>
                d.status == DueStatus.pending ||
                d.status == DueStatus.overdue,
          )
          .toList()
        ..sort((a, b) {
          final yearCmp = b.year.compareTo(a.year);
          if (yearCmp != 0) return yearCmp;
          return b.month.compareTo(a.month);
        });
      return reviewable;
    });

class _ReviewButtonSpinner extends StatelessWidget {
  const _ReviewButtonSpinner({this.color});

  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      height: 22,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? AppColors.error,
        ),
      ),
    );
  }
}
