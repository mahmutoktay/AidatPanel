import express from "express";
import { logger } from "../config/logger.js";
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
import { createDiskUpload } from "../utils/createMulterUpload.js";

const upload = createDiskUpload();
const router = express.Router();

router.use(authMiddleware);

router.post(
  "/upload",
  dekontUploadLimiter,
  requireRoles("RESIDENT", "MANAGER"),
  (req, res, next) => {
    upload.single("file")(req, res, (err) => {
      if (err) {
        logger.error({ type: "dekont_multer_error", err: err?.message || String(err) });
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
