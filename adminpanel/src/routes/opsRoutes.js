import express from "express";
import { adminApi, cookieHeader } from "../services/apiClient.js";
import { renderPage } from "../utils/renderPage.js";

const router = express.Router();

router.get("/dekonts", async (req, res) => {
  const { status, lowConfidence, page = 1 } = req.query;
  const [summary, list] = await Promise.all([
    adminApi("/dekonts/summary", { cookies: cookieHeader(req) }),
    adminApi("/dekonts", {
      cookies: cookieHeader(req),
      query: { status, lowConfidence, page, limit: 25 },
    }),
  ]);

  await renderPage(res, "ops-dekonts-body", {
    title: "Dekont Operasyonları",
    admin: req.admin,
    summary: summary.json?.data || {},
    dekonts: list.json?.data?.items || [],
    pagination: list.json?.data || {},
    filters: { status, lowConfidence },
    currentPath: "/ops/dekonts",
    includeCharts: true,
  });
});

router.get("/tickets", async (req, res) => {
  const { moderation, page = 1 } = req.query;
  const [summary, list] = await Promise.all([
    adminApi("/tickets/summary", { cookies: cookieHeader(req) }),
    adminApi("/tickets", {
      cookies: cookieHeader(req),
      query: { moderation, page, limit: 25 },
    }),
  ]);

  await renderPage(res, "ops-tickets-body", {
    title: "Talep Moderasyonu",
    admin: req.admin,
    summary: summary.json?.data || {},
    tickets: list.json?.data?.items || [],
    pagination: list.json?.data || {},
    filters: { moderation },
    currentPath: "/ops/tickets",
    includeCharts: false,
  });
});

export default router;
