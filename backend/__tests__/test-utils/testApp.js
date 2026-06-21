/**
 * Test Application Factory
 *
 * Jest + Supertest için izole test sunucusu oluşturur.
 * Her test dosyası için ayrı Prisma istemcisi gerekirse kullanılır.
 */

import express from "express";
import { json, urlencoded } from "express";
import cors from "cors";
import helmet from "helmet";

export async function createTestApp() {
  const app = express();

  app.use(json());
  app.use(urlencoded({ extended: true }));
  app.use(cors({ origin: true, credentials: true }));
  app.use(helmet());

  // Routes
  const authRoutes = await import("../../src/routes/authRoutes.js");
  const buildingRoutes = await import("../../src/routes/buildingRoutes.js");
  const dekontRoutes = await import("../../src/routes/dekontRoutes.js");
  const expenseRoutes = await import("../../src/routes/expenseRoutes.js");
  const ticketRoutes = await import("../../src/routes/ticketRoutes.js");
  const apartmentRoutes = await import("../../src/routes/apartmentRoutes.js");
  const meRoutes = await import("../../src/routes/meRoutes.js");
  const notificationRoutes = await import("../../src/routes/notificationRoutes.js");
  const inviteCodeRoutes = await import("../../src/routes/inviteCodeRoutes.js");
  const subscriptionRoutes = await import("../../src/routes/subscriptionRoutes.js");
  const apartmentTicketRoutes = await import("../../src/routes/apartmentTicketRoutes.js");

  app.use("/api/v1/auth", authRoutes.default);
  app.use("/api/v1/buildings", buildingRoutes.default);
  app.use("/api/v1/dekonts", dekontRoutes.default);
  app.use("/api/v1/expenses", expenseRoutes.default);
  app.use("/api/v1/tickets", ticketRoutes.default);
  app.use("/api/v1/apartments", apartmentRoutes.default);
  app.use("/api/v1/me", meRoutes.default);
  app.use("/api/v1/notifications", notificationRoutes.default);
  app.use("/api/v1/invite-codes", inviteCodeRoutes.default);
  app.use("/api/v1/subscriptions", subscriptionRoutes.default);
  app.use("/api/v1/apartment-tickets", apartmentTicketRoutes.default);

  // Error handler
  const errorHandler = await import("../../src/middlewares/errorHandler.js");
  app.use(errorHandler.errorHandler);

  return app;
}