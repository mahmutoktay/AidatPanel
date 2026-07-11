import {
  allocateAmountFifo,
  computeDuePaymentTotals,
  isDueFullyPaid,
  parseDueIdsFromBody,
  withinAmountTolerance,
} from "../src/utils/duePaymentTotals.js";

describe("duePaymentTotals", () => {
  test("computeDuePaymentTotals remaining", () => {
    const due = {
      amount: 1000,
      payments: [{ amount: 600 }, { amount: 100 }],
    };
    expect(computeDuePaymentTotals(due)).toEqual({
      amount: 1000,
      paidAmount: 700,
      remainingAmount: 300,
    });
  });

  test("isDueFullyPaid with partial", () => {
    expect(
      isDueFullyPaid({ amount: 1000, payments: [{ amount: 600 }] })
    ).toBe(false);
    expect(
      isDueFullyPaid({ amount: 1000, payments: [{ amount: 1000 }] })
    ).toBe(true);
  });

  test("allocateAmountFifo oldest first across two dues", () => {
    const dues = [
      { id: "b", year: 2026, month: 7, amount: 500, payments: [] },
      { id: "a", year: 2026, month: 6, amount: 500, payments: [] },
    ];
    const { allocations, leftover } = allocateAmountFifo(dues, 700);
    expect(allocations).toHaveLength(2);
    expect(allocations[0].due.id).toBe("a");
    expect(allocations[0].amount).toBe(500);
    expect(allocations[1].due.id).toBe("b");
    expect(allocations[1].amount).toBe(200);
    expect(leftover).toBe(0);
  });

  test("withinAmountTolerance", () => {
    expect(withinAmountTolerance(100, 100)).toBe(true);
    expect(withinAmountTolerance(95, 100)).toBe(true);
    expect(withinAmountTolerance(50, 100)).toBe(false);
  });

  test("parseDueIdsFromBody", () => {
    expect(parseDueIdsFromBody({ dueId: "11111111-1111-1111-1111-111111111111" })).toEqual([
      "11111111-1111-1111-1111-111111111111",
    ]);
    expect(
      parseDueIdsFromBody({
        dueIds: JSON.stringify([
          "11111111-1111-1111-1111-111111111111",
          "22222222-2222-2222-2222-222222222222",
        ]),
      })
    ).toHaveLength(2);
  });
});
