import { prisma } from "../config/db.js";
import { logger } from "../config/logger.js";
import { NOTIFICATION_TYPES } from "../constants/notificationConstants.js";
import { NOTIFICATION_CODES } from "../constants/notificationCatalog.js";
import { createForUsers } from "./notificationService.js";

const MANAGER_PIPELINE_STATUSES = new Set([
  "NEEDS_MANAGER_REVIEW",
  "RECIPIENT_MISMATCH",
  "UNMATCHED",
  "MATCHED",
  "MATCH_AMBIGUOUS",
  "PARSE_LOW_CONFIDENCE",
  "EXTRACT_FAILED",
]);

/**
 * Dekont durumuna göre bildirim (upload + pipeline + review).
 */
export async function notifyDekontStatus(dekontId) {
  try {
    const dekont = await prisma.dekont.findUnique({
      where: { id: dekontId },
      include: {
        building: { select: { id: true, managerId: true, name: true } },
        apartment: { select: { number: true } },
        uploadedBy: { select: { id: true } },
      },
    });

    if (!dekont) return;

    const managerId = dekont.building.managerId;
    const apt = dekont.apartment?.number ?? "?";
    const baseData = {
      dekontId: dekont.id,
      buildingId: dekont.buildingId,
      apartmentId: dekont.apartmentId ?? "",
      status: dekont.status,
      route: "/manager-dashboard",
    };

    if (dekont.status === "RECEIVED") {
      await createForUsers([managerId], {
        type: NOTIFICATION_TYPES.DEKONT_RECEIVED,
        code: NOTIFICATION_CODES.DEKONT_RECEIVED_MANAGER,
        params: { apartmentNumber: apt, filename: dekont.originalFilename },
        data: baseData,
      });
      return;
    }

    if (dekont.status === "MATCHED") {
      await createForUsers([managerId], {
        type: NOTIFICATION_TYPES.DEKONT_MATCHED,
        code: NOTIFICATION_CODES.DEKONT_MATCHED_MANAGER,
        params: { apartmentNumber: apt },
        data: baseData,
      });
      return;
    }

    if (MANAGER_PIPELINE_STATUSES.has(dekont.status)) {
      await createForUsers([managerId], {
        type: NOTIFICATION_TYPES.DEKONT_NEEDS_REVIEW,
        code: NOTIFICATION_CODES.DEKONT_NEEDS_REVIEW_MANAGER,
        params: { apartmentNumber: apt },
        data: { ...baseData, route: "/manager-dashboard" },
      });
    }
  } catch (err) {
    logger.error({ type: "dekont_notify_status_failed", dekontId, err: err?.message });
  }
}

/** Yönetici REJECT sonrası sakin bildirimi */
export async function notifyDekontRejected(dekontId) {
  try {
    const dekont = await prisma.dekont.findUnique({
      where: { id: dekontId },
      select: {
        id: true,
        buildingId: true,
        apartmentId: true,
        uploadedById: true,
        rejectionReason: true,
        reviewNote: true,
      },
    });
    if (!dekont?.uploadedById) return;

    const reason = dekont.rejectionReason || dekont.reviewNote;
    await createForUsers([dekont.uploadedById], {
      type: NOTIFICATION_TYPES.SYSTEM,
      code: NOTIFICATION_CODES.DEKONT_REJECTED_RESIDENT,
      params: { reason: reason ?? "" },
      data: {
        dekontId: dekont.id,
        buildingId: dekont.buildingId,
        apartmentId: dekont.apartmentId ?? "",
        status: "REJECTED",
        route: "/resident-dashboard",
      },
    });
  } catch (err) {
    logger.error({ type: "dekont_notify_rejected_failed", dekontId, err: err?.message });
  }
}
