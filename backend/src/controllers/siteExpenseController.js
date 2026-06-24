import {
  listSiteExpensesService,
  getSiteExpenseSummaryService,
  createSiteExpenseService,
  updateSiteExpenseService,
  deleteSiteExpenseService,
} from "../services/siteExpenseService.js";
import { HttpError } from "../utils/httpError.js";

const handleHttp = (err, res, next) => {
  if (err instanceof HttpError) {
    return res.status(err.statusCode).json({
      success: false,
      message: err.message,
    });
  }
  next(err);
};

export const getSiteExpenses = async (req, res, next) => {
  try {
    const { id: siteId } = req.params;
    const { month, year, category, cursor, limit, paginated } = req.query;
    const data = await listSiteExpensesService(siteId, req.user.id, {
      month,
      year,
      category,
      cursor,
      limit,
      paginated,
    });
    res.status(200).json({ success: true, data });
  } catch (err) {
    handleHttp(err, res, next);
  }
};

export const getSiteExpenseSummary = async (req, res, next) => {
  try {
    const { id: siteId } = req.params;
    const { month, year } = req.query;
    const data = await getSiteExpenseSummaryService(siteId, req.user.id, {
      month,
      year,
    });
    res.status(200).json({ success: true, data });
  } catch (err) {
    handleHttp(err, res, next);
  }
};

export const createSiteExpense = async (req, res, next) => {
  try {
    const { id: siteId } = req.params;
    const result = await createSiteExpenseService(siteId, req.user.id, req.body);

    if (result.preview) {
      return res.status(200).json({
        success: true,
        data: result.preview,
      });
    }

    const message = result.warnings?.length
      ? result.warnings.join(" ")
      : "Site gideri kaydedildi.";

    res.status(201).json({
      success: true,
      message,
      data: {
        expense: result.expense,
        expenses: result.expenses,
        warnings: result.warnings ?? [],
        pastMonthWarning: result.pastMonthWarning ?? false,
        splitGroupId: result.splitGroupId ?? null,
      },
    });
  } catch (err) {
    handleHttp(err, res, next);
  }
};

export const updateSiteExpense = async (req, res, next) => {
  try {
    const data = await updateSiteExpenseService(
      req.params.expenseId,
      req.user.id,
      req.body
    );
    res.status(200).json({
      success: true,
      message: "Site gideri güncellendi.",
      data,
    });
  } catch (err) {
    handleHttp(err, res, next);
  }
};

export const deleteSiteExpense = async (req, res, next) => {
  try {
    const data = await deleteSiteExpenseService(
      req.params.expenseId,
      req.user.id
    );
    res.status(200).json({
      success: true,
      message: "Site gideri silindi.",
      data,
    });
  } catch (err) {
    handleHttp(err, res, next);
  }
};
