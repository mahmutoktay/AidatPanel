import { jest } from "@jest/globals";

const mockUserFindFirst = jest.fn();
const mockTransaction = jest.fn();
const mockInviteUpdate = jest.fn();
const mockUserUpdate = jest.fn();
const mockValidateInviteCode = jest.fn();
const mockEnsureApartmentDues = jest.fn();

jest.unstable_mockModule("../src/config/db.js", () => ({
  prisma: {
    user: {
      findFirst: mockUserFindFirst,
      update: mockUserUpdate,
    },
    inviteCode: {
      update: mockInviteUpdate,
    },
    $transaction: mockTransaction,
  },
}));

jest.unstable_mockModule("../src/services/inviteCodeService.js", () => ({
  validateInviteCode: mockValidateInviteCode,
}));

jest.unstable_mockModule("../src/services/dueBulkService.js", () => ({
  ensureApartmentDuesService: mockEnsureApartmentDues,
}));

const { rejoinWithInviteCodeService } = await import(
  "../src/services/authService.js"
);
const { HttpError } = await import("../src/utils/httpError.js");

describe("rejoinWithInviteCodeService", () => {
  beforeEach(() => {
    jest.clearAllMocks();
    mockTransaction.mockImplementation(async (fn) =>
      fn({
        inviteCode: { update: mockInviteUpdate },
        user: { update: mockUserUpdate },
      })
    );
    mockUserUpdate.mockResolvedValue({
      id: "u1",
      role: "RESIDENT",
      apartmentId: "apt-new",
      name: "Sakin",
      email: null,
      phone: "5551112233",
      language: "tr",
      createdAt: new Date(),
      updatedAt: new Date(),
    });
  });

  test("daire bağlantısı olmayan sakin davet kodu ile bağlanır", async () => {
    mockUserFindFirst
      .mockResolvedValueOnce({
        id: "u1",
        role: "RESIDENT",
        apartmentId: null,
      })
      .mockResolvedValueOnce(null);
    mockValidateInviteCode.mockResolvedValue({
      id: "inv1",
      apartmentId: "apt-new",
    });

    const result = await rejoinWithInviteCodeService("u1", "AP3-B12-A9F0");

    expect(result.user.apartmentId).toBe("apt-new");
    expect(mockInviteUpdate).toHaveBeenCalledWith(
      expect.objectContaining({
        where: { id: "inv1" },
        data: expect.objectContaining({ usedBy: "u1" }),
      })
    );
    expect(mockEnsureApartmentDues).toHaveBeenCalledWith("apt-new");
  });

  test("zaten daireye bağlı sakin 409 döner", async () => {
    mockUserFindFirst.mockResolvedValue({
      id: "u1",
      role: "RESIDENT",
      apartmentId: "apt-old",
    });

    await expect(
      rejoinWithInviteCodeService("u1", "AP3-B12-A9F0")
    ).rejects.toMatchObject({
      statusCode: 409,
      message: "Zaten bir daireye bağlısınız.",
    });
  });

  test("dolu daire 409 döner", async () => {
    mockUserFindFirst
      .mockResolvedValueOnce({
        id: "u1",
        role: "RESIDENT",
        apartmentId: null,
      })
      .mockResolvedValueOnce({ id: "other" });
    mockValidateInviteCode.mockResolvedValue({
      id: "inv1",
      apartmentId: "apt-new",
    });

    await expect(
      rejoinWithInviteCodeService("u1", "AP3-B12-A9F0")
    ).rejects.toMatchObject({
      statusCode: 409,
      message: "Bu dairede zaten bir sakin kayıtlı.",
    });
  });
});
