/** @deprecated Doğrudan import için `dekontStorage/index.js` kullanın — geriye uyumluluk. */
export {
  saveDekontFile,
  moveTempToDekontFile,
  resolveDekontAbsolutePath,
  dekontFileExists,
  createDekontReadStream,
  readDekontFileBuffer,
  safeDekontFilename,
  deleteDekontFile,
} from "./dekontStorage/index.js";
