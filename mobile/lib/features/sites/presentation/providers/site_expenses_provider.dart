import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/user_error_message.dart';
import '../../../expenses/data/models/expense_model.dart';
import '../../../expenses/domain/entities/expense_entity.dart';
import '../../data/datasources/site_expense_remote_datasource.dart';
import '../../data/sites_store.dart';
import '../../domain/entities/site_expense_create_outcome.dart';
import '../../domain/entities/site_expense_entity.dart';
import '../../domain/repositories/site_repository.dart';

class SiteExpensesState {
  final bool isLoading;
  final bool isLoadingMore;
  final List<SiteExpenseEntity> expenses;
  final SiteExpenseSummaryEntity? summary;
  final String? nextCursor;
  final String? error;
  final String? siteId;
  final int? month;
  final int? year;

  const SiteExpensesState({
    this.isLoading = false,
    this.isLoadingMore = false,
    this.expenses = const [],
    this.summary,
    this.nextCursor,
    this.error,
    this.siteId,
    this.month,
    this.year,
  });

  bool get canLoadMore =>
      nextCursor != null &&
      nextCursor!.isNotEmpty &&
      !isLoading &&
      !isLoadingMore;

  SiteExpensesState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    List<SiteExpenseEntity>? expenses,
    SiteExpenseSummaryEntity? summary,
    String? nextCursor,
    String? error,
    String? siteId,
    int? month,
    int? year,
    bool clearError = false,
    bool clearSummary = false,
    bool clearNextCursor = false,
  }) {
    return SiteExpensesState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      expenses: expenses ?? this.expenses,
      summary: clearSummary ? null : (summary ?? this.summary),
      nextCursor: clearNextCursor ? null : (nextCursor ?? this.nextCursor),
      error: clearError ? null : (error ?? this.error),
      siteId: siteId ?? this.siteId,
      month: month ?? this.month,
      year: year ?? this.year,
    );
  }
}

class SiteExpensesNotifier extends Notifier<SiteExpensesState> {
  SiteRepository get _repository => ref.read(siteRepositoryProvider);
  SiteExpenseRemoteDataSource get _remote =>
      ref.read(siteExpenseRemoteDataSourceProvider);

  @override
  SiteExpensesState build() => const SiteExpensesState();

  Future<void> load(
    String siteId, {
    bool refresh = true,
    int? month,
    int? year,
  }) async {
    final filtersChanged =
        state.siteId != siteId || state.month != month || state.year != year;
    final effectiveRefresh = refresh || filtersChanged;
    if (!effectiveRefresh && !state.canLoadMore) return;

    state = state.copyWith(
      isLoading: effectiveRefresh,
      isLoadingMore: !effectiveRefresh,
      clearError: true,
      siteId: siteId,
      month: month,
      year: year,
      clearNextCursor: effectiveRefresh,
    );

    try {
      final result = await _remote.fetchSiteExpenses(
        siteId,
        month: month,
        year: year,
        cursor: effectiveRefresh ? null : state.nextCursor,
      );

      SiteExpenseSummaryEntity? summary;
      if (effectiveRefresh && month != null && year != null) {
        summary = await _repository.fetchSiteExpenseSummary(
          siteId,
          month: month,
          year: year,
        );
      }

      final merged = effectiveRefresh
          ? result.items.map((m) => m.toEntity()).toList()
          : [
              ...state.expenses,
              ...result.items.map((m) => m.toEntity()),
            ];

      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        expenses: merged,
        summary: summary,
        nextCursor: result.nextCursor,
        clearNextCursor: result.nextCursor == null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        error: userFacingError(e),
      );
    }
  }

  Future<void> loadMore() async {
    final id = state.siteId;
    if (id == null) return;
    await load(id, refresh: false, month: state.month, year: state.year);
  }

  Future<void> reload() async {
    final id = state.siteId;
    if (id == null) return;
    await load(id, month: state.month, year: state.year);
  }

  Future<({bool success, SiteExpensePaidImpactPreview? preview})> create({
    required String siteId,
    required String title,
    required double amount,
    required ExpenseCategory category,
    required DateTime date,
    required int targetMonth,
    required int targetYear,
    String? note,
    bool confirmPaidImpact = false,
  }) async {
    try {
      final outcome = await _repository.createSiteExpense(
        siteId,
        title: title,
        amount: amount,
        category: ExpenseModel.categoryToApi(category),
        date: date,
        targetMonth: targetMonth,
        targetYear: targetYear,
        note: note,
        confirmPaidImpact: confirmPaidImpact,
      );

      if (outcome.requiresConfirmation) {
        return (success: false, preview: outcome.preview);
      }

      await load(siteId, month: state.month, year: state.year);
      return (success: true, preview: null);
    } catch (e) {
      state = state.copyWith(error: userFacingError(e));
      return (success: false, preview: null);
    }
  }

  Future<bool> update({
    required String siteId,
    required String expenseId,
    String? title,
    double? amount,
    ExpenseCategory? category,
    DateTime? date,
    String? note,
  }) async {
    try {
      await _repository.updateSiteExpense(
        siteId,
        expenseId,
        title: title,
        amount: amount,
        category:
            category != null ? ExpenseModel.categoryToApi(category) : null,
        date: date,
        note: note,
      );
      await reload();
      return true;
    } catch (e) {
      state = state.copyWith(error: userFacingError(e));
      return false;
    }
  }

  Future<bool> delete(String siteId, String expenseId) async {
    try {
      await _repository.deleteSiteExpense(siteId, expenseId);
      await reload();
      return true;
    } catch (e) {
      state = state.copyWith(error: userFacingError(e));
      return false;
    }
  }
}

final siteExpensesNotifierProvider =
    NotifierProvider<SiteExpensesNotifier, SiteExpensesState>(
  SiteExpensesNotifier.new,
);
