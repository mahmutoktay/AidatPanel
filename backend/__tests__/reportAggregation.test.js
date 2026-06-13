import {
  summarizeDues,
  computeNet,
  resolveExpenseAmount,
  toMoneyDecimal,
} from "../src/utils/reportAggregation.js";

describe("reportAggregation", () => {
  test("summarizeDues bos liste", () => {
    const s = summarizeDues([]);
    expect(s).toMatchObject({
      expected: 0,
      collected: 0,
      totalCount: 0,
      collectionRate: 0,
    });
  });

  test("summarizeDues durum dagilimi", () => {
    const s = summarizeDues([
      { amount: 100, status: "PAID" },
      { amount: 200, status: "OVERDUE" },
      { amount: 150, status: "PENDING" },
      { amount: 50, status: "WAIVED" },
    ]);
    expect(s.expected).toBe(500);
    expect(s.collected).toBe(100);
    expect(s.overdueAmount).toBe(200);
    expect(s.pendingAmount).toBe(150);
    expect(s.waivedAmount).toBe(50);
    expect(s.paidCount).toBe(1);
    expect(s.collectionRate).toBe(20);
  });

  test("computeNet", () => {
    expect(computeNet(1000, 350)).toBe(650);
  });

  test("resolveExpenseAmount oncelik amount", () => {
    expect(resolveExpenseAmount({ amount: 10, parsedAmount: 20 })).toBe(10);
    expect(resolveExpenseAmount({ amount: null, parsedAmount: 20 })).toBe(20);
    expect(resolveExpenseAmount({ amount: null, parsedAmount: null })).toBeNull();
  });

  test("toMoneyDecimal string", () => {
    expect(toMoneyDecimal("125.50")).toBe(125.5);
  });
});
