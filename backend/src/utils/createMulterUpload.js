import fs from "node:fs";
import crypto from "node:crypto";
import path from "node:path";
import multer from "multer";

import { extensionForMime } from "../services/fileValidationService.js";
import {
  DEKONT_UPLOAD_TMP_DIR,
  DEKONT_MAX_BYTES,
  DEKONT_ALLOWED_MIMES,
} from "../config/dekont.js";

/**
 * Multer disk storage yapılandırması oluşturur.
 *
 * - Dekont ve gider kanıt yüklemesi için ortak konfigürasyon.
 * - Dosya adı: randomUUID + uzantı.
 *
 * @param {object} [options]
 * @param {string} [options.filenamePrefix]  Dosya adı ön eki (örn. "exp_")
 * @param {number} [options.maxFileSize]         Bayt cinsinden max dosya boyutu (varsayılan: DEKONT_MAX_BYTES)
 * @returns {import("multer").Multer}
 */
export function createDiskUpload(options = {}) {
  const { filenamePrefix = "", maxFileSize = DEKONT_MAX_BYTES } = options;

  return multer({
    storage: multer.diskStorage({
      destination: (_req, _file, cb) => {
        fs.mkdir(DEKONT_UPLOAD_TMP_DIR, { recursive: true }, (err) => {
          cb(err, DEKONT_UPLOAD_TMP_DIR);
        });
      },
      filename: (_req, file, cb) => {
        const ext =
          extensionForMime(file.mimetype) ||
          path.extname(file.originalname || "") ||
          ".bin";
        cb(null, `${filenamePrefix}${crypto.randomUUID()}${ext}`);
      },
    }),
    limits: { fileSize: maxFileSize },
    // fileFilter kasıtlı boş — MIME doğrulaması fileValidationService'a bırakıldı.
    // Client MIME değeri güvenilmez; magic-byte kontrolü servis katmanında yapılır.
  });
}
