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
import { HttpError } from "../utils/httpError.js";
import { createDekontReadStream } from "../services/dekontStorageService.js";

const handleHttp = (err, res, next) => {
  if (err instanceof HttpError) {
    return res.status(err.statusCode).json({
      success: false,
      message: err.message,
    });
  }
  next(err);
};

export const getExpensesByBuilding = async (req, res, next) => {
  try {
    const { id: buildingId } = req.params;
    const { month, year, category } = req.query;
    const data = await listExpensesByBuildingService(buildingId, req.user.id, {
      month,
      year,
      category,
    });
    res.status(200).json({ success: true, data });
  } catch (err) {
    handleHttp(err, res, next);
  }
};

export const getExpenseSummary = async (req, res, next) => {
  try {
    const { id: buildingId } = req.params;
    const { month, year } = req.query;
    const data = await getExpenseSummaryService(buildingId, req.user.id, {
      month,
      year,
    });
    res.status(200).json({ success: true, data });
  } catch (err) {
    handleHttp(err, res, next);
  }
};

export const createExpense = async (req, res, next) => {
  try {
    const { id: buildingId } = req.params;
    // amount ve receiptUrl artık body'den alınmıyor — OCR'dan gelecek
    const { title, category, date, note } = req.body;
    const data = await createExpenseService(buildingId, req.user.id, {
      title,
      category,
      date,
      note,
    });
    res.status(201).json({
      success: true,
      message: "Gider kaydedildi.",
      data,
    });
  } catch (err) {
    handleHttp(err, res, next);
  }
};

export const updateExpense = async (req, res, next) => {
  try {
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
  } catch (err) {
    handleHttp(err, res, next);
  }
};

export const deleteExpense = async (req, res, next) => {
  try {
    const data = await deleteExpenseService(req.params.expenseId, req.user.id);
    res.status(200).json({
      success: true,
      message: "Gider silindi.",
      data,
    });
  } catch (err) {
    handleHttp(err, res, next);
  }
};

export const uploadExpenseProofs = async (req, res, next) => {
  try {
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
  } catch (err) {
    handleHttp(err, res, next);
  }
};

/** @deprecated Tek dosya desteği için geriye uyumluluk — yeni kod uploadExpenseProofs kullanmalı. */
export const uploadExpenseProof = uploadExpenseProofs;

export const getExpenseFile = async (req, res, next) => {
  try {
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
      console.error("[expense] file stream error", err);
      next(err);
    });

    stream.pipe(res);
  } catch (err) {
    handleHttp(err, res, next);
  }
};

export const getMyExpenses = async (req, res, next) => {
  try {
    const { month, year, category } = req.query;
    const data = await listExpensesForResidentService(req.user.id, {
      month,
      year,
      category,
    });
    res.status(200).json({ success: true, data });
  } catch (err) {
    handleHttp(err, res, next);
  }
};
