import crypto from "crypto";
import fs from "fs";
import { fileTypeFromBuffer, fileTypeFromStream } from "file-type";
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

  const sizeBytes = file.size ?? stat.size;
  if (sizeBytes > DEKONT_MAX_BYTES) {
    return {
      ok: false,
      code: 413,
      message: `Dosya boyutu en fazla ${Math.floor(DEKONT_MAX_BYTES / 1024 / 1024)} MB olabilir.`,
    };
  }

  // 1. Dosya türünü tespit et (Magic Bytes) - Stream üzerinden
  const readStreamForType = fs.createReadStream(filePath);
  let detected;
  try {
    detected = await fileTypeFromStream(readStreamForType);
  } catch (err) {
    readStreamForType.destroy();
    return { ok: false, code: 400, message: "Dosya türü okunamadı." };
  }
  readStreamForType.destroy();

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

  // 2. Hash hesapla ve PDF imzasını doğrula (Stream ile)
  return new Promise((resolve, reject) => {
    const hashStream = crypto.createHash("sha256");
    const readStreamForHash = fs.createReadStream(filePath);
    let isPdfSignatureValid = true;
    let bytesRead = 0;
    let pdfChecked = false;

    readStreamForHash.on('data', (chunk) => {
      hashStream.update(chunk);
      
      if (mime === "application/pdf" && !pdfChecked) {
        if (bytesRead === 0 && chunk.length >= 5) {
          isPdfSignatureValid = chunk.subarray(0, 5).toString("utf8") === "%PDF-";
          pdfChecked = true;
        }
      }
      bytesRead += chunk.length;
    });

    readStreamForHash.on('end', () => {
      if (mime === "application/pdf" && !isPdfSignatureValid) {
        resolve({ ok: false, code: 400, message: "Geçersiz PDF dosyası." });
        return;
      }
      const fileHash = hashStream.digest("hex");
      resolve({ ok: true, mime, fileHash, sizeBytes });
    });

    readStreamForHash.on('error', (err) => {
      resolve({ ok: false, code: 500, message: "Dosya okunurken bir hata oluştu." });
    });
  });
}
