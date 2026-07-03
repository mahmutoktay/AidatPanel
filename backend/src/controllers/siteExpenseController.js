<<<<<<< HEAD
=======
import { asyncHandler } from "../utils/asyncHandler.js";
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
import {
  listSiteExpensesService,
  getSiteExpenseSummaryService,
  createSiteExpenseService,
  updateSiteExpenseService,
  deleteSiteExpenseService,
} from "../services/siteExpenseService.js";
<<<<<<< HEAD
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
=======

export const getSiteExpenses = asyncHandler(async (req, res) => {
  const data = await listSiteExpensesService(req.params.id, req.user.id, req.query);
  res.json({ success: true, data });
});

export const getSiteExpenseSummary = asyncHandler(async (req, res) => {
  const now = new Date();
  const month = req.query.month ? parseInt(String(req.query.month), 10) : now.getMonth() + 1;
  const year = req.query.year ? parseInt(String(req.query.year), 10) : now.getFullYear();
  const data = await getSiteExpenseSummaryService(req.params.id, req.user.id, {
    month,
    year,
  });
  res.json({ success: true, data });
});

export const createSiteExpense = asyncHandler(async (req, res) => {
  const result = await createSiteExpenseService(req.params.id, req.user.id, req.body, {
    carryForwardPolicy: req.body.carryForwardPolicy ?? "NONE",
    confirmPaidImpact: req.body.confirmPaidImpact === true,
  });

  if (result.preview) {
    return res.status(200).json({
      success: true,
      message: "Onay gerekli.",
      data: result.preview,
    });
  }

  res.status(201).json({
    success: true,
    message: "Site gideri eklendi.",
    data: result,
  });
});

export const updateSiteExpense = asyncHandler(async (req, res) => {
  const expense = await updateSiteExpenseService(
    req.params.expenseId,
    req.user.id,
    req.body
  );
  res.json({ success: true, data: expense });
});

export const deleteSiteExpense = asyncHandler(async (req, res) => {
  await deleteSiteExpenseService(req.params.expenseId, req.user.id);
  res.json({ success: true, message: "Site gideri silindi." });
});
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
