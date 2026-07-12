import { prisma } from "../config/db.js";
import { HttpError } from "../utils/httpError.js";
import {
  assertManagerOwnsBuilding,
  assertResidentOwnsApartment,
} from "../utils/access.js";
import { userPublicSelect } from "./meService.js";
import { NOTIFICATION_TYPES } from "../constants/notificationConstants.js";
import { NOTIFICATION_CODES } from "../constants/notificationCatalog.js";
import { createForUsers } from "./notificationService.js";
import {
  resolveListTake,
  resolvePageLimit,
  wantsPaginatedList,
  buildListResponse,
  mergeCreatedAtCursorWhere,
} from "../utils/listQuery.js";
import fs from "fs/promises";
import path from "path";
import sharp from "sharp";

const TICKET_ATTACHMENT_DIR = "uploads/tickets";

/** Yönetici akışı: Açık→Onaylandı/Reddedildi; Onaylandı→Yapıldı; Geri Al ters geçişleri. */
const ALLOWED_STATUS_TRANSITIONS = {
  OPEN: ["IN_PROGRESS", "CLOSED"],
  IN_PROGRESS: ["RESOLVED", "OPEN"],
  RESOLVED: ["IN_PROGRESS"],
  CLOSED: ["OPEN"],
};

const UPDATABLE_STATUSES = new Set(["OPEN", "IN_PROGRESS"]);

const STATUS_NOTIFY_CODES = {
  IN_PROGRESS: NOTIFICATION_CODES.TICKET_STATUS_IN_PROGRESS,
  RESOLVED: NOTIFICATION_CODES.TICKET_STATUS_RESOLVED,
  CLOSED: NOTIFICATION_CODES.TICKET_STATUS_CLOSED,
};

/**
 * Yeni talep — binanın yöneticisine in-app bildirim + FCM (Aşama A8).
 */
async function notifyBuildingManager(ticket) {
  const managerId = ticket.apartment?.building?.managerId;
  if (!managerId) return;

  const apartmentNumber = ticket.apartment?.number ?? "?";

  await createForUsers([managerId], {
    type: NOTIFICATION_TYPES.TICKET_CREATED,
    code: NOTIFICATION_CODES.TICKET_CREATED_MANAGER,
    params: { apartmentNumber, ticketTitle: ticket.title },
    data: {
      ticketId: ticket.id,
      buildingId: ticket.apartment?.buildingId ?? "",
      apartmentId: ticket.apartmentId,
      category: ticket.category,
      status: ticket.status,
      route: "/manager-dashboard",
    },
  });
}

/**
 * Talep sahibi sakine in-app bildirim + FCM (Aşama A3).
 */
async function notifyTicketOwner(ticket, { code, params, status }) {
  const buildingId = ticket.apartment?.buildingId;
  if (!ticket.userId) return;

  await createForUsers([ticket.userId], {
    type: NOTIFICATION_TYPES.TICKET_UPDATE,
    code,
    params,
    data: {
      ticketId: ticket.id,
      buildingId: buildingId ?? "",
      status,
      route: "/resident-dashboard",
    },
  });
}

const ticketIncludeList = {
  apartment: {
    select: {
      id: true,
      number: true,
      floor: true,
      buildingId: true,
      building: { select: { managerId: true } },
      resident: { select: userPublicSelect },
    },
  },
  user: { select: userPublicSelect },
};

function formatTicketRow(ticket) {
  const { apartment, user, attachmentPath, ...rest } = ticket;
  return {
    ...rest,
    attachmentPath: attachmentPath ?? null,
    attachmentUrl: attachmentPath
      ? `/uploads/tickets/${attachmentPath}`
      : null,
    apartmentNumber: apartment?.number ?? null,
    apartment: apartment
      ? {
          id: apartment.id,
          number: apartment.number,
          floor: apartment.floor,
          buildingId: apartment.buildingId,
        }
      : null,
    resident: apartment?.resident ?? null,
    createdBy: user ?? null,
  };
}

function buildTicketWhere(filters) {
  const where = {};
  if (filters.status) where.status = filters.status;
  if (filters.category) where.category = filters.category;
  return where;
}

