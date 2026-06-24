import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/user_error_message.dart';
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
  final String? error;
  final String? siteId;
  final int? month;
  final int? year;

  const SiteExpensesState({
    this.isLoading = false,
    this.expenses = const [],
    this.summary,
    this.error,
    this.siteId,
    this.month,
    this.year,
  });

  SiteExpensesState copyWith({
    bool? isLoading,
    List<SiteExpenseEntity>? expenses,
    SiteExpenseSummaryEntity? summary,
    String? error,
    String? siteId,
    int? month,
    int? year,
    bool clearError = false,
    bool clearSummary = false,
  }) {
    return SiteExpensesState(
      isLoading: isLoading ?? this.isLoading,
      expenses: expenses ?? this.expenses,
      summary: clearSummary ? null : (summary ?? this.summary),
      error: clearError ? null : (error ?? this.error),
      siteId: siteId ?? this.siteId,
      month: month ?? this.month,
      year: year ?? this.year,
    );
  }
}

class SiteExpensesNotifier extends Notifier<SiteExpensesState> {
  SiteRepository get _repository => ref.read(siteRepositoryProvider);

  @override
  SiteExpensesState build() => const SiteExpensesState();

  Future<void> load(
    String siteId, {
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
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: userFacingError(e),
      );
    }
  }

  Future<({bool success, ExpensePaidImpactPreview? preview})> create({
    required String siteId,
    required String title,
    required double amount,
    required ExpenseCategory category,
    required DateTime date,
    required int targetMonth,
    required int targetYear,
    String? note,
    ExpenseCarryForwardPolicyApi carryForwardPolicy =
        ExpenseCarryForwardPolicyApi.warnOnly,
    bool confirmPaidImpact = false,
  }) async {
    try {
      final outcome = await _repository.createSiteExpense(
        siteId,
        title: title,
        amount: amount,
        category: category,
        date: date,
        targetMonth: targetMonth,
        targetYear: targetYear,
        note: note,
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
      return (success: true, preview: null);
    } catch (e) {
      state = state.copyWith(error: userFacingError(e));
      return (success: false, preview: null);
    }
  }

  Future<bool> update({
    required SiteExpenseEntity expense,
    required String title,
    required double amount,
    required ExpenseCategory category,
    required DateTime date,
    required int targetMonth,
    required int targetYear,
    String? note,
  }) async {
    try {
      await _repository.updateSiteExpense(
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
      return true;
    } catch (e) {
      state = state.copyWith(error: userFacingError(e));
      return false;
    }
  }

  Future<bool> delete(String expenseId) async {
    try {
      await _repository.deleteSiteExpense(expenseId);
      if (state.siteId != null && state.month != null && state.year != null) {
        await load(state.siteId!, month: state.month!, year: state.year!);
      }
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
