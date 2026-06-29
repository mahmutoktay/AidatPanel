import express from "express";
import { adminApi, cookieHeader } from "../services/apiClient.js";
import { renderPage } from "../utils/renderPage.js";

const router = express.Router();

router.get("/", async (req, res) => {
  const { action, adminId, page = 1 } = req.query;
  const { json } = await adminApi("/audit-logs", {
    cookies: cookieHeader(req),
    query: { action, adminId, page, limit: 25 },
  });

  await renderPage(res, "audit-body", {
    title: "Denetim Kayıtları",
    admin: req.admin,
    logs: json?.data?.items || [],
    pagination: json?.data || {},
    filters: { action, adminId },
    currentPath: "/audit",
  });
});

export default router;
