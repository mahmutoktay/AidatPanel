import { prisma } from "../config/db.js";
import { recipientMatchesCollectionIban } from "../utils/iban.js";
import { HttpError } from "../utils/httpError.js";
import { dekontLog } from "../utils/dekontDebug.js";
import { resolveEffectiveBuildingConfig } from "./buildingConfigService.js";
import {
  computeDuePaymentTotals,
  withinAmountTolerance,
} from "../utils/duePaymentTotals.js";
import { duePaymentsAmountInclude } from "../utils/dueQueryIncludes.js";

const GRACE_DAYS = Number(process.env.DEKONT_GRACE_DAYS) || 7;

function addDays(date, days) {
  const d = new Date(date);
  d.setUTCDate(d.getUTCDate() + days);
  return d;
}

async function loadTargetDuesForRules(dekont) {
  const allocations = await prisma.dekontDueAllocation.findMany({
    where: { dekontId: dekont.id },
    select: { dueId: true },
  });
  let ids = allocations.map((a) => a.dueId);
  if (ids.length === 0 && dekont.dueId) ids = [dekont.dueId];
  if (ids.length === 0) return [];

  return prisma.due.findMany({
    where: { id: { in: ids } },
    include: duePaymentsAmountInclude,
  });
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

  const effective = await resolveEffectiveBuildingConfig(dekont.building);

  if (!effective.effectiveCollectionIban) {
    result.reasons.push("collectionIban_missing");
    return result;
  }

  const recipientCheck = recipientMatchesCollectionIban({
    parsedReceiverIban: parsed?.receiverIban ?? dekont.receiverIban,
    collectionIban: effective.effectiveCollectionIban,
    rawText: dekont.rawText,
  });
  result.recipientOk = recipientCheck.ok;
  if (!recipientCheck.ok) {
    dekontLog("rules.recipient_mismatch", recipientCheck);
    result.suggestedStatus = "RECIPIENT_MISMATCH";
    result.reasons.push("recipient_mismatch");
    return result;
  }
  if (recipientCheck.source === "rawtext_scan") {
    result.reasons.push("recipient_matched_rawtext_fallback");
    dekontLog("rules.recipient_rawtext_fallback", {
      dekontId,
      matchedIban: recipientCheck.matchedIban,
      parsedIban: recipientCheck.parsedIban,
    });
  }

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

  const targetDues = await loadTargetDuesForRules(dekont);
  if (targetDues.length === 0) {
    result.reasons.push("due_missing");
    return result;
  }

  const totalRemaining = targetDues.reduce(
    (sum, due) => sum + computeDuePaymentTotals(due).remainingAmount,
    0
  );
  const amount = parsed?.amount;
  result.amountOk = withinAmountTolerance(amount, totalRemaining);
  if (!result.amountOk) {
    result.suggestedStatus = "UNMATCHED";
    result.reasons.push("amount_mismatch");
  }

  const txDateIso = parsed?.transactionDate;
  if (txDateIso) {
    const txDate = new Date(txDateIso);
    const years = targetDues.map((d) => d.year);
    const months = targetDues.map((d) => d.month);
    const minYear = Math.min(...years);
    const minMonth = Math.min(
      ...targetDues.filter((d) => d.year === minYear).map((d) => d.month)
    );
    const periodStart = new Date(Date.UTC(minYear, minMonth - 1, 1));
    const latestDueDate = targetDues.reduce(
      (max, d) => (new Date(d.dueDate) > max ? new Date(d.dueDate) : max),
      new Date(targetDues[0].dueDate)
    );
    const periodEnd = addDays(latestDueDate, GRACE_DAYS);
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

  dekontLog("rules.result", {
    dekontId,
    suggestedStatus: result.suggestedStatus,
    reasons: result.reasons,
    recipientOk: result.recipientOk,
    amountOk: result.amountOk,
    dateOk: result.dateOk,
    targetDueCount: targetDues.length,
    totalRemaining,
  });

  return result;
}
