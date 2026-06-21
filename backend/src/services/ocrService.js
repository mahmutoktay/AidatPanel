import fs from "fs";
import os from "os";
import path from "path";
import { execFile } from "child_process";
import { promisify } from "util";
import sharp from "sharp";
import { DEKONT_MIN_TEXT_LENGTH } from "../config/dekont.js";
import { logger } from "../config/logger.js";
import { runTesseractOnImageBuffer } from "../utils/runTesseract.js";
import { parseReceiptText } from "../constants/bankReceiptProfiles.js";

const execFileAsync = promisify(execFile);

/** pdfjs-dist lazy loader — workerSrc crash önleme (Node.js ortamında browser global yok). */
let _pdfjsModule = null;
async function getPdfjs() {
  if (!_pdfjsModule) {
    _pdfjsModule = await import("pdfjs-dist/legacy/build/pdf.mjs");
    // Worker devre dışı — Node.js'te web worker yok, main thread kullan.
    _pdfjsModule.GlobalWorkerOptions.workerSrc = "";
  }
  return _pdfjsModule;
}

async function withTempDir(fn) {
  const dir = await fs.promises.mkdtemp(path.join(os.tmpdir(), "aidatpanel-pdf-"));
  try {
    return await fn(dir);
  } finally {
    await fs.promises.rm(dir, { recursive: true, force: true });
  }
}

async function pdfFirstPageToPngBuffer(pdfBuffer) {
  return withTempDir(async (dir) => {
    const inPath = path.join(dir, "in.pdf");
    const outPrefix = path.join(dir, "page");
    await fs.promises.writeFile(inPath, pdfBuffer);

    // poppler-utils: pdftoppm -f 1 -l 1 -png in.pdf page
    await execFileAsync("pdftoppm", ["-f", "1", "-l", "1", "-png", inPath, outPrefix]);

    const outPath = `${outPrefix}-1.png`;
    return await fs.promises.readFile(outPath);
  });
}

function normalizeForOcrImage(buffer) {
  return sharp(buffer)
    .rotate()
    .grayscale()
    .normalize()
    .toBuffer();
}

/**
 * pdfjs-dist ile PDF'den metin çıkarır.
 * pdf-parse (bakımsız) yerine kullanılıyor — pdfjs-dist Mozilla tarafından aktif geliştiriliyor.
 */
async function extractPdfTextWithPdfjs(pdfBuffer) {
  const { getDocument } = await getPdfjs();
  const uint8Array = new Uint8Array(pdfBuffer);
  const doc = await getDocument({ data: uint8Array, useWorkerFetch: false }).promise;
  let text = "";
  for (let i = 1; i <= doc.numPages; i++) {
    const page = await doc.getPage(i);
    const textContent = await page.getTextContent();
    text += textContent.items.map((item) => item.str).join(" ") + "\n";
  }
  return text.trim();
}

/**
 * @returns {Promise<{ rawText: string, parsed: any, profile: string, confidence: number }>}
 */
export async function extractDekontText(buffer, mimeType) {
  if (mimeType === "application/pdf") {
    // pdfjs-dist ile metin çıkarımı — başarısız olursa scanned PDF fallback
    let text = "";
    try {
      text = await extractPdfTextWithPdfjs(buffer);
    } catch (err) {
      logger.warn("pdfjs-dist metin çıkarımı başarısız, scanned PDF fallback'e geçiliyor", { error: err.message });
    }

    if (text.length >= DEKONT_MIN_TEXT_LENGTH) {
      const parsed = parseReceiptText(text);
      return { rawText: text, parsed: parsed.parsed, profile: parsed.profile, confidence: 0.95 };
    }

    // scanned PDF fallback: pdftoppm → Tesseract OCR
    const png = await pdfFirstPageToPngBuffer(buffer);
    const normalized = await normalizeForOcrImage(png);
    const ocr = await runTesseractOnImageBuffer(normalized);
    if (!ocr.ok) {
      return { rawText: "", parsed: null, profile: "OCR_FAILED", confidence: 0.0 };
    }
    const ocrText = String(ocr.text ?? "").trim();
    const parsed = parseReceiptText(ocrText);
    const confidence = ocrText.length >= DEKONT_MIN_TEXT_LENGTH ? 0.75 : 0.4;
    return { rawText: ocrText, parsed: parsed.parsed, profile: parsed.profile, confidence };
  }

  // image/jpeg or image/png
  const normalized = await normalizeForOcrImage(buffer);
  const ocr = await runTesseractOnImageBuffer(normalized);
  if (!ocr.ok) {
    return { rawText: "", parsed: null, profile: "OCR_FAILED", confidence: 0.0 };
  }
  const ocrText = String(ocr.text ?? "").trim();
  const parsed = parseReceiptText(ocrText);
  const confidence = ocrText.length >= DEKONT_MIN_TEXT_LENGTH ? 0.7 : 0.35;
  return { rawText: ocrText, parsed: parsed.parsed, profile: parsed.profile, confidence };
}

