/** Jest global setup — test ortamı + test DB (.env.test) */
import { config } from "dotenv";
import { resolve, dirname } from "path";
import { fileURLToPath } from "url";

process.env.NODE_ENV = "test";

// .env.test dosyasını yükle (varsa; yoksa .env fallback)
const __dirname = dirname(fileURLToPath(import.meta.url));
const testEnvPath = resolve(__dirname, "..", ".env.test");
config({ path: testEnvPath });
