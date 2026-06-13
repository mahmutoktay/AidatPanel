import { endOfDueDayIstanbul, getIstanbulYearMonth } from "./trDueDate.js";

/**
 * Belirtilen ay–yıl için tek bir aidat satırı üretir.
 */
export function buildSingleDueRow(apartmentId, month, year, { dueAmount, dueDay = 1, currency = "TRY" }) {
  return {
    apartmentId,
    amount: dueAmount,
    currency,
    month,
    year,
    dueDate: endOfDueDayIstanbul(year, month, dueDay),
    status: "PENDING",
  };
}

/**
 * fromMonth → yıl sonuna kadar daire(ler) için aidat satırları üretir.
 */
export function buildDueRowsFromMonth(apartmentIds, fromMonth, year, { dueAmount, dueDay = 1, currency = "TRY" }) {
  if (!dueAmount || apartmentIds.length === 0 || fromMonth < 1 || fromMonth > 12) {
    return [];
  }

  const dueRows = [];
  for (const apartmentId of apartmentIds) {
    for (let month = fromMonth; month <= 12; month++) {
      dueRows.push(buildSingleDueRow(apartmentId, month, year, { dueAmount, dueDay, currency }));
    }
  }
  return dueRows;
}

/**
 * Bulunulan aydan (İstanbul) yıl sonuna kadar — bina/daire oluşturma akışı.
 */
export function buildDueRowsForApartments(apartmentIds, { dueAmount, dueDay = 1, currency = "TRY" }) {
  const { year, month } = getIstanbulYearMonth();
  return buildDueRowsFromMonth(apartmentIds, month, year, { dueAmount, dueDay, currency });
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
