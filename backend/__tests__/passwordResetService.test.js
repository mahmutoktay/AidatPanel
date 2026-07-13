import { jest } from "@jest/globals";

const sendSmsMock = jest.fn(async () => ({ ok: true, dev: true }));

jest.unstable_mockModule("../src/config/db.js", () => ({
  prisma: {
    user: { findFirst: jest.fn() },
    passwordResetToken: {
      deleteMany: jest.fn(),
      create: jest.fn(),
      findUnique: jest.fn(),
      update: jest.fn(),
    },
    $transaction: jest.fn(async (ops) => {
      for (const op of ops) await op;
    }),
  },
}));

jest.unstable_mockModule("../src/services/sessionService.js", () => ({
  revokeAllUserSessions: jest.fn(),
}));

jest.unstable_mockModule("../src/services/sms/sendSms.js", () => ({
  sendSms: sendSmsMock,
}));

jest.unstable_mockModule("../src/config/logger.js", () => ({
  logger: { warn: jest.fn(), error: jest.fn(), info: jest.fn() },
}));

const { prisma } = await import("../src/config/db.js");
const { requestPasswordResetService } = await import(
  "../src/services/passwordResetService.js"
);

describe("requestPasswordResetService channel rules", () => {
  const originalFetch = global.fetch;
  const originalEnv = { ...process.env };

  beforeEach(() => {
    jest.clearAllMocks();
    process.env = { ...originalEnv };
    delete process.env.RESEND_API_KEY;
    delete process.env.AIDATPANEL_E2E;
    delete process.env.AIDATPANEL_E2E_RESET_LOG;
    global.fetch = jest.fn(async () => ({
      ok: true,
      status: 200,
      text: async () => "",
    }));
    prisma.passwordResetToken.deleteMany.mockResolvedValue({ count: 0 });
    prisma.passwordResetToken.create.mockResolvedValue({ id: "t1" });
  });

  afterAll(() => {
    global.fetch = originalFetch;
    process.env = originalEnv;
  });

  test("kullanıcı yoksa sessiz sonuç", async () => {
    prisma.user.findFirst.mockResolvedValue(null);
    const result = await requestPasswordResetService({
      email: "yok@example.com",
    });
    expect(result).toEqual({
      deliveredVia: null,
      smsFallbackAvailable: false,
    });
    expect(prisma.passwordResetToken.create).not.toHaveBeenCalled();
    expect(sendSmsMock).not.toHaveBeenCalled();
  });

  test("email varsa varsayılan kanal email; SMS fallback bayrağı", async () => {
    process.env.RESEND_API_KEY = "re_test";
    prisma.user.findFirst.mockResolvedValue({
      id: "u1",
      email: "a@b.com",
      phone: "5551112233",
    });

    const result = await requestPasswordResetService({ email: "a@b.com" });

    expect(result).toEqual({
      deliveredVia: "email",
      smsFallbackAvailable: true,
    });
    expect(global.fetch).toHaveBeenCalled();
    expect(sendSmsMock).not.toHaveBeenCalled();
  });

  test("yalnızca telefon → SMS", async () => {
    prisma.user.findFirst.mockResolvedValue({
      id: "u2",
      email: null,
      phone: "5551112233",
    });

    const result = await requestPasswordResetService({ phone: "05551112233" });

    expect(result).toEqual({
      deliveredVia: "sms",
      smsFallbackAvailable: false,
    });
    expect(sendSmsMock).toHaveBeenCalledTimes(1);
    expect(sendSmsMock.mock.calls[0][0]).toBe("5551112233");
    expect(String(sendSmsMock.mock.calls[0][1])).toMatch(/sifre sifirlama/i);
  });

  test("channel=sms ile opt-in SMS (email+telefon hesabı)", async () => {
    prisma.user.findFirst.mockResolvedValue({
      id: "u3",
      email: "a@b.com",
      phone: "5559998877",
    });

    const result = await requestPasswordResetService({
      email: "a@b.com",
      channel: "sms",
    });

    expect(result).toEqual({
      deliveredVia: "sms",
      smsFallbackAvailable: false,
    });
    expect(sendSmsMock).toHaveBeenCalledTimes(1);
    expect(global.fetch).not.toHaveBeenCalled();
  });

  test("string email geriye dönük uyumluluk", async () => {
    process.env.RESEND_API_KEY = "re_test";
    prisma.user.findFirst.mockResolvedValue({
      id: "u4",
      email: "legacy@b.com",
      phone: null,
    });

    const result = await requestPasswordResetService("legacy@b.com");
    expect(result.deliveredVia).toBe("email");
    expect(result.smsFallbackAvailable).toBe(false);
  });

  test("channel=sms ama telefon yok → sessiz", async () => {
    prisma.user.findFirst.mockResolvedValue({
      id: "u5",
      email: "only@mail.com",
      phone: null,
    });

    const result = await requestPasswordResetService({
      email: "only@mail.com",
      channel: "sms",
    });

    expect(result).toEqual({
      deliveredVia: null,
      smsFallbackAvailable: false,
    });
    expect(sendSmsMock).not.toHaveBeenCalled();
    expect(prisma.passwordResetToken.create).not.toHaveBeenCalled();
  });
});
