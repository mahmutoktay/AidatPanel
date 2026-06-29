import express from "express";
import { adminApi, cookieHeader } from "../services/apiClient.js";
import { renderPage } from "../utils/renderPage.js";

const router = express.Router();

router.get("/", async (req, res) => {
  const cookies = cookieHeader(req);
  const [kpis, dekontSummary, notifications, activeUsers] = await Promise.all([
    adminApi("/dashboard/kpis", { cookies }),
    adminApi("/dekonts/summary", { cookies }),
    adminApi("/notifications", { cookies }),
    adminApi("/analytics/active-users", { cookies, query: { days: 14 } }),
  ]);

  await renderPage(res, "dashboard-body", {
    title: "Dashboard",
    admin: req.admin,
    kpis: kpis.json?.data || {},
    dekontSummary: dekontSummary.json?.data || {},
    notifications: notifications.json?.data || [],
    activeUsers: activeUsers.json?.data || [],
    currentPath: "/",
    includeCharts: true,
  });
});

router.get("/partials/kpis", async (req, res) => {
  const { json } = await adminApi("/dashboard/kpis", { cookies: cookieHeader(req) });
  res.render("partials/kpi-grid", { kpis: json?.data || {} });
});

export default router;
