import { prisma } from "../../config/db.js";
import { HttpError } from "../../utils/httpError.js";
import { sortByNatural } from "../../utils/naturalCompare.js";
import { adminDisplayEmail, adminDisplayPhone, adminDisplayName } from "../../utils/piiMasking.js";
import { writeAdminAuditLog } from "./adminAuditService.js";
import { getPaymentHabitsService } from "./adminReportService.js";

function buildManagerWhere(q) {
  const where = { role: "MANAGER", deletedAt: null };
  if (q) {
    where.OR = [
      { name: { contains: q, mode: "insensitive" } },
      { email: { contains: q, mode: "insensitive" } },
      { phone: { contains: q } },
    ];
  }
  return where;
}

export async function listHierarchyManagers({ q, page = 1, limit = 25 }) {
  const where = buildManagerWhere(q);
  const skip = (page - 1) * limit;

  const [managers, total] = await Promise.all([
    prisma.user.findMany({
      where,
      orderBy: { name: "asc" },
      skip,
      take: limit,
      select: {
        id: true,
        name: true,
        email: true,
        phone: true,
        createdAt: true,
        subscription: { select: { status: true, plan: true, currentPeriodEnd: true } },
        managedBuildings: {
          take: 1,
          select: { city: true, district: true },
          orderBy: { createdAt: "asc" },
        },
        _count: { select: { managedBuildings: true } },
      },
    }),
    prisma.user.count({ where }),
  ]);

  return {
    items: managers.map((m) => ({
      id: m.id,
      name: adminDisplayName(m.name),
      email: adminDisplayEmail(m.email),
      phone: adminDisplayPhone(m.phone),
      buildingCount: m._count.managedBuildings,
      subStatus: m.subscription?.status ?? null,
      subPlan: m.subscription?.plan ?? null,
      city: m.managedBuildings[0]?.city ?? null,
      district: m.managedBuildings[0]?.district ?? null,
    })),
    total,
    page,
    limit,
    totalPages: Math.ceil(total / limit),
  };
}

export async function getHierarchyManagerDetail(adminId, managerId, ipAddress) {
  const manager = await prisma.user.findFirst({
    where: { id: managerId, role: "MANAGER", deletedAt: null },
    include: {
      subscription: true,
      managedBuildings: {
        select: {
          id: true,
          name: true,
          city: true,
          district: true,
          _count: { select: { apartments: true } },
        },
        orderBy: { name: "asc" },
      },
      managedSites: {
        select: { id: true, name: true, city: true, district: true },
        orderBy: { name: "asc" },
      },
      sessions: {
        where: { revokedAt: null },
        orderBy: { lastSeenAt: "desc" },
        take: 3,
        select: { deviceLabel: true, platform: true, lastSeenAt: true },
      },
    },
  });

  if (!manager) throw new HttpError(404, "Yönetici bulunamadı.");

  await writeAdminAuditLog({
    adminId,
    action: "USER_VIEW",
    targetType: "User",
    targetId: managerId,
    ipAddress,
  });

  return {
    id: manager.id,
    name: manager.name,
    email: manager.email,
    phone: manager.phone,
    createdAt: manager.createdAt,
    subscription: manager.subscription,
    managedBuildings: manager.managedBuildings.map((b) => ({
      id: b.id,
      name: b.name,
      city: b.city,
      district: b.district,
      apartmentCount: b._count.apartments,
    })),
    managedSites: manager.managedSites,
    sessions: manager.sessions,
  };
}

export async function getHierarchyBuildingDetail(adminId, buildingId, ipAddress) {
  const building = await prisma.building.findUnique({
    where: { id: buildingId },
    include: {
      manager: { select: { id: true, name: true } },
      apartments: {
        orderBy: { number: "asc" },
        select: {
          id: true,
          number: true,
          floor: true,
          resident: {
            select: { id: true, name: true, email: true, deletedAt: true },
          },
          dues: {
            where: { status: "OVERDUE" },
            select: { id: true },
            take: 1,
          },
        },
      },
    },
  });

  if (!building) throw new HttpError(404, "Bina bulunamadı.");

  await writeAdminAuditLog({
    adminId,
    action: "USER_VIEW",
    targetType: "Building",
    targetId: buildingId,
    metadata: { managerId: building.managerId },
    ipAddress,
  });

  return {
    id: building.id,
    name: building.name,
    address: building.address,
    city: building.city,
    district: building.district,
    manager: building.manager,
    apartments: sortByNatural(building.apartments, (a) => a.number).map((a) => ({
      id: a.id,
      number: a.number,
      floor: a.floor,
      residentId: a.resident?.id ?? null,
      residentName: a.resident?.name ?? null,
      hasResident: !!a.resident && !a.resident.deletedAt,
      hasOverdue: a.dues.length > 0,
    })),
  };
}

export async function getHierarchyApartmentDetail(adminId, apartmentId, ipAddress) {
  const apartment = await prisma.apartment.findUnique({
    where: { id: apartmentId },
    include: {
      building: {
        select: {
          id: true,
          name: true,
          city: true,
          manager: { select: { id: true, name: true } },
        },
      },
      resident: {
        select: {
          id: true,
          name: true,
          email: true,
          phone: true,
          createdAt: true,
          deletedAt: true,
        },
      },
    },
  });

  if (!apartment) throw new HttpError(404, "Daire bulunamadı.");

  if (apartment.resident?.id) {
    await writeAdminAuditLog({
      adminId,
      action: "USER_VIEW",
      targetType: "User",
      targetId: apartment.resident.id,
      ipAddress,
    });
  }

  let paymentHabits = null;
  if (apartment.resident?.id && !apartment.resident.deletedAt) {
    try {
      paymentHabits = await getPaymentHabitsService(apartment.resident.id);
    } catch {
      paymentHabits = null;
    }
  }

  return {
    id: apartment.id,
    number: apartment.number,
    floor: apartment.floor,
    building: apartment.building,
    resident: apartment.resident,
    paymentHabits,
  };
}
