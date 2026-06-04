import fs from "fs";
import {
  DEKONT_UPLOAD_DIR,
  DEKONT_UPLOAD_TMP_DIR,
} from "../config/dekont.js";

/**
 * Upload / geçici dizinlerin var olduğundan emin olur (cwd bağımsız mutlak yol).
 */
export async function ensureDekontStorageDirs() {
  await fs.promises.mkdir(DEKONT_UPLOAD_DIR, { recursive: true });
  await fs.promises.mkdir(DEKONT_UPLOAD_TMP_DIR, { recursive: true });
  console.log("[dekont] storage ready", {
    uploadDir: DEKONT_UPLOAD_DIR,
    tmpDir: DEKONT_UPLOAD_TMP_DIR,
  });
}
