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
import { authMiddleware } from "../middlewares/authMiddleware.js";
import { requireRoles } from "../middlewares/roleMiddleware.js";
import { validate, siteSchemas } from "../middlewares/validate.js";

const router = express.Router();

router.use(authMiddleware);
router.use(requireRoles("MANAGER"));

router.post("/", validate(siteSchemas.create), createSite);
router.get("/", validate(siteSchemas.list), getSites);
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
  validate(siteSchemas.createBuilding),
  createSiteBuilding
);

export default router;
