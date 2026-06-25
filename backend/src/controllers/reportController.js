import { asyncHandler } from "../utils/asyncHandler.js";
import { HttpError } from "../utils/httpError.js";
import {
  getMonthlyReportData,
  getAnnualReportData,
} from "../services/reportDataService.js";
import {
  buildMonthlyReportPdf,
  buildAnnualReportPdf,
} from "../services/reportPdfService.js";
import { sanitizeFilenamePart } from "../utils/sanitizeFilename.js";

export const getBuildingReport = asyncHandler(async (req, res) => {
  const { id: buildingId } = req.params;
  const { type, month, year } = req.query;

  let buffer;
  let filename;

  if (type === "monthly") {
    const data = await getMonthlyReportData(buildingId, req.user.id, {
      month,
      year,
    });
    buffer = await buildMonthlyReportPdf(data);
    const m = String(data.period.month).padStart(2, "0");
    const slug = sanitizeFilenamePart(data.building.name);
    filename = `rapor-${slug}-${data.period.year}-${m}.pdf`;
  } else if (type === "annual") {
    const data = await getAnnualReportData(buildingId, req.user.id, { year });
    buffer = await buildAnnualReportPdf(data);
    const slug = sanitizeFilenamePart(data.building.name);
    filename = `rapor-yillik-${slug}-${data.period.year}.pdf`;
  } else {
    throw new HttpError(400, "Gecerli bir rapor turu secin (monthly veya annual).");
  }

  res.setHeader("Content-Type", "application/pdf");
  res.setHeader("Content-Disposition", `attachment; filename="${filename}"`);
  res.setHeader("Cache-Control", "private, no-store");
  res.setHeader("Content-Length", String(buffer.length));
  res.status(200).send(buffer);
});
