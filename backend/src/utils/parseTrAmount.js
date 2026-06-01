export function parseTrAmount(input) {
  if (input == null) return null;
  let s = String(input).trim();
  if (!s) return null;

  // örn: "1.250,50" → "1250.50"
  // örn: "1250,50" → "1250.50"
  // örn: "1 250,50" → "1250.50"
  s = s.replace(/\s/g, "");

  // binlik ayıracı noktayı kaldır (TR)
  // ama "1,234.56" gibi US formatı gelirse basitçe normalize et
  const hasComma = s.includes(",");
  const hasDot = s.includes(".");

  if (hasComma && hasDot) {
    // TR varsayımı: dot=binlik, comma=ondalık
    // 1.234,56
    if (s.lastIndexOf(",") > s.lastIndexOf(".")) {
      s = s.replace(/\./g, "").replace(",", ".");
    } else {
      // 1,234.56 (US)
      s = s.replace(/,/g, "");
    }
  } else if (hasComma) {
    s = s.replace(",", ".");
  }

  const n = Number(s);
  if (!Number.isFinite(n)) return null;
  return n;
}

