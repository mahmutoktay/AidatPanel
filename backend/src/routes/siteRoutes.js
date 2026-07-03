import express from "express";
import {
  createSite,
  getSites,
  getSiteById,
  updateSite,
<<<<<<< HEAD
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
=======
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
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6

const router = express.Router();

router.use(authMiddleware);
router.use(requireRoles("MANAGER"));

router.post("/", validate(siteSchemas.create), createSite);
<<<<<<< HEAD
router.get("/", validate(siteSchemas.list), getSites);

=======
router.get("/", getSites);
router.get("/:id", validate(siteSchemas.getById), getSiteById);
router.put("/:id", validate(siteSchemas.update), updateSite);
router.delete("/:id", validate(siteSchemas.delete), deleteSite);
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
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
<<<<<<< HEAD
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
=======
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
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
  getSiteReport
);
router.get(
  "/:id/expenses",
<<<<<<< HEAD
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
=======
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
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6

export default router;
