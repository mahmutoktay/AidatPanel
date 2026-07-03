import fs from "node:fs";
import PDFDocument from "pdfkit";
import {
  MONTH_NAMES_TR,
  DUE_STATUS_LABELS,
} from "../constants/reportLabels.js";

const PAGE_WIDTH = 595.28;
const MARGIN = 48;
const CONTENT_WIDTH = PAGE_WIDTH - MARGIN * 2;

const FONT_CANDIDATES = [
  "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
  "/usr/share/fonts/TTF/DejaVuSans.ttf",
  "/usr/share/fonts/liberation/LiberationSans-Regular.ttf",
];

function resolveFontPath() {
  for (const path of FONT_CANDIDATES) {
    if (fs.existsSync(path)) return path;
  }
  return null;
}

function bufferFromDoc(doc) {
  return new Promise((resolve, reject) => {
    const chunks = [];
    doc.on("data", (chunk) => chunks.push(chunk));
    doc.on("end", () => resolve(Buffer.concat(chunks)));
    doc.on("error", reject);
  });
}

function applyFont(doc, fontPath, size) {
  if (fontPath) {
    doc.font(fontPath);
  } else {
    doc.font("Helvetica");
  }
  doc.fontSize(size);
}

function ensureSpace(doc, y, needed, fontPath) {
  const pageBottom = doc.page.height - MARGIN;
  if (y + needed > pageBottom) {
    doc.addPage();
    return MARGIN;
  }
  return y;
}

function drawSectionTitle(doc, fontPath, y, title) {
  y = ensureSpace(doc, y, 28, fontPath);
  applyFont(doc, fontPath, 14);
  doc.fillColor("#111111").text(title, MARGIN, y, { width: CONTENT_WIDTH });
  y += 22;
  doc
    .moveTo(MARGIN, y)
    .lineTo(MARGIN + CONTENT_WIDTH, y)
    .strokeColor("#cccccc")
    .stroke();
  return y + 12;
}

function drawKeyValueRows(doc, fontPath, y, rows) {
  applyFont(doc, fontPath, 11);
  for (const row of rows) {
    y = ensureSpace(doc, y, 18, fontPath);
    doc.fillColor("#333333").text(row.label, MARGIN, y, { width: 200 });
    doc.fillColor("#111111").text(row.value, MARGIN + 210, y, {
      width: CONTENT_WIDTH - 210,
    });
    y += 16;
  }
  return y + 8;
}

function drawTableHeader(doc, fontPath, y, columns) {
  y = ensureSpace(doc, y, 22, fontPath);
  applyFont(doc, fontPath, 10);
  doc.fillColor("#ffffff");
  doc.rect(MARGIN, y - 2, CONTENT_WIDTH, 18).fill("#2c5282");

  let x = MARGIN + 6;
  for (const col of columns) {
    doc.fillColor("#ffffff").text(col.label, x, y, {
      width: col.width - 8,
      lineBreak: false,
    });
    x += col.width;
  }
  return y + 20;
}

function drawTableRow(doc, fontPath, y, columns, values, shaded) {
  y = ensureSpace(doc, y, 18, fontPath);
  if (shaded) {
    doc.rect(MARGIN, y - 2, CONTENT_WIDTH, 16).fill("#f5f7fa");
  }
  applyFont(doc, fontPath, 9);
  let x = MARGIN + 6;
  let idx = 0;
  for (const col of columns) {
    doc.fillColor("#222222").text(String(values[idx] ?? ""), x, y, {
      width: col.width - 8,
      lineBreak: false,
    });
    x += col.width;
    idx += 1;
  }
  return y + 16;
}

function formatDateTr(iso) {
  if (!iso) return "-";
  const d = new Date(iso);
  const day = String(d.getUTCDate()).padStart(2, "0");
  const month = String(d.getUTCMonth() + 1).padStart(2, "0");
  const year = d.getUTCFullYear();
  return `${day}.${month}.${year}`;
}

