import fs from "fs";
import os from "os";
import path from "path";
import { execFile } from "child_process";
import { promisify } from "util";
import { TESSERACT_CMD, TESSERACT_LANG } from "../config/dekont.js";

const execFileAsync = promisify(execFile);

async function withTempDir(fn) {
  const dir = await fs.promises.mkdtemp(path.join(os.tmpdir(), "aidatpanel-ocr-"));
  try {
    return await fn(dir);
  } finally {
    await fs.promises.rm(dir, { recursive: true, force: true });
  }
}

/**
 * @param {Buffer} imageBuffer PNG/JPG
 * @returns {Promise<{ text: string, ok: boolean, error?: string }>}
 */
export async function runTesseractOnImageBuffer(imageBuffer) {
  return withTempDir(async (dir) => {
    const inputPath = path.join(dir, "input.png");
    const outBase = path.join(dir, "out");
    await fs.promises.writeFile(inputPath, imageBuffer);

    try {
      await execFileAsync(TESSERACT_CMD, [
        inputPath,
        outBase,
        "-l",
        TESSERACT_LANG,
        "--dpi",
        "300",
      ]);
    } catch (err) {
      const msg = err?.stderr?.toString?.() || err?.message || "tesseract failed";
      return { ok: false, text: "", error: msg };
    }

    const txtPath = `${outBase}.txt`;
    const text = await fs.promises.readFile(txtPath, "utf8").catch(() => "");
    return { ok: true, text };
  });
}

