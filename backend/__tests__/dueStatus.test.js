import {
  buildDueStatusFilterClause,
  resolveEffectiveDueStatus,
  resolveEffectiveOverdueDays,
} from "../src/utils/dueStatus.js";

describe("dueStatus", () => {
  const baseDue = {
    status: "PENDING",
    dueDate: new Date("2026-01-15T21:00:00.000Z"),
  };

  test("resolveEffectiveDueStatus PAID/WAIVED değişmez", () => {
    expect(resolveEffectiveDueStatus({ ...baseDue, status: "PAID" })).toBe("PAID");
    expect(resolveEffectiveDueStatus({ ...baseDue, status: "WAIVED" })).toBe("WAIVED");
  });

  test("resolveEffectiveDueStatus vadesi geçmiş PENDING → OVERDUE", () => {
    const past = new Date(Date.now() - 86_400_000);
    expect(
      resolveEffectiveDueStatus({ status: "PENDING", dueDate: past })
    ).toBe("OVERDUE");
  });

  test("resolveEffectiveDueStatus gelecek vade PENDING kalır", () => {
    const future = new Date(Date.now() + 86_400_000 * 30);
    expect(
      resolveEffectiveDueStatus({ status: "PENDING", dueDate: future })
    ).toBe("PENDING");
  });

  test("resolveEffectiveOverdueDays gecikmiş kayıtta pozitif", () => {
    const past = new Date(Date.now() - 86_400_000 * 3);
    expect(
      resolveEffectiveOverdueDays({ status: "PENDING", dueDate: past })
    ).toBeGreaterThan(0);
  });

  test("buildDueStatusFilterClause OVERDUE geç vadeli PENDING içerir", () => {
    const clause = buildDueStatusFilterClause("OVERDUE");
    expect(clause.OR).toEqual(
      expect.arrayContaining([
        { status: "OVERDUE" },
        expect.objectContaining({ status: "PENDING" }),
      ])
    );
  });

  test("buildDueStatusFilterClause PENDING yalnızca gelecek vade", () => {
    const clause = buildDueStatusFilterClause("PENDING");
    expect(clause.status).toBe("PENDING");
    expect(clause.dueDate.gte).toBeInstanceOf(Date);
  });
});
