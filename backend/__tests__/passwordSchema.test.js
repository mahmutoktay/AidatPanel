import { passwordSchema } from "../src/validators/shared.js";

describe("passwordSchema", () => {
  test("harf + rakam kabul eder", () => {
    expect(passwordSchema.safeParse("Abc123").success).toBe(true);
  });

  test("özel karakter isteğe bağlıdır", () => {
    expect(passwordSchema.safeParse("Abc123!").success).toBe(true);
    expect(passwordSchema.safeParse("Aidat#2026").success).toBe(true);
  });

  test("yalnızca harf veya yalnızca rakam reddedilir", () => {
    expect(passwordSchema.safeParse("abcdef").success).toBe(false);
    expect(passwordSchema.safeParse("123456").success).toBe(false);
  });

  test("6 karakterden kısa reddedilir", () => {
    expect(passwordSchema.safeParse("Ab1").success).toBe(false);
  });
});
