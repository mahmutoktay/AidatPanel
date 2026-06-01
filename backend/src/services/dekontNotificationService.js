import { prisma } from "../config/db.js";
import { NOTIFICATION_TYPES } from "../constants/notificationConstants.js";
import {
  DEKONT_RECEIVED_MANAGER,
  DEKONT_NEEDS_REVIEW_MANAGER,
  DEKONT_MATCHED_MANAGER,
  DEKONT_REJECTED_RESIDENT,
} from "../constants/notificationTemplates.js";
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
      title: DEKONT_RECEIVED_MANAGER.title,
      body: DEKONT_RECEIVED_MANAGER.body(apt, dekont.originalFilename),
      data: baseData,
    });
    return;
  }

  if (dekont.status === "MATCHED") {
    await createForUsers([managerId], {
      type: NOTIFICATION_TYPES.DEKONT_MATCHED,
      title: DEKONT_MATCHED_MANAGER.title,
      body: DEKONT_MATCHED_MANAGER.body(apt),
      data: baseData,
    });
    return;
  }

  if (MANAGER_PIPELINE_STATUSES.has(dekont.status)) {
    await createForUsers([managerId], {
      type: NOTIFICATION_TYPES.DEKONT_NEEDS_REVIEW,
      title: DEKONT_NEEDS_REVIEW_MANAGER.title,
      body: DEKONT_NEEDS_REVIEW_MANAGER.body(apt),
      data: { ...baseData, route: "/manager-dashboard" },
    });
  }
}

/** Yönetici REJECT sonrası sakin bildirimi */
export async function notifyDekontRejected(dekontId) {
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
    title: DEKONT_REJECTED_RESIDENT.title,
    body: DEKONT_REJECTED_RESIDENT.body(reason),
    data: {
      dekontId: dekont.id,
      buildingId: dekont.buildingId,
      apartmentId: dekont.apartmentId ?? "",
      status: "REJECTED",
      route: "/resident-dashboard",
    },
  });
}
