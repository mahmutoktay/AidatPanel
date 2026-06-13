import { computeOverdueDays, endOfDueDayIstanbul } from "../src/utils/trDueDate.js";

describe("trDueDate", () => {
  test("endOfDueDayIstanbul TRT gün sonunu UTC olarak döndürür", () => {
    const d = endOfDueDayIstanbul(2026, 6, 5);
    expect(d.toISOString()).toBe("2026-06-05T20:59:59.999Z");
  });

  test("computeOverdueDays vade sonrası gün sayısını hesaplar", () => {
    const dueDate = new Date("2026-06-05T20:59:59.999Z");
    const now = new Date("2026-06-13T12:00:00.000Z");
    expect(computeOverdueDays(dueDate, now)).toBe(8);
  });

  test("computeOverdueDays vade öncesi 0 döner", () => {
    const dueDate = new Date("2026-12-31T20:59:59.999Z");
    const now = new Date("2026-06-01T00:00:00.000Z");
    expect(computeOverdueDays(dueDate, now)).toBe(0);
  });
});
