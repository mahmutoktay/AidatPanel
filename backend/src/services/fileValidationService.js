import crypto from "crypto";
import fs from "fs";
import { fileTypeFromBuffer } from "file-type";
import { DEKONT_ALLOWED_MIMES, DEKONT_MAX_BYTES } from "../config/dekont.js";

/**
 * @param {Buffer} buffer
 * @param {{ mimetype?: string, size?: number }} file — multer file
 */
export async function validateDekontUploadFile(buffer, file) {
  if (!buffer?.length) {
    return { ok: false, code: 400, message: "Dosya boş olamaz." };
  }

  if (file.size > DEKONT_MAX_BYTES) {
    return {
      ok: false,
      code: 413,
      message: `Dosya boyutu en fazla ${Math.floor(DEKONT_MAX_BYTES / 1024 / 1024)} MB olabilir.`,
    };
  }

  const detected = await fileTypeFromBuffer(buffer);
  const mime = detected?.mime;

  if (!mime || !DEKONT_ALLOWED_MIMES.has(mime)) {
    return {
      ok: false,
      code: 400,
      message: "Desteklenmeyen dosya türü. Yalnızca PDF, JPEG veya PNG yükleyebilirsiniz.",
    };
  }

  if (file.mimetype && file.mimetype !== mime && file.mimetype !== "application/octet-stream") {
    return {
      ok: false,
      code: 400,
      message: "Dosya içeriği bildirilen türle uyuşmuyor.",
    };
  }

  if (mime === "application/pdf" && !buffer.subarray(0, 5).toString("utf8").startsWith("%PDF-")) {
    return { ok: false, code: 400, message: "Geçersiz PDF dosyası." };
  }

  const fileHash = crypto.createHash("sha256").update(buffer).digest("hex");

  return { ok: true, mime, fileHash, sizeBytes: buffer.length };
}

/**
 * Disk üzerindeki geçici dosyayı doğrular (multer diskStorage).
 * @param {string} filePath
 * @param {{ mimetype?: string, size?: number }} file
 */
export async function validateDekontUploadFileFromPath(filePath, file) {
  const stat = await fs.promises.stat(filePath).catch(() => null);
  if (!stat?.isFile()) {
    return { ok: false, code: 400, message: "Dosya okunamadı." };
  }

  const buffer = await fs.promises.readFile(filePath);
  return validateDekontUploadFile(buffer, {
    mimetype: file.mimetype,
    size: file.size ?? stat.size,
  });
}
