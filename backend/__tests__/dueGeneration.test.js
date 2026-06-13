import {
  buildDueRowsForApartments,
  buildDueRowsFromMonth,
  filterNewDueRows,
  dueLookupKeys,
} from "../src/utils/dueGeneration.js";

describe("dueGeneration", () => {
  test("buildDueRowsFromMonth üretir (Haziran–Aralık = 7 ay)", () => {
    const rows = buildDueRowsFromMonth(["apt-1"], 6, 2026, {
      dueAmount: 500,
      dueDay: 5,
      currency: "TRY",
    });
    expect(rows).toHaveLength(7);
    expect(rows[0]).toMatchObject({
      apartmentId: "apt-1",
      month: 6,
      year: 2026,
      status: "PENDING",
      currency: "TRY",
    });
    expect(rows[6].month).toBe(12);
  });

  test("dueAmount yoksa boş dizi döner", () => {
    expect(buildDueRowsFromMonth(["apt-1"], 1, 2026, { dueAmount: null })).toEqual([]);
  });

  test("filterNewDueRows mevcut kayıtları atlar", () => {
    const rows = buildDueRowsFromMonth(["a1", "a2"], 1, 2026, { dueAmount: 100 });
    const keys = dueLookupKeys([{ apartmentId: "a1", month: 1 }]);
    const fresh = filterNewDueRows(rows, keys);
    expect(fresh).toHaveLength(rows.length - 1);
    expect(fresh.every((r) => r.apartmentId !== "a1" || r.month !== 1)).toBe(true);
  });

  test("buildDueRowsForApartments İstanbul ayından yıl sonuna üretir", () => {
    const rows = buildDueRowsForApartments(["apt-x"], {
      dueAmount: 200,
      dueDay: 1,
    });
    expect(rows.length).toBeGreaterThan(0);
    expect(rows[0].year).toBeGreaterThanOrEqual(2026);
    expect(rows[rows.length - 1].month).toBe(12);
  });
});
