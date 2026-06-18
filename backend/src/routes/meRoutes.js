import express from "express";
import { getMyDues } from "../controllers/dueController.js";
import { getMyTickets } from "../controllers/ticketController.js";
import { getMyDekonts } from "../controllers/dekontController.js";
import { getMyExpenses } from "../controllers/expenseController.js";
import {
  getMe,
  getMyPaymentCollection,
  updateMe,
  deleteMe,
  updatePassword,
  updateLanguage,
  updateFcmToken,
  uploadProfilePicture,
  deleteProfilePicture,
} from "../controllers/meController.js";
import { getMySubscription } from "../controllers/subscriptionController.js";
import { getMySessions, revokeMySession } from "../controllers/sessionController.js";
import { authMiddleware } from "../middlewares/authMiddleware.js";
import { requireRoles } from "../middlewares/roleMiddleware.js";
import { validate, dueSchemas, meSchemas, ticketSchemas, dekontSchemas } from "../middlewares/validate.js";
import multer from "multer";

const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 5 * 1024 * 1024 }, // 5MB
  fileFilter: (_req, file, cb) => {
    const allowedMimes = ["image/jpeg", "image/png", "image/gif"];
    if (allowedMimes.includes(file.mimetype)) {
      cb(null, true);
    } else {
      cb(new Error("Desteklenmeyen dosya türü. Sadece JPG, PNG veya GIF yükleyebilirsiniz."));
    }
  }
});

const router = express.Router();

router.use(authMiddleware);

/** Profil / KVKK / FCM — MANAGER ve RESIDENT */
router.get("/", getMe);
router.put("/", validate(meSchemas.updateProfile), updateMe);
router.delete("/", deleteMe);
router.put("/password", validate(meSchemas.updatePassword), updatePassword);
router.put("/language", validate(meSchemas.updateLanguage), updateLanguage);
router.put("/fcm-token", validate(meSchemas.updateFcmToken), updateFcmToken);

/** Aktif cihaz oturumları — MANAGER ve RESIDENT */
router.get("/sessions", getMySessions);
router.delete("/sessions/:sessionId", revokeMySession);

/** GET /api/v1/me/subscription — yönetici abonelik durumu (FAZ 6) */
router.get("/subscription", requireRoles("MANAGER"), getMySubscription);

/** GET /api/v1/me/payment-collection — sakin ödeme ekranı (IBAN, açıklama) */
router.get("/payment-collection", requireRoles("RESIDENT"), getMyPaymentCollection);

/** GET /api/v1/me/dues — yalnızca sakin */
router.get("/dues", requireRoles("RESIDENT"), validate(dueSchemas.myDues), getMyDues);

/** GET /api/v1/me/expenses — yalnızca sakin */
router.get("/expenses", requireRoles("RESIDENT"), validate(meSchemas.myExpenses), getMyExpenses);

/** GET /api/v1/me/tickets — yalnızca sakin */
router.get("/tickets", requireRoles("RESIDENT"), validate(ticketSchemas.myTickets), getMyTickets);

/** GET /api/v1/me/dekonts — yalnızca sakin */
router.get("/dekonts", requireRoles("RESIDENT"), validate(dekontSchemas.myList), getMyDekonts);

/** Profil Fotoğrafı Yükleme / Silme */
router.post(
  "/profile-picture",
  (req, res, next) => {
    upload.single("file")(req, res, (err) => {
      if (err) {
        return res.status(400).json({ success: false, message: err.message });
      }
      next();
    });
  },
  uploadProfilePicture
);

router.delete("/profile-picture", deleteProfilePicture);

export default router;
