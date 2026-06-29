import { asyncHandler } from "../utils/asyncHandler.js";
import {
  adminLoginService,
  adminRefreshService,
  getAdminProfileService,
  adminLogoutService,
} from "../services/admin/adminAuthService.js";
import {
  listAdminUsersService,
  getAdminUserDetailService,
  adminResetPasswordService,
  adminCloseAccountService,
} from "../services/admin/adminUserService.js";
import {
  listAdminSubscriptionsService,
  grantSubscriptionService,
  resolveUserByContact,
  listPromoGrantsService,
  createPromoGrantService,
} from "../services/admin/adminSubscriptionService.js";
import {
  getDekontSummaryService,
  listAdminDekontsService,
  listAdminResidentsService,
  getPaymentHabitsService,
  getDashboardKpisService,
} from "../services/admin/adminReportService.js";
import {
  getActiveUsersAnalytics,
  listAdminNotificationsService,
  markNotificationReadService,
  broadcastNotificationService,
} from "../services/admin/adminAnalyticsService.js";
import { listAdminAuditLogs } from "../services/admin/adminAuditService.js";
import {
  getDashboardAlertsService,
  getDashboardInsightsService,
  getDashboardSegmentsService,
  previewBroadcastSegmentService,
} from "../services/admin/adminDashboardService.js";
import {
  listHierarchyManagers,
  getHierarchyManagerDetail,
  getHierarchyBuildingDetail,
  getHierarchyApartmentDetail,
} from "../services/admin/adminHierarchyService.js";
import {
  createBackupService,
  listBackupsService,
  generateDownloadTokenService,
  streamBackupDownload,
} from "../services/admin/adminBackupService.js";
import { createReadStream } from "node:fs";

const isProduction = process.env.NODE_ENV === "production";

function setAdminCookies(res, { accessToken, refreshToken }) {
  const cookieOpts = {
    httpOnly: true,
    sameSite: "strict",
    secure: isProduction,
    path: "/",
  };
  res.cookie("admin_token", accessToken, { ...cookieOpts, maxAge: 15 * 60 * 1000 });
  res.cookie("admin_refresh", refreshToken, { ...cookieOpts, maxAge: 8 * 60 * 60 * 1000 });
}

function clearAdminCookies(res) {
  res.clearCookie("admin_token", { path: "/" });
  res.clearCookie("admin_refresh", { path: "/" });
}

function clientIp(req) {
  return req.ip || req.headers["x-forwarded-for"]?.split(",")[0]?.trim();
}

export const adminLogin = asyncHandler(async (req, res) => {
  const result = await adminLoginService({
    email: req.body.email,
    password: req.body.password,
    ipAddress: clientIp(req),
  });
  setAdminCookies(res, result);
  res.json({
    success: true,
    message: "Giriş başarılı.",
    data: {
      ...result.admin,
      accessToken: result.accessToken,
      refreshToken: result.refreshToken,
    },
  });
});

export const adminRefresh = asyncHandler(async (req, res) => {
  const refreshToken = req.body.refreshToken || req.cookies?.admin_refresh;
  const result = await adminRefreshService(refreshToken);
  setAdminCookies(res, result);
  res.json({ success: true, data: result.admin });
});

export const adminLogout = asyncHandler(async (req, res) => {
  await adminLogoutService(req.admin.id, clientIp(req));
  clearAdminCookies(res);
  res.json({ success: true, message: "Çıkış yapıldı." });
});

export const adminMe = asyncHandler(async (req, res) => {
  const admin = await getAdminProfileService(req.admin.id);
  res.json({ success: true, data: admin });
});

export const listUsers = asyncHandler(async (req, res) => {
  const data = await listAdminUsersService(req.query);
  res.json({ success: true, data });
});

export const getUser = asyncHandler(async (req, res) => {
  const data = await getAdminUserDetailService(req.admin.id, req.params.id, clientIp(req));
  res.json({ success: true, data });
});

export const resetUserPassword = asyncHandler(async (req, res) => {
  const data = await adminResetPasswordService(req.admin.id, req.params.id, clientIp(req));
  res.json({ success: true, message: "Şifre sıfırlama bağlantısı gönderildi.", data });
});

export const closeUserAccount = asyncHandler(async (req, res) => {
  await adminCloseAccountService(
    req.admin.id,
    req.params.id,
    req.body,
    req.admin.role,
    clientIp(req)
  );
  res.json({ success: true, message: "Hesap kapatıldı." });
});

export const listSubscriptions = asyncHandler(async (req, res) => {
  const data = await listAdminSubscriptionsService(req.query);
  res.json({ success: true, data });
});

