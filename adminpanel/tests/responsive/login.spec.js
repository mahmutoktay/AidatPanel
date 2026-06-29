import { test, expect } from "@playwright/test";

const viewports = [
  { width: 320, height: 568, name: "xs" },
  { width: 480, height: 800, name: "sm" },
  { width: 768, height: 1024, name: "md" },
  { width: 1024, height: 768, name: "lg" },
  { width: 1440, height: 900, name: "xl" },
];

for (const vp of viewports) {
  test(`login page responsive ${vp.name}`, async ({ page }) => {
    await page.setViewportSize({ width: vp.width, height: vp.height });
    await page.goto("/auth/login");
    await expect(page.locator(".login-card")).toBeVisible();
    const scrollWidth = await page.evaluate(() => document.documentElement.scrollWidth);
    const clientWidth = await page.evaluate(() => document.documentElement.clientWidth);
    expect(scrollWidth).toBeLessThanOrEqual(clientWidth + 2);
  });
}

test("login form has touch-friendly button", async ({ page }) => {
  await page.goto("/auth/login");
  const box = await page.locator('button[type="submit"]').boundingBox();
  expect(box?.height).toBeGreaterThanOrEqual(44);
});

test("protected routes redirect to login", async ({ page }) => {
  const routes = ["/", "/users", "/subscriptions", "/reports/dekonts", "/audit"];
  for (const route of routes) {
    await page.goto(route);
    await expect(page).toHaveURL(/\/auth\/login/);
  }
});

test("login page has accessible form labels", async ({ page }) => {
  await page.goto("/auth/login");
  await expect(page.getByLabel("E-posta adresi")).toBeVisible();
  await expect(page.getByLabel("Şifre")).toBeVisible();
});
