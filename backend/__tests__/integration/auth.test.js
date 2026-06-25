/**
 * Integration Test: Auth Flow
 *
 * Supertest + test DB ile gerçek HTTP akışı test edilir.
 * PR pipeline'de çalıştırılır.
 */

import { jest } from "@jest/globals";
import request from "supertest";

// --- Mocks ---
jest.unstable_mockModule("../../src/middlewares/rateLimitMiddleware.js", () => ({
  authLimiter: (_req, _res, next) => next(),
  apiLimiter: (_req, _res, next) => next(),
  dekontUploadLimiter: (_req, _res, next) => next(),
  strictLimiter: (_req, _res, next) => next(),
}));

const { createTestApp } = await import("../test-utils/testApp.js");

describe("Auth Flow - Integration", () => {
  let app;
  const testEmail = `int-test-${Date.now()}@test.com`;
  const testPhone = `+90555${String(Date.now()).slice(-7)}`;
  let accessToken;
  let refreshToken;
  let userId;

  beforeAll(async () => {
    app = await createTestApp();
  });

  it("POST /register - creates new manager", async () => {
    const res = await request(app)
      .post("/api/v1/auth/register")
      .send({
        name: "Test Manager",
        email: testEmail,
        phone: testPhone,
        password: "Test1234!",
      });

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.user.email).toBe(testEmail);
    userId = res.body.data.user.id;
  });

  it("POST /login - returns tokens", async () => {
    const res = await request(app)
      .post("/api/v1/auth/login")
      .send({
        identifier: testEmail,
        password: "Test1234!",
      });

    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.accessToken).toBeTruthy();
    expect(res.body.data.refreshToken).toBeTruthy();
    accessToken = res.body.data.accessToken;
    refreshToken = res.body.data.refreshToken;
  });

  it("POST /refresh - rotates tokens", async () => {
    const res = await request(app)
      .post("/api/v1/auth/refresh")
      .send({ refreshToken });

    expect(res.status).toBe(200);
    expect(res.body.data.accessToken).toBeTruthy();
    expect(res.body.data.refreshToken).toBeTruthy();
    expect(res.body.data.accessToken).not.toBe(accessToken);
    accessToken = res.body.data.accessToken;
    refreshToken = res.body.data.refreshToken;
  });

  it("POST /logout - clears session", async () => {
    const res = await request(app)
      .post("/api/v1/auth/logout")
      .set("Authorization", `Bearer ${accessToken}`);

    expect(res.status).toBe(200);
  });
});