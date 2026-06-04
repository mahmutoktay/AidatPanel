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
import '../../../../shared/widgets/toast_overlay.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../dues/domain/entities/due_entity.dart';
import '../../../dues/presentation/providers/dues_provider.dart';
import '../../data/dekont_preview_cache.dart';
import '../../domain/entities/dekont_entity.dart';
import '../../domain/entities/dekont_status.dart';
import '../providers/dekont_provider.dart';
import '../utils/dekont_labels.dart';
import '../widgets/dekont_file_preview.dart';

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadFile();
    });
  }

  Future<void> _loadFile({bool forceFromServer = false}) async {
    setState(() {
      _loadingFile = true;
      _fileError = null;
    });
    try {
      if (!forceFromServer) {
        final memoryCached =
            ref.read(dekontLocalPreviewProvider)[widget.dekontId];
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
            ref.read(dekontLocalPreviewProvider.notifier).update(
                  (m) => {...m, widget.dekontId: diskCached},
                );
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
        ref.read(dekontLocalPreviewProvider.notifier).update(
              (m) => {...m, widget.dekontId: copy},
            );
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
        ref.read(toastProvider.notifier).show(
              msg,
              type: ToastType.error,
            );
      }
    } finally {
      if (mounted) setState(() => _loadingFile = false);
    }
  }

  Future<void> _shareFile(DekontEntity dekont) async {
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
      builder: (_) => _ManagerReviewSheet(dekont: dekont),
    );
    if (ok == true && mounted) {
      ref.invalidate(dekontDetailProvider(widget.dekontId));
      ref.read(toastProvider.notifier).show(
            context.t.features.dekont.reviewSuccess,
            type: ToastType.success,
          );
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
          final visual = dekontStatusVisual(context, dekont.status);
          final date =
              DateFormat('d MMMM yyyy, HH:mm').format(dekont.createdAt);

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(dekontDetailProvider(widget.dekontId));
              await ref.read(dekontDetailProvider(widget.dekontId).future);
              await _loadFile(forceFromServer: true);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: AppSizes.screenBodyScrollPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSizes.spacingM),
                    decoration: BoxDecoration(
                      color: visual.background,
                      borderRadius:
                          BorderRadius.circular(AppSizes.cardRadius),
                    ),
                    child: Text(
                      visual.label,
                      style: AppTypography.h3.copyWith(color: visual.color),
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacingM),
                  Text(
                    dekont.originalFilename,
                    style: AppTypography.h4.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    date,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (dekont.apartment != null) ...[
                    const SizedBox(height: AppSizes.spacingS),
                    Text(
                      '${t.apartment}: ${dekont.apartment!.number}',
                      style: AppTypography.body2,
                    ),
                  ],
                  if (dekont.uploadedBy != null) ...[
                    const SizedBox(height: AppSizes.spacingS),
                    Text(
                      '${t.uploadedBy}: ${dekont.uploadedBy!.name}',
                      style: AppTypography.body2,
                    ),
                  ],
                  if (dekont.parsedAmount != null) ...[
                    const SizedBox(height: AppSizes.spacingM),
                    Text(
                      '${t.parsedAmount}: ${dekont.parsedAmount}',
                      style: AppTypography.body1.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  if (dekont.rejectionReason != null) ...[
                    const SizedBox(height: AppSizes.spacingM),
                    Text(
                      '${t.rejectionReason}: ${dekont.rejectionReason}',
                      style: AppTypography.body2.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSizes.spacingL),
                  Text(
                    t.filePreview,
                    style: AppTypography.h3,
                  ),
                  const SizedBox(height: AppSizes.spacingM),
                  if (_loadingFile)
                    const Center(child: CircularProgressIndicator())
                  else if (_fileBytes != null) ...[
                    DekontFilePreview(
                      bytes: _fileBytes!,
                      mimeType: dekont.mimeType,
                      fileName: dekont.originalFilename,
                    ),
                  ] else if (_fileError != null) ...[
                    Text(
                      _fileError!,
                      style: AppTypography.body2.copyWith(
                        color: AppColors.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSizes.spacingM),
                    OutlinedButton(
                      onPressed: _loadFile,
                      style: AppButtonStyles.outlinedPrimary(),
                      child: Text(context.t.common.tryAgain),
                    ),
                    if (!isManager) ...[
                      const SizedBox(height: AppSizes.spacingM),
                      SizedBox(
                        height: AppSizes.buttonHeightPrimary,
                        child: ElevatedButton(
                          onPressed: () => context.push('/payment'),
                          style: AppButtonStyles.elevatedSuccess(),
                          child: Text(t.reupload),
                        ),
                      ),
                    ],
                  ] else
                    OutlinedButton(
                      onPressed: _loadFile,
                      style: AppButtonStyles.outlinedPrimary(),
                      child: Text(t.filePreview),
                    ),
                  if (_fileBytes != null) ...[
                    const SizedBox(height: AppSizes.spacingM),
                    OutlinedButton.icon(
                      onPressed: () => _shareFile(dekont),
                      style: AppButtonStyles.outlinedPrimary(),
                      icon: const Icon(Icons.share_outlined),
                      label: Text(t.shareFile),
                    ),
                  ],
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
                  if (isManager && dekont.status.needsManagerAttention) ...[
                    const SizedBox(height: AppSizes.spacingL),
                    SizedBox(
                      height: AppSizes.buttonHeightPrimary,
                      child: ElevatedButton(
                        onPressed: () => _openReviewSheet(dekont),
                        style: AppButtonStyles.elevatedInfo(),
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
  bool _submitting = false;

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
      ref.read(toastProvider.notifier).show(
            t.selectDueForApprove,
            type: ToastType.info,
          );
      return;
    }

    setState(() => _submitting = true);
    final ok = await ref.read(managerDekontsNotifierProvider.notifier).review(
          id: widget.dekont.id,
          decision: decision,
          note: _noteController.text,
          dueId: dueId,
        );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (ok) {
      Navigator.of(context).pop(true);
    } else {
      ref.read(toastProvider.notifier).show(
            t.reviewFailed,
            type: ToastType.error,
          );
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
        padding: const EdgeInsets.all(AppSizes.spacingL),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(t.detailTitle, style: AppTypography.h2),
              const SizedBox(height: AppSizes.spacingM),
              TextField(
                controller: _noteController,
                decoration: InputDecoration(
                  labelText: t.reviewNote,
                ),
                maxLines: 3,
              ),
              const SizedBox(height: AppSizes.spacingM),
              _BuildingDuesPicker(
                buildingId: buildingId,
                selectedDueId: _selectedDueId ?? widget.dekont.dueId,
                onChanged: (id) => setState(() => _selectedDueId = id),
              ),
              const SizedBox(height: AppSizes.spacingL),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _submitting
                          ? null
                          : () => _submit(DekontReviewDecision.reject),
                      style: AppButtonStyles.outlinedDanger(),
                      child: Text(t.reject),
                    ),
                  ),
                  const SizedBox(width: AppSizes.spacingM),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submitting
                          ? null
                          : () => _submit(DekontReviewDecision.approve),
                      style: AppButtonStyles.elevatedSuccess(),
                      child: _submitting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Text(t.approve),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BuildingDuesPicker extends ConsumerWidget {
  final String buildingId;
  final String? selectedDueId;
  final ValueChanged<String?> onChanged;

  const _BuildingDuesPicker({
    required this.buildingId,
    this.selectedDueId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t.features.dekont;
    final duesAsync = ref.watch(
      buildingDuesForReviewProvider(buildingId),
    );

    return duesAsync.when(
      loading: () => const LinearProgressIndicator(),
      error: (_, _) => Text(t.selectDueForApprove),
      data: (dues) {
        if (dues.isEmpty) {
          return Text(t.noPendingDues);
        }
        return DropdownButtonFormField<String>(
          key: ValueKey(selectedDueId),
          initialValue: selectedDueId,
          decoration: InputDecoration(labelText: t.selectDueForApprove),
          items: [
            for (final d in dues)
              DropdownMenuItem(
                value: d.id,
                child: Text(
                  '${d.month}/${d.year} — ${d.apartmentNumber} — ${d.amount}',
                ),
              ),
          ],
          onChanged: onChanged,
        );
      },
    );
  }
}

final buildingDuesForReviewProvider = FutureProvider.autoDispose
    .family<List<DueEntity>, String>((ref, buildingId) async {
  return ref.read(duesRepositoryProvider).getBuildingDues(
        buildingId,
        status: DueStatus.pending,
      );
});
