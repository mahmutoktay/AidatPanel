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
import { dekontLog, dekontLogError } from "../utils/dekontDebug.js";

const handleHttp = (err, res, next) => {
  if (err instanceof HttpError || (err?.name === "HttpError" && err?.statusCode)) {
    const body = {
      success: false,
      message: err.message,
    };
    if (err.data != null) {
      body.data = err.data;
    }
    return res.status(err.statusCode).json(body);
  }
  dekontLogError("dekont HTTP handler passthrough", err);
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
    dekontLogError("POST /dekonts/upload fail", err, { userId: req.user?.id });
    handleHttp(err, res, next);
  }
};

export const getDekontById = async (req, res, next) => {
  dekontLog("GET /dekonts/:id", {
    dekontId: req.params.id,
    userId: req.user?.id,
  });
  try {
    const data = await getDekontByIdForUser(req.params.id, req.user);
    dekontLog("GET /dekonts/:id ok", {
      dekontId: data?.id,
      status: data?.status,
    });
    res.status(200).json({ success: true, data });
  } catch (err) {
    dekontLogError("GET /dekonts/:id fail", err, { dekontId: req.params.id });
    handleHttp(err, res, next);
  }
};

export const getMyDekonts = async (req, res, next) => {
  dekontLog("GET /me/dekonts", {
    userId: req.user?.id,
    status: req.query?.status ?? null,
  });
  try {
    const data = await listDekontsForResident(req.user.id, req.query);
    const count = Array.isArray(data) ? data.length : data?.items?.length ?? 0;
    dekontLog("GET /me/dekonts ok", { count });
    res.status(200).json({ success: true, data });
  } catch (err) {
    dekontLogError("GET /me/dekonts fail", err);
    handleHttp(err, res, next);
  }
};

export const getDekontsByBuilding = async (req, res, next) => {
  dekontLog("GET /buildings/:id/dekonts", {
    buildingId: req.params.id,
    managerId: req.user?.id,
    status: req.query?.status ?? null,
    apartmentId: req.query?.apartmentId ?? null,
  });
  try {
    const data = await listDekontsForBuilding(
      req.params.id,
      req.user.id,
      req.query
    );
    const count = Array.isArray(data) ? data.length : data?.items?.length ?? 0;
    dekontLog("GET /buildings/:id/dekonts ok", { buildingId: req.params.id, count });
    res.status(200).json({ success: true, data });
  } catch (err) {
    dekontLogError("GET /buildings/:id/dekonts fail", err, {
      buildingId: req.params.id,
    });
    handleHttp(err, res, next);
  }
};

export const reviewDekont = async (req, res, next) => {
  dekontLog("PATCH /dekonts/:id/review", {
    dekontId: req.params.id,
    managerId: req.user?.id,
    decision: req.body?.decision,
    dueId: req.body?.dueId ?? null,
  });
  try {
    const data = await reviewDekontService(req.params.id, req.user.id, req.body);
    dekontLog("PATCH /dekonts/:id/review ok", {
      dekontId: data?.id,
      status: data?.status,
    });
    res.status(200).json({
      success: true,
      message: "Dekont güncellendi.",
      data,
    });
  } catch (err) {
    dekontLogError("PATCH /dekonts/:id/review fail", err, {
      dekontId: req.params.id,
    });
    handleHttp(err, res, next);
  }
};

export const getDekontFile = async (req, res, next) => {
  dekontLog("GET /dekonts/:id/file", {
    dekontId: req.params.id,
    userId: req.user?.id,
    download: req.query.download === "1",
  });
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

    stream.on("error", (err) => {
      dekontLogError("GET /dekonts/:id/file stream", err, {
        dekontId: req.params.id,
      });
      next(err);
    });
    dekontLog("GET /dekonts/:id/file stream-start", {
      dekontId: dekont.id,
      mimeType: dekont.mimeType,
      sizeBytes: dekont.sizeBytes,
    });
    stream.pipe(res);
  } catch (err) {
    dekontLogError("GET /dekonts/:id/file fail", err, { dekontId: req.params.id });
    handleHttp(err, res, next);
  }
};
