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
import '../../../../core/utils/app_currency_format.dart';
import '../../../../core/utils/month_labels.dart';
import '../../../../core/utils/user_error_message.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../features/profile/presentation/theme/profile_settings_ui.dart';
import '../../../../shared/widgets/premium_bottom_sheet.dart';
import '../../../../shared/widgets/minimal_form_widgets.dart';
import '../../../../shared/widgets/dashboard_secondary_scaffold.dart';
import '../../../../shared/widgets/toast_overlay.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../dashboard/presentation/utils/dashboard_filter_scope_routing.dart';
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
  final _amountController = TextEditingController();
  DekontReviewDecision? _pendingDecision;

  bool get _needsManualAmount {
    final raw = widget.dekont.parsedAmount;
    if (raw == null || raw.trim().isEmpty) return true;
    final n = double.tryParse(raw.replaceAll(',', '.'));
    return n == null || n <= 0;
  }

  double? get _parsedAmount {
    final raw = widget.dekont.parsedAmount;
    if (raw == null) return null;
    return double.tryParse(raw.replaceAll(',', '.'));
  }

  double get _totalRemaining {
    return widget.dekont.allocations.fold<double>(0, (sum, a) {
      final rem = double.tryParse(a.remainingAmount ?? '') ??
          double.tryParse(a.amount ?? '') ??
          0;
      return sum + rem;
    });
  }

  @override
  void dispose() {
    _noteController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit(DekontReviewDecision decision) async {
    final t = context.t.features.dekont;
    final dueIds = widget.dekont.targetDueIds;
    if (decision == DekontReviewDecision.approve && dueIds.isEmpty) {
      ref
          .read(toastProvider.notifier)
          .show(t.errorReviewNeedDue, type: ToastType.info);
      return;
    }

    double? amount;
    if (decision == DekontReviewDecision.approve) {
      if (_needsManualAmount) {
        final typed = _amountController.text.trim().replaceAll(',', '.');
        amount = double.tryParse(typed);
        if (amount == null || amount <= 0) {
          ref
              .read(toastProvider.notifier)
              .show(t.errorReviewNeedAmount, type: ToastType.info);
          return;
        }
      } else {
        amount = _parsedAmount;
      }
    }

    setState(() => _pendingDecision = decision);
    final ok = await ref
        .read(managerDekontsNotifierProvider.notifier)
        .review(
          id: widget.dekont.id,
          decision: decision,
          note: _noteController.text,
          dueId: dueIds.isNotEmpty ? dueIds.first : null,
          dueIds: dueIds.isNotEmpty ? dueIds : null,
          amount: amount,
        );
    if (!mounted) return;
    setState(() => _pendingDecision = null);
    if (ok) {
      Navigator.of(context).pop(true);
    } else {
      final err = ref.read(managerDekontsNotifierProvider).reviewError;
      ref.read(toastProvider.notifier).show(
            err ?? t.reviewFailed,
            type: ToastType.error,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.dekont;
    final remaining = _totalRemaining;
    final applyPreview = _needsManualAmount
        ? null
        : _parsedAmount;

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
          const SizedBox(height: AppSizes.spacingM),
          if (remaining > 0 || applyPreview != null)
            Container(
              padding: const EdgeInsets.all(AppSizes.spacingM),
              decoration: BoxDecoration(
                color: AppColors.fill,
                borderRadius: BorderRadius.circular(AppSizes.cardRadius),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (applyPreview != null)
                    Text(
                      t.reviewApplyAmount.replaceAll(
                        '{amount}',
                        AppCurrencyFormat.format(applyPreview),
                      ),
                      style: AppTypography.body1.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  if (remaining > 0) ...[
                    if (applyPreview != null) const SizedBox(height: 4),
                    Text(
                      t.reviewRemainingAmount.replaceAll(
                        '{amount}',
                        AppCurrencyFormat.format(remaining),
                      ),
                      style: AppTypography.body2.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          if (_needsManualAmount) ...[
            const SizedBox(height: AppSizes.spacingM),
            Text(
              t.reviewAmountRequiredHint,
              style: AppTypography.body2.copyWith(
                color: AppColors.statusRed,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSizes.spacingS),
            MinimalTextField(
              controller: _amountController,
              label: t.reviewAmountLabel,
              icon: Icons.payments_outlined,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
          ],
          const SizedBox(height: AppSizes.spacingL),
          MinimalTextField(
            controller: _noteController,
            label: t.reviewNote,
            icon: Icons.notes_outlined,
            maxLines: 3,
          ),
          const SizedBox(height: AppSizes.spacingM),
          _ResidentSelectedDuesInfo(dekont: widget.dekont),
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

class _ResidentSelectedDuesInfo extends StatelessWidget {
  const _ResidentSelectedDuesInfo({required this.dekont});

  final DekontEntity dekont;

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.dekont;
    final allocations = dekont.allocations;
    final dueIds = dekont.targetDueIds;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          t.residentSelectedDues,
          style: AppTypography.body1.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: AppSizes.spacingXS),
        Text(
          t.residentSelectedDuesHint,
          style: AppTypography.body2.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSizes.spacingS),
        if (allocations.isEmpty && dueIds.isEmpty)
          Text(
            t.noPendingDues,
            style: AppTypography.body2.copyWith(
              color: AppColors.textSecondary,
            ),
          )
        else if (allocations.isNotEmpty)
          for (final a in allocations)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.spacingXS),
              child: _SelectedDueRow(
                title: _allocationTitle(context, a),
                subtitle: _allocationSubtitle(context, a),
              ),
            )
        else
          for (final id in dueIds)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.spacingXS),
              child: _SelectedDueRow(
                title: id,
                subtitle: null,
              ),
            ),
      ],
    );
  }

  String _allocationTitle(BuildContext context, DekontDueAllocationSummary a) {
    if (a.month != null && a.year != null) {
      final month = localizedMonthName(context, a.month!);
      final apt = a.apartmentNumber;
      if (apt != null && apt.isNotEmpty) {
        return '$month ${a.year} · ${context.t.common.stepApartment} $apt';
      }
      return '$month ${a.year}';
    }
    return a.dueId;
  }

  String? _allocationSubtitle(
    BuildContext context,
    DekontDueAllocationSummary a,
  ) {
    final amount = a.remainingAmount ?? a.amount;
    if (amount == null || amount.isEmpty) return null;
    final parsed = double.tryParse(amount);
    if (parsed == null) return amount;
    return AppCurrencyFormat.format(parsed);
  }
}

class _SelectedDueRow extends StatelessWidget {
  const _SelectedDueRow({required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spacingM,
        vertical: AppSizes.spacingS,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Icon(Icons.receipt_long_outlined, color: AppColors.mutedText, size: 22),
          const SizedBox(width: AppSizes.spacingS),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.body1.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: AppTypography.body2.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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
