import { jest } from "@jest/globals";

const mockVerifyIdToken = jest.fn();

jest.unstable_mockModule("../src/config/firebase.js", () => ({
  isFirebaseReady: () => true,
  getAuth: () => ({
    verifyIdToken: mockVerifyIdToken,
  }),
  getMessaging: () => null,
  initFirebase: () => true,
}));

jest.unstable_mockModule("../src/config/db.js", () => ({
  prisma: {
    user: {
      findFirst: jest.fn(),
      update: jest.fn(),
      create: jest.fn(),
    },
    phoneOtpToken: {
      findFirst: jest.fn(),
      create: jest.fn(),
      update: jest.fn(),
      deleteMany: jest.fn(),
    },
    userSession: {
      update: jest.fn(),
    },
    $transaction: jest.fn(async (fn) => {
      if (typeof fn === "function") {
        return fn({
          userSession: { update: jest.fn() },
          user: { create: jest.fn() },
          inviteCode: { update: jest.fn() },
        });
      }
      return Promise.all(fn);
    }),
  },
}));

jest.unstable_mockModule("../src/services/sessionService.js", () => ({
  createSession: jest.fn(async () => ({ id: "session-1" })),
}));

jest.unstable_mockModule("../src/utils/generateTokens.js", () => ({
  generateAccessToken: () => "access-token",
  generateRefreshToken: () => "refresh-token",
}));

jest.unstable_mockModule("../src/services/dueBulkService.js", () => ({
  ensureApartmentDuesService: jest.fn(),
}));

jest.unstable_mockModule("../src/services/inviteCodeService.js", () => ({
  validateInviteCode: jest.fn(),
  normalizeInviteCode: (c) =>
    typeof c === "string" ? c.trim().toUpperCase().replace(/\s+/g, "") : c,
}));

jest.unstable_mockModule("../src/services/sms/sendSms.js", () => ({
  sendSms: jest.fn(),
}));

jest.unstable_mockModule("../src/services/sms/twilioVerifyProvider.js", () => ({
  isTwilioVerifyConfigured: () => false,
  startTwilioVerification: jest.fn(),
  checkTwilioVerification: jest.fn(),
}));

jest.unstable_mockModule("../src/services/email/resendEmail.js", () => ({
  sendOtpEmail: jest.fn(),
}));

jest.unstable_mockModule("../src/config/logger.js", () => ({
  logger: { warn: jest.fn(), error: jest.fn(), info: jest.fn() },
}));

const { prisma } = await import("../src/config/db.js");
const { verifyFirebasePhoneIdToken } = await import(
  "../src/services/firebasePhoneAuthService.js"
);
const { verifyFirebasePhoneService, sendOtpService } = await import(
  "../src/services/otpService.js"
);

describe("firebasePhoneAuthService", () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  test("geçerli idToken → phone10 ve firebaseUid döner", async () => {
    mockVerifyIdToken.mockResolvedValue({
      uid: "fb-uid-1",
      phone_number: "+905551112233",
    });
    const result = await verifyFirebasePhoneIdToken("token");
    expect(result).toEqual({
      firebaseUid: "fb-uid-1",
      phoneE164: "+905551112233",
      phone10: "5551112233",
    });
  });

  test("phone_number yoksa 401", async () => {
    mockVerifyIdToken.mockResolvedValue({ uid: "fb-uid-1" });
    await expect(verifyFirebasePhoneIdToken("token")).rejects.toMatchObject({
      statusCode: 401,
    });
  });

  test("geçersiz token → 401", async () => {
    mockVerifyIdToken.mockRejectedValue(new Error("invalid"));
    await expect(verifyFirebasePhoneIdToken("bad")).rejects.toMatchObject({
      statusCode: 401,
    });
  });
});

describe("verifyFirebasePhoneService / sendOtp cutover", () => {
  beforeEach(() => {
    jest.clearAllMocks();
    prisma.phoneOtpToken.deleteMany.mockResolvedValue({ count: 0 });
    prisma.phoneOtpToken.create.mockResolvedValue({ id: "otp-1" });
    prisma.user.update.mockResolvedValue({});
  });

  test("sakin telefon otp/send → 410", async () => {
    await expect(
      sendOtpService({
        phone: "5551112233",
        purpose: "resident_login",
      })
    ).rejects.toMatchObject({ statusCode: 410 });
  });

  test("resident_login — kullanıcı yoksa 404", async () => {
    mockVerifyIdToken.mockResolvedValue({
      uid: "fb-uid-1",
      phone_number: "+905551112233",
    });
    prisma.user.findFirst.mockResolvedValue(null);

    await expect(
      verifyFirebasePhoneService({
        idToken: "token",
        purpose: "resident_login",
      })
    ).rejects.toMatchObject({ statusCode: 404 });
  });

  test("resident_login — kullanıcı varsa JWT döner", async () => {
    mockVerifyIdToken.mockResolvedValue({
      uid: "fb-uid-1",
      phone_number: "+905551112233",
    });
    const resident = {
      id: "user-1",
      email: null,
      name: "Ali",
      role: "RESIDENT",
      phone: "5551112233",
      language: "tr",
      apartmentId: "apt-1",
      firebaseUid: null,
      createdAt: new Date(),
      updatedAt: new Date(),
      deletedAt: null,
    };
    prisma.user.findFirst.mockResolvedValue(resident);

    const result = await verifyFirebasePhoneService({
      idToken: "token",
      purpose: "resident_login",
      deviceLabel: "Pixel",
      platform: "android",
    });

    expect(result.user).toMatchObject({
      id: "user-1",
      name: "Ali",
      role: "RESIDENT",
      phone: "5551112233",
    });
    // Token üretimi generateTokens mock'una bağlı; oturum oluşturma yeter.
    const { createSession } = await import("../src/services/sessionService.js");
    expect(createSession).toHaveBeenCalled();
  });

  test("resident_join isim yoksa requireName", async () => {
    mockVerifyIdToken.mockResolvedValue({
      uid: "fb-uid-2",
      phone_number: "+905559998877",
    });
    prisma.user.findFirst.mockResolvedValue(null);

    const result = await verifyFirebasePhoneService({
      idToken: "token",
      purpose: "resident_join",
    });

    expect(result).toEqual({ requireName: true });
    expect(prisma.phoneOtpToken.create).toHaveBeenCalled();
  });

  test("resident_phone_change → verified", async () => {
    mockVerifyIdToken.mockResolvedValue({
      uid: "fb-uid-3",
      phone_number: "+905554443322",
    });
    prisma.user.findFirst.mockResolvedValue(null);

    const result = await verifyFirebasePhoneService({
      idToken: "token",
      purpose: "resident_phone_change",
    });

    expect(result).toEqual({ verified: true });
    expect(prisma.phoneOtpToken.create).toHaveBeenCalled();
  });
});
