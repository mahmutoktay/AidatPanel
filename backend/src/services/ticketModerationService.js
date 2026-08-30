import { prisma } from "../config/db.js";
import { HttpError } from "../utils/httpError.js";
import { assertManagerOwnsBuilding } from "../utils/access.js";

const DEFAULT_RESTRICTION_DAYS = 3;

function buildRestrictionReason(ticket, note) {
  const excerpt =
    ticket.description.length > 240
      ? `${ticket.description.slice(0, 237)}...`
      : ticket.description;
  const quote = `Talep: "${ticket.title}"\n${excerpt}`;
  const trimmedNote = note?.trim();
  if (trimmedNote) {
    return `${quote}\n\nNot: ${trimmedNote}`;
  }
  return quote;
}

async function assertTicketForRestriction(ticketId, apartmentId, userId) {
  const ticket = await prisma.ticket.findFirst({
    where: {
      id: ticketId,
      apartmentId,
      userId,
    },
    select: {
      id: true,
      title: true,
      description: true,
    },
  });

  if (!ticket) {
    throw new HttpError(400, "Seçilen talep bu sakine ait değil.");
  }

  return ticket;
}

/**
 * Aktif talep oluşturma kısıtı — lazy expiry (expiresAt > now, liftedAt null).
 */
export async function getActiveRestrictionForUser(userId) {
  const now = new Date();
  return prisma.ticketCreationRestriction.findFirst({
    where: {
      userId,
      liftedAt: null,
      expiresAt: { gt: now },
    },
    orderBy: { expiresAt: "desc" },
    select: {
      id: true,
      reason: true,
      expiresAt: true,
      createdAt: true,
      buildingId: true,
    },
  });
}

export async function assertCanCreateTicket(userId) {
  const active = await getActiveRestrictionForUser(userId);
  if (active) {
    throw new HttpError(
      403,
      "Talep gönderme yetkiniz geçici olarak kısıtlanmıştır."
    );
  }
}

/**
 * Talep veya timeline güncellemesini uygunsuz içerik olarak bildirir.
 */
export async function reportTicketService(ticketId, reporter, { ticketUpdateId } = {}) {
  const ticket = await prisma.ticket.findUnique({
    where: { id: ticketId },
    select: {
      id: true,
      userId: true,
      apartment: {
        select: { building: { select: { managerId: true } } },
      },
    },
  });

  if (!ticket) {
    throw new HttpError(404, "Talep bulunamadı.");
  }

  const isOwner = ticket.userId === reporter.id;
  const isManager =
    reporter.role === "MANAGER" &&
    ticket.apartment?.building?.managerId === reporter.id;

  if (!isOwner && !isManager) {
    throw new HttpError(404, "Talep bulunamadı.");
  }

  if (isOwner && !ticketUpdateId) {
    throw new HttpError(400, "Kendi talebinizi bildiremezsiniz.");
  }

  if (ticketUpdateId) {
    const update = await prisma.ticketUpdate.findFirst({
      where: { id: ticketUpdateId, ticketId },
      select: { id: true, fromRole: true },
    });
    if (!update) {
      throw new HttpError(404, "Talep güncellemesi bulunamadı.");
    }
    if (update.fromRole === reporter.role) {
      throw new HttpError(400, "Kendi içeriğinizi bildiremezsiniz.");
    }
  }

  const existing = await prisma.ticketReport.findFirst({
    where: {
      ticketId,
      reporterId: reporter.id,
      ticketUpdateId: ticketUpdateId ?? null,
    },
  });

  if (!existing) {
    await prisma.ticketReport.create({
      data: {
        ticketId,
        ticketUpdateId: ticketUpdateId ?? null,
        reporterId: reporter.id,
      },
    });
  }

  await prisma.ticket.update({
    where: { id: ticketId },
    data: { isReported: true },
  });

  return { reported: true };
}

async function getApartmentForManager(apartmentId, managerId) {
  const apartment = await prisma.apartment.findUnique({
    where: { id: apartmentId },
    include: {
      resident: { select: { id: true, role: true, deletedAt: true } },
      building: { select: { id: true, managerId: true } },
    },
  });

  if (!apartment || apartment.building.managerId !== managerId) {
    throw new HttpError(404, "Daire bulunamadı.");
  }

  if (!apartment.resident || apartment.resident.deletedAt) {
    throw new HttpError(400, "Bu dairede sakin bulunmuyor.");
  }

  return apartment;
}

