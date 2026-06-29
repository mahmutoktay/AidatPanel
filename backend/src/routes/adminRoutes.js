import express from "express";
import {
  adminLogin,
  adminRefresh,
  adminLogout,
  adminMe,
  listUsers,
  getUser,
  resetUserPassword,
  closeUserAccount,
  listSubscriptions,
  grantSubscription,
  listPromos,
  createPromo,
  dekontSummary,
  listDekonts,
  listResidents,
  paymentHabits,
  dashboardKpis,
  activeUsers,
  listNotifications,
  readNotification,
  broadcastNotification,
  listAuditLogs,
  createBackup,
  listBackups,
  backupDownloadToken,
  downloadBackup,
} from "../controllers/adminController.js";
import { adminAuthMiddleware, requireSuperAdmin } from "../middlewares/adminAuthMiddleware.js";
import { adminAuthLimiter } from "../middlewares/adminRateLimitMiddleware.js";
import { strictLimiter } from "../middlewares/rateLimitMiddleware.js";
import { validate } from "../middlewares/validateMiddleware.js";
import { adminSchemas } from "../validators/adminSchemas.js";

const router = express.Router();

router.post("/auth/login", adminAuthLimiter, validate(adminSchemas.login), adminLogin);
router.post("/auth/refresh", validate(adminSchemas.refresh), adminRefresh);

router.use(adminAuthMiddleware);

router.post("/auth/logout", adminLogout);
router.get("/auth/me", adminMe);
router.get("/dashboard/kpis", dashboardKpis);

router.get("/users", validate(adminSchemas.listUsers), listUsers);
router.get("/users/:id", getUser);
router.post("/users/:id/reset-password", strictLimiter, resetUserPassword);
router.post("/users/:id/close-account", strictLimiter, requireSuperAdmin, validate(adminSchemas.closeAccount), closeUserAccount);

router.get("/subscriptions", listSubscriptions);
router.post("/subscriptions/:userId/grant", strictLimiter, validate(adminSchemas.grantSubscription), grantSubscription);

router.get("/promos", listPromos);
router.post("/promos", strictLimiter, validate(adminSchemas.createPromo), createPromo);

router.get("/dekonts/summary", dekontSummary);
router.get("/dekonts", validate(adminSchemas.listDekonts), listDekonts);

router.get("/residents", listResidents);
router.get("/residents/:id/payment-habits", paymentHabits);

router.get("/analytics/active-users", validate(adminSchemas.analytics), activeUsers);

router.get("/notifications", listNotifications);
router.patch("/notifications/:id/read", readNotification);
router.post("/notifications/broadcast", strictLimiter, validate(adminSchemas.broadcast), broadcastNotification);

router.get("/audit-logs", listAuditLogs);

router.post("/backups/create", requireSuperAdmin, strictLimiter, createBackup);
router.get("/backups", requireSuperAdmin, listBackups);
router.post("/backups/:id/download-token", requireSuperAdmin, strictLimiter, backupDownloadToken);
router.get("/backups/:id/download", requireSuperAdmin, downloadBackup);

export default router;
