import { Router } from "express";
import { authMiddleware } from "../middlewares/authMiddleware.js";
import { requireRoles } from "../middlewares/roleMiddleware.js";
import { validate, siteExpenseSchemas } from "../middlewares/validate.js";
import {
  updateSiteExpense,
  deleteSiteExpense,
} from "../controllers/siteExpenseController.js";

const router = Router();

router.use(authMiddleware);
router.use(requireRoles("MANAGER"));

router.put(
  "/:expenseId",
  validate(siteExpenseSchemas.update),
  updateSiteExpense
);
router.delete(
  "/:expenseId",
  validate(siteExpenseSchemas.delete),
  deleteSiteExpense
);

export default router;
