import { autoGenerateAllBuildingDuesService } from "../services/dueBulkService.js";
import { markOverdueDuesService } from "../services/dueOverdueService.js";

const DEFAULT_INTERVAL_MS = 24 * 60 * 60 * 1000;
const STARTUP_DELAY_MS = 30_000;

let timer = null;

export async function runDueMaintenanceJob() {
  const generated = await autoGenerateAllBuildingDuesService();
  const overdue = await markOverdueDuesService();

  if (generated.totalCreated > 0) {
    console.info(
      `[due-job] ${generated.totalCreated} aidat oluşturuldu (${generated.buildingsProcessed} bina)`
    );
  }
  if (overdue.transitioned > 0 || overdue.refreshed > 0) {
    console.info(
      `[due-job] gecikme: ${overdue.transitioned} PENDING→OVERDUE, ${overdue.refreshed} overdueDays güncellendi`
    );
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
      console.error("[due-job] hata:", err?.stack || err);
    });
  };

  setTimeout(tick, STARTUP_DELAY_MS);
  timer = setInterval(tick, intervalMs);

  console.info(
    `[due-job] Otomatik aidat bakımı aktif (üretim + gecikme; aralık: ${Math.round(intervalMs / 60_000)} dk)`
  );
}

export function stopDueAutoGenerateScheduler() {
  if (timer) {
    clearInterval(timer);
    timer = null;
  }
}
