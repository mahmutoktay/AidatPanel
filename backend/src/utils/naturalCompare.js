/**
 * Alfabetik yerine doğal (sayısal) sıralama — örn. 1, 2, 10.
 */
function splitNaturalParts(value) {
  const parts = [];
  const str = String(value).trim().toLowerCase();
  let buffer = "";
  let inDigits = null;

  for (const ch of str) {
    const isDigit = ch >= "0" && ch <= "9";
    if (buffer.length === 0) {
      inDigits = isDigit;
      buffer = ch;
      continue;
    }
    if (isDigit === inDigits) {
      buffer += ch;
    } else {
      parts.push(buffer);
      buffer = ch;
      inDigits = isDigit;
    }
  }
  if (buffer.length > 0) parts.push(buffer);
  return parts;
}

function isDigits(value) {
  return /^\d+$/.test(value);
}

export function naturalCompare(a, b) {
  const left = String(a ?? "").trim().toLowerCase();
  const right = String(b ?? "").trim().toLowerCase();
  if (left === right) return 0;

  const leftParts = splitNaturalParts(left);
  const rightParts = splitNaturalParts(right);
  const maxLen = Math.max(leftParts.length, rightParts.length);

  for (let i = 0; i < maxLen; i++) {
    const lp = leftParts[i] ?? "";
    const rp = rightParts[i] ?? "";
    if (lp === rp) continue;

    const leftIsNum = isDigits(lp);
    const rightIsNum = isDigits(rp);
    if (leftIsNum && rightIsNum) {
      const ln = Number(lp);
      const rn = Number(rp);
      if (ln !== rn) return ln < rn ? -1 : 1;
      if (lp.length !== rp.length) return lp.length < rp.length ? -1 : 1;
      continue;
    }

    const textCompare = lp.localeCompare(rp, "tr");
    if (textCompare !== 0) return textCompare;
  }

  return left.length < right.length ? -1 : left.length > right.length ? 1 : 0;
}

export function sortByNatural(items, selector = (item) => item) {
  return [...items].sort((a, b) => naturalCompare(selector(a), selector(b)));
}
