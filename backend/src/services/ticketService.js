import { prisma } from "../config/db.js";
import { HttpError } from "../utils/httpError.js";
import {
  assertManagerOwnsBuilding,
  assertResidentOwnsApartment,
} from "../utils/access.js";
import { userPublicSelect } from "./meService.js";
import { NOTIFICATION_TYPES } from "../constants/notificationConstants.js";
import { TICKET_CREATED_MANAGER } from "../constants/notificationTemplates.js";
import { createForUsers } from "./notificationService.js";
import {
  resolveListTake,
  resolvePageLimit,
  wantsPaginatedList,
  buildListResponse,
  mergeCreatedAtCursorWhere,
} from "../utils/listQuery.js";

const ALLOWED_STATUS_TRANSITIONS = {
  OPEN: ["IN_PROGRESS", "RESOLVED", "CLOSED"],
  IN_PROGRESS: ["RESOLVED", "CLOSED"],
  RESOLVED: ["CLOSED"],
  CLOSED: [],
};

const UPDATABLE_STATUSES = new Set(["OPEN", "IN_PROGRESS"]);

const STATUS_NOTIFY_COPY = {
  IN_PROGRESS: {
    title: "Talebiniz inceleniyor",
    body: (ticket) => `"${ticket.title}" talebiniz üzerinde çalışılıyor.`,
  },
  RESOLVED: {
    title: "Talebiniz çözüldü",
    body: (ticket) => `"${ticket.title}" talebiniz çözüldü olarak işaretlendi.`,
  },
  CLOSED: {
    title: "Talebiniz kapatıldı",
    body: (ticket) => `"${ticket.title}" talebiniz kapatıldı.`,
  },
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
    title: TICKET_CREATED_MANAGER.title,
    body: TICKET_CREATED_MANAGER.body(apartmentNumber, ticket.title),
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
async function notifyTicketOwner(ticket, { title, body, status }) {
  const buildingId = ticket.apartment?.buildingId;
  if (!ticket.userId) return;

  await createForUsers([ticket.userId], {
    type: "TICKET_UPDATE",
    title,
    body,
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
  const { apartment, user, ...rest } = ticket;
  return {
    ...rest,
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
    title: "Talebiniz güncellendi",
    body: `Yöneticiniz talebinize not ekledi: ${preview}`,
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

  if (ticket.status === "CLOSED") {
    throw new HttpError(409, "Kapatılmış talebin durumu değiştirilemez.");
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

  const copy = STATUS_NOTIFY_COPY[nextStatus];
  if (copy) {
    await notifyTicketOwner(
      {
        id: ticket.id,
        userId: ticket.userId,
        title: ticket.title,
        apartment: ticket.apartment,
      },
      {
        title: copy.title,
        body: copy.body(ticket),
        status: nextStatus,
      }
    );
  }

  return formatTicketRow(updated);
}
