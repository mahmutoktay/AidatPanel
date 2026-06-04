import express from "express";
import fs from "fs";
import path from "path";
import crypto from "crypto";
import multer from "multer";
import { authMiddleware } from "../middlewares/authMiddleware.js";
import { requireRoles } from "../middlewares/roleMiddleware.js";
import { validate, dekontSchemas } from "../middlewares/validate.js";
import { dekontUploadLimiter } from "../middlewares/rateLimitMiddleware.js";
import {
  uploadDekont,
  getDekontById,
  getDekontFile,
  reviewDekont,
} from "../controllers/dekontController.js";
import {
  DEKONT_MAX_BYTES,
  DEKONT_ALLOWED_MIMES,
  DEKONT_UPLOAD_TMP_DIR,
} from "../config/dekont.js";
import { extensionForMime } from "../services/dekontStorage/local.js";

const upload = multer({
  storage: multer.diskStorage({
    destination: (_req, _file, cb) => {
      fs.mkdir(DEKONT_UPLOAD_TMP_DIR, { recursive: true }, (err) => {
        cb(err, DEKONT_UPLOAD_TMP_DIR);
      });
    },
    filename: (_req, file, cb) => {
      const ext =
        extensionForMime(file.mimetype) ||
        path.extname(file.originalname || "") ||
        ".bin";
      cb(null, `${crypto.randomUUID()}${ext}`);
    },
  }),
  limits: { fileSize: DEKONT_MAX_BYTES },
  fileFilter: (_req, file, cb) => {
    if (DEKONT_ALLOWED_MIMES.has(file.mimetype)) {
      cb(null, true);
      return;
    }
    cb(new Error("Desteklenmeyen dosya türü. PDF veya JPEG/PNG yükleyin."));
  },
});

const router = express.Router();

router.use(authMiddleware);

router.post(
  "/upload",
  dekontUploadLimiter,
  requireRoles("RESIDENT", "MANAGER"),
  (req, res, next) => {
    upload.single("file")(req, res, (err) => {
      if (err) {
        console.error("[dekont] multer hata", err?.message || err);
        return next(err);
      }
      next();
    });
  },
  validate(dekontSchemas.upload),
  uploadDekont
);

router.get(
  "/:id/file",
  validate(dekontSchemas.getFile),
  getDekontFile
);

router.get("/:id", validate(dekontSchemas.getById), getDekontById);

router.patch(
  "/:id/review",
  requireRoles("MANAGER"),
  validate(dekontSchemas.review),
  reviewDekont
);

export default router;
