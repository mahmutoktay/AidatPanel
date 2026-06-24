import { HttpError } from "../utils/httpError.js";
import {
  getMonthlySiteReportData,
  getAnnualSiteReportData,
} from "../services/reportDataService.js";
import {
  buildMonthlySiteReportPdf,
  buildAnnualSiteReportPdf,
} from "../services/reportPdfService.js";

const handleHttp = (err, res, next) => {
  if (err instanceof HttpError) {
    return res.status(err.statusCode).json({
      success: false,
      message: err.message,
    });
  }
  next(err);
};

function sanitizeFilenamePart(value) {
  return String(value)
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .replace(/[^a-zA-Z0-9._-]+/g, "-")
    .replace(/^-+|-+$/g, "")
    .slice(0, 60) || "site";
}

export const getSiteReport = async (req, res, next) => {
  try {
    const { id: siteId } = req.params;
    const { type, month, year } = req.query;

    let buffer;
    let filename;

    if (type === "monthly") {
      const data = await getMonthlySiteReportData(siteId, req.user.id, {
        month,
        year,
      });
      buffer = await buildMonthlySiteReportPdf(data);
      const m = String(data.period.month).padStart(2, "0");
      const slug = sanitizeFilenamePart(data.site.name);
      filename = `site-rapor-${slug}-${data.period.year}-${m}.pdf`;
    } else if (type === "annual") {
      const data = await getAnnualSiteReportData(siteId, req.user.id, { year });
      buffer = await buildAnnualSiteReportPdf(data);
      const slug = sanitizeFilenamePart(data.site.name);
      filename = `site-rapor-yillik-${slug}-${data.period.year}.pdf`;
    } else {
      throw new HttpError(400, "Gecerli bir rapor turu secin (monthly veya annual).");
    }

    res.setHeader("Content-Type", "application/pdf");
    res.setHeader("Content-Disposition", `attachment; filename="${filename}"`);
    res.setHeader("Cache-Control", "private, no-store");
    res.setHeader("Content-Length", String(buffer.length));
    res.status(200).send(buffer);
  } catch (err) {
    handleHttp(err, res, next);
  }
};
