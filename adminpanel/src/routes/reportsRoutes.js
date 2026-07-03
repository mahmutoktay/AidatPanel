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

  await renderPage(res, "dekonts-body", {
    title: "Dekont Raporları",
    admin: req.admin,
    summary: summary.json?.data || {},
    dekonts: list.json?.data?.items || [],
    pagination: list.json?.data || {},
    filters: { status, lowConfidence },
    currentPath: "/reports/dekonts",
    includeCharts: true,
  });
});

router.get("/residents", async (req, res) => {
  const { q, page = 1 } = req.query;
  const { json } = await adminApi("/residents", {
    cookies: cookieHeader(req),
    query: { q, page, limit: 25 },
  });

  await renderPage(res, "residents-body", {
    title: "Sakinler",
    admin: req.admin,
    residents: json?.data?.items || [],
    pagination: json?.data || {},
    filters: { q },
    currentPath: "/reports/residents",
  });
});

router.get("/residents/:id/habits", async (req, res) => {
  const { json, ok } = await adminApi(`/residents/${req.params.id}/payment-habits`, {
    cookies: cookieHeader(req),
  });
  if (!ok) return res.redirect("/reports/residents");

  await renderPage(res, "payment-habits-body", {
    title: "Ödeme Alışkanlığı",
    admin: req.admin,
    habits: json.data,
    currentPath: "/reports/residents",
  });
});

export default router;
