import fs from "fs";
import {
  DEKONT_UPLOAD_DIR,
  DEKONT_UPLOAD_TMP_DIR,
} from "../config/dekont.js";
import { logger } from "../config/logger.js";

/**
 * Upload / geçici dizinlerin var olduğundan emin olur (cwd bağımsız mutlak yol).
 */
export async function ensureDekontStorageDirs() {
  await fs.promises.mkdir(DEKONT_UPLOAD_DIR, { recursive: true });
  await fs.promises.mkdir(DEKONT_UPLOAD_TMP_DIR, { recursive: true });
  logger.info({ type: "dekont_storage_ready", uploadDir: DEKONT_UPLOAD_DIR, tmpDir: DEKONT_UPLOAD_TMP_DIR });
}
