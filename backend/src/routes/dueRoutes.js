import express from "express";
import {
  getDuesByBuilding,
  updateDueStatus,
  getMyDues,
  updateBuildingDueAmount,
} from "../controllers/dueController.js";

import { authMiddleware } from "../middlewares/authMiddleware.js";
import { validate, dueSchemas } from "../middlewares/validate.js";

const router = express.Router();

router.use(authMiddleware);

// Sakin: Kendi aidatlarım
router.get("/me", getMyDues);

// Yönetici: Binanın aidat bedelini güncelle
router.patch(
  "/buildings/:buildingId/amount",
  validate(dueSchemas.updateAmount),
  updateBuildingDueAmount
);

// Yönetici: Binadaki tüm aidatları listele
router.get(
  "/buildings/:buildingId",
  validate(dueSchemas.getByBuilding),
  getDuesByBuilding
);

// Yönetici: Aidat durumu güncelle
router.patch("/:dueId/status", validate(dueSchemas.updateStatus), updateDueStatus);

export default router;
