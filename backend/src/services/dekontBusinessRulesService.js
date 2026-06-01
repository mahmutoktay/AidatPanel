import { prisma } from "../config/db.js";
import { ibansMatch } from "../utils/iban.js";
import { HttpError } from "../utils/httpError.js";

const AMOUNT_TOLERANCE = Number(process.env.DEKONT_AMOUNT_TOLERANCE) || 0.05;
const GRACE_DAYS = Number(process.env.DEKONT_GRACE_DAYS) || 7;

function withinTolerance(a, b) {
  if (a == null || b == null) return false;
  const aa = Number(a);
  const bb = Number(b);
  if (!Number.isFinite(aa) || !Number.isFinite(bb) || bb === 0) return false;
  return Math.abs(aa - bb) / Math.abs(bb) <= AMOUNT_TOLERANCE;
}

function addDays(date, days) {
  const d = new Date(date);
  d.setUTCDate(d.getUTCDate() + days);
  return d;
}

export async function evaluateDekontBusinessRules(dekontId, parsed) {
  const dekont = await prisma.dekont.findUnique({
    where: { id: dekontId },
    include: {
      building: true,
      due: true,
    },
  });
  if (!dekont) throw new HttpError(404, "Dekont bulunamadı.");

  const result = {
    recipientOk: null,
    amountOk: null,
    dateOk: null,
    referenceUnique: null,
    suggestedStatus: "NEEDS_MANAGER_REVIEW",
    reasons: [],
  };

  if (!dekont.building.collectionIban) {
    result.reasons.push("collectionIban_missing");
    return result;
  }

  const receiverIban = parsed?.receiverIban ? String(parsed.receiverIban) : "";
  result.recipientOk = ibansMatch(receiverIban, dekont.building.collectionIban);
  if (!result.recipientOk) {
    result.suggestedStatus = "RECIPIENT_MISMATCH";
    result.reasons.push("recipient_mismatch");
    return result;
  }

  // reference uniqueness (building scoped)
  const ref = parsed?.referenceNumber ? String(parsed.referenceNumber) : null;
  if (ref) {
    const dup = await prisma.dekont.findFirst({
      where: {
        id: { not: dekont.id },
        buildingId: dekont.buildingId,
        referenceNumber: ref,
      },
      select: { id: true },
    });
    result.referenceUnique = !dup;
    if (!result.referenceUnique) {
      result.suggestedStatus = "REJECTED";
      result.reasons.push("duplicate_reference");
      return result;
    }
  }

  if (!dekont.dueId || !dekont.due) {
    result.reasons.push("due_missing");
    return result;
  }

  const amount = parsed?.amount;
  result.amountOk = withinTolerance(amount, dekont.due.amount);
  if (!result.amountOk) {
    result.suggestedStatus = "UNMATCHED";
    result.reasons.push("amount_mismatch");
  }

  const txDateIso = parsed?.transactionDate;
  if (txDateIso) {
    const txDate = new Date(txDateIso);
    const periodStart = new Date(Date.UTC(dekont.due.year, dekont.due.month - 1, 1));
    const periodEnd = addDays(new Date(dekont.due.dueDate), GRACE_DAYS);
    result.dateOk = txDate >= periodStart && txDate <= periodEnd;
    if (!result.dateOk) {
      result.suggestedStatus = "UNMATCHED";
      result.reasons.push("date_out_of_period");
    }
  } else {
    result.reasons.push("date_missing");
  }

  if (result.recipientOk && result.amountOk !== false && result.dateOk !== false) {
    result.suggestedStatus = "MATCHED";
  }

  return result;
}