export async function listTicketsByBuildingService(buildingId, managerId, filters = {}) {
  await assertManagerOwnsBuilding(buildingId, managerId);

  const paginated = wantsPaginatedList(filters);
  const pageLimit = paginated ? resolvePageLimit(filters.limit) : resolveListTake(filters.limit);
  const take = paginated ? pageLimit + 1 : pageLimit;

  let where = {
    apartment: { buildingId },
    ...buildTicketWhere(filters),
  };

  if (paginated && filters.cursor) {
    where = await mergeCreatedAtCursorWhere(where, filters.cursor, (id) =>
      prisma.ticket.findFirst({
        where: { id, apartment: { buildingId } },
        select: { id: true, createdAt: true },
      })
    );
  }

  const tickets = await prisma.ticket.findMany({
    where,
    include: ticketIncludeList,
    orderBy: [{ createdAt: "desc" }, { id: "desc" }],
    take,
  });

  return buildListResponse(filters, tickets, formatTicketRow);
}

export async function listMyTicketsService(userId, filters = {}) {
  const user = await prisma.user.findFirst({
    where: { id: userId, deletedAt: null, role: "RESIDENT" },
    select: { apartmentId: true },
  });

  if (!user?.apartmentId) {
    return wantsPaginatedList(filters) ? { items: [], nextCursor: null } : [];
  }

  const paginated = wantsPaginatedList(filters);
  const pageLimit = paginated ? resolvePageLimit(filters.limit) : resolveListTake(filters.limit);
  const take = paginated ? pageLimit + 1 : pageLimit;

  let where = {
    userId,
    apartmentId: user.apartmentId,
    ...buildTicketWhere(filters),
  };

  if (paginated && filters.cursor) {
    where = await mergeCreatedAtCursorWhere(where, filters.cursor, (id) =>
      prisma.ticket.findFirst({
        where: { id, userId, apartmentId: user.apartmentId },
        select: { id: true, createdAt: true },
      })
    );
  }

  const tickets = await prisma.ticket.findMany({
    where,
    include: ticketIncludeList,
    orderBy: [{ createdAt: "desc" }, { id: "desc" }],
    take,
  });

  return buildListResponse(filters, tickets, formatTicketRow);
}

export async function getTicketByIdService(ticketId, user) {
  const full = await prisma.ticket.findUnique({
    where: { id: ticketId },
    include: {
      ...ticketIncludeList,
      updates: { orderBy: { createdAt: "asc" } },
    },
  });

  if (!full) {
    throw new HttpError(404, "Talep bulunamadı.");
  }

  const isOwner = full.userId === user.id;
  const isManager =
    user.role === "MANAGER" &&
    full.apartment?.building?.managerId === user.id;

  if (!isOwner && !isManager) {
    throw new HttpError(404, "Talep bulunamadı.");
  }

  return formatTicketRow(full);
}

export async function createTicketService(apartmentId, userId, { title, description, category }) {
  await assertResidentOwnsApartment(apartmentId, userId);

  const ticket = await prisma.ticket.create({
    data: {
      apartmentId,
      userId,
      title,
      description,
      category,
      status: "OPEN",
    },
    include: ticketIncludeList,
  });

  await notifyBuildingManager(ticket);

  return formatTicketRow(ticket);
}

export async function addTicketUpdateService(ticketId, managerId, message) {
  const ticket = await prisma.ticket.findUnique({
    where: { id: ticketId },
    select: {
      id: true,
      userId: true,
      title: true,
      status: true,
      apartment: {
        select: { buildingId: true, building: { select: { managerId: true } } },
      },
    },
  });

  if (!ticket || ticket.apartment.building.managerId !== managerId) {
    throw new HttpError(404, "Talep bulunamadı.");
  }

  if (!UPDATABLE_STATUSES.has(ticket.status)) {
    throw new HttpError(409, "Kapalı veya sonuçlanmış talebe not eklenemez.");
  }

  await prisma.ticket.update({
    where: { id: ticketId },
    data: {
      updates: {
        create: {
          message,
          fromRole: "MANAGER",
        },
      },
      updatedAt: new Date(),
    },
  });

  const preview =
    message.length > 120 ? `${message.slice(0, 117)}...` : message;
  await notifyTicketOwner(ticket, {
    code: NOTIFICATION_CODES.TICKET_UPDATE_NOTE,
    params: { preview },
    status: ticket.status,
  });

  const full = await prisma.ticket.findUnique({
    where: { id: ticketId },
    include: {
      ...ticketIncludeList,
      updates: { orderBy: { createdAt: "asc" } },
    },
  });

  return formatTicketRow(full);
}

