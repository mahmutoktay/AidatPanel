import { jest } from "@jest/globals";

const publishCalls = [];

jest.unstable_mockModule("../src/realtime/realtimeHub.js", () => ({
  publishToUser: (userId, payload) => {
    publishCalls.push({ userId, payload });
  },
}));

jest.unstable_mockModule("../src/config/db.js", () => ({
  prisma: {
    userSession: {
      create: jest.fn(),
      findMany: jest.fn(),
      findFirst: jest.fn(),
      update: jest.fn(),
      updateMany: jest.fn(),
    },
  },
}));

const { prisma } = await import("../src/config/db.js");
const {
  createSession,
  listActiveSessions,
  revokeOtherSessions,
  revokeSession,
  assertSessionActive,
} = await import("../src/services/sessionService.js");

describe("sessionService", () => {
  beforeEach(() => {
    jest.clearAllMocks();
    publishCalls.length = 0;
  });

  test("createSession normalizes device metadata", async () => {
    prisma.userSession.create.mockResolvedValue({ id: "s1" });
    await createSession("u1", { deviceLabel: "  Galaxy A54 ", platform: " Android " });
    expect(prisma.userSession.create).toHaveBeenCalledWith({
      data: {
        userId: "u1",
        deviceLabel: "Galaxy A54",
        platform: "android",
      },
    });
  });

  test("listActiveSessions marks current session", async () => {
    prisma.userSession.findMany.mockResolvedValue([
      {
        id: "s1",
        deviceLabel: "Phone A",
        platform: "android",
        createdAt: new Date("2026-06-01T10:00:00Z"),
        lastSeenAt: new Date("2026-06-18T08:00:00Z"),
      },
      {
        id: "s2",
        deviceLabel: "Phone B",
        platform: "ios",
        createdAt: new Date("2026-06-02T10:00:00Z"),
        lastSeenAt: new Date("2026-06-17T08:00:00Z"),
      },
    ]);

    const result = await listActiveSessions("u1", "s1");
    expect(result).toHaveLength(2);
    expect(result[0].isCurrent).toBe(true);
    expect(result[1].isCurrent).toBe(false);
  });

  test("revokeSession publishes targeted force_logout", async () => {
    prisma.userSession.findFirst.mockResolvedValue({ id: "s2" });
    prisma.userSession.update.mockResolvedValue({ id: "s2" });

    await revokeSession("u1", "s2");

    expect(prisma.userSession.update).toHaveBeenCalled();
    expect(publishCalls).toEqual([
      { userId: "u1", payload: { event: "force_logout", sessionId: "s2" } },
    ]);
  });

  test("revokeOtherSessions skips current session", async () => {
    prisma.userSession.findMany.mockResolvedValue([{ id: "s2" }]);
    prisma.userSession.updateMany.mockResolvedValue({ count: 1 });

    const revoked = await revokeOtherSessions("u1", "s1");

    expect(revoked).toEqual(["s2"]);
    expect(prisma.userSession.findMany).toHaveBeenCalledWith({
      where: { userId: "u1", revokedAt: null, id: { not: "s1" } },
      select: { id: true },
    });
    expect(publishCalls).toEqual([
      { userId: "u1", payload: { event: "force_logout", sessionId: "s2" } },
    ]);
  });

  test("assertSessionActive rejects revoked session", async () => {
    prisma.userSession.findFirst.mockResolvedValue(null);
    await expect(assertSessionActive("s-missing")).rejects.toMatchObject({
      statusCode: 401,
    });
  });
});
