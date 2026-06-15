import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/utils/app_currency_format.dart';
import '../../../../core/utils/app_date_format.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/strings.g.dart';
import '../../../../shared/theme/dashboard_screen_style.dart';
import '../../../../shared/widgets/dashboard_secondary_scaffold.dart';
import '../../../../shared/widgets/document_preview_screen.dart';
import '../../domain/entities/expense_entity.dart';
import '../providers/expenses_provider.dart';
import '../utils/expense_labels.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ExpenseDetailScreen extends ConsumerStatefulWidget {
  final String expenseId;
  final ExpenseEntity? initialExpense;

  const ExpenseDetailScreen({
    super.key,
    required this.expenseId,
    this.initialExpense,
  });

  @override
  ConsumerState<ExpenseDetailScreen> createState() =>
      _ExpenseDetailScreenState();
}

class _ExpenseDetailScreenState extends ConsumerState<ExpenseDetailScreen> {
  final Map<String, Uint8List> _filesBytes = {};
  final Map<String, bool> _loadingFiles = {};
  final Map<String, String> _filesErrors = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadAllFiles();
    });
  }

  void _loadAllFiles() {
    final expense = _getExpense();
    if (expense == null) return;
    for (final url in expense.receiptUrls) {
      _loadFile(url);
    }
  }

  ExpenseEntity? _getExpense() {
    final state = ref.watch(expensesNotifierProvider);
    try {
      return state.expenses.firstWhere((e) => e.id == widget.expenseId);
    } catch (_) {
      return widget.initialExpense;
    }
  }

  Future<void> _loadFile(String url) async {
    if (url.isEmpty) return;

    setState(() {
      _loadingFiles[url] = true;
      _filesErrors.remove(url);
    });

    try {
      final isAbsolute = Uri.parse(url).isAbsolute;

      Response<List<int>> response;
      if (isAbsolute) {
        final dio = Dio();
        response = await dio.get<List<int>>(
          url,
          options: Options(responseType: ResponseType.bytes),
        );
      } else {
        final dio = ref.read(dioClientProvider);
        response = await dio.get<List<int>>(
          url,
          options: Options(responseType: ResponseType.bytes),
        );
      }

      if (mounted && response.data != null) {
        setState(() {
          _filesBytes[url] = Uint8List.fromList(response.data!);
          _filesErrors.remove(url);
        });
      }
    } catch (e) {
      debugPrint('Receipt download error ($url): $e');
      if (mounted) {
        setState(
          () => _filesErrors[url] = context.t.features.dekont.errorFileDownload,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loadingFiles[url] = false);
      }
    }
  }

  Future<void> _shareFile(ExpenseEntity expense, String url) async {
    final bytes = _filesBytes[url];
    if (bytes == null) return;
    final ext = url.toLowerCase().contains('.pdf') ? 'pdf' : 'jpg';
    final file = XFile.fromData(
      bytes,
      mimeType: ext == 'pdf' ? 'application/pdf' : 'image/jpeg',
      name: 'expense_${expense.id}_${url.split('/').last}',
    );
    await SharePlus.instance.share(ShareParams(files: [file]));
  }

  Future<void> _openReceiptPreview(
    BuildContext context,
    ExpenseEntity expense,
    String url,
  ) async {
    final bytes = _filesBytes[url];
    if (bytes == null) return;

    final ext = url.toLowerCase().contains('.pdf') ? 'pdf' : 'jpg';
    final mimeType = ext == 'pdf' ? 'application/pdf' : 'image/jpeg';
    final filename = url.split('/').last;

    await DocumentPreviewScreen.open(
      context,
      bytes: bytes,
      fileName: filename.isNotEmpty ? filename : '${expense.title}.$ext',
      mimeType: mimeType,
      onShare: () => _shareFile(expense, url),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
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

  Widget _buildFileCard(
    BuildContext context,
    ExpenseEntity expense,
    String url,
    int index,
  ) {
    final t = context.t.features.expenses;
    final bytes = _filesBytes[url];
    final isLoading = _loadingFiles[url] == true;
    final error = _filesErrors[url];

    if (isLoading) {
      return DashboardSurfaceCard(
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (error != null) {
      return DashboardSurfaceCard(
        child: Row(
          children: [
            Expanded(
              child: Text(
                error,
                style: AppTypography.body2.copyWith(color: AppColors.error),
              ),
            ),
            IconButton(
              onPressed: () => _loadFile(url),
              icon: const Icon(Icons.refresh),
              color: AppColors.primary,
            ),
          ],
        ),
      );
    }

    final ext = url.toLowerCase().contains('.pdf') ? 'pdf' : 'jpg';
    final isPdf = ext == 'pdf';
    final sizeBytes = bytes?.length ?? 0;

    return DashboardSurfaceCard(
      child: Row(
        children: [
          _buildFileIcon(
            isPdf ? Icons.picture_as_pdf_outlined : Icons.image_outlined,
            isPdf ? Colors.red[700]! : AppColors.primary,
          ),
          const SizedBox(width: AppSizes.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${t.receiptTitle} ${index + 1}',
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
          IconButton(
            onPressed: bytes != null
                ? () => _openReceiptPreview(context, expense, url)
                : null,
            icon: const Icon(Icons.visibility_outlined),
            color: AppColors.primary,
            tooltip: t.viewReceipt,
            constraints: const BoxConstraints(
              minWidth: AppSizes.minTouchTarget,
              minHeight: AppSizes.minTouchTarget,
            ),
          ),
          IconButton(
            onPressed: bytes != null ? () => _shareFile(expense, url) : null,
            icon: const Icon(Icons.share_outlined),
            color: AppColors.primary,
            tooltip: context.t.features.dekont.shareFile,
            constraints: const BoxConstraints(
              minWidth: AppSizes.minTouchTarget,
              minHeight: AppSizes.minTouchTarget,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(
    BuildContext context,
    ExpenseEntity expense,
    NumberFormat currencyFormat,
    String createdAtDate,
    String expenseDate,
  ) {
    final t = context.t.features.expenses;

    return DashboardSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.title,
                      style: AppTypography.h4.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      expenseDate,
                      style: AppTypography.body2.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSizes.spacingS),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.spacingM,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(
                    DashboardScreenStyle.pillRadius,
                  ),
                ),
                child: Text(
                  expense.category.label(context),
                  style: AppTypography.body2.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacingM),
          Divider(height: 1, color: AppColors.border.withValues(alpha: 0.5)),
          const SizedBox(height: AppSizes.spacingM),
          Text(
            '${context.t.features.dekont.amount}: ${currencyFormat.format(expense.amount)}',
            style: AppTypography.h3.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: AppSizes.spacingS),
          Text(
            '${t.fieldCreatedAt}: $createdAtDate',
            style: AppTypography.body1,
          ),
          if (expense.note != null && expense.note!.isNotEmpty) ...[
            const SizedBox(height: AppSizes.spacingM),
            Divider(height: 1, color: AppColors.border.withValues(alpha: 0.5)),
            const SizedBox(height: AppSizes.spacingM),
            Text(
              '${t.fieldNote}:',
              style: AppTypography.body2.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 4),
            Text(
              expense.note!,
              style: AppTypography.body1,
            ),
          ],
        ],
      ),
    );
  }

  int _listItemCount(ExpenseEntity expense) {
    if (expense.receiptUrls.isEmpty) return 2; // header + empty receipts
    return 1 + expense.receiptUrls.length; // header + receipts
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t.features.expenses;
    final expense = _getExpense();

    if (expense == null) {
      return DashboardSecondaryScaffold(
        title: t.detailTitle,
        body: Center(
          child: Text(context.t.common.api.expenseNotFound),
        ),
      );
    }

    final currencyFormat = AppCurrencyFormat.standard();
    final createdAtDate = AppDateFormat.dateTimeMedium(expense.createdAt);
    final expenseDate = AppDateFormat.dateMedium(expense.date);

    return DashboardSecondaryScaffold(
      title: t.detailTitle,
      body: ListView.builder(
        padding: AppSizes.screenBodyScrollPadding,
        itemCount: _listItemCount(expense),
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: DashboardScreenStyle.listItemPadding,
              child: _buildHeaderCard(
                context,
                expense,
                currencyFormat,
                createdAtDate,
                expenseDate,
              ),
            );
          }

          if (expense.receiptUrls.isEmpty) {
            return DashboardSurfaceCard(
              child: Center(
                child: Text(
                  t.receiptMissing,
                  style: AppTypography.body2.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            );
          }

          final receiptIndex = index - 1;
          final url = expense.receiptUrls[receiptIndex];
          return Padding(
            padding: DashboardScreenStyle.listItemPadding,
            child: _buildFileCard(context, expense, url, receiptIndex),
          );
        },
      ),
    );
  }
}
