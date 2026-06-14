import {
  roundMoney,
  nextPeriod,
  splitAmount,
  computePerUnitAmount,
  isPastTargetMonth,
} from "../src/services/dueExpenseRecalcService.js";

describe("dueExpenseRecalcService helpers", () => {
  test("roundMoney rounds to 2 decimals", () => {
    expect(roundMoney(10.456)).toBe(10.46);
    expect(roundMoney(10.454)).toBe(10.45);
  });

  test("nextPeriod rolls December to January next year", () => {
    expect(nextPeriod(12, 2025)).toEqual({ month: 1, year: 2026 });
    expect(nextPeriod(6, 2025)).toEqual({ month: 7, year: 2025 });
  });

  test("splitAmount divides with remainder on last part", () => {
    expect(splitAmount(100, 3)).toEqual([33.33, 33.33, 33.34]);
    expect(splitAmount(450, 1)).toEqual([450]);
  });

  test("computePerUnitAmount divides by apartment count", () => {
    expect(computePerUnitAmount(450, 3)).toBe(150);
    expect(computePerUnitAmount(100, 0)).toBe(0);
  });

  test("isPastTargetMonth detects past periods", () => {
    const now = new Date("2026-06-14T12:00:00Z");
    expect(isPastTargetMonth(5, 2026, now)).toBe(true);
    expect(isPastTargetMonth(6, 2026, now)).toBe(false);
    expect(isPastTargetMonth(7, 2026, now)).toBe(false);
  });
});
