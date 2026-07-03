import express from "express";
import { adminApi, cookieHeader } from "../services/apiClient.js";
import { renderPage } from "../utils/renderPage.js";

const router = express.Router();

router.get("/", async (req, res) => {
  const cookies = cookieHeader(req);
  const [alertsRes, insightsRes, segmentsRes, activeUsersRes] = await Promise.all([
    adminApi("/dashboard/alerts", { cookies }),
    adminApi("/dashboard/insights", { cookies }),
    adminApi("/dashboard/segments", { cookies }),
    adminApi("/analytics/active-users", { cookies, query: { days: 14 } }),
  ]);

  await renderPage(res, "dashboard-body", {
    title: "Komuta Merkezi",
    admin: req.admin,
    alerts: alertsRes.json?.data ?? [],
    insights: insightsRes.json?.data ?? {},
    segments: segmentsRes.json?.data ?? {},
    activeUsers: activeUsersRes.json?.data ?? [],
    currentPath: "/",
    includeCharts: true,
  });
});

export default router;
