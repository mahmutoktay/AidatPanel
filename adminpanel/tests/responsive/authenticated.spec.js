import { test, expect } from "@playwright/test";

const email = process.env.ADMIN_TEST_EMAIL;
const password = process.env.ADMIN_TEST_PASSWORD;

test.describe("authenticated shell", () => {
  test.skip(!email || !password, "ADMIN_TEST_EMAIL ve ADMIN_TEST_PASSWORD gerekli");

  test.beforeEach(async ({ page }) => {
    await page.goto("/auth/login");
    await page.getByLabel("E-posta adresi").fill(email);
    await page.getByLabel("Şifre").fill(password);
    await page.locator('button[type="submit"]').click();
    await expect(page).toHaveURL("/");
  });

  test("command center shows action grid", async ({ page }) => {
    await expect(page.locator(".action-grid")).toBeVisible();
    await expect(page.getByRole("link", { name: /Müşteri Gezgini/i })).toBeVisible();
  });

  test("notification dropdown toggles", async ({ page }) => {
    const bell = page.getByRole("button", { name: "Bildirimler" });
    await bell.click();
    await expect(bell).toHaveAttribute("aria-expanded", "true");
    await bell.click();
    await expect(bell).toHaveAttribute("aria-expanded", "false");
  });

  test("explorer page loads tree", async ({ page }) => {
    await page.goto("/explorer");
    await expect(page.locator(".explorer-tree")).toBeVisible();
  });

  test("search page has input", async ({ page }) => {
    await page.goto("/search");
    await expect(page.locator("#q")).toBeVisible();
  });

  test("growth and ops routes work", async ({ page }) => {
    await page.goto("/growth");
    await expect(page).toHaveURL("/growth");
    await page.goto("/ops/dekonts");
    await expect(page).toHaveURL(/\/ops\/dekonts/);
  });
});
