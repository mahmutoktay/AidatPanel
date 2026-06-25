import { jest } from "@jest/globals";
import crypto from "crypto";
import jwt from "jsonwebtoken";

const REFRESH_SECRET = "test-refresh-secret-32-chars-min!!";

function hashToken(token) {
  return crypto.createHash("sha256").update(token).digest("hex");
}

const mockTx = {
  $queryRawUnsafe: jest.fn(),
  userSession: { update: jest.fn(), create: jest.fn(), updateMany: jest.fn() },
  user: { update: jest.fn() },
};

const mockPrisma = {
  user: { findFirst: jest.fn(), update: jest.fn() },
  userSession: { update: jest.fn(), updateMany: jest.fn() },
  $transaction: jest.fn(),
};

jest.unstable_mockModule("../src/config/db.js", () => ({
  prisma: mockPrisma,
}));

jest.unstable_mockModule("../src/realtime/realtimeHub.js", () => ({
  publishToUser: jest.fn(),
}));

jest.unstable_mockModule("../src/utils/generateTokens.js", () => ({
  generateAccessToken: jest.fn().mockReturnValue("mock-access-token"),
  generateRefreshToken: jest.fn().mockReturnValue("mock-refresh-token"),
}));

const { prisma } = await import("../src/config/db.js");
const { refreshAccessTokenService } = await import(
  "../src/services/authService.js"
);

function makeRefreshToken(userId, sessionId, rv = 0) {
  return jwt.sign(
    { id: userId, role: "MANAGER", rv, sid: sessionId },
    REFRESH_SECRET,
    { expiresIn: "1h" }
  );
}

describe("authService — token replay detection", () => {
  beforeEach(() => {
    jest.clearAllMocks();
    process.env.REFRESH_TOKEN_SECRET = REFRESH_SECRET;
    // restoreMocks:true resets jest.fn() implementations —
    // $transaction callback'i her test öncesinde yeniden bağlanmalı.
    mockPrisma.$transaction.mockImplementation((cb) => cb(mockTx));
  });

  test("refresh succeeds when token hash matches", async () => {
    const token = makeRefreshToken("u1", "s1");
    const tokenHash = hashToken(token);

    prisma.user.findFirst.mockResolvedValue({
      id: "u1",
      role: "MANAGER",
      deletedAt: null,
      refreshTokenVersion: 0,
    });

    mockTx.$queryRawUnsafe.mockResolvedValue([
      { id: "s1", lastTokenHash: tokenHash },
    ]);
    mockTx.userSession.update.mockResolvedValue({});

    const result = await refreshAccessTokenService(token, {});

    expect(mockTx.$queryRawUnsafe).toHaveBeenCalled();
    expect(mockTx.userSession.update).toHaveBeenCalled();
    expect(mockTx.user.update).not.toHaveBeenCalled();
    expect(prisma.userSession.updateMany).not.toHaveBeenCalled();
    expect(result).toBeTruthy();
  });

  test("replay attack: old token hash mismatch → revoke all sessions", async () => {
    const oldToken = makeRefreshToken("u1", "s1");
    const differentHash = "a-completely-different-hash-value";

    prisma.user.findFirst.mockResolvedValue({
      id: "u1",
      role: "MANAGER",
      deletedAt: null,
      refreshTokenVersion: 0,
    });

    mockTx.$queryRawUnsafe.mockResolvedValue([
      { id: "s1", lastTokenHash: differentHash },
    ]);

    await expect(refreshAccessTokenService(oldToken, {})).rejects.toMatchObject(
      {
        statusCode: 401,
        message: expect.stringContaining("Şüpheli"),
      }
    );

    expect(mockTx.user.update).toHaveBeenCalledWith({
      where: { id: "u1" },
      data: { refreshTokenVersion: { increment: 1 } },
    });
    expect(mockTx.userSession.updateMany).toHaveBeenCalledWith({
      where: { userId: "u1", revokedAt: null },
      data: { revokedAt: expect.any(Date) },
    });
  });

  test("first refresh with no stored hash (null) → skip replay check", async () => {
    const token = makeRefreshToken("u1", "s1");

    prisma.user.findFirst.mockResolvedValue({
      id: "u1",
      role: "MANAGER",
      deletedAt: null,
      refreshTokenVersion: 0,
    });

    mockTx.$queryRawUnsafe.mockResolvedValue([
      { id: "s1", lastTokenHash: null },
    ]);
    mockTx.userSession.update.mockResolvedValue({});

    const result = await refreshAccessTokenService(token, {});

    expect(mockTx.$queryRawUnsafe).toHaveBeenCalled();
    expect(mockTx.userSession.update).toHaveBeenCalled();
    expect(prisma.userSession.updateMany).not.toHaveBeenCalled();
  });
});