export const grantSubscription = asyncHandler(async (req, res) => {
  const data = await grantSubscriptionService(req.admin.id, req.params.userId, req.body, clientIp(req));
  res.json({ success: true, message: "Abonelik tanımlandı.", data });
});

export const grantSubscriptionByContact = asyncHandler(async (req, res) => {
  const user = await resolveUserByContact(req.body.contact);
  const data = await grantSubscriptionService(req.admin.id, user.id, req.body, clientIp(req));
  res.json({ success: true, message: "Abonelik tanımlandı.", data });
});

export const listPromos = asyncHandler(async (req, res) => {
  const data = await listPromoGrantsService(req.query);
  res.json({ success: true, data });
});

export const createPromo = asyncHandler(async (req, res) => {
  const data = await createPromoGrantService(req.admin.id, req.body, clientIp(req));
  res.json({ success: true, message: "Promosyon oluşturuldu.", data });
});

export const dekontSummary = asyncHandler(async (req, res) => {
  const data = await getDekontSummaryService();
  res.json({ success: true, data });
});

export const listDekonts = asyncHandler(async (req, res) => {
  const data = await listAdminDekontsService(req.query);
  res.json({ success: true, data });
});

export const listResidents = asyncHandler(async (req, res) => {
  const data = await listAdminResidentsService(req.query);
  res.json({ success: true, data });
});

export const paymentHabits = asyncHandler(async (req, res) => {
  const data = await getPaymentHabitsService(req.params.id);
  res.json({ success: true, data });
});

export const dashboardKpis = asyncHandler(async (req, res) => {
  const data = await getDashboardKpisService();
  res.json({ success: true, data });
});

export const dashboardAlerts = asyncHandler(async (req, res) => {
  const data = await getDashboardAlertsService();
  res.json({ success: true, data });
});

export const dashboardInsights = asyncHandler(async (req, res) => {
  const data = await getDashboardInsightsService();
  res.json({ success: true, data });
});

export const dashboardSegments = asyncHandler(async (req, res) => {
  const data = await getDashboardSegmentsService();
  res.json({ success: true, data });
});

export const hierarchyManagers = asyncHandler(async (req, res) => {
  const data = await listHierarchyManagers(req.query);
  res.json({ success: true, data });
});

export const hierarchyManagerDetail = asyncHandler(async (req, res) => {
  const data = await getHierarchyManagerDetail(req.admin.id, req.params.id, clientIp(req));
  res.json({ success: true, data });
});

export const hierarchyBuildingDetail = asyncHandler(async (req, res) => {
  const data = await getHierarchyBuildingDetail(req.admin.id, req.params.id, clientIp(req));
  res.json({ success: true, data });
});

export const hierarchyApartmentDetail = asyncHandler(async (req, res) => {
  const data = await getHierarchyApartmentDetail(req.admin.id, req.params.id, clientIp(req));
  res.json({ success: true, data });
});

export const previewBroadcast = asyncHandler(async (req, res) => {
  const data = await previewBroadcastSegmentService(req.body.segment);
  res.json({ success: true, data });
});

export const activeUsers = asyncHandler(async (req, res) => {
  const data = await getActiveUsersAnalytics(req.query);
  res.json({ success: true, data });
});

export const listNotifications = asyncHandler(async (req, res) => {
  const data = await listAdminNotificationsService(req.admin.id, {
    unreadOnly: req.query.unreadOnly === "true",
  });
  res.json({ success: true, data });
});

export const readNotification = asyncHandler(async (req, res) => {
  const data = await markNotificationReadService(req.admin.id, req.params.id);
  res.json({ success: true, data });
});

export const broadcastNotification = asyncHandler(async (req, res) => {
  const data = await broadcastNotificationService(req.admin.id, req.body, clientIp(req));
  res.json({ success: true, message: "Yayın kaydedildi.", data });
});

export const listAuditLogs = asyncHandler(async (req, res) => {
  const data = await listAdminAuditLogs(req.query);
  res.json({ success: true, data });
});

export const createBackup = asyncHandler(async (req, res) => {
  const data = await createBackupService(req.admin.id, clientIp(req));
  res.json({ success: true, message: "Yedekleme başlatıldı.", data });
});

export const listBackups = asyncHandler(async (req, res) => {
  const data = await listBackupsService();
  res.json({ success: true, data });
});

export const backupDownloadToken = asyncHandler(async (req, res) => {
  const data = await generateDownloadTokenService(req.admin.id, req.params.id, clientIp(req));
  res.json({ success: true, data });
});

export const downloadBackup = asyncHandler(async (req, res) => {
  const { filepath, filename } = await streamBackupDownload(req.params.id, req.query.token);
  res.setHeader("Content-Type", "application/gzip");
  res.setHeader("Content-Disposition", `attachment; filename="${filename}"`);
  createReadStream(filepath).pipe(res);
});
