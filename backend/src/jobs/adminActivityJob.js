import { logger } from "../config/logger.js";
import { aggregateUserActivityDaily } from "../services/admin/adminAnalyticsService.js";

const INTERVAL_MS = Number(process.env.ADMIN_ACTIVITY_INTERVAL_MS) || 24 * 60 * 60 * 1000;

export function startAdminActivityScheduler() {
  const run = async () => {
    try {
      await aggregateUserActivityDaily();
      logger.info("Admin activity aggregation completed");
    } catch (err) {
      logger.error({ type: "admin_activity_job_failed", err: err?.message });
    }
  };

  run();
  setInterval(run, INTERVAL_MS);
  logger.info("Admin activity scheduler started", { intervalMs: INTERVAL_MS });
}
