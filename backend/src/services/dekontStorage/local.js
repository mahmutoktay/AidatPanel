import fs from "fs";
import path from "path";
import { createReadStream } from "fs";
import { DEKONT_UPLOAD_DIR } from "../../config/dekont.js";

export function extensionForMime(mimeType) {
  if (mimeType === "application/pdf") return ".pdf";
  if (mimeType === "image/png") return ".png";
  if (mimeType === "image/jpeg") return ".jpg";
  return "";
}

/**
 * Rol alt dizinini belirler.
 * source: "RESIDENT_UPLOAD" → "Sakinler"
 * source: "MANAGER_UPLOAD"  → "Yoneticiler"
 * source: "EXPENSE"         → "Giderler"
 */
function resolveRoleSubdir(source) {
  if (source === "RESIDENT_UPLOAD") return "Sakinler";
  if (source === "MANAGER_UPLOAD") return "Yoneticiler";
  if (source === "EXPENSE") return "Giderler";
  return "Diger";
}

/**
 * Yeni klasör hiyerarşisi:
 *   Binalar/{buildingId}/{Sakinler|Yoneticiler|Giderler}/{dekontId}.ext
 *
 * @param {object} opts
 * @param {string} opts.buildingId
 * @param {string} opts.dekontId
 * @param {string} opts.mimeType
 * @param {string} [opts.source] — "RESIDENT_UPLOAD" | "MANAGER_UPLOAD" | "EXPENSE"
 * @returns {Promise<string>} storedPath — göreli yol (DB'de saklanır)
 */
export async function saveDekontFile(buffer, { buildingId, dekontId, mimeType, source }) {
  const ext = extensionForMime(mimeType);
  const subdir = resolveRoleSubdir(source);
  const relativePath = path.join("Binalar", buildingId, subdir, `${dekontId}${ext}`);
  const absolutePath = path.join(DEKONT_UPLOAD_DIR, relativePath);
  await fs.promises.mkdir(path.dirname(absolutePath), { recursive: true });
  await fs.promises.writeFile(absolutePath, buffer);
  return relativePath.replace(/\\/g, "/");
}

/**
 * Geçici upload dosyasını kalıcı konuma taşır (ek bellek kopyası yok).
 * @param {string} tempAbsolutePath
 */
export async function moveTempToDekontFile(
  tempAbsolutePath,
  { buildingId, dekontId, mimeType, source }
) {
  const ext = extensionForMime(mimeType);
  const subdir = resolveRoleSubdir(source);
  const relativePath = path.join("Binalar", buildingId, subdir, `${dekontId}${ext}`);
  const absolutePath = path.join(DEKONT_UPLOAD_DIR, relativePath);
  await fs.promises.mkdir(path.dirname(absolutePath), { recursive: true });

  try {
    await fs.promises.rename(tempAbsolutePath, absolutePath);
  } catch (err) {
    if (err.code !== "EXDEV") {
      throw err;
    }
    await fs.promises.copyFile(tempAbsolutePath, absolutePath);
    await fs.promises.unlink(tempAbsolutePath);
  }

  return relativePath.replace(/\\/g, "/");
}

export function resolveDekontAbsolutePath(storedPath) {
  return path.join(DEKONT_UPLOAD_DIR, storedPath);
}

export async function dekontFileExists(storedPath) {
  try {
    await fs.promises.access(resolveDekontAbsolutePath(storedPath), fs.constants.R_OK);
    return true;
  } catch {
    return false;
  }
}

export function createDekontReadStream(storedPath) {
  return createReadStream(resolveDekontAbsolutePath(storedPath));
}

export async function readDekontFileBuffer(storedPath) {
  return fs.promises.readFile(resolveDekontAbsolutePath(storedPath));
}

export function safeDekontFilename(dekont) {
  const base =
    dekont.originalFilename?.replace(/[^\w.\-() ]+/g, "_").slice(0, 120) ||
    `dekont-${dekont.id}`;
  if (base.includes(".")) return base;
  const ext = extensionForMime(dekont.mimeType);
  return `${base}${ext}`;
}

export async function deleteDekontFile(storedPath) {
  try {
    await fs.promises.unlink(resolveDekontAbsolutePath(storedPath));
  } catch (err) {
    if (err.code !== "ENOENT") throw err;
  }
}
