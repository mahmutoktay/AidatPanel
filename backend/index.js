import { config } from "dotenv";
config();

import express from "express";
import cors from "cors";
import helmet from "helmet";
import fs from "fs";
import { connectDB, disconnectDB } from "./src/config/db.js";
import { initFirebase } from "./src/config/firebase.js";
import authRouter from "./src/routes/authRoutes.js";
import buildingRoutes from "./src/routes/buildingRoutes.js";
import apartmentRoutes from "./src/routes/apartmentRoutes.js";
import inviteCodeRoutes from "./src/routes/inviteCodeRoutes.js";
import meRoutes from "./src/routes/meRoutes.js";
import notificationRoutes from "./src/routes/notificationRoutes.js";
import ticketRoutes from "./src/routes/ticketRoutes.js";
import apartmentTicketRoutes from "./src/routes/apartmentTicketRoutes.js";
import expenseRoutes from "./src/routes/expenseRoutes.js";
import dekontRoutes from "./src/routes/dekontRoutes.js";
import { apiLimiter } from "./src/middlewares/rateLimitMiddleware.js";
import { errorHandler, notFoundHandler } from "./src/middlewares/errorHandler.js";
import { attachWebSocketServer } from "./src/realtime/wsGateway.js";
import { ensureDekontStorageDirs } from "./src/utils/ensureDekontStorage.js";
import { startDueAutoGenerateScheduler } from "./src/jobs/dueAutoGenerateJob.js";

const app = express();

// Trust proxy - reverse proxy (nginx, Cloudflare) arkasında çalışırken gerekli
// Express-rate-limit X-Forwarded-For header'ını doğru şekilde okuyabilsin
app.set('trust proxy', 1);

const port = process.env.PORT || 4200;

const allowedOrigins = process.env.ALLOWED_ORIGINS
  ? process.env.ALLOWED_ORIGINS.split(',')
  : ['http://localhost:3000', 'http://localhost:4200'];

// GÜVENLİK MIDDLEWARE'LERİ
// Helmet - HTTP başlıklarını güvenli hale getirir
app.use(helmet());

// CORS - Flutter'dan gelen isteklere izin ver
app.use(cors({
  origin: allowedOrigins,
  credentials: true,
  // PATCH: aidat durumu / due-amount (Faz 1); Flutter web ön uç testi için gerekli
  methods: ["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"],
  allowedHeaders: ["Content-Type", "Authorization"]
}));
// Rate Limiting - Tüm API'ler için 15 dakikada 100 istek
app.use("/api/v1", apiLimiter);

// BODY PARSING MIDDLEWARE'I
app.use(express.json());

if (process.env.NODE_ENV !== "production") {
  app.use((req, res, next) => {
    console.log(`[http] ${req.method} ${req.originalUrl}`);
    next();
  });
}

// ROTALAR — Faz 2A mount sırası (PLAN.md A0): notifications/tickets önce
app.use("/api/v1/notifications", notificationRoutes);
app.use("/api/v1/tickets", ticketRoutes);
app.use("/api/v1/apartments/:apartmentId/tickets", apartmentTicketRoutes);
app.use("/api/v1/expenses", expenseRoutes);
app.use("/api/v1/dekonts", dekontRoutes);
app.use("/api/v1/auth", authRouter);
app.use("/api/v1/buildings", buildingRoutes);
app.use("/api/v1/buildings/:buildingId/apartments", apartmentRoutes);
app.use("/api/v1/apartments/:apartmentId/invite-code", inviteCodeRoutes);
app.use("/api/v1/me", meRoutes);

app.use("/uploads/avatars", express.static("uploads/avatars"));

// 404 Handler - Tanımlanmamış route'lar
app.use(notFoundHandler);

// Global Error Handler - Tüm hataları merkezi olarak yönetir
app.use(errorHandler);

let server;

async function bootstrap() {
  await connectDB();
  initFirebase();
  await ensureDekontStorageDirs();
  await fs.promises.mkdir("uploads/avatars", { recursive: true });
  server = app.listen(port, () => {
    console.log("Server is running on port: ", port);
  });
  attachWebSocketServer(server);
  startDueAutoGenerateScheduler();
}

bootstrap().catch((err) => {
  console.error("Bootstrap failed:", err);
  process.exit(1);
});

// Yakalanmamış promise — tek istek yüzünden tüm API'yi kapatma (502/502 dalgası önlenir)
process.on("unhandledRejection", (err) => {
  console.error("[api] Unhandled Rejection:", err?.stack || err);
});

// Gerçek senkron çökme — yine de logla; production'da PM2 yeniden başlatır
process.on("uncaughtException", async (err) => {
  console.error("[api] Uncaught Exception:", err?.stack || err);
  try {
    await disconnectDB();
  } catch (_) {
    /* ignore */
  }
  process.exit(1);
});

// Graceful shutdown
process.on("SIGTERM", async () => {
  console.log("SIGTERM received, shutting down gracefully");
  if (!server) {
    process.exit(0);
    return;
  }
  server.close(async () => {
    await disconnectDB();
    process.exit(0);
  });
});
