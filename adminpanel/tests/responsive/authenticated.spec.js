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

  test("dashboard shows KPI grid", async ({ page }) => {
    await expect(page.locator(".kpi-grid")).toBeVisible();
    await expect(page.locator(".sidebar")).toBeAttached();
  });

  test("navigation links work", async ({ page }) => {
    await page.getByRole("link", { name: "Üyeler" }).click();
    await expect(page).toHaveURL("/users");
    await expect(page.locator(".page-header__title")).toContainText("Üyeler");

    await page.getByRole("link", { name: "Denetim Kayıtları" }).click();
    await expect(page).toHaveURL("/audit");
  });

  test("users page has subscription filter", async ({ page }) => {
    await page.goto("/users");
    await expect(page.locator("#hasSubscription")).toBeVisible();
  });

  test("dekonts page has status filter", async ({ page }) => {
    await page.goto("/reports/dekonts");
    await expect(page.locator("#status")).toBeVisible();
  });
});
