import express from "express";
import { Readable } from "node:stream";
import { pipeline } from "node:stream/promises";
import { adminApi, API_BASE, cookieHeader } from "../services/apiClient.js";
import { renderPage } from "../utils/renderPage.js";

const router = express.Router();

function redirectError(res, message) {
  return res.redirect(`/backups?msg=error&detail=${encodeURIComponent(message)}`);
}

router.get("/", async (req, res) => {
  if (req.admin.role !== "SUPER_ADMIN") {
    return res.status(403).send("Yetkisiz");
  }

  const result = await adminApi("/backups", { cookies: cookieHeader(req) });
  if (!result.ok) {
    return await renderPage(res, "backups-body", {
      title: "Veritabanı Yedekleri",
      admin: req.admin,
      backups: [],
      apiError: result.json?.message || "Yedek listesi alınamadı.",
      currentPath: "/backups",
    });
  }

  await renderPage(res, "backups-body", {
    title: "Veritabanı Yedekleri",
    admin: req.admin,
    backups: result.json?.data || [],
    currentPath: "/backups",
  });
});

router.post("/create", async (req, res) => {
  if (req.admin.role !== "SUPER_ADMIN") {
    return redirectError(res, "Bu işlem SUPER_ADMIN yetkisi gerektirir.");
  }

  const result = await adminApi("/backups/create", { method: "POST", cookies: cookieHeader(req) });
  if (!result.ok) {
    return redirectError(res, result.json?.message || "Yedekleme başlatılamadı.");
  }
  res.redirect("/backups?msg=started");
});

router.post("/:id/download-token", async (req, res) => {
  if (req.admin.role !== "SUPER_ADMIN") {
    return redirectError(res, "Bu işlem SUPER_ADMIN yetkisi gerektirir.");
  }

  const result = await adminApi(`/backups/${req.params.id}/download-token`, {
    method: "POST",
    cookies: cookieHeader(req),
  });
  const token = result.json?.data?.token;
  const backupId = result.json?.data?.backupId;
  if (!result.ok || !token) {
    return redirectError(res, result.json?.message || "İndirme bağlantısı oluşturulamadı.");
  }
  res.redirect(`/backups/${backupId}/download?token=${encodeURIComponent(token)}`);
});

router.get("/:id/download", async (req, res) => {
  if (req.admin.role !== "SUPER_ADMIN") {
    return res.status(403).send("Yetkisiz");
  }

  const token = req.query.token;
  if (!token) {
    return redirectError(res, "Geçersiz indirme bağlantısı.");
  }

  try {
    const url = `${API_BASE}/backups/${req.params.id}/download?token=${encodeURIComponent(token)}`;
    const response = await fetch(url, { headers: { Cookie: cookieHeader(req) } });
    if (!response.ok) {
      const body = await response.json().catch(() => ({}));
      return redirectError(res, body.message || "Yedek indirilemedi.");
    }

    res.setHeader("Content-Type", response.headers.get("content-type") || "application/gzip");
    const disposition = response.headers.get("content-disposition");
    if (disposition) res.setHeader("Content-Disposition", disposition);

    if (!response.body) {
      return redirectError(res, "Yedek dosyası okunamadı.");
    }

    await pipeline(Readable.fromWeb(response.body), res);
  } catch (err) {
    redirectError(res, err.message || "İndirme bağlantı hatası.");
  }
});

export default router;
