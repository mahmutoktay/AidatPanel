import { HttpError } from "./httpError.js";

/** @returns {{ start: Date, end: Date }} */
export function monthYearRange(year, month) {
  const y = parseInt(String(year), 10);
  const m = parseInt(String(month), 10);
  if (Number.isNaN(y) || Number.isNaN(m) || m < 1 || m > 12) {
    throw new HttpError(400, "Geçerli bir ay ve yıl giriniz.");
  }
  const start = new Date(Date.UTC(y, m - 1, 1, 0, 0, 0, 0));
  const end = new Date(Date.UTC(y, m, 0, 23, 59, 59, 999));
  return { start, end };
}

/** @returns {{ start: Date, end: Date }} */
export function yearRange(year) {
  const y = parseInt(String(year), 10);
  if (Number.isNaN(y)) {
    throw new HttpError(400, "Geçerli bir yıl giriniz.");
  }
  const start = new Date(Date.UTC(y, 0, 1, 0, 0, 0, 0));
  const end = new Date(Date.UTC(y, 11, 31, 23, 59, 59, 999));
  return { start, end };
}
