import express from "express";
import { adminApi, cookieHeader } from "../services/apiClient.js";
import { renderPage } from "../utils/renderPage.js";

const router = express.Router();

router.get("/", async (req, res) => {
  const { period = "day", role, days = 30 } = req.query;
  const [analytics, notifications] = await Promise.all([
    adminApi("/analytics/active-users", {
      cookies: cookieHeader(req),
      query: { period, role, days },
    }),
    adminApi("/notifications", { cookies: cookieHeader(req) }),
  ]);

  await renderPage(res, "analytics-body", {
    title: "Analitik & Bildirimler",
    admin: req.admin,
    analytics: analytics.json?.data || [],
    notifications: notifications.json?.data || [],
    filters: { period, role, days },
    currentPath: "/analytics",
    includeCharts: true,
  });
});

router.post("/broadcast", async (req, res) => {
  const { title, body, segmentRole, segmentPlan, segmentCity, expiringWithinDays } = req.body;
  await adminApi("/notifications/broadcast", {
    method: "POST",
    cookies: cookieHeader(req),
    body: {
      title,
      body,
      segment: {
        role: segmentRole || undefined,
        plan: segmentPlan || undefined,
        city: segmentCity || undefined,
        expiringWithinDays: expiringWithinDays ? Number(expiringWithinDays) : undefined,
      },
    },
  });
  res.redirect("/analytics?msg=sent");
});

router.post("/preview-segment", async (req, res) => {
  const { segmentRole, segmentPlan, segmentCity } = req.body;
  const { json, ok } = await adminApi("/notifications/preview", {
    method: "POST",
    cookies: cookieHeader(req),
    body: {
      segment: {
        role: segmentRole || undefined,
        plan: segmentPlan || undefined,
        city: segmentCity || undefined,
      },
    },
  });
  res.status(ok ? 200 : 400).json(json);
});

export default router;
