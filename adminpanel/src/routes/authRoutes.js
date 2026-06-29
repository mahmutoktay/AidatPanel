import express from "express";
import { adminApi, cookieHeader } from "../services/apiClient.js";

const router = express.Router();

router.get("/login", (req, res) => {
  if (req.cookies?.admin_token) return res.redirect("/");
  res.render("pages/login", { error: null, title: "Giriş" });
});

router.post("/login", async (req, res) => {
  const { email, password } = req.body;
  const result = await adminApi("/auth/login", {
    method: "POST",
    body: { email, password },
  });

  if (!result.ok) {
    return res.render("pages/login", {
      error: result.json?.message || "Giriş başarısız.",
      title: "Giriş",
    });
  }

  const { accessToken, refreshToken } = result.json.data || {};
  if (accessToken) {
    res.cookie("admin_token", accessToken, { httpOnly: true, sameSite: "strict", path: "/" });
  }
  if (refreshToken) {
    res.cookie("admin_refresh", refreshToken, { httpOnly: true, sameSite: "strict", path: "/" });
  }

  res.redirect("/");
});

router.post("/logout", async (req, res) => {
  await adminApi("/auth/logout", { method: "POST", cookies: cookieHeader(req) });
  res.clearCookie("admin_token");
  res.clearCookie("admin_refresh");
  res.redirect("/auth/login");
});

export default router;
