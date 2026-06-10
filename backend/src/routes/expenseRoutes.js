import { Router } from "express";
import { authMiddleware } from "../middlewares/authMiddleware.js";
import { requireRoles } from "../middlewares/roleMiddleware.js";
import { validate, expenseSchemas } from "../middlewares/validate.js";
import { updateExpense, deleteExpense, uploadExpenseProof } from "../controllers/expenseController.js";
import multer from "multer";
import fs from "fs";
import path from "path";
import crypto from "crypto";
import { DEKONT_MAX_BYTES, DEKONT_ALLOWED_MIMES, DEKONT_UPLOAD_TMP_DIR } from "../config/dekont.js";
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
      cb(null, `exp_${crypto.randomUUID()}${ext}`);
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
});const router = Router();

router.use(authMiddleware);
router.use(requireRoles("MANAGER"));

router.put("/:expenseId", validate(expenseSchemas.update), updateExpense);
router.delete("/:expenseId", validate(expenseSchemas.delete), deleteExpense);

router.post(
  "/:expenseId/proof",
  (req, res, next) => {
    upload.single("file")(req, res, (err) => {
      if (err) {
        console.error("[expense] multer hata", err?.message || err);
        return next(err);
      }
      next();
    });
  },
  validate(expenseSchemas.uploadProof),
  uploadExpenseProof
);

export default router;
