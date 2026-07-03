import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/user_error_message.dart';
<<<<<<< HEAD
import '../../../expenses/data/datasources/expense_remote_datasource.dart';
import '../../../expenses/domain/entities/expense_create_outcome.dart';
import '../../../expenses/domain/entities/expense_entity.dart';
import '../../data/repositories/site_repository.dart';
import '../../data/sites_store.dart';
import '../../domain/entities/site_expense_entity.dart';

class SiteExpensesState {
  final bool isLoading;
  final List<SiteExpenseEntity> expenses;
  final SiteExpenseSummaryEntity? summary;
=======
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
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
  final String? error;
  final String? siteId;
  final int? month;
  final int? year;

  const SiteExpensesState({
    this.isLoading = false,
<<<<<<< HEAD
    this.expenses = const [],
    this.summary,
=======
    this.isLoadingMore = false,
    this.expenses = const [],
    this.summary,
    this.nextCursor,
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
    this.error,
    this.siteId,
    this.month,
    this.year,
  });

<<<<<<< HEAD
  SiteExpensesState copyWith({
    bool? isLoading,
    List<SiteExpenseEntity>? expenses,
    SiteExpenseSummaryEntity? summary,
=======
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
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
    String? error,
    String? siteId,
    int? month,
    int? year,
    bool clearError = false,
    bool clearSummary = false,
<<<<<<< HEAD
  }) {
    return SiteExpensesState(
      isLoading: isLoading ?? this.isLoading,
      expenses: expenses ?? this.expenses,
      summary: clearSummary ? null : (summary ?? this.summary),
=======
    bool clearNextCursor = false,
  }) {
    return SiteExpensesState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      expenses: expenses ?? this.expenses,
      summary: clearSummary ? null : (summary ?? this.summary),
      nextCursor: clearNextCursor ? null : (nextCursor ?? this.nextCursor),
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
      error: clearError ? null : (error ?? this.error),
      siteId: siteId ?? this.siteId,
      month: month ?? this.month,
      year: year ?? this.year,
    );
  }
}

class SiteExpensesNotifier extends Notifier<SiteExpensesState> {
  SiteRepository get _repository => ref.read(siteRepositoryProvider);
<<<<<<< HEAD
=======
  SiteExpenseRemoteDataSource get _remote =>
      ref.read(siteExpenseRemoteDataSourceProvider);
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6

  @override
  SiteExpensesState build() => const SiteExpensesState();

  Future<void> load(
    String siteId, {
<<<<<<< HEAD
    required int month,
    required int year,
  }) async {
    state = state.copyWith(
      isLoading: true,
      siteId: siteId,
      month: month,
      year: year,
      clearError: true,
    );
    try {
      final expenses = await _repository.fetchSiteExpenses(
        siteId,
        month: month,
        year: year,
      );
      final summary = await _repository.fetchSiteExpenseSummary(
        siteId,
        month: month,
        year: year,
      );
      state = state.copyWith(
        isLoading: false,
        expenses: expenses,
        summary: summary,
=======
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
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
<<<<<<< HEAD
=======
        isLoadingMore: false,
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
        error: userFacingError(e),
      );
    }
  }

<<<<<<< HEAD
  Future<({bool success, ExpensePaidImpactPreview? preview})> create({
=======
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
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
    required String siteId,
    required String title,
    required double amount,
    required ExpenseCategory category,
    required DateTime date,
    required int targetMonth,
    required int targetYear,
    String? note,
<<<<<<< HEAD
    ExpenseCarryForwardPolicyApi carryForwardPolicy =
        ExpenseCarryForwardPolicyApi.warnOnly,
=======
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
    bool confirmPaidImpact = false,
  }) async {
    try {
      final outcome = await _repository.createSiteExpense(
        siteId,
        title: title,
        amount: amount,
<<<<<<< HEAD
        category: category,
=======
        category: ExpenseModel.categoryToApi(category),
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
        date: date,
        targetMonth: targetMonth,
        targetYear: targetYear,
        note: note,
<<<<<<< HEAD
        carryForwardPolicy: carryForwardPolicy,
        confirmPaidImpact: confirmPaidImpact,
      );
      if (outcome.requiresConfirmation) {
        return (success: false, preview: outcome.preview);
      }
      if (state.siteId == siteId &&
          state.month == targetMonth &&
          state.year == targetYear) {
        await load(siteId, month: targetMonth, year: targetYear);
      }
=======
        confirmPaidImpact: confirmPaidImpact,
      );

      if (outcome.requiresConfirmation) {
        return (success: false, preview: outcome.preview);
      }

      await load(siteId, month: state.month, year: state.year);
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
      return (success: true, preview: null);
    } catch (e) {
      state = state.copyWith(error: userFacingError(e));
      return (success: false, preview: null);
    }
  }

  Future<bool> update({
<<<<<<< HEAD
    required SiteExpenseEntity expense,
    required String title,
    required double amount,
    required ExpenseCategory category,
    required DateTime date,
    required int targetMonth,
    required int targetYear,
=======
    required String siteId,
    required String expenseId,
    String? title,
    double? amount,
    ExpenseCategory? category,
    DateTime? date,
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
    String? note,
  }) async {
    try {
      await _repository.updateSiteExpense(
<<<<<<< HEAD
        expense.id,
        title: title,
        amount: amount,
        category: category,
        date: date,
        targetMonth: targetMonth,
        targetYear: targetYear,
        note: note,
      );
      if (state.siteId != null && state.month != null && state.year != null) {
        await load(state.siteId!, month: state.month!, year: state.year!);
      }
=======
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
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
      return true;
    } catch (e) {
      state = state.copyWith(error: userFacingError(e));
      return false;
    }
  }

<<<<<<< HEAD
  Future<bool> delete(String expenseId) async {
    try {
      await _repository.deleteSiteExpense(expenseId);
      if (state.siteId != null && state.month != null && state.year != null) {
        await load(state.siteId!, month: state.month!, year: state.year!);
      }
=======
  Future<bool> delete(String siteId, String expenseId) async {
    try {
      await _repository.deleteSiteExpense(siteId, expenseId);
      await reload();
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
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
