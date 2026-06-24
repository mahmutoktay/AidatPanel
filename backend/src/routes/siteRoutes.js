import express from "express";
import {
  createSite,
  getSites,
  getSiteById,
  updateSite,
  patchSiteCollection,
  deleteSite,
  createSiteBuilding,
  getSiteBuildings,
} from "../controllers/siteController.js";
import {
  getSiteExpenses,
  getSiteExpenseSummary,
  createSiteExpense,
} from "../controllers/siteExpenseController.js";
import { getSiteReport } from "../controllers/reportController.js";
import { authMiddleware } from "../middlewares/authMiddleware.js";
import { requireRoles } from "../middlewares/roleMiddleware.js";
import {
  validate,
  siteSchemas,
  siteExpenseSchemas,
  reportSchemas,
} from "../middlewares/validate.js";

const router = express.Router();

router.use(authMiddleware);
router.use(requireRoles("MANAGER"));

router.post("/", validate(siteSchemas.create), createSite);
router.get("/", validate(siteSchemas.list), getSites);

router.patch(
  "/:id/collection",
  validate(siteSchemas.updateCollection),
  patchSiteCollection
);
router.get(
  "/:id/buildings",
  validate(siteSchemas.listBuildings),
  getSiteBuildings
);
router.post(
  "/:id/buildings",
  validate(siteSchemas.createBuilding),
  createSiteBuilding
);
router.get(
  "/:id/expenses/summary",
  validate(siteExpenseSchemas.summaryBySite),
  getSiteExpenseSummary
);
router.get(
  "/:id/reports",
  validate(reportSchemas.siteReport),
  getSiteReport
);
router.get(
  "/:id/expenses",
  validate(siteExpenseSchemas.listBySite),
  getSiteExpenses
);
router.post(
  "/:id/expenses",
  validate(siteExpenseSchemas.create),
  createSiteExpense
);

router.get("/:id", validate(siteSchemas.getById), getSiteById);
router.put("/:id", validate(siteSchemas.update), updateSite);
router.delete("/:id", validate(siteSchemas.delete), deleteSite);

export default router;
