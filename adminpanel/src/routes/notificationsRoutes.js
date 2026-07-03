import express from "express";
import { adminApi, cookieHeader } from "../services/apiClient.js";

const router = express.Router();

router.post("/:id/read", async (req, res) => {
  await adminApi(`/notifications/${req.params.id}/read`, {
    method: "PATCH",
    cookies: cookieHeader(req),
  });
  const back = req.get("referer") || "/";
  res.redirect(back);
});

router.post("/read-all", async (req, res) => {
  const { json } = await adminApi("/notifications", {
    cookies: cookieHeader(req),
    query: { unreadOnly: "true" },
  });
  const unread = json?.data || [];
  await Promise.all(
    unread.map((n) =>
      adminApi(`/notifications/${n.id}/read`, { method: "PATCH", cookies: cookieHeader(req) })
    )
  );
  const back = req.get("referer") || "/";
  res.redirect(back);
});

export default router;
