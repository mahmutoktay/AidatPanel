import express from "express";
import { adminApi, cookieHeader } from "../services/apiClient.js";
import { renderPage } from "../utils/renderPage.js";

const router = express.Router();

router.get("/", async (req, res) => {
  const { q, role, deleted, hasSubscription, page = 1 } = req.query;
  const queries = [];

  if (!role || role === "MANAGER") {
    queries.push(
      adminApi("/users", {
        cookies: cookieHeader(req),
        query: { q, role: "MANAGER", deleted, hasSubscription, page, limit: 15 },
      })
    );
  } else {
    queries.push(Promise.resolve({ json: { data: { items: [] } } }));
  }

  if (!role || role === "RESIDENT") {
    queries.push(
      adminApi("/residents", {
        cookies: cookieHeader(req),
        query: { q, page, limit: 15 },
      })
    );
  } else {
    queries.push(Promise.resolve({ json: { data: { items: [] } } }));
  }

  const [managersRes, residentsRes] = await Promise.all(queries);
  const managers = managersRes.json?.data?.items || [];
  const residents = residentsRes.json?.data?.items || [];

  await renderPage(res, "search-body", {
    title: "Arama",
    admin: req.admin,
    managers,
    residents,
    filters: { q, role, deleted, hasSubscription },
    currentPath: "/search",
  });
});

export default router;
