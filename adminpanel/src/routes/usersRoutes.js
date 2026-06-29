import express from "express";
import { adminApi, cookieHeader } from "../services/apiClient.js";
import { renderPage } from "../utils/renderPage.js";

const router = express.Router();

router.get("/", async (req, res) => {
  const { q, role, deleted, hasSubscription, page = 1 } = req.query;
  const { json } = await adminApi("/users", {
    cookies: cookieHeader(req),
    query: { q, role, deleted, hasSubscription, page, limit: 25 },
  });

  await renderPage(res, "users-list-body", {
    title: "Üyeler",
    admin: req.admin,
    users: json?.data?.items || [],
    pagination: json?.data || {},
    filters: { q, role, deleted, hasSubscription },
    currentPath: "/users",
  });
});

router.get("/:id", async (req, res) => {
  const { json, ok } = await adminApi(`/users/${req.params.id}`, { cookies: cookieHeader(req) });
  if (!ok) return res.redirect("/users");

  await renderPage(res, "user-detail-body", {
    title: "Üye Detayı",
    admin: req.admin,
    user: json.data,
    currentPath: "/users",
  });
});

router.post("/:id/reset-password", async (req, res) => {
  await adminApi(`/users/${req.params.id}/reset-password`, {
    method: "POST",
    cookies: cookieHeader(req),
  });
  res.redirect(`/users/${req.params.id}?msg=reset`);
});

router.post("/:id/close-account", async (req, res) => {
  const { reason, forceManager } = req.body;
  await adminApi(`/users/${req.params.id}/close-account`, {
    method: "POST",
    cookies: cookieHeader(req),
    body: { reason, forceManager: forceManager === "on" },
  });
  res.redirect("/users?msg=closed");
});

export default router;
