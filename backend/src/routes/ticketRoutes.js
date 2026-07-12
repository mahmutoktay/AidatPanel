import { Router } from "express";
import multer from "multer";
import { authMiddleware } from "../middlewares/authMiddleware.js";
import { requireRoles } from "../middlewares/roleMiddleware.js";
import { validate, ticketSchemas } from "../middlewares/validate.js";
import { logger } from "../config/logger.js";
import {
  getTicketById,
  addTicketUpdate,
  patchTicketStatus,
  uploadTicketAttachment,
} from "../controllers/ticketController.js";

const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 5 * 1024 * 1024 },
  fileFilter: (_req, file, cb) => {
    const allowedMimes = ["image/jpeg", "image/png"];
    if (allowedMimes.includes(file.mimetype)) {
      cb(null, true);
    } else {
      cb(new Error("Desteklenmeyen dosya türü. Sadece JPG veya PNG yükleyebilirsiniz."));
    }
  },
});

const router = Router();

router.use(authMiddleware);

router.get(
  "/:ticketId",
  validate(ticketSchemas.getById),
  getTicketById
);

router.post(
  "/:ticketId/attachment",
  requireRoles("RESIDENT"),
  (req, res, next) => {
    upload.single("file")(req, res, (err) => {
      if (err) {
        logger.error({ type: "ticket_multer_error", err: err?.message || String(err) });
        return next(err);
      }
      next();
    });
  },
  validate(ticketSchemas.uploadAttachment),
  uploadTicketAttachment
);

router.post(
  "/:ticketId/updates",
  requireRoles("MANAGER"),
  validate(ticketSchemas.addUpdate),
  addTicketUpdate
);

router.patch(
  "/:ticketId/status",
  requireRoles("MANAGER"),
  validate(ticketSchemas.updateStatus),
  patchTicketStatus
);

export default router;
