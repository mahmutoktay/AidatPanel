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
    title: "Büyüme & Abonelik",
    admin: req.admin,
    subscriptions: subs.json?.data?.items || [],
    pagination: subs.json?.data || {},
    promos: promos.json?.data?.items || [],
    filters: { plan, status, platform, city, expiringWithinDays },
    currentPath: "/growth",
  });
});

router.post("/grant", async (req, res) => {
  const { contact, durationDays, plan, reason } = req.body;
  const result = await adminApi("/subscriptions/grant", {
    method: "POST",
    cookies: cookieHeader(req),
    body: { contact, durationDays: Number(durationDays), plan, reason },
  });
  if (!result.ok) {
    return res.redirect(`/growth?msg=error&detail=${encodeURIComponent(result.json?.message || "İşlem başarısız")}`);
  }
  res.redirect("/growth?msg=granted");
});

router.post("/promos", async (req, res) => {
  const result = await adminApi("/promos", {
    method: "POST",
    cookies: cookieHeader(req),
    body: {
      contact: req.body.contact,
      type: req.body.type,
      plan: req.body.plan,
      durationDays: req.body.durationDays ? Number(req.body.durationDays) : undefined,
      discountPercent: req.body.discountPercent ? Number(req.body.discountPercent) : undefined,
      reason: req.body.reason,
    },
  });
  if (!result.ok) {
    return res.redirect(`/growth?msg=error&detail=${encodeURIComponent(result.json?.message || "İşlem başarısız")}`);
  }
  res.redirect("/growth?msg=promo");
});

export default router;
