import { Router } from "express";
import { authMiddleware } from "../middlewares/authMiddleware.js";
import { requireRoles } from "../middlewares/roleMiddleware.js";
import { validate, expenseSchemas } from "../middlewares/validate.js";
import { createDiskUpload } from "../utils/createMulterUpload.js";
import { logger } from "../config/logger.js";
import {
  updateExpense,
  deleteExpense,
  uploadExpenseProofs,
  getExpenseFile,
} from "../controllers/expenseController.js";

const upload = createDiskUpload({ filenamePrefix: "exp_" });
const router = Router();

router.use(authMiddleware);

// Gider makbuzu indirme rotaları hem sakine hem yöneticiye açıktır
router.get("/:expenseId/file", getExpenseFile);
router.get("/:expenseId/file/:filename", getExpenseFile);

router.use(requireRoles("MANAGER"));

router.put("/:expenseId", validate(expenseSchemas.update), updateExpense);
router.delete("/:expenseId", validate(expenseSchemas.delete), deleteExpense);

router.post(
  "/:expenseId/proof",
  (req, res, next) => {
    upload.fields([
      { name: "files", maxCount: 10 },
      { name: "files[]", maxCount: 10 },
    ])(req, res, (err) => {
      if (err) {
        logger.error({ type: "expense_multer_error", err: err?.message || String(err) });
        return next(err);
      }
      next();
    });
  },
  validate(expenseSchemas.uploadProof),
  uploadExpenseProofs
);

export default router;
