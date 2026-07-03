import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import { maskEmail, maskPhone, maskName } from "../src/utils/piiMasking.js";
import {
  generateAdminAccessToken,
  generateAdminRefreshToken,
} from "../src/utils/adminTokens.js";

describe("piiMasking", () => {
  it("masks email", () => {
    expect(maskEmail("test@example.com")).toMatch(/@example\.com$/);
    expect(maskEmail("test@example.com")).not.toBe("test@example.com");
  });

  it("masks phone", () => {
    expect(maskPhone("5551234567")).toContain("***");
  });

  it("masks name", () => {
    expect(maskName("Ahmet Yılmaz")).toBe("Ahmet Y.");
  });
});

describe("adminTokens", () => {
  beforeAll(() => {
    process.env.ADMIN_JWT_SECRET = "test_admin_jwt_secret_minimum_32_chars_ok";
  });

  it("generates and verifies admin access token", () => {
    const admin = { id: "admin-1", role: "SUPER_ADMIN" };
    const token = generateAdminAccessToken(admin);
    expect(typeof token).toBe("string");
    const decoded = jwt.verify(token, process.env.ADMIN_JWT_SECRET);
    expect(decoded.id).toBe("admin-1");
    expect(decoded.type).toBe("admin");
  });

  it("generates refresh token", () => {
    const admin = { id: "admin-1", role: "SUPPORT" };
    const token = generateAdminRefreshToken(admin);
    const decoded = jwt.verify(token, process.env.ADMIN_JWT_SECRET);
    expect(decoded.type).toBe("admin_refresh");
  });
});

describe("admin password hash", () => {
  it("hashes password with bcrypt", async () => {
    const hash = await bcrypt.hash("Admin123!", 4);
    expect(await bcrypt.compare("Admin123!", hash)).toBe(true);
  });
});
