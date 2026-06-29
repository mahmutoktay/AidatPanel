import express from "express";
import { adminApi, cookieHeader } from "../services/apiClient.js";
import { renderPage } from "../utils/renderPage.js";

const router = express.Router();

router.get("/", async (req, res) => {
  const { plan, status, platform, city, expiringWithinDays, page = 1 } = req.query;
  const [subs, promos] = await Promise.all([
    adminApi("/subscriptions", {
      cookies: cookieHeader(req),
      query: { plan, status, platform, city, expiringWithinDays, page, limit: 25 },
    }),
    adminApi("/promos", { cookies: cookieHeader(req), query: { page: 1, limit: 10 } }),
  ]);

  await renderPage(res, "subscriptions-body", {
    title: "Abonelikler",
    admin: req.admin,
    subscriptions: subs.json?.data?.items || [],
    pagination: subs.json?.data || {},
    promos: promos.json?.data?.items || [],
    filters: { plan, status, platform, city, expiringWithinDays },
    currentPath: "/subscriptions",
  });
});

router.post("/grant", async (req, res) => {
  const { userId, durationDays, plan, reason } = req.body;
  await adminApi(`/subscriptions/${userId}/grant`, {
    method: "POST",
    cookies: cookieHeader(req),
    body: { durationDays: Number(durationDays), plan, reason },
  });
  res.redirect("/subscriptions?msg=granted");
});

router.post("/promos", async (req, res) => {
  await adminApi("/promos", {
    method: "POST",
    cookies: cookieHeader(req),
    body: {
      userId: req.body.userId,
      type: req.body.type,
      plan: req.body.plan,
      durationDays: req.body.durationDays ? Number(req.body.durationDays) : undefined,
      discountPercent: req.body.discountPercent ? Number(req.body.discountPercent) : undefined,
      reason: req.body.reason,
    },
  });
  res.redirect("/subscriptions?msg=promo");
});

export default router;
