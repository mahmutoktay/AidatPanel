import { prisma } from "../../config/db.js";

export async function getTicketModerationSummaryService() {
  const [reportedCount, needsReviewCount] = await Promise.all([
    prisma.ticket.count({ where: { isReported: true } }),
    prisma.ticket.count({ where: { needsReview: true } }),
  ]);

  return { reportedCount, needsReviewCount };
}

export async function listAdminTicketsService({
  moderation,
  page = 1,
  limit = 25,
}) {
  const where = {};
  if (moderation === "reported") {
    where.isReported = true;
  } else if (moderation === "needsReview") {
    where.needsReview = true;
  }

  const skip = (page - 1) * limit;
  const [items, total] = await Promise.all([
    prisma.ticket.findMany({
      where,
      skip,
      take: limit,
      orderBy: { createdAt: "desc" },
      select: {
        id: true,
        title: true,
        status: true,
        category: true,
        isReported: true,
        needsReview: true,
        createdAt: true,
        user: { select: { name: true } },
        apartment: {
          select: {
            number: true,
            building: { select: { name: true, city: true } },
          },
        },
      },
    }),
    prisma.ticket.count({ where }),
  ]);

  return {
    items: items.map((t) => ({
      id: t.id,
      title: t.title,
      status: t.status,
      category: t.category,
      isReported: t.isReported,
      needsReview: t.needsReview,
      createdAt: t.createdAt,
      residentName: t.user?.name ?? null,
      apartmentNumber: t.apartment?.number ?? null,
      buildingName: t.apartment?.building?.name ?? null,
      buildingCity: t.apartment?.building?.city ?? null,
    })),
    total,
    page,
    limit,
    totalPages: Math.ceil(total / limit) || 1,
  };
}
