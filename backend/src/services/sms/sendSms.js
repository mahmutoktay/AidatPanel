import { logger } from "../../config/logger.js";
import { sendNetgsmSms } from "./netgsmProvider.js";
import { sendTwilioSms } from "./twilioProvider.js";

/**
 * SMS sağlayıcı seçimi:
 * - SMS_PROVIDER=twilio | netgsm | auto (varsayılan auto)
 * - auto: Twilio env doluysa Twilio, değilse NetGsm, o da yoksa dev log
 */
export async function sendSms(phone10, message) {
  const provider = (process.env.SMS_PROVIDER || "auto").toLowerCase();

  const tryTwilio =
    provider === "twilio" ||
    (provider === "auto" && process.env.TWILIO_ACCOUNT_SID?.trim());

  if (tryTwilio) {
    const result = await sendTwilioSms(phone10, message);
    if (!result.skipped) {
      return result;
    }
    if (provider === "twilio") {
      logger.error({ type: "twilio_required_but_missing_env" });
      return { ok: false, error: "twilio_not_configured" };
    }
  }

  const tryNetgsm =
    provider === "netgsm" ||
    (provider === "auto" &&
      process.env.NETGSM_USER?.trim() &&
      process.env.NETGSM_PASS?.trim());

  if (tryNetgsm) {
    return sendNetgsmSms(phone10, message);
  }

  logger.info({ type: "sms_dev_skip", phone: phone10, message });
  return { ok: true, dev: true };
}
