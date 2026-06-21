import { DEKONT_PIPELINE_CONCURRENCY } from "../config/dekont.js";
import { logger } from "../config/logger.js";

/** @type {Array<{ run: () => Promise<void>, label?: string }>} */
const pending = [];
let active = 0;

function drain() {
  while (active < DEKONT_PIPELINE_CONCURRENCY && pending.length > 0) {
    const { run, label } = pending.shift();
    active += 1;
    Promise.resolve()
      .then(run)
      .catch((err) => {
        logger.error({ type: "dekont_queue_error", label: label ?? "pipeline", err: err?.message });
      })
      .finally(() => {
        active -= 1;
        setImmediate(drain);
      });
  }
}

/**
 * OCR pipeline işlerini sıraya alır (varsayılan eşzamanlılık: 1).
 * Aynı anda birden fazla Tesseract/pdftoppm çalışmasını engeller; API yanıt süresini korur.
 *
 * @param {() => Promise<void>} run
 * @param {{ label?: string }} [meta]
 */
export function enqueueDekontPipeline(run, meta = {}) {
  pending.push({ run, label: meta.label });
  setImmediate(drain);
}
