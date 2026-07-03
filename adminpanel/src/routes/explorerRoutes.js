import express from "express";
import { adminApi, cookieHeader } from "../services/apiClient.js";
import { renderPage } from "../utils/renderPage.js";

const router = express.Router();

router.get("/", async (req, res) => {
  const cookies = cookieHeader(req);
  const { json, ok } = await adminApi("/hierarchy/managers", {
    cookies,
    query: { limit: 50 },
  });

  await renderPage(res, "explorer-body", {
    title: "Müşteri Gezgini",
    admin: req.admin,
    currentPath: "/explorer",
    focus: req.query.focus || null,
    initialManagers: ok ? json?.data?.items ?? [] : [],
    managersError: ok ? null : json?.message || "Yöneticiler yüklenemedi.",
  });
});

router.get("/api/managers", async (req, res) => {
  const { json, ok } = await adminApi("/hierarchy/managers", {
    cookies: cookieHeader(req),
    query: req.query,
  });
  res.status(ok ? 200 : 500).json(json);
});

router.get("/api/managers/:id", async (req, res) => {
  const { json, ok } = await adminApi(`/hierarchy/managers/${req.params.id}`, {
    cookies: cookieHeader(req),
  });
  res.status(ok ? 200 : 500).json(json);
});

router.get("/api/buildings/:id", async (req, res) => {
  const { json, ok } = await adminApi(`/hierarchy/buildings/${req.params.id}`, {
    cookies: cookieHeader(req),
  });
  res.status(ok ? 200 : 500).json(json);
});

router.get("/api/apartments/:id", async (req, res) => {
  const { json, ok } = await adminApi(`/hierarchy/apartments/${req.params.id}`, {
    cookies: cookieHeader(req),
  });
  res.status(ok ? 200 : 500).json(json);
});

export default router;
