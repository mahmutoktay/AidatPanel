import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_button_styles.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/api_user_message.dart';
import '../../../../core/utils/user_error_message.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../features/profile/presentation/theme/profile_settings_ui.dart';
import '../../../../shared/widgets/premium_bottom_sheet.dart';
import '../../../../shared/widgets/minimal_form_widgets.dart';
import '../../../../shared/widgets/app_select_field.dart';
import '../../../../shared/widgets/dashboard_secondary_scaffold.dart';
import '../../../../shared/widgets/toast_overlay.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../dashboard/presentation/utils/dashboard_filter_scope_routing.dart';
import '../../../dues/domain/entities/due_entity.dart';
import '../../../dues/presentation/providers/dues_provider.dart';
import '../../data/dekont_preview_cache.dart';
import '../../domain/entities/dekont_entity.dart';
import '../../domain/entities/dekont_status.dart';
import '../providers/dekont_provider.dart';
import '../providers/dekont_download_provider.dart';
import '../../../../shared/widgets/document_preview_screen.dart';
import '../widgets/dekont_detail_file_row.dart';
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
    final ok = await PremiumBottomSheetScaffold.show<bool>(
      context: context,
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
    final t = context.t.common.errorKeys;
    ref
        .read(toastProvider.notifier)
        .show(t.downloadStarted, type: ToastType.info);

    try {
      final raw = await ref
          .read(dekontDownloadProvider)
          .downloadAndSave(dekont.id, dekont.mimeType, dekont.originalFilename);

      if (!mounted) return;
      final msg = _downloadMessage(context, raw);
      ref
          .read(toastProvider.notifier)
          .show(
            msg,
            type: ToastType.success,
            duration: const Duration(seconds: 4),
          );
    } catch (e) {
      if (!mounted) return;
      final msg = _downloadMessage(context, e.toString());
      ref
          .read(toastProvider.notifier)
          .show(msg, type: ToastType.error);
    }
  }

  String _downloadMessage(BuildContext context, String key) {
    final t = context.t.common.errorKeys;
    switch (key) {
      case 'download_saved_to_gallery':
        return t.downloadSavedToGallery;
      case 'download_saved_to_downloads':
        return t.downloadSavedToDownloads;
      case 'download_fallback_share':
        return t.downloadFallbackShare;
      default:
        return t.downloadError;
    }
  }

  List<Widget>? _downloadActions(AsyncValue<DekontEntity> detail) {
    if (detail.asData?.value == null) return null;
    return [
      IconButton(
        icon: const Icon(Icons.download_rounded),
        onPressed: () => _downloadDekont(detail.asData!.value),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(dekontDetailProvider(widget.dekontId));
    final isManager =
        ref.watch(authStateProvider.select((state) => state.user?.role)) ==
        UserRole.manager;
    final t = context.t.features.dekont;
    final downloadActions = _downloadActions(detail);
    final fallbackRoute = isManager
        ? _managerDueTransactionsFallback(detail)
        : '/resident-dashboard/dekonts';

    final body = detail.when(
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
                DekontSystemInfoSection(dekont: dekont, isManager: isManager),
                const SizedBox(height: AppSizes.spacingM),
                DekontDetailFileRow(
                  dekont: dekont,
                  sizeBytes: _fileBytes?.length,
                  loadingFile: _loadingFile,
                  onPreview: () => _openDekontPreview(dekont),
                  onShare: () => _shareFile(dekont),
                ),
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
                if (!isManager && dekont.status == DekontStatus.rejected) ...[
                  const SizedBox(height: AppSizes.spacingM),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.push('/payment'),
                      style: AppButtonStyles.elevatedSuccess(),
                      child: Text(t.reupload),
                    ),
                  ),
                ],
                if (isManager && dekont.status.needsManagerApproval) ...[
                  const SizedBox(height: AppSizes.spacingM),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _openReviewSheet(dekont),
                      style: ProfileSettingsUi.primaryButton,
                      child: Text('${t.approve} / ${t.reject}'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );

    return DashboardSecondaryScaffold(
      title: t.detailTitle,
      actions: downloadActions,
      fallbackRoute: fallbackRoute,
      body: body,
    );
  }

  String _managerDueTransactionsFallback(AsyncValue<DekontEntity> detail) {
    final buildingId = detail.asData?.value.buildingId;
    if (buildingId != null && buildingId.isNotEmpty) {
      return dueTransactionsPathForBuilding(buildingId);
    }
    return '/manager-dashboard/due-transactions';
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
    final buildingId = widget.dekont.buildingId;

    return PremiumBottomSheetScaffold(
      title: t.reviewAction,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            t.managerApprovalHint,
            style: AppTypography.body2.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSizes.spacingL),
          MinimalTextField(
            controller: _noteController,
            label: t.reviewNote,
            icon: Icons.notes_outlined,
            maxLines: 3,
          ),
          const SizedBox(height: AppSizes.spacingM),
          _BuildingDuesPicker(
            buildingId: buildingId,
            apartmentId: widget.dekont.apartmentId,
            selectedDueId: _selectedDueId ?? widget.dekont.dueId,
            onChanged: (id) => setState(() => _selectedDueId = id),
          ),
        ],
      ),
      actions: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.spacingL,
          AppSizes.spacingS,
          AppSizes.spacingL,
          AppSizes.spacingM,
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _pendingDecision != null
                    ? null
                    : () => _submit(DekontReviewDecision.reject),
                style: ProfileSettingsUi.dangerOutlinedButton,
                child: _pendingDecision == DekontReviewDecision.reject
                    ? const _ReviewButtonSpinner()
                    : Text(t.reject),
              ),
            ),
            const SizedBox(width: AppSizes.spacingS),
            Expanded(
              child: ElevatedButton(
                onPressed: _pendingDecision != null
                    ? null
                    : () => _submit(DekontReviewDecision.approve),
                style: AppButtonStyles.elevatedSuccess(fullWidth: true),
                child: _pendingDecision == DekontReviewDecision.approve
                    ? const _ReviewButtonSpinner(color: Colors.white)
                    : Text(t.approve),
              ),
            ),
          ],
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
    final forApartment = dues
        .where((d) => d.apartmentId == apartmentId)
        .toList();
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
      final reviewable =
          all.items
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
        valueColor: AlwaysStoppedAnimation<Color>(color ?? AppColors.error),
      ),
    );
  }
}
