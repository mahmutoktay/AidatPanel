import { adminApi, cookieHeader } from "../services/apiClient.js";

export async function requireAdminSession(req, res, next) {
  if (req.path.startsWith("/auth")) return next();

  const cookies = cookieHeader(req);
  if (!cookies) {
    return res.redirect("/auth/login");
  }

  const { ok, json } = await adminApi("/auth/me", { cookies });
  if (!ok) {
    res.clearCookie("admin_token");
    res.clearCookie("admin_refresh");
    return res.redirect("/auth/login");
  }

  req.admin = json.data;
  req.adminCookies = cookies;
  next();
}
