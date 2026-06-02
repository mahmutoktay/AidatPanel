import express from "express";
import { getMyDues } from "../controllers/dueController.js";
import { getMyTickets } from "../controllers/ticketController.js";
import { getMyDekonts } from "../controllers/dekontController.js";
import {
  getMe,
  getMyPaymentCollection,
  updateMe,
  deleteMe,
  updatePassword,
  updateLanguage,
  updateFcmToken,
} from "../controllers/meController.js";
import { authMiddleware } from "../middlewares/authMiddleware.js";
import { requireRoles } from "../middlewares/roleMiddleware.js";
import { validate, dueSchemas, meSchemas, ticketSchemas, dekontSchemas } from "../middlewares/validate.js";

const router = express.Router();

router.use(authMiddleware);

/** Profil / KVKK / FCM — MANAGER ve RESIDENT */
router.get("/", getMe);
router.put("/", validate(meSchemas.updateProfile), updateMe);
router.delete("/", deleteMe);
router.put("/password", validate(meSchemas.updatePassword), updatePassword);
router.put("/language", validate(meSchemas.updateLanguage), updateLanguage);
router.put("/fcm-token", validate(meSchemas.updateFcmToken), updateFcmToken);

/** GET /api/v1/me/payment-collection — sakin ödeme ekranı (IBAN, açıklama) */
router.get("/payment-collection", requireRoles("RESIDENT"), getMyPaymentCollection);

/** GET /api/v1/me/dues — yalnızca sakin */
router.get("/dues", requireRoles("RESIDENT"), validate(dueSchemas.myDues), getMyDues);

/** GET /api/v1/me/tickets — yalnızca sakin */
router.get("/tickets", requireRoles("RESIDENT"), validate(ticketSchemas.myTickets), getMyTickets);

/** GET /api/v1/me/dekonts — yalnızca sakin */
router.get("/dekonts", requireRoles("RESIDENT"), validate(dekontSchemas.myList), getMyDekonts);

export default router;
