import fs from "fs";
import { validateDekontUploadFile, validateDekontUploadFileFromPath } from "../services/fileValidationService.js";

/**
 * Multer dosyasından doğrulama (bellek veya disk).
 * @param {Express.Multer.File} file
 */
export async function validateMulterDekontFile(file) {
  if (file.path) {
    return validateDekontUploadFileFromPath(file.path, file);
  }
  if (file.buffer?.length) {
    return validateDekontUploadFile(file.buffer, file);
  }
  return { ok: false, code: 400, message: "Dosya okunamadı." };
}

/** Geçici multer dosyasını güvenle sil */
export async function cleanupMulterTempFile(file) {
  if (!file?.path) return;
  await fs.promises.unlink(file.path).catch(() => {});
}
