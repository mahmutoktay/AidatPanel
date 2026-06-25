import {
  listExpensesByBuildingService,
  getExpenseSummaryService,
  createExpenseService,
  updateExpenseService,
  deleteExpenseService,
  uploadExpenseProofsService,
  getExpenseFileService,
  listExpensesForResidentService,
} from "../services/expenseService.js";
import { createDekontReadStream } from "../services/dekontStorageService.js";
import { logger } from "../config/logger.js";
import { asyncHandler } from "../utils/asyncHandler.js";

export const getExpensesByBuilding = asyncHandler(async (req, res) => {
  const { id: buildingId } = req.params;
  const { month, year, category, cursor, limit, paginated } = req.query;
  const data = await listExpensesByBuildingService(buildingId, req.user.id, {
    month,
    year,
    category,
    cursor,
    limit,
    paginated,
  });
  res.status(200).json({ success: true, data });
});

export const getExpenseSummary = asyncHandler(async (req, res) => {
  const { id: buildingId } = req.params;
  const { month, year } = req.query;
  const data = await getExpenseSummaryService(buildingId, req.user.id, {
    month,
    year,
  });
  res.status(200).json({ success: true, data });
});

export const createExpense = asyncHandler(async (req, res) => {
  const { id: buildingId } = req.params;
  const result = await createExpenseService(buildingId, req.user.id, req.body);

  if (result.preview) {
    return res.status(200).json({
      success: true,
      data: result.preview,
    });
  }

  const message = result.warnings?.length
    ? result.warnings.join(" ")
    : "Gider kaydedildi.";

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
});

export const updateExpense = asyncHandler(async (req, res) => {
  const data = await updateExpenseService(
    req.params.expenseId,
    req.user.id,
    req.body
  );
  res.status(200).json({
    success: true,
    message: "Gider güncellendi.",
    data,
  });
});

export const deleteExpense = asyncHandler(async (req, res) => {
  const data = await deleteExpenseService(req.params.expenseId, req.user.id);
  res.status(200).json({
    success: true,
    message: "Gider silindi.",
    data,
  });
});

export const uploadExpenseProofs = asyncHandler(async (req, res) => {
  let files = [];
  if (req.files) {
    if (Array.isArray(req.files)) {
      files = req.files;
    } else {
      files = [
        ...(req.files.files || []),
        ...(req.files["files[]"] || []),
      ];
    }
  }

  if (files.length === 0) {
    return res.status(400).json({
      success: false,
      message: "En az bir makbuz dosyası gereklidir.",
    });
  }

  const data = await uploadExpenseProofsService(
    req.params.expenseId,
    req.user.id,
    files
  );

  res.status(200).json({
    success: true,
    message: data.ocrSummary?.message ?? "Makbuzlar başarıyla yüklendi.",
    data,
  });
});

/** @deprecated Tek dosya desteği için geriye uyumluluk — yeni kod uploadExpenseProofs kullanmalı. */
export const uploadExpenseProof = uploadExpenseProofs;

export const getExpenseFile = asyncHandler(async (req, res) => {
  const { expenseId } = req.params;
  const { storedPath, mimeType, filename, sizeBytes } = await getExpenseFileService(
    expenseId,
    req.user.id,
    req.user.role
  );

  const stream = createDekontReadStream(storedPath);

  res.setHeader("Content-Type", mimeType);
  if (sizeBytes) {
    res.setHeader("Content-Length", String(sizeBytes));
  }
  res.setHeader(
    "Content-Disposition",
    `inline; filename="${filename}"`
  );
  res.setHeader("Cache-Control", "private, no-store");

  stream.on("error", (err) => {
    logger.error({ type: "expense_file_stream", expenseId: req.params.expenseId, err: err?.message });
    if (res.headersSent) {
      res.end();
    } else {
      res.status(500).end();
    }
  });

  stream.pipe(res);
});

export const getMyExpenses = asyncHandler(async (req, res) => {
  const { month, year, category, cursor, limit, paginated } = req.query;
  const data = await listExpensesForResidentService(req.user.id, {
    month,
    year,
    category,
    cursor,
    limit,
    paginated,
  });
  res.status(200).json({ success: true, data });
});
