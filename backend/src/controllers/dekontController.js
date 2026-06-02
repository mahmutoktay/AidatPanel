import {
  createDekontFromUpload,
  getDekontByIdForUser,
  listDekontsForResident,
  listDekontsForBuilding,
  reviewDekont as reviewDekontService,
  getDekontFileForUser,
} from "../services/dekontService.js";
import {
  createDekontReadStream,
  safeDekontFilename,
} from "../services/dekontStorageService.js";
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

export const uploadDekont = async (req, res, next) => {
  try {
    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: "Dosya gereklidir.",
      });
    }

    const data = await createDekontFromUpload(req.user, req.file, {
      dueId: req.body.dueId,
    });

    res.status(201).json({
      success: true,
      message: "Dekont alındı, doğrulama başlatıldı.",
      data,
    });
  } catch (err) {
    handleHttp(err, res, next);
  }
};

export const getDekontById = async (req, res, next) => {
  try {
    const data = await getDekontByIdForUser(req.params.id, req.user);
    res.status(200).json({ success: true, data });
  } catch (err) {
    handleHttp(err, res, next);
  }
};

export const getMyDekonts = async (req, res, next) => {
  try {
    const data = await listDekontsForResident(req.user.id, req.query);
    res.status(200).json({ success: true, data });
  } catch (err) {
    handleHttp(err, res, next);
  }
};

export const getDekontsByBuilding = async (req, res, next) => {
  try {
    const data = await listDekontsForBuilding(
      req.params.id,
      req.user.id,
      req.query
    );
    res.status(200).json({ success: true, data });
  } catch (err) {
    handleHttp(err, res, next);
  }
};

export const reviewDekont = async (req, res, next) => {
  try {
    const data = await reviewDekontService(req.params.id, req.user.id, req.body);
    res.status(200).json({
      success: true,
      message: "Dekont güncellendi.",
      data,
    });
  } catch (err) {
    handleHttp(err, res, next);
  }
};

export const getDekontFile = async (req, res, next) => {
  try {
    const dekont = await getDekontFileForUser(req.params.id, req.user);
    const inline = req.query.download !== "1";
    const filename = safeDekontFilename(dekont);
    const stream = createDekontReadStream(dekont.storedPath);

    res.setHeader("Content-Type", dekont.mimeType);
    res.setHeader("Content-Length", String(dekont.sizeBytes));
    res.setHeader(
      "Content-Disposition",
      `${inline ? "inline" : "attachment"}; filename="${filename}"`
    );
    res.setHeader("Cache-Control", "private, no-store");

    stream.on("error", (err) => next(err));
    stream.pipe(res);
  } catch (err) {
    handleHttp(err, res, next);
  }
};