function renderHeader(doc, fontPath, data, subtitle) {
  let y = MARGIN;
  applyFont(doc, fontPath, 18);
  doc.fillColor("#111111").text("AidatPanel Raporu", MARGIN, y);
  y += 26;

  applyFont(doc, fontPath, 14);
  doc.text(data.building.name, MARGIN, y);
  y += 18;

  applyFont(doc, fontPath, 11);
  doc.fillColor("#444444");
  const address = [data.building.address, data.building.city]
    .filter(Boolean)
    .join(", ");
  if (address) {
    doc.text(address, MARGIN, y, { width: CONTENT_WIDTH });
    y += 16;
  }

  doc.fillColor("#111111").text(subtitle, MARGIN, y);
  y += 16;
  doc
    .fillColor("#666666")
    .text(`Yonetici: ${data.managerName}`, MARGIN, y);
  y += 14;
  doc.text(`Olusturma: ${formatDateTr(data.generatedAt)}`, MARGIN, y);
  return y + 20;
}

export async function buildMonthlyReportPdf(data) {
  const fontPath = resolveFontPath();
  const doc = new PDFDocument({ size: "A4", margin: MARGIN });
  const bufferPromise = bufferFromDoc(doc);

  const monthName = MONTH_NAMES_TR[data.period.month] ?? String(data.period.month);
  const subtitle = `${monthName} ${data.period.year} — Aylik Ozet`;

  let y = renderHeader(doc, fontPath, data, subtitle);

  y = drawSectionTitle(doc, fontPath, y, "Ozet");
  y = drawKeyValueRows(doc, fontPath, y, [
    {
      label: "Doluluk",
      value: `${data.occupancy.occupied} / ${data.occupancy.total} daire`,
    },
    {
      label: "Beklenen aidat",
      value: data.dues.summary.expectedFormatted,
    },
    {
      label: "Tahsil edilen",
      value: `${data.dues.summary.collectedFormatted} (%${data.dues.summary.collectionRateRounded})`,
    },
    {
      label: "Geciken",
      value: `${data.dues.summary.overdueCount} kayit — ${data.dues.summary.overdueAmountFormatted}`,
    },
    {
      label: "Toplam gider",
      value: data.expenses.totalAmountFormatted,
    },
    {
      label: "Donem net",
      value: data.financial.netFormatted,
    },
  ]);

  if (data.expenses.uncalculatedCount > 0) {
    y = drawKeyValueRows(doc, fontPath, y, [
      {
        label: "Hesaplanmayan gider",
        value: `${data.expenses.uncalculatedCount} kayit (OCR bekliyor)`,
      },
    ]);
  }

  y = drawSectionTitle(doc, fontPath, y, "Aidat Detayi");
  const dueCols = [
    { label: "Daire", width: 70 },
    { label: "Sakin", width: 120 },
    { label: "Tutar", width: 85 },
    { label: "Durum", width: 75 },
    { label: "Odeme", width: 75 },
    { label: "Gec.", width: 40 },
  ];
  y = drawTableHeader(doc, fontPath, y, dueCols);
  data.dues.rows.forEach((row, i) => {
    y = drawTableRow(
      doc,
      fontPath,
      y,
      dueCols,
      [
        row.apartmentNumber,
        row.residentName,
        row.amountFormatted,
        DUE_STATUS_LABELS[row.status] ?? row.status,
        formatDateTr(row.paidAt),
        row.overdueDays > 0 ? String(row.overdueDays) : "-",
      ],
      i % 2 === 1
    );
  });

  y = drawSectionTitle(doc, fontPath, y, "Giderler (Kategori)");
  const expCols = [
    { label: "Kategori", width: 180 },
    { label: "Adet", width: 80 },
    { label: "Tutar", width: CONTENT_WIDTH - 260 },
  ];
  y = drawTableHeader(doc, fontPath, y, expCols);
  if (data.expenses.byCategory.length === 0) {
    y = drawTableRow(doc, fontPath, y, expCols, ["Kayit yok", "0", "0.00"], false);
  } else {
    data.expenses.byCategory.forEach((row, i) => {
      y = drawTableRow(
        doc,
        fontPath,
        y,
        expCols,
        [row.label, String(row.count), row.amountFormatted],
        i % 2 === 1
      );
    });
  }

  if (data.expenses.items.length > 0) {
    y = drawSectionTitle(doc, fontPath, y, "Gider Listesi");
    const listCols = [
      { label: "Tarih", width: 70 },
      { label: "Baslik", width: 180 },
      { label: "Kategori", width: 90 },
      { label: "Tutar", width: CONTENT_WIDTH - 340 },
    ];
    y = drawTableHeader(doc, fontPath, y, listCols);
    data.expenses.items.forEach((row, i) => {
      y = drawTableRow(
        doc,
        fontPath,
        y,
        listCols,
        [
          formatDateTr(row.date),
          row.title,
          row.categoryLabel,
          row.amountFormatted,
        ],
        i % 2 === 1
      );
    });
  }

  y = drawSectionTitle(doc, fontPath, y, "Operasyonel");
  y = drawKeyValueRows(doc, fontPath, y, [
    { label: "Yeni talep", value: String(data.operational.ticketsOpened) },
    { label: "Cozulen talep", value: String(data.operational.ticketsResolved) },
    { label: "Acik talep", value: String(data.operational.ticketsOpen) },
    { label: "Dekont yukleme", value: String(data.operational.dekontUploaded) },
    { label: "Onaylanan dekont", value: String(data.operational.dekontApproved) },
    { label: "Inceleme bekleyen", value: String(data.operational.dekontPending) },
    { label: "Duyuru", value: String(data.operational.announcements) },
  ]);

  applyFont(doc, fontPath, 8);
  y = ensureSpace(doc, y, 30, fontPath);
  doc.fillColor("#888888").text(data.financial.note, MARGIN, y, {
    width: CONTENT_WIDTH,
  });

  doc.end();
  return bufferPromise;
}

