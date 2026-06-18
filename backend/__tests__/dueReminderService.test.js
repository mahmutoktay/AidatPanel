import { jest } from "@jest/globals";

const createForUsersMock = jest.fn();

jest.unstable_mockModule("../src/config/db.js", () => ({
  prisma: {
    due: {
      findMany: jest.fn(),
    },
    notification: {
      findFirst: jest.fn(),
    },
  },
}));

jest.unstable_mockModule("../src/utils/access.js", () => ({
  assertManagerOwnsBuilding: jest.fn(),
}));

jest.unstable_mockModule("../src/services/notificationService.js", () => ({
  createForUsers: (...args) => createForUsersMock(...args),
}));

jest.unstable_mockModule("../src/utils/listQuery.js", () => ({
  resolveListTake: () => 500,
}));

const { prisma } = await import("../src/config/db.js");
const { assertManagerOwnsBuilding } = await import("../src/utils/access.js");
const {
  remindBuildingDuesService,
  wasRemindedRecently,
} = await import("../src/services/dueReminderService.js");

const buildingId = "b1";
const managerId = "m1";
const dueId = "due-1";
const residentId = "r1";

const sampleDue = {
  id: dueId,
  apartmentId: "a1",
  month: 6,
  year: 2026,
  amount: 500,
  currency: "TRY",
  apartment: {
    id: "a1",
    number: "3",
    resident: { id: residentId },
  },
};

describe("dueReminderService", () => {
  beforeEach(() => {
    jest.clearAllMocks();
    assertManagerOwnsBuilding.mockResolvedValue({ currency: "TRY" });
    createForUsersMock.mockResolvedValue({
      pushSent: 1,
      pushFailed: 0,
      pushSkipped: 0,
    });
  });

  describe("wasRemindedRecently", () => {
    test("returns true when recent DUE_REMINDER exists for dueId", async () => {
      prisma.notification.findFirst.mockResolvedValue({ id: "n1" });

      const result = await wasRemindedRecently(residentId, dueId);

      expect(result).toBe(true);
      expect(prisma.notification.findFirst).toHaveBeenCalledWith(
        expect.objectContaining({
          where: expect.objectContaining({
            userId: residentId,
            type: "DUE_REMINDER",
            data: {
              path: ["dueId"],
              equals: dueId,
            },
          }),
        })
      );
    });

    test("returns false when no recent reminder", async () => {
      prisma.notification.findFirst.mockResolvedValue(null);

      const result = await wasRemindedRecently(residentId, dueId);

      expect(result).toBe(false);
    });
  });

  describe("remindBuildingDuesService", () => {
    test("sends reminder when not in cooldown", async () => {
      prisma.due.findMany.mockResolvedValue([sampleDue]);
      prisma.notification.findFirst.mockResolvedValue(null);

      const result = await remindBuildingDuesService(buildingId, managerId, {
        dueIds: [dueId],
      });

      expect(result).toEqual({
        reminded: 1,
        skippedCooldown: 0,
        pushSent: 1,
        pushFailed: 0,
        pushSkipped: 0,
      });
      expect(createForUsersMock).toHaveBeenCalledWith(
        [residentId],
        expect.objectContaining({
          type: "DUE_REMINDER",
          data: expect.objectContaining({ dueId }),
        })
      );
    });

    test("skips reminder when in 24h cooldown", async () => {
      prisma.due.findMany.mockResolvedValue([sampleDue]);
      prisma.notification.findFirst.mockResolvedValue({ id: "n1" });

      const result = await remindBuildingDuesService(buildingId, managerId, {
        dueIds: [dueId],
      });

      expect(result).toEqual({
        reminded: 0,
        skippedCooldown: 1,
        pushSent: 0,
        pushFailed: 0,
        pushSkipped: 0,
      });
      expect(createForUsersMock).not.toHaveBeenCalled();
    });

    test("returns zeros when no matching dues", async () => {
      prisma.due.findMany.mockResolvedValue([]);

      const result = await remindBuildingDuesService(buildingId, managerId, {
        dueIds: [dueId],
      });

      expect(result).toEqual({
        reminded: 0,
        skippedCooldown: 0,
        pushSent: 0,
        pushFailed: 0,
        pushSkipped: 0,
      });
      expect(createForUsersMock).not.toHaveBeenCalled();
    });
  });
});