export async function changeTicketStatusService(ticketId, managerId, nextStatus) {
  const ticket = await prisma.ticket.findUnique({
    where: { id: ticketId },
    select: {
      id: true,
      userId: true,
      title: true,
      status: true,
      apartment: {
        select: { buildingId: true, building: { select: { managerId: true } } },
      },
    },
  });

  if (!ticket || ticket.apartment.building.managerId !== managerId) {
    throw new HttpError(404, "Talep bulunamadı.");
  }

  const allowed = ALLOWED_STATUS_TRANSITIONS[ticket.status] ?? [];
  if (!allowed.includes(nextStatus)) {
    throw new HttpError(400, "Geçersiz durum geçişi.");
  }

  const updated = await prisma.ticket.update({
    where: { id: ticketId },
    data: { status: nextStatus },
    include: ticketIncludeList,
  });

  const code = STATUS_NOTIFY_CODES[nextStatus];
  if (code) {
    await notifyTicketOwner(
      {
        id: ticket.id,
        userId: ticket.userId,
        title: ticket.title,
        apartment: ticket.apartment,
      },
      {
        code,
        params: { ticketTitle: ticket.title },
        status: nextStatus,
      }
    );
  }

  return formatTicketRow(updated);
}

/**
 * Talep görsel eki — yalnızca talep sahibi, OPEN durumda.
 * @param {string} ticketId
 * @param {string} userId
 * @param {Object} file — multer memory file
 */
export async function uploadTicketAttachmentService(ticketId, userId, file) {
  if (!file) {
    throw new HttpError(400, "Lütfen bir dosya yükleyin.");
  }

  const allowedMimeTypes = ["image/jpeg", "image/png"];
  if (!allowedMimeTypes.includes(file.mimetype)) {
    throw new HttpError(
      400,
      "Desteklenmeyen dosya türü. Sadece JPG veya PNG yükleyebilirsiniz."
    );
  }

  const maxSizeBytes = 5 * 1024 * 1024;
  if (file.size > maxSizeBytes) {
    throw new HttpError(400, "Dosya boyutu çok büyük. Maksimum 5MB yükleyebilirsiniz.");
  }

  const ticket = await prisma.ticket.findUnique({
    where: { id: ticketId },
    select: {
      id: true,
      userId: true,
      status: true,
      attachmentPath: true,
    },
  });

  if (!ticket || ticket.userId !== userId) {
    throw new HttpError(404, "Talep bulunamadı.");
  }

  if (ticket.status !== "OPEN") {
    throw new HttpError(409, "Yalnızca açık taleplere görsel eklenebilir.");
  }

  await fs.mkdir(TICKET_ATTACHMENT_DIR, { recursive: true });

  if (ticket.attachmentPath) {
    const oldPath = path.join(TICKET_ATTACHMENT_DIR, ticket.attachmentPath);
    await fs.unlink(oldPath).catch(() => {});
  }

  const filename = `ticket-${ticketId}-${Date.now()}.jpg`;
  const destPath = path.join(TICKET_ATTACHMENT_DIR, filename);

  await sharp(file.buffer)
    .rotate()
    .resize(2048, 2048, {
      fit: "inside",
      withoutEnlargement: true,
    })
    .jpeg({ quality: 85 })
    .toFile(destPath);

  const updated = await prisma.ticket.update({
    where: { id: ticketId },
    data: { attachmentPath: filename },
    include: ticketIncludeList,
  });

  return formatTicketRow(updated);
}
