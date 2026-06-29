import express from "express";
import { adminApi, cookieHeader } from "../services/apiClient.js";
import { renderPage } from "../utils/renderPage.js";

const router = express.Router();

router.get("/", async (req, res) => {
  if (req.admin.role !== "SUPER_ADMIN") {
    return res.status(403).send("Yetkisiz");
  }

  const { json } = await adminApi("/backups", { cookies: cookieHeader(req) });
  await renderPage(res, "backups-body", {
    title: "Veritabanı Yedekleri",
    admin: req.admin,
    backups: json?.data || [],
    currentPath: "/backups",
  });
});

router.post("/create", async (req, res) => {
  await adminApi("/backups/create", { method: "POST", cookies: cookieHeader(req) });
  res.redirect("/backups?msg=started");
});

router.post("/:id/download-token", async (req, res) => {
  const { json } = await adminApi(`/backups/${req.params.id}/download-token`, {
    method: "POST",
    cookies: cookieHeader(req),
  });
  const token = json?.data?.token;
  const backupId = json?.data?.backupId;
  if (token) {
    const base = process.env.ADMIN_API_BASE || "http://localhost:4200/api/v1/admin";
    return res.redirect(`${base}/backups/${backupId}/download?token=${token}`);
  }
  res.redirect("/backups?msg=error");
});

export default router;
