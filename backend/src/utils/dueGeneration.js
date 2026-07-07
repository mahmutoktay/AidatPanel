import { endOfDueDayIstanbul, getIstanbulYearMonth } from "./trDueDate.js";

/**
 * Belirtilen ay–yıl için tek bir aidat satırı üretir.
 */
export function buildSingleDueRow(
  apartmentId,
  month,
  year,
  { dueAmount, dueDay = 1, currency = "TRY", residentNameSnapshot = null }
) {
  return {
    apartmentId,
    amount: dueAmount,
    currency,
    month,
    year,
    dueDate: endOfDueDayIstanbul(year, month, dueDay),
    status: "PENDING",
    residentNameSnapshot,
  };
}

/**
 * fromMonth → yıl sonuna kadar daire(ler) için aidat satırları üretir.
 */
export function buildDueRowsFromMonth(
  apartmentEntries,
  fromMonth,
  year,
  { dueAmount, dueDay = 1, currency = "TRY" }
) {
  if (!dueAmount || apartmentEntries.length === 0 || fromMonth < 1 || fromMonth > 12) {
    return [];
  }

  const dueRows = [];
  for (const entry of apartmentEntries) {
    const apartmentId = typeof entry === "string" ? entry : entry.id;
    const residentNameSnapshot =
      typeof entry === "string" ? null : entry.residentName ?? null;
    for (let month = fromMonth; month <= 12; month++) {
      dueRows.push(
        buildSingleDueRow(apartmentId, month, year, {
          dueAmount,
          dueDay,
          currency,
          residentNameSnapshot,
        })
      );
    }
  }
  return dueRows;
}

/**
 * Bulunulan aydan (İstanbul) yıl sonuna kadar — bina/daire oluşturma akışı.
 */
export function buildDueRowsForApartments(apartmentEntries, { dueAmount, dueDay = 1, currency = "TRY" }) {
  const { year, month } = getIstanbulYearMonth();
  return buildDueRowsFromMonth(apartmentEntries, month, year, { dueAmount, dueDay, currency });
}

/**
 * Mevcut kayıtları atlayarak eksik aidat satırlarını döndürür.
 * @param {string[]} apartmentIds
 * @param {Set<string>} existingKeys — `"apartmentId:month"` formatında
 */
export function filterNewDueRows(dueRows, existingKeys) {
  return dueRows.filter((row) => !existingKeys.has(`${row.apartmentId}:${row.month}`));
}

/**
 * Var olan aidat kayıtları için lookup anahtarları üretir.
 * @param {Array<{ apartmentId: string, month: number }>} existingDues
 */
export function dueLookupKeys(existingDues) {
  return new Set(existingDues.map((d) => `${d.apartmentId}:${d.month}`));
}
