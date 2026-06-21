import { autoGenerateAllBuildingDuesService } from "../services/dueBulkService.js";
import { markOverdueDuesService } from "../services/dueOverdueService.js";
import { logger } from "../config/logger.js";

const DEFAULT_INTERVAL_MS = 24 * 60 * 60 * 1000;
const STARTUP_DELAY_MS = 30_000;

let timer = null;

export async function runDueMaintenanceJob() {
  const generated = await autoGenerateAllBuildingDuesService();
  const overdue = await markOverdueDuesService();

  if (generated.totalCreated > 0) {
    logger.info({
      type: "due_job_generated",
      totalCreated: generated.totalCreated,
      buildingsProcessed: generated.buildingsProcessed,
    });
  }
  if (overdue.transitioned > 0 || overdue.refreshed > 0) {
    logger.info({
      type: "due_job_overdue",
      transitioned: overdue.transitioned,
      refreshed: overdue.refreshed,
    });
  }

  return { generated, overdue };
}

/** @deprecated runDueMaintenanceJob kullanın */
export async function runDueAutoGenerateJob() {
  return runDueMaintenanceJob();
}

/**
 * Günlük otomatik aidat bakımı — `DUE_AUTO_GENERATE_ENABLED=true` ile aktif.
 * 1) Eksik aidatları tamamlar (bulunulan ay → yıl sonu)
 * 2) Vadesi geçen PENDING kayıtları OVERDUE yapar
 */
export function startDueAutoGenerateScheduler() {
  if (process.env.DUE_AUTO_GENERATE_ENABLED !== "true") {
    return;
  }

  const intervalMs = Math.max(
    60_000,
    Number(process.env.DUE_AUTO_GENERATE_INTERVAL_MS) || DEFAULT_INTERVAL_MS
  );

  const tick = () => {
    runDueMaintenanceJob().catch((err) => {
      logger.error({ type: "due_job_error", err: err?.stack || err?.message });
    });
  };

  setTimeout(tick, STARTUP_DELAY_MS);
  timer = setInterval(tick, intervalMs);

  logger.info({
    type: "due_job_started",
    intervalMin: Math.round(intervalMs / 60_000),
  });
}

export function stopDueAutoGenerateScheduler() {
  if (timer) {
    clearInterval(timer);
    timer = null;
  }
}
