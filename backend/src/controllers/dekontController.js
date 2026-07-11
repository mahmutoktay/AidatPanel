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
import { dekontLog, dekontLogError } from "../utils/dekontDebug.js";
import { parseDueIdsFromBody } from "../utils/duePaymentTotals.js";
import { asyncHandler } from "../utils/asyncHandler.js";

export const uploadDekont = asyncHandler(async (req, res) => {
  if (!req.file) {
    return res.status(400).json({
      success: false,
      message: "Dosya gereklidir.",
    });
  }

  const dueIds = parseDueIdsFromBody(req.body);
  const data = await createDekontFromUpload(req.user, req.file, {
    dueId: dueIds[0],
    dueIds,
  });

  res.status(201).json({
    success: true,
    message: "Dekont alındı, doğrulama başlatıldı.",
    data,
  });
});

export const getDekontById = asyncHandler(async (req, res) => {
  dekontLog("GET /dekonts/:id", {
    dekontId: req.params.id,
    userId: req.user?.id,
  });
  const data = await getDekontByIdForUser(req.params.id, req.user);
  dekontLog("GET /dekonts/:id ok", {
    dekontId: data?.id,
    status: data?.status,
  });
  res.status(200).json({ success: true, data });
});

export const getMyDekonts = asyncHandler(async (req, res) => {
  dekontLog("GET /me/dekonts", {
    userId: req.user?.id,
    status: req.query?.status ?? null,
  });
  const data = await listDekontsForResident(req.user.id, req.query);
  const count = Array.isArray(data) ? data.length : data?.items?.length ?? 0;
  dekontLog("GET /me/dekonts ok", { count });
  res.status(200).json({ success: true, data });
});

export const getDekontsByBuilding = asyncHandler(async (req, res) => {
  dekontLog("GET /buildings/:id/dekonts", {
    buildingId: req.params.id,
    managerId: req.user?.id,
    status: req.query?.status ?? null,
    apartmentId: req.query?.apartmentId ?? null,
  });
  const data = await listDekontsForBuilding(
    req.params.id,
    req.user.id,
    req.query
  );
  const count = Array.isArray(data) ? data.length : data?.items?.length ?? 0;
  dekontLog("GET /buildings/:id/dekonts ok", { buildingId: req.params.id, count });
  res.status(200).json({ success: true, data });
});

export const reviewDekont = asyncHandler(async (req, res) => {
  dekontLog("PATCH /dekonts/:id/review", {
    dekontId: req.params.id,
    managerId: req.user?.id,
    decision: req.body?.decision,
    dueId: req.body?.dueId ?? null,
    dueIds: req.body?.dueIds ?? null,
    amount: req.body?.amount ?? null,
  });
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
});

export const getDekontFile = asyncHandler(async (req, res) => {
  dekontLog("GET /dekonts/:id/file", {
    dekontId: req.params.id,
    userId: req.user?.id,
    download: req.query.download === "1",
  });
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
    if (res.headersSent) {
      res.end();
    } else {
      res.status(500).end();
    }
  });
  dekontLog("GET /dekonts/:id/file stream-start", {
    dekontId: dekont.id,
    mimeType: dekont.mimeType,
    sizeBytes: dekont.sizeBytes,
  });
  stream.pipe(res);
});
