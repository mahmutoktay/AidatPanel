import { endOfDueDayIstanbul } from "../src/utils/trDueDate.js";
import { resolveOpenDueSyncData } from "../src/services/dueExpenseRecalcService.js";

describe("resolveOpenDueSyncData", () => {
  const juneDue = { month: 6, year: 2026 };
  const nowJune15 = new Date("2026-06-15T12:00:00.000Z");

  test("Senaryo A: OVERDUE → dueDay ileri alınınca PENDING olur", () => {
    const result = resolveOpenDueSyncData(
      juneDue,
      { dueDay: 20, amount: 1000, currency: "TRY", now: nowJune15 }
    );

    expect(result.status).toBe("PENDING");
    expect(result.overdueDays).toBe(0);
    expect(result.dueDate).toEqual(endOfDueDayIstanbul(2026, 6, 20));
    expect(result.amount).toBe(1000);
  });

  test("Senaryo B: PENDING → dueDay geri alınınca OVERDUE olur", () => {
    const result = resolveOpenDueSyncData(
      juneDue,
      { dueDay: 12, amount: 500, currency: "TRY", now: nowJune15 }
    );

    expect(result.status).toBe("OVERDUE");
    expect(result.overdueDays).toBeGreaterThan(0);
    expect(result.dueDate).toEqual(endOfDueDayIstanbul(2026, 6, 12));
  });

  test("Vade günü bugün ise PENDING kalır", () => {
    const result = resolveOpenDueSyncData(
      juneDue,
      { dueDay: 15, amount: 500, currency: "TRY", now: nowJune15 }
    );

    expect(result.status).toBe("PENDING");
    expect(result.overdueDays).toBe(0);
  });
});
