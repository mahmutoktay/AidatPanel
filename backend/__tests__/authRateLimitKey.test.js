import { authRouteKey } from "../src/utils/authRateLimitKey.js";

const ip = "203.0.113.10";

describe("authRouteKey", () => {
  test("oturumlu istek userId kullanır", () => {
    const key = authRouteKey({
      user: { id: "user-abc" },
      path: "/logout",
      ip,
    });
    expect(key).toBe("user:user-abc");
  });

  test("login identifier bazlı anahtar üretir", () => {
    const key = authRouteKey({
      path: "/login",
      body: { identifier: "  Test@Example.COM ", password: "x" },
      ip,
    });
    expect(key).toBe("login:test@example.com");
  });

  test("login telefon identifier normalize edilir", () => {
    const key = authRouteKey({
      path: "/login",
      body: { identifier: " 5551234567 " },
      ip,
    });
    expect(key).toBe("login:5551234567");
  });

  test("register ve join farklı prefix kullanır", () => {
    const email = "a@b.com";
    expect(
      authRouteKey({ path: "/register", body: { email }, ip })
    ).toBe("register:a@b.com");
    expect(authRouteKey({ path: "/join", body: { email }, ip })).toBe(
      "join:a@b.com"
    );
  });

  test("forgot-password e-posta bazlı", () => {
    const key = authRouteKey({
      path: "/forgot-password",
      body: { email: "User@Mail.com" },
      ip,
    });
    expect(key).toBe("fp:user@mail.com");
  });

  test("reset-password token bazlı", () => {
    const key = authRouteKey({
      path: "/reset-password",
      body: { token: " ab3cde " },
      ip,
    });
    expect(key).toBe("reset:AB3CDE");
  });

  test("tanımlayıcı yoksa IP fallback", () => {
    const key = authRouteKey({ path: "/login", body: {}, ip });
    expect(key).toBe(ip);
  });

  test("otp send telefon bazlı", () => {
    const key = authRouteKey({
      path: "/otp/send",
      body: { phone: "+905551234567" },
      ip,
    });
    expect(key).toBe("otp-send:5551234567");
  });

  test("otp verify telefon bazlı", () => {
    const key = authRouteKey({
      path: "/otp/verify",
      body: { phone: "05551234567" },
      ip,
    });
    expect(key).toBe("otp-verify:5551234567");
  });

  test("invite validate kod bazlı", () => {
    const key = authRouteKey({
      path: "/invite/validate",
      body: { inviteCode: " abc123 " },
      ip,
    });
    expect(key).toBe("invite:ABC123");
  });
});
