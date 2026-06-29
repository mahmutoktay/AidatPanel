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
import subscriptionsRoutes from "./routes/subscriptionsRoutes.js";
import reportsRoutes from "./routes/reportsRoutes.js";
import analyticsRoutes from "./routes/analyticsRoutes.js";
import backupsRoutes from "./routes/backupsRoutes.js";
import auditRoutes from "./routes/auditRoutes.js";
import notificationsRoutes from "./routes/notificationsRoutes.js";
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
        scriptSrc: ["'self'", "'unsafe-inline'", "https://unpkg.com", "https://cdn.jsdelivr.net"],
        styleSrc: ["'self'", "'unsafe-inline'", "https://fonts.googleapis.com"],
        fontSrc: ["'self'", "https://fonts.gstatic.com"],
        imgSrc: ["'self'", "data:"],
        connectSrc: ["'self'", process.env.ADMIN_API_BASE || "http://localhost:4200"],
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
app.use("/", requireAdminSession, dashboardRoutes);
app.use("/users", requireAdminSession, usersRoutes);
app.use("/subscriptions", requireAdminSession, subscriptionsRoutes);
app.use("/reports", requireAdminSession, reportsRoutes);
app.use("/analytics", requireAdminSession, analyticsRoutes);
app.use("/backups", requireAdminSession, backupsRoutes);
app.use("/audit", requireAdminSession, auditRoutes);
app.use("/notifications", requireAdminSession, notificationsRoutes);

app.listen(port, () => {
  console.log(`Admin panel http://localhost:${port}`);
});
