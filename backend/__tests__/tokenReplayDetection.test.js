import { jest } from "@jest/globals";
import crypto from "crypto";
import jwt from "jsonwebtoken";

const REFRESH_SECRET = "test-refresh-secret-32-chars-min!!";

// --- Mocks ---

jest.unstable_mockModule("../src/config/db.js", () => ({
  prisma: {
    user: {
      findFirst: jest.fn(),
      update: jest.fn(),
    },
    userSession: {
      update: jest.fn(),
      updateMany: jest.fn(),
    },
  },
}));

jest.unstable_mockModule("../src/realtime/realtimeHub.js", () => ({
  publishToUser: jest.fn(),
}));

jest.unstable_mockModule("../src/services/sessionService.js", () => ({
  assertSessionActive: jest.fn(),
  createSession: jest.fn(),
  revokeOtherSessions: jest.fn(),
  touchSession: jest.fn(),
}));

jest.unstable_mockModule("../src/services/inviteCodeService.js", () => ({
  validateInviteCode: jest.fn(),
}));

jest.unstable_mockModule("../src/utils/generateTokens.js", () => ({
  generateAccessToken: jest.fn().mockReturnValue("mock-access-token"),
  generateRefreshToken: jest.fn().mockReturnValue("mock-refresh-token"),
}));

const { prisma } = await import("../src/config/db.js");
const { assertSessionActive, touchSession } = await import(
  "../src/services/sessionService.js"
);
const { refreshAccessTokenService } = await import("../src/services/authService.js");

// --- Helpers ---

function makeRefreshToken(userId, sessionId, rv = 0) {
  return jwt.sign(
    { id: userId, role: "MANAGER", rv, sid: sessionId },
    REFRESH_SECRET,
    { expiresIn: "1h" }
  );
}

function hashToken(token) {
  return crypto.createHash("sha256").update(token).digest("hex");
}

// --- Tests ---

describe("authService — token replay detection", () => {
  beforeEach(() => {
    jest.clearAllMocks();
    process.env.REFRESH_TOKEN_SECRET = REFRESH_SECRET;
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

    assertSessionActive.mockResolvedValue({ id: "s1", lastTokenHash: tokenHash });
    touchSession.mockResolvedValue(undefined);
    prisma.userSession.update.mockResolvedValue({});

    const result = await refreshAccessTokenService(token, {});

    // touchSession called (not revoked)
    expect(touchSession).toHaveBeenCalledWith("s1");
    // No revoke triggered
    expect(prisma.userSession.updateMany).not.toHaveBeenCalled();
    // rv match → refreshTokenVersion NOT incremented
    expect(prisma.user.update).not.toHaveBeenCalled();
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

    assertSessionActive.mockResolvedValue({ id: "s1", lastTokenHash: differentHash });
    prisma.user.update.mockResolvedValue({});
    prisma.userSession.updateMany.mockResolvedValue({ count: 2 });

    await expect(refreshAccessTokenService(oldToken, {})).rejects.toMatchObject({
      statusCode: 401,
      message: expect.stringContaining("Şüpheli"),
    });

    // All sessions revoked
    expect(prisma.userSession.updateMany).toHaveBeenCalledWith({
      where: { userId: "u1", revokedAt: null },
      data: { revokedAt: expect.any(Date) },
    });
    // refreshTokenVersion incremented
    expect(prisma.user.update).toHaveBeenCalledWith({
      where: { id: "u1" },
      data: { refreshTokenVersion: { increment: 1 } },
    });
    // touchSession should NOT have been called
    expect(touchSession).not.toHaveBeenCalled();
  });

  test("first refresh with no stored hash (null) → skip replay check", async () => {
    const token = makeRefreshToken("u1", "s1");

    prisma.user.findFirst.mockResolvedValue({
      id: "u1",
      role: "MANAGER",
      deletedAt: null,
      refreshTokenVersion: 0,
    });

    assertSessionActive.mockResolvedValue({ id: "s1", lastTokenHash: null });
    touchSession.mockResolvedValue(undefined);
    prisma.userSession.update.mockResolvedValue({});

    const result = await refreshAccessTokenService(token, {});
    // No revoke triggered
    expect(prisma.userSession.updateMany).not.toHaveBeenCalled();
    // touchSession called normally
    expect(touchSession).toHaveBeenCalledWith("s1");
  });
});
