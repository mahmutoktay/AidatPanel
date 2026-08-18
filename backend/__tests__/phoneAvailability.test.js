import { jest } from "@jest/globals";

const mockFindFirst = jest.fn();

jest.unstable_mockModule("../src/config/db.js", () => ({
  prisma: {
    user: {
      findFirst: mockFindFirst,
    },
  },
}));

const { assertPhoneGloballyAvailable } = await import(
  "../src/utils/phoneAvailability.js"
);
const { HttpError } = await import("../src/utils/httpError.js");

describe("phoneAvailability", () => {
  beforeEach(() => {
    mockFindFirst.mockReset();
  });

  test("telefon boşsa kontrol atlanır", async () => {
    await expect(assertPhoneGloballyAvailable(null)).resolves.toBeUndefined();
    await expect(assertPhoneGloballyAvailable("")).resolves.toBeUndefined();
    expect(mockFindFirst).not.toHaveBeenCalled();
  });

  test("kullanılmayan telefon geçer", async () => {
    mockFindFirst.mockResolvedValue(null);
    await expect(
      assertPhoneGloballyAvailable("5551112233", { requestingRole: "MANAGER" })
    ).resolves.toBeUndefined();
  });

  test("sakin telefonu yönetici kaydında engellenir", async () => {
    mockFindFirst.mockResolvedValue({ id: "u1", role: "RESIDENT" });
    await expect(
      assertPhoneGloballyAvailable("5551112233", { requestingRole: "MANAGER" })
    ).rejects.toMatchObject({
      statusCode: 409,
      message:
        "Bu telefon numarası bir sakin hesabına kayıtlı. Yönetici hesabında kullanılamaz.",
    });
  });

  test("yönetici telefonu sakin kaydında engellenir", async () => {
    mockFindFirst.mockResolvedValue({ id: "u2", role: "MANAGER" });
    await expect(
      assertPhoneGloballyAvailable("5551112233", { requestingRole: "RESIDENT" })
    ).rejects.toMatchObject({
      statusCode: 409,
      message:
        "Bu telefon numarası bir yönetici hesabına kayıtlı. Sakin hesabında kullanılamaz.",
    });
  });

  test("aynı rol çakışması genel mesaj döner", async () => {
    mockFindFirst.mockResolvedValue({ id: "u3", role: "MANAGER" });
    await expect(
      assertPhoneGloballyAvailable("5551112233", { requestingRole: "MANAGER" })
    ).rejects.toEqual(expect.any(HttpError));
    await expect(
      assertPhoneGloballyAvailable("5551112233", { requestingRole: "MANAGER" })
    ).rejects.toMatchObject({
      message: "Bu telefon numarası zaten kullanılıyor.",
    });
  });

  test("excludeUserId kendi kaydını hariç tutar", async () => {
    mockFindFirst.mockResolvedValue(null);
    await assertPhoneGloballyAvailable("5551112233", {
      excludeUserId: "self-id",
      requestingRole: "MANAGER",
    });
    expect(mockFindFirst).toHaveBeenCalledWith(
      expect.objectContaining({
        where: expect.objectContaining({
          NOT: { id: "self-id" },
        }),
      })
    );
  });
});
