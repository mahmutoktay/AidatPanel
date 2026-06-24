import { asyncHandler } from "../utils/asyncHandler.js";
import {
  listSiteExpensesService,
  getSiteExpenseSummaryService,
  createSiteExpenseService,
  updateSiteExpenseService,
  deleteSiteExpenseService,
} from "../services/siteExpenseService.js";

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