export async function buildAnnualReportPdf(data) {
  const fontPath = resolveFontPath();
  const doc = new PDFDocument({ size: "A4", margin: MARGIN });
  const bufferPromise = bufferFromDoc(doc);

  const subtitle = `${data.period.year} — Yillik Ozet`;
  let y = renderHeader(doc, fontPath, data, subtitle);

  y = drawSectionTitle(doc, fontPath, y, "Yillik Ozet");
  y = drawKeyValueRows(doc, fontPath, y, [
    {
      label: "Doluluk",
      value: `${data.occupancy.occupied} / ${data.occupancy.total} daire`,
    },
    {
      label: "Beklenen aidat",
      value: data.yearSummary.expectedFormatted,
    },
    {
      label: "Tahsil edilen",
      value: `${data.yearSummary.collectedFormatted} (%${data.yearSummary.collectionRateRounded})`,
    },
    {
      label: "Toplam gider",
      value: data.yearSummary.expensesFormatted,
    },
    {
      label: "Yillik net",
      value: data.yearSummary.netFormatted,
    },
  ]);

  y = drawSectionTitle(doc, fontPath, y, "Aylik Tablo");
  const monthCols = [
    { label: "Ay", width: 70 },
    { label: "Tahsil", width: 110 },
    { label: "Gider", width: 110 },
    { label: "Net", width: 110 },
    { label: "%", width: CONTENT_WIDTH - 400 },
  ];
  y = drawTableHeader(doc, fontPath, y, monthCols);
  data.monthlyRows.forEach((row, i) => {
    const monthLabel = MONTH_NAMES_TR[row.month] ?? String(row.month);
    y = drawTableRow(
      doc,
      fontPath,
      y,
      monthCols,
      [
        monthLabel,
        row.collectedFormatted,
        row.expensesFormatted,
        row.netFormatted,
        String(row.collectionRateRounded),
      ],
      i % 2 === 1
    );
  });

  y = drawSectionTitle(doc, fontPath, y, "Yillik Gider (Kategori)");
  const expCols = [
    { label: "Kategori", width: 180 },
    { label: "Adet", width: 80 },
    { label: "Tutar", width: CONTENT_WIDTH - 260 },
  ];
  y = drawTableHeader(doc, fontPath, y, expCols);
  if (data.expenses.byCategory.length === 0) {
    y = drawTableRow(doc, fontPath, y, expCols, ["Kayit yok", "0", "0.00"], false);
  } else {
    data.expenses.byCategory.forEach((row, i) => {
      y = drawTableRow(
        doc,
        fontPath,
        y,
        expCols,
        [row.label, String(row.count), row.amountFormatted],
        i % 2 === 1
      );
    });
  }

  y = drawSectionTitle(doc, fontPath, y, "Operasyonel (Yil)");
  y = drawKeyValueRows(doc, fontPath, y, [
    { label: "Yeni talep", value: String(data.operational.ticketsOpened) },
    { label: "Cozulen talep", value: String(data.operational.ticketsResolved) },
    { label: "Acik talep", value: String(data.operational.ticketsOpen) },
    { label: "Dekont yukleme", value: String(data.operational.dekontUploaded) },
    { label: "Onaylanan dekont", value: String(data.operational.dekontApproved) },
    { label: "Duyuru", value: String(data.operational.announcements) },
  ]);

  applyFont(doc, fontPath, 8);
  y = ensureSpace(doc, y, 30, fontPath);
  doc.fillColor("#888888").text(data.financial.note, MARGIN, y, {
    width: CONTENT_WIDTH,
  });

  doc.end();
  return bufferPromise;
}

