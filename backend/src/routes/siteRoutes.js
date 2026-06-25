import express from "express";
import {
  createSite,
  getSites,
  getSiteById,
  updateSite,
  deleteSite,
  createSiteBuilding,
  getSiteBuildings,
  getSiteAggregation,
} from "../controllers/siteController.js";
import { patchSiteCollection } from "../controllers/siteCollectionController.js";
import { getSiteReport } from "../controllers/siteReportController.js";
import {
  getSiteExpenses,
  createSiteExpense,
  updateSiteExpense,
  deleteSiteExpense,
  getSiteExpenseSummary,
} from "../controllers/siteExpenseController.js";
import { authMiddleware } from "../middlewares/authMiddleware.js";
import { requireRoles } from "../middlewares/roleMiddleware.js";
import { validate, siteSchemas } from "../middlewares/validate.js";

const router = express.Router();

router.use(authMiddleware);
router.use(requireRoles("MANAGER"));

router.post("/", validate(siteSchemas.create), createSite);
router.get("/", getSites);
router.get("/:id", validate(siteSchemas.getById), getSiteById);
router.put("/:id", validate(siteSchemas.update), updateSite);
router.delete("/:id", validate(siteSchemas.delete), deleteSite);
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
  validate(siteSchemas.createSiteBuilding),
  createSiteBuilding
);
router.get(
  "/:id/aggregation",
  validate(siteSchemas.aggregation),
  getSiteAggregation
);
router.get(
  "/:id/reports",
  validate(siteSchemas.siteReport),
  getSiteReport
);
router.get(
  "/:id/expenses",
  validate(siteSchemas.siteExpenses),
  getSiteExpenses
);
router.get(
  "/:id/expenses/summary",
  validate(siteSchemas.siteExpenses),
  getSiteExpenseSummary
);
router.post(
  "/:id/expenses",
  validate(siteSchemas.createSiteExpense),
  createSiteExpense
);
router.put(
  "/:siteId/expenses/:expenseId",
  validate(siteSchemas.updateSiteExpense),
  updateSiteExpense
);
router.delete(
  "/:siteId/expenses/:expenseId",
  validate(siteSchemas.deleteSiteExpense),
  deleteSiteExpense
);

export default router;
