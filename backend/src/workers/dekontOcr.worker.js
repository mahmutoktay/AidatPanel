import { parentPort, workerData } from "worker_threads";
import fs from "fs";
import { extractDekontText } from "../services/ocrService.js";

async function main() {
  const { filePath, mimeType } = workerData ?? {};
  if (!filePath || !mimeType) {
    parentPort.postMessage({ ok: false, error: "filePath ve mimeType gerekli" });
    return;
  }

  try {
    const buffer = await fs.promises.readFile(filePath);
    const result = await extractDekontText(buffer, mimeType);
    parentPort.postMessage({ ok: true, result });
  } catch (err) {
    parentPort.postMessage({
      ok: false,
      error: err?.message || String(err),
    });
  }
}

main();
