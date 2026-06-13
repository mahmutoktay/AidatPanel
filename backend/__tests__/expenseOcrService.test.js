import { aggregateOcrAmounts } from "../src/services/expenseOcrService.js";

describe("expenseOcrService", () => {
  test("aggregateOcrAmounts toplam ve bayrak", () => {
    const empty = aggregateOcrAmounts([
      { parsedAmount: null },
      { parsedAmount: 0 },
    ]);
    expect(empty).toEqual({ totalParsedAmount: 0, hasAnyAmount: false });

    const mixed = aggregateOcrAmounts([
      { parsedAmount: 120.5 },
      { parsedAmount: null },
      { parsedAmount: 30 },
    ]);
    expect(mixed).toEqual({ totalParsedAmount: 150.5, hasAnyAmount: true });
  });
});
