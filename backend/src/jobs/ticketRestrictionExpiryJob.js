import { logger } from "../config/logger.js";
import { processExpiredTicketRestrictions } from "../services/ticketModerationService.js";

const DEFAULT_INTERVAL_MS = 24 * 60 * 60 * 1000;
const STARTUP_DELAY_MS = 60_000;

let timer = null;

export function startTicketRestrictionExpiryJob() {
  if (process.env.TICKET_RESTRICTION_JOB_ENABLED !== "true") {
    return;
  }

  const intervalMs = Math.max(
    60_000,
    Number(process.env.TICKET_RESTRICTION_JOB_INTERVAL_MS) || DEFAULT_INTERVAL_MS
  );

  const tick = () => {
    processExpiredTicketRestrictions()
      .then((result) => {
        if (result.processed > 0) {
          logger.info({
            type: "ticket_restriction_expiry_job",
            processed: result.processed,
          });
        }
      })
      .catch((err) => {
        logger.error({
          type: "ticket_restriction_expiry_job_error",
          err: err?.message,
        });
      })
      .finally(() => {
        timer = setTimeout(tick, intervalMs);
      });
  };

  timer = setTimeout(tick, STARTUP_DELAY_MS);
  logger.info({
    type: "ticket_restriction_expiry_job_started",
    intervalMin: Math.round(intervalMs / 60_000),
  });
}

export function stopTicketRestrictionExpiryJob() {
  if (timer) {
    clearTimeout(timer);
    timer = null;
  }
}
