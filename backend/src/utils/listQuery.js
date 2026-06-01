import { HttpError } from "./httpError.js";

/** Liste uçlarında bellek/yanıt boyutu üst sınırı (cursor yokken) */
export const LIST_MAX_ROWS = Math.max(
  100,
  Number(process.env.LIST_MAX_ROWS) || 2500
);

/** `?cursor=` ile sayfalama varsayılan sayfa boyutu */
export const LIST_PAGE_SIZE = Math.max(
  1,
  Number(process.env.LIST_PAGE_SIZE) || 50
);

/**
 * @param {string|number|undefined} limit — istemci `?limit=` (opsiyonel)
 * @returns {number} Prisma `take` değeri (cursor modu dışı)
 */
export function resolveListTake(limit) {
  if (limit === undefined || limit === null || limit === "") {
    return LIST_MAX_ROWS;
  }
  const n = Number.parseInt(String(limit), 10);
  if (!Number.isFinite(n) || n < 1) {
    return LIST_MAX_ROWS;
  }
  return Math.min(n, LIST_MAX_ROWS);
}

/**
 * @param {string|number|undefined} limit
 * @returns {number}
 */
export function resolvePageLimit(limit) {
  if (limit === undefined || limit === null || limit === "") {
    return LIST_PAGE_SIZE;
  }
  const n = Number.parseInt(String(limit), 10);
  if (!Number.isFinite(n) || n < 1) {
    return LIST_PAGE_SIZE;
  }
  return Math.min(n, LIST_MAX_ROWS);
}

/** `?cursor=` veya `?paginated=true` gönderildiyse sayfalı yanıt */
export function wantsPaginatedList(filters = {}) {
  if (filters.paginated === true || filters.paginated === "true") {
    return true;
  }
  const c = filters.cursor;
  return typeof c === "string" && c.length > 0;
}

/**
 * @param {object} filters
 * @param {Array<Record<string, unknown>>} rows — limit+1 ile çekilmiş ham satırlar
 * @param {(row: object) => object} mapRow
 * @param {{ getCursorValue?: (row: object) => { createdAt: Date, id: string } }} [opts]
 */
export function buildListResponse(filters, rows, mapRow, opts = {}) {
  const mapped = rows.map(mapRow);

  if (!wantsPaginatedList(filters)) {
    return mapped;
  }

  const pageLimit = resolvePageLimit(filters.limit);
  const hasMore = rows.length > pageLimit;
  const page = hasMore ? mapped.slice(0, pageLimit) : mapped;
  const last = page[page.length - 1];
  const nextCursor = hasMore && last ? last.id : null;

  return { items: page, nextCursor };
}

/**
 * createdAt + id ile cursor (bildirimlerle aynı mantık).
 * @param {object} baseWhere
 * @param {string} cursorId
 * @param {(id: string) => Promise<{ id: string, createdAt: Date } | null>} findCursorRow
 */
export async function mergeCreatedAtCursorWhere(baseWhere, cursorId, findCursorRow) {
  const cursorRow = await findCursorRow(cursorId);

  if (!cursorRow) {
    throw new HttpError(400, "Geçersiz cursor.");
  }

  return {
    ...baseWhere,
    AND: [
      ...(baseWhere.AND ? [].concat(baseWhere.AND) : []),
      {
        OR: [
          { createdAt: { lt: cursorRow.createdAt } },
          { createdAt: cursorRow.createdAt, id: { lt: cursorRow.id } },
        ],
      },
    ],
  };
}
