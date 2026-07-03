import { jest } from "@jest/globals";
import crypto from "crypto";
import jwt from "jsonwebtoken";

const REFRESH_SECRET = "test-refresh-secret-32-chars-min!!";

<<<<<<< HEAD
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
=======
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
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
}));

jest.unstable_mockModule("../src/realtime/realtimeHub.js", () => ({
  publishToUser: jest.fn(),
}));

<<<<<<< HEAD
jest.unstable_mockModule("../src/services/sessionService.js", () => ({
  assertSessionActive: jest.fn(),
  createSession: jest.fn(),
  revokeOtherSessions: jest.fn(),
  touchSession: jest.fn(),
}));

jest.unstable_mockModule("../src/services/inviteCodeService.js", () => ({
  validateInviteCode: jest.fn(),
}));

=======
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
jest.unstable_mockModule("../src/utils/generateTokens.js", () => ({
  generateAccessToken: jest.fn().mockReturnValue("mock-access-token"),
  generateRefreshToken: jest.fn().mockReturnValue("mock-refresh-token"),
}));

const { prisma } = await import("../src/config/db.js");
<<<<<<< HEAD
const { assertSessionActive, touchSession } = await import(
  "../src/services/sessionService.js"
);
const { refreshAccessTokenService } = await import("../src/services/authService.js");

// --- Helpers ---
=======
const { refreshAccessTokenService } = await import(
  "../src/services/authService.js"
);
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6

function makeRefreshToken(userId, sessionId, rv = 0) {
  return jwt.sign(
    { id: userId, role: "MANAGER", rv, sid: sessionId },
    REFRESH_SECRET,
    { expiresIn: "1h" }
  );
}

<<<<<<< HEAD
function hashToken(token) {
  return crypto.createHash("sha256").update(token).digest("hex");
}

// --- Tests ---

=======
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
describe("authService — token replay detection", () => {
  beforeEach(() => {
    jest.clearAllMocks();
    process.env.REFRESH_TOKEN_SECRET = REFRESH_SECRET;
<<<<<<< HEAD
=======
    // restoreMocks:true resets jest.fn() implementations —
    // $transaction callback'i her test öncesinde yeniden bağlanmalı.
    mockPrisma.$transaction.mockImplementation((cb) => cb(mockTx));
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
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

<<<<<<< HEAD
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
=======
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
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
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

<<<<<<< HEAD
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
=======
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
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
  });

  test("first refresh with no stored hash (null) → skip replay check", async () => {
    const token = makeRefreshToken("u1", "s1");

    prisma.user.findFirst.mockResolvedValue({
      id: "u1",
      role: "MANAGER",
      deletedAt: null,
      refreshTokenVersion: 0,
    });

<<<<<<< HEAD
    assertSessionActive.mockResolvedValue({ id: "s1", lastTokenHash: null });
    touchSession.mockResolvedValue(undefined);
    prisma.userSession.update.mockResolvedValue({});

    const result = await refreshAccessTokenService(token, {});
    // No revoke triggered
    expect(prisma.userSession.updateMany).not.toHaveBeenCalled();
    // touchSession called normally
    expect(touchSession).toHaveBeenCalledWith("s1");
=======
    mockTx.$queryRawUnsafe.mockResolvedValue([
      { id: "s1", lastTokenHash: null },
    ]);
    mockTx.userSession.update.mockResolvedValue({});

    const result = await refreshAccessTokenService(token, {});

    expect(mockTx.$queryRawUnsafe).toHaveBeenCalled();
    expect(mockTx.userSession.update).toHaveBeenCalled();
    expect(prisma.userSession.updateMany).not.toHaveBeenCalled();
>>>>>>> e6f0cc38ed07757b214400fd14a6d14faad243f6
  });
});
