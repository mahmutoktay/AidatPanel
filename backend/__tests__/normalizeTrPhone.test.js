import { normalizeTrPhone, normalizeLoginIdentifier } from "../src/utils/normalizeTrPhone.js";

describe("normalizeTrPhone", () => {
  test("10 hane olduğu gibi", () => {
    expect(normalizeTrPhone("5551234567")).toBe("5551234567");
  });

  test("+90 prefix strip", () => {
    expect(normalizeTrPhone("+905551234567")).toBe("5551234567");
  });

  test("0 prefix strip", () => {
    expect(normalizeTrPhone("0555 123 45 67")).toBe("5551234567");
  });

  test("geçersiz numara null", () => {
    expect(normalizeTrPhone("123")).toBeNull();
    expect(normalizeTrPhone(null)).toBeNull();
  });
});

describe("normalizeLoginIdentifier", () => {
  test("email lowercase", () => {
    expect(normalizeLoginIdentifier("  Test@Example.COM ")).toBe("test@example.com");
  });

  test("telefon normalize", () => {
    expect(normalizeLoginIdentifier("05551234567")).toBe("5551234567");
  });
});
