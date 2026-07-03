import { config } from "dotenv";
config();

import express from "express";
import path from "path";
import { fileURLToPath } from "url";
import cookieParser from "cookie-parser";
import helmet from "helmet";
import authRoutes from "./routes/authRoutes.js";
import dashboardRoutes from "./routes/dashboardRoutes.js";
import usersRoutes from "./routes/usersRoutes.js";
import reportsRoutes from "./routes/reportsRoutes.js";
import analyticsRoutes from "./routes/analyticsRoutes.js";
import backupsRoutes from "./routes/backupsRoutes.js";
import auditRoutes from "./routes/auditRoutes.js";
import notificationsRoutes from "./routes/notificationsRoutes.js";
import explorerRoutes from "./routes/explorerRoutes.js";
import searchRoutes from "./routes/searchRoutes.js";
import growthRoutes from "./routes/growthRoutes.js";
import opsRoutes from "./routes/opsRoutes.js";
import { requireAdminSession } from "./middleware/requireAdminSession.js";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const app = express();
const port = process.env.ADMIN_PORT || 4300;

app.set("view engine", "ejs");
app.set("views", path.join(__dirname, "views"));

app.use(
  helmet({
    contentSecurityPolicy: {
      directives: {
        defaultSrc: ["'self'"],
        // Alpine.js ifadeleri dahili olarak Function() kullanır; unsafe-eval zorunlu
        scriptSrc: ["'self'", "'unsafe-inline'", "'unsafe-eval'", "https://unpkg.com", "https://cdn.jsdelivr.net"],
        styleSrc: ["'self'", "'unsafe-inline'", "https://fonts.googleapis.com"],
        fontSrc: ["'self'", "https://fonts.gstatic.com"],
        imgSrc: ["'self'", "data:"],
        connectSrc: ["'self'", process.env.ADMIN_API_BASE || "http://127.0.0.1:4200"],
      },
    },
  })
);
app.use(cookieParser());
app.use(express.urlencoded({ extended: true }));
app.use(express.json());
app.use("/css", express.static(path.join(__dirname, "../public/css")));
app.use("/js", express.static(path.join(__dirname, "../public/js")));

app.use("/auth", authRoutes);

const authed = requireAdminSession;

app.use("/", authed, dashboardRoutes);
app.use("/explorer", authed, explorerRoutes);
app.use("/search", authed, searchRoutes);
app.use("/growth", authed, growthRoutes);
app.use("/ops", authed, opsRoutes);
app.use("/users", authed, usersRoutes);
app.use("/analytics", authed, analyticsRoutes);
app.use("/audit", authed, auditRoutes);
app.use("/backups", authed, backupsRoutes);
app.use("/notifications", authed, notificationsRoutes);

app.get("/subscriptions", authed, (req, res) => {
  const qs = new URLSearchParams(req.query).toString();
  res.redirect("/growth" + (qs ? `?${qs}` : ""));
});
app.get("/reports/dekonts", authed, (req, res) => {
  const qs = new URLSearchParams(req.query).toString();
  res.redirect("/ops/dekonts" + (qs ? `?${qs}` : ""));
});
app.get("/reports/residents", authed, (_req, res) => res.redirect("/explorer"));
app.use("/reports", authed, reportsRoutes);

app.listen(port, () => {
  console.log(`Admin panel http://localhost:${port}`);
});