export async function restrictTicketCreationService(
  apartmentId,
  managerId,
  { ticketId, note }
) {
  const apartment = await getApartmentForManager(apartmentId, managerId);
  const userId = apartment.resident.id;
  const buildingId = apartment.building.id;
  const ticket = await assertTicketForRestriction(ticketId, apartmentId, userId);
  const reason = buildRestrictionReason(ticket, note);

  const expiresAt = new Date(
    Date.now() + DEFAULT_RESTRICTION_DAYS * 24 * 60 * 60 * 1000
  );

  await prisma.$transaction(async (tx) => {
    const active = await tx.ticketCreationRestriction.findFirst({
      where: {
        userId,
        buildingId,
        liftedAt: null,
        expiresAt: { gt: new Date() },
      },
    });

    if (active) {
      await tx.ticketCreationRestriction.update({
        where: { id: active.id },
        data: { liftedAt: new Date(), liftedById: managerId },
      });
      await tx.ticketRestrictionAuditLog.create({
        data: {
          userId,
          managerId,
          buildingId,
          action: "LIFT_MANUAL",
          reason: "Yeni kısıtlama uygulanmadan önce kaldırıldı.",
          expiresAt: active.expiresAt,
        },
      });
    }

    await tx.ticketCreationRestriction.create({
      data: {
        userId,
        buildingId,
        managerId,
        relatedTicketId: ticket.id,
        reason,
        expiresAt,
      },
    });

    await tx.ticketRestrictionAuditLog.create({
      data: {
        userId,
        managerId,
        buildingId,
        action: "RESTRICT",
        reason,
        expiresAt,
      },
    });
  });

  return getApartmentRestrictionService(apartmentId, managerId);
}

export async function liftTicketRestrictionService(apartmentId, managerId) {
  const apartment = await getApartmentForManager(apartmentId, managerId);
  const userId = apartment.resident.id;
  const buildingId = apartment.building.id;

  const active = await getActiveRestrictionForUser(userId);
  if (!active || active.buildingId !== buildingId) {
    throw new HttpError(404, "Aktif talep kısıtlaması bulunamadı.");
  }

  await prisma.$transaction(async (tx) => {
    await tx.ticketCreationRestriction.update({
      where: { id: active.id },
      data: { liftedAt: new Date(), liftedById: managerId },
    });
    await tx.ticketRestrictionAuditLog.create({
      data: {
        userId,
        managerId,
        buildingId,
        action: "LIFT_MANUAL",
        reason: "Yönetici tarafından kaldırıldı.",
        expiresAt: active.expiresAt,
      },
    });
  });

  return { active: false };
}

export async function getApartmentRestrictionService(apartmentId, managerId) {
  const apartment = await getApartmentForManager(apartmentId, managerId);
  const active = await getActiveRestrictionForUser(apartment.resident.id);

  if (!active || active.buildingId !== apartment.building.id) {
    return { active: false, restriction: null };
  }

  return {
    active: true,
    restriction: {
      reason: active.reason,
      expiresAt: active.expiresAt,
      createdAt: active.createdAt,
    },
  };
}

export async function getMyTicketRestrictionService(userId) {
  const active = await getActiveRestrictionForUser(userId);
  if (!active) {
    return { active: false, restriction: null };
  }

  return {
    active: true,
    restriction: {
      reason: active.reason,
      expiresAt: active.expiresAt,
      createdAt: active.createdAt,
    },
  };
}

/**
 * Süresi dolmuş kısıtlamaları işaretler ve audit yazar.
 */
export async function processExpiredTicketRestrictions() {
  const now = new Date();
  const expired = await prisma.ticketCreationRestriction.findMany({
    where: {
      liftedAt: null,
      expiresAt: { lte: now },
    },
    select: {
      id: true,
      userId: true,
      managerId: true,
      buildingId: true,
      reason: true,
      expiresAt: true,
    },
  });

  let processed = 0;
  for (const row of expired) {
    await prisma.$transaction(async (tx) => {
      const updated = await tx.ticketCreationRestriction.updateMany({
        where: { id: row.id, liftedAt: null },
        data: { liftedAt: row.expiresAt },
      });
      if (updated.count === 0) return;

      await tx.ticketRestrictionAuditLog.create({
        data: {
          userId: row.userId,
          managerId: row.managerId,
          buildingId: row.buildingId,
          action: "EXPIRED",
          reason: row.reason,
          expiresAt: row.expiresAt,
        },
      });
      processed += 1;
    });
  }

  return { processed };
}