export async function buildMonthlySiteReportPdf(data) {
  const doc = new PDFDocument({ margin: MARGIN, size: "A4" });
  const bufferPromise = bufferFromDoc(doc);
  const fontPath = resolveFontPath();

  let y = MARGIN;
  applyFont(doc, fontPath, 18);
  doc.fillColor("#111111").text("Site Aylik Rapor", MARGIN, y);
  y += 28;
  applyFont(doc, fontPath, 12);
  doc.text(`${data.site.name} — ${data.period.month}/${data.period.year}`, MARGIN, y);
  y += 24;

  y = drawKeyValueRows(doc, fontPath, y, [
    { label: "Adres", value: `${data.site.address}, ${data.site.city}` },
    { label: "Blok sayisi", value: String(data.buildings.length) },
    { label: "Daire", value: `${data.occupancy.occupied}/${data.occupancy.total}` },
    { label: "Tahsil", value: data.dues.summary.collectedFormatted },
    { label: "Site gideri", value: data.siteExpenses.totalAmountFormatted },
    { label: "Net", value: data.financial.netFormatted },
  ]);

  y = drawSectionTitle(doc, fontPath, y, "Aidatlar");
  const cols = [
    { label: "Blok", width: 80 },
    { label: "Daire", width: 60 },
    { label: "Sakin", width: 120 },
    { label: "Tutar", width: 80 },
    { label: "Durum", width: CONTENT_WIDTH - 340 },
  ];
  y = drawTableHeader(doc, fontPath, y, cols);
  data.dues.rows.forEach((row, i) => {
    y = drawTableRow(
      doc,
      fontPath,
      y,
      cols,
      [
        row.buildingName,
        row.apartmentNumber,
        row.residentName,
        row.amountFormatted,
        DUE_STATUS_LABELS[row.status] ?? row.status,
      ],
      i % 2 === 1
    );
  });

  doc.end();
  return bufferPromise;
}

export async function buildAnnualSiteReportPdf(data) {
  const doc = new PDFDocument({ margin: MARGIN, size: "A4" });
  const bufferPromise = bufferFromDoc(doc);
  const fontPath = resolveFontPath();

  let y = MARGIN;
  applyFont(doc, fontPath, 18);
  doc.fillColor("#111111").text("Site Yillik Rapor", MARGIN, y);
  y += 28;
  applyFont(doc, fontPath, 12);
  doc.text(`${data.site.name} — ${data.period.year}`, MARGIN, y);
  y += 24;

  y = drawKeyValueRows(doc, fontPath, y, [
    { label: "Tahsil", value: data.yearSummary.collectedFormatted },
    { label: "Gider", value: data.yearSummary.expensesFormatted },
    { label: "Net", value: data.yearSummary.netFormatted },
  ]);

  doc.end();
  return bufferPromise;
}
