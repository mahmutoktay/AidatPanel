/**
 * Play Store / tanıtım videosu — canlı yönetici hesabına gerçekçi veri.
 *
 * - Vefa Apartman korunur (zenginleştirilir)
 * - Tüm ID'ler geçerli UUID (API Zod .uuid() uyumlu)
 * - UI'da "demo / örnek / showcase" ifadesi yok
 *
 * Kullanım (Postgres tüneli 5433):
 *   DEMO_MANAGER_EMAIL=... DEMO_FORCE=1 node scripts/seed-showcase-demo.js
 */

import { config } from "dotenv";
import bcrypt from "bcryptjs";
import { createHash } from "crypto";
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";
import { execFileSync } from "child_process";
import PDFDocument from "pdfkit";

config();

const DEMO_DB_PORT = process.env.DEMO_DB_PORT || "5433";
const rawUrl = process.env.DATABASE_URL?.trim();
if (!rawUrl) {
  console.error("DATABASE_URL yok");
  process.exit(1);
}
process.env.DATABASE_URL = rawUrl
  .replace(/:(5432)\//, `:${DEMO_DB_PORT}/`)
  .replace("@localhost:", "@127.0.0.1:");

const { prisma, disconnectDB } = await import("../src/config/db.js");
const { createExpenseService } = await import("../src/services/expenseService.js");
const { createSiteExpenseService } = await import("../src/services/siteExpenseService.js");
const { recalculateBuildingDuesForMonth } = await import(
  "../src/services/dueExpenseRecalcService.js"
);

const MANAGER_EMAIL =
  process.env.DEMO_MANAGER_EMAIL || "abdullahaslan061212@gmail.com";
const RESIDENT_PASSWORD = process.env.DEMO_RESIDENT_PASSWORD || "DemoSakin123!";
const ADMIN_ID = "4fd0b69f-e470-4b9d-b00c-b0f9e573601d";
const FORCE = process.env.DEMO_FORCE === "1";
const SSH_KEY = process.env.DEMO_SSH_KEY || "/home/abdullah/.ssh/aidat";
const SSH_TARGET = process.env.DEMO_SSH_TARGET || "aidatpanel-api@62.171.146.132";
const REMOTE_DEKONT_ROOT =
  process.env.DEMO_REMOTE_DEKONT_ROOT ||
  "/home/aidatpanel-api/htdocs/api.aidatpanel.com/uploads/dekonts";
const SCRIPT_DIR = path.dirname(fileURLToPath(import.meta.url));
const LOCAL_TMP = path.join(SCRIPT_DIR, "../uploads/dekonts/_tmp");

/** Deterministik UUID v5-benzeri (yeniden çalıştırmada aynı ID). */
function stableUuid(seed) {
  const hash = createHash("sha1").update(`aidatpanel-demo-v2:${seed}`).digest();
  const b = Buffer.from(hash);
  b[6] = (b[6] & 0x0f) | 0x50;
  b[8] = (b[8] & 0x3f) | 0x80;
  const h = b.toString("hex");
  return `${h.slice(0, 8)}-${h.slice(8, 12)}-${h.slice(12, 16)}-${h.slice(16, 20)}-${h.slice(20, 32)}`;
}

const ids = {
  site: stableUuid("site-bahceli"),
  blockA: stableUuid("block-a"),
  blockB: stableUuid("block-b"),
  blockC: stableUuid("block-c"),
  lale: stableUuid("building-lale"),
};

const LEGACY_BUILDING_IDS = [
  "showcase-site-bahceli",
  "showcase-block-a",
  "showcase-block-b",
  "showcase-block-c",
  "showcase-building-lale",
];

const DEMO_PHONES = [
  "5550101002",
  "5550101003",
  "5550101004",
  "5550101005",
  "5550101006",
  "5550101007",
  "5550202001",
  "5550202002",
  "5550202003",
  "5550202004",
  "5550202005",
  "5550202006",
  "5550202007",
  "5550202008",
  "5550202009",
  "5550202010",
  "5550202011",
  "5550202012",
  "5550303001",
  "5550303002",
  "5550303003",
  "5550303004",
  "5550303005",
  "5550303006",
  "5550303007",
  "5550303008",
  "5550303009",
  "5550303010",
];

const NOW = new Date();
const Y = NOW.getFullYear();
const M = NOW.getMonth() + 1;

function monthAgo(offset) {
  const d = new Date(Y, M - 1 - offset, 1);
  return { year: d.getFullYear(), month: d.getMonth() + 1 };
}

function dueDateFor(year, month, day) {
  return new Date(Date.UTC(year, month - 1, day, 20, 59, 59, 999));
}

function log(step, msg) {
  console.log(`  [${step}] ${msg}`);
}

async function deleteBuildingForest(buildingIds, siteIds = []) {
  if (!buildingIds.length && !siteIds.length) return;

  const apartments = buildingIds.length
    ? await prisma.apartment.findMany({
        where: { buildingId: { in: buildingIds } },
        select: { id: true },
      })
    : [];
  const aptIds = apartments.map((a) => a.id);

  const dues = aptIds.length
    ? await prisma.due.findMany({
        where: { apartmentId: { in: aptIds } },
        select: { id: true },
      })
    : [];
  const dueIds = dues.map((d) => d.id);

  const dekonts = buildingIds.length
    ? await prisma.dekont.findMany({
        where: { buildingId: { in: buildingIds } },
        select: { id: true, storedPath: true },
      })
    : [];
  const dekontIds = dekonts.map((d) => d.id);

  if (dekontIds.length) {
    await prisma.duePayment.deleteMany({ where: { dekontId: { in: dekontIds } } });
    await prisma.dekontDueAllocation.deleteMany({
      where: { dekontId: { in: dekontIds } },
    });
    await prisma.dekont.deleteMany({ where: { id: { in: dekontIds } } });
  }
  if (dueIds.length) {
    await prisma.duePayment.deleteMany({ where: { dueId: { in: dueIds } } });
    await prisma.dekontDueAllocation.deleteMany({ where: { dueId: { in: dueIds } } });
  }
  if (aptIds.length) {
    await prisma.dueExpenseCarryforward.deleteMany({
      where: { apartmentId: { in: aptIds } },
    });
    await prisma.ticketUpdate.deleteMany({
      where: { ticket: { apartmentId: { in: aptIds } } },
    });
    await prisma.ticket.deleteMany({ where: { apartmentId: { in: aptIds } } });
    await prisma.inviteCode.deleteMany({ where: { apartmentId: { in: aptIds } } });
    await prisma.due.deleteMany({ where: { apartmentId: { in: aptIds } } });
    await prisma.user.updateMany({
      where: { apartmentId: { in: aptIds } },
      data: { apartmentId: null },
    });
    await prisma.apartment.deleteMany({ where: { id: { in: aptIds } } });
  }
  if (buildingIds.length) {
    await prisma.expense.deleteMany({ where: { buildingId: { in: buildingIds } } });
    await prisma.building.deleteMany({ where: { id: { in: buildingIds } } });
  }
  if (siteIds.length) {
    await prisma.siteExpense.deleteMany({ where: { siteId: { in: siteIds } } });
    await prisma.site.deleteMany({ where: { id: { in: siteIds } } });
  }

  // Sunucudaki eski dekont klasörlerini temizle
  for (const bid of buildingIds) {
    try {
      execFileSync(
        "ssh",
        [
          "-i",
          SSH_KEY,
          "-o",
          "StrictHostKeyChecking=no",
          SSH_TARGET,
          `rm -rf '${REMOTE_DEKONT_ROOT}/Binalar/${bid}'`,
        ],
        { stdio: "ignore" }
      );
    } catch {
      /* yoksa sorun değil */
    }
  }
}

async function deleteShowcaseTree(managerId) {
  const byId = await prisma.building.findMany({
    where: {
      OR: [
        {
          id: {
            in: [ids.blockA, ids.blockB, ids.blockC, ids.lale, ...LEGACY_BUILDING_IDS],
          },
        },
        { siteId: { in: [ids.site, "showcase-site-bahceli"] } },
        {
          managerId,
          name: { in: ["Lale Apartmanı", "A Blok", "B Blok", "C Blok"] },
        },
      ],
    },
    select: { id: true, siteId: true },
  });

  const sites = await prisma.site.findMany({
    where: {
      OR: [
        { id: { in: [ids.site, "showcase-site-bahceli"] } },
        { managerId, name: "Bahçeli Evler Sitesi" },
      ],
    },
    select: { id: true },
  });

  const siteIds = [...new Set([...sites.map((s) => s.id), ...byId.map((b) => b.siteId).filter(Boolean)])];
  const buildingIds = [
    ...new Set([
      ...byId.map((b) => b.id),
      ...(await prisma.building.findMany({
        where: { siteId: { in: siteIds } },
        select: { id: true },
      })).map((b) => b.id),
    ]),
  ];

  await deleteBuildingForest(buildingIds, siteIds);

  // Seed sakinlerini telefonla temizle (eski showcase-* id'ler dahil)
  const seedResidents = await prisma.user.findMany({
    where: {
      role: "RESIDENT",
      OR: [
        { id: { startsWith: "showcase-resident-" } },
        { phone: { in: DEMO_PHONES } },
      ],
    },
    select: { id: true },
  });
  const seedResidentIds = seedResidents.map((u) => u.id);
  if (seedResidentIds.length) {
    await prisma.notification.deleteMany({ where: { userId: { in: seedResidentIds } } });
    await prisma.ticketUpdate.deleteMany({
      where: { ticket: { userId: { in: seedResidentIds } } },
    });
    await prisma.ticket.deleteMany({ where: { userId: { in: seedResidentIds } } });
    await prisma.userSession.deleteMany({ where: { userId: { in: seedResidentIds } } });
    await prisma.passwordResetToken.deleteMany({
      where: { userId: { in: seedResidentIds } },
    });
    // Kullanıcının yüklediği dekontlar (ağaç dışı kalabilir)
    const uploaded = await prisma.dekont.findMany({
      where: { uploadedById: { in: seedResidentIds } },
      select: { id: true },
    });
    const uploadedIds = uploaded.map((d) => d.id);
    if (uploadedIds.length) {
      await prisma.duePayment.deleteMany({ where: { dekontId: { in: uploadedIds } } });
      await prisma.dekontDueAllocation.deleteMany({
        where: { dekontId: { in: uploadedIds } },
      });
      await prisma.dekont.deleteMany({ where: { id: { in: uploadedIds } } });
    }
    await prisma.user.updateMany({
      where: { id: { in: seedResidentIds } },
      data: { apartmentId: null },
    });
    await prisma.user.deleteMany({ where: { id: { in: seedResidentIds } } });
  }

  console.log("  Eski tanıtım site/bina ağacı temizlendi");
}

async function cleanVefaArtifacts(vefaId) {
  await prisma.ticketUpdate.deleteMany({
    where: {
      ticket: {
        apartment: { buildingId: vefaId },
        OR: [
          { title: { startsWith: "[Demo]" } },
          {
            title: {
              in: [
                "Asansör garip ses çıkarıyor",
                "Merdiven aydınlatması yanmıyor",
                "Kapı önü su birikintisi",
              ],
            },
          },
        ],
      },
    },
  });
  await prisma.ticket.deleteMany({
    where: {
      apartment: { buildingId: vefaId },
      OR: [
        { title: { startsWith: "[Demo]" } },
        {
          title: {
            in: [
              "Asansör garip ses çıkarıyor",
              "Merdiven aydınlatması yanmıyor",
              "Kapı önü su birikintisi",
            ],
          },
        },
      ],
    },
  });
  await prisma.expense.deleteMany({
    where: {
      buildingId: vefaId,
      OR: [
        { note: { contains: "[showcase]" } },
        {
          title: {
            in: [
              "Merdiven temizliği",
              "Asansör periyodik bakım",
              "Ortak alan elektrik",
              "Su kaçağı tamiri",
            ],
          },
        },
      ],
    },
  });
  await prisma.notification.deleteMany({
    where: {
      OR: [
        { code: { in: ["SHOWCASE_WELCOME", "SHOWCASE_DUE", "SHOWCASE_DEKONT"] } },
        { title: { contains: "örnek" } },
        { title: { contains: "Tanıtım" } },
      ],
    },
  });
  await prisma.dekontDueAllocation.deleteMany({
    where: { dekont: { referenceNumber: { startsWith: "SHOWCASE-REF" } } },
  });
  await prisma.dekont.deleteMany({
    where: {
      OR: [
        { referenceNumber: { startsWith: "SHOWCASE-REF" } },
        { referenceNumber: { startsWith: "AP-HV-" } },
      ],
    },
  });
}

async function grantBusiness(managerId) {
  const durationDays = 90;
  const now = new Date();
  const end = new Date(now);
  end.setDate(end.getDate() + durationDays);

  const subscription = await prisma.subscription.upsert({
    where: { userId: managerId },
    create: {
      userId: managerId,
      status: "ACTIVE",
      plan: "business_annual",
      platform: "admin_grant",
      currentPeriodStart: now,
      currentPeriodEnd: end,
    },
    update: {
      status: "ACTIVE",
      plan: "business_annual",
      platform: "admin_grant",
      currentPeriodStart: now,
      currentPeriodEnd: end,
    },
  });

  const existingGrant = await prisma.promoGrant.findFirst({
    where: {
      userId: managerId,
      reason: { contains: "Play Store" },
    },
  });
  if (!existingGrant) {
    await prisma.promoGrant.create({
      data: {
        userId: managerId,
        grantedById: ADMIN_ID,
        type: "FREE_PERIOD",
        plan: "business_annual",
        durationDays,
        reason: "Play Store mağaza görseli ve tanıtım videosu hazırlığı",
        expiresAt: end,
      },
    });
  }

  return subscription;
}

async function upsertInvite(apartmentId, code) {
  const expiresAt = new Date();
  expiresAt.setDate(expiresAt.getDate() + 365);
  const existing = await prisma.inviteCode.findUnique({ where: { code } });
  if (existing) {
    if (existing.apartmentId === apartmentId) return existing;
    return prisma.inviteCode.create({
      data: {
        code: `${code.slice(0, 10)}${Math.floor(Math.random() * 90 + 10)}`,
        apartmentId,
        expiresAt,
      },
    });
  }
  return prisma.inviteCode.create({
    data: { code, apartmentId, expiresAt },
  });
}

async function ensureResident({ id, name, phone, apartmentId, passwordHash }) {
  const existingById = await prisma.user.findUnique({ where: { id } });
  if (existingById) {
    return prisma.user.update({
      where: { id },
      data: {
        name,
        phone,
        apartmentId,
        passwordHash,
        role: "RESIDENT",
        deletedAt: null,
      },
    });
  }
  const phoneTaken = await prisma.user.findFirst({
    where: { phone, role: "RESIDENT" },
  });
  if (phoneTaken) {
    return prisma.user.update({
      where: { id: phoneTaken.id },
      data: { apartmentId, name, passwordHash, deletedAt: null },
    });
  }
  return prisma.user.create({
    data: {
      id,
      name,
      phone,
      passwordHash,
      role: "RESIDENT",
      apartmentId,
      language: "tr",
    },
  });
}

function deterministicPaid(apartmentId, year, month, paidRatio) {
  const n = createHash("sha1")
    .update(`${apartmentId}:${year}:${month}`)
    .digest()[0];
  return n / 255 < paidRatio;
}

async function applyExactPaidRatio(
  buildingId,
  year,
  month,
  ratio,
  { dueDay = 1, unpaidAs = "OVERDUE", exactCount = null } = {}
) {
  let dues = await prisma.due.findMany({
    where: { year, month, apartment: { buildingId } },
    include: { apartment: { select: { number: true } } },
  });
  dues.sort((a, b) =>
    String(a.apartment.number).localeCompare(String(b.apartment.number), "tr")
  );

  if (exactCount != null && dues.length > exactCount) {
    const drop = dues.slice(exactCount);
    for (const d of drop) {
      await prisma.dekontDueAllocation.deleteMany({ where: { dueId: d.id } });
      await prisma.duePayment.deleteMany({ where: { dueId: d.id } });
      await prisma.due.delete({ where: { id: d.id } });
    }
    dues = dues.slice(0, exactCount);
  }

  const targetPaid = Math.round(dues.length * ratio);
  let i = 0;
  for (const due of dues) {
    const shouldPaid = i < targetPaid;
    i += 1;
    if (shouldPaid) {
      const paidAt = new Date(year, month - 1, Math.min(dueDay + 3, 28));
      await prisma.duePayment.deleteMany({ where: { dueId: due.id } });
      await prisma.due.update({
        where: { id: due.id },
        data: {
          status: "PAID",
          paidAt,
          overdueDays: 0,
        },
      });
      await prisma.duePayment.create({
        data: {
          dueId: due.id,
          amount: due.amount,
          paidAt,
          currency: due.currency || "TRY",
          note: "Tanıtım verisi",
        },
      });
    } else {
      const dd = dueDateFor(year, month, dueDay);
      const isPast = dd.getTime() < NOW.getTime();
      const status =
        unpaidAs === "AUTO" ? (isPast ? "OVERDUE" : "PENDING") : unpaidAs;
      const overdueDays =
        status === "OVERDUE"
          ? Math.max(
              1,
              Math.floor((NOW.getTime() - dd.getTime()) / (24 * 60 * 60 * 1000))
            )
          : 0;
      await prisma.duePayment.deleteMany({ where: { dueId: due.id } });
      await prisma.due.update({
        where: { id: due.id },
        data: { status, paidAt: null, overdueDays },
      });
    }
  }
  return { total: dues.length, paid: targetPaid };
}

async function ensureDuesForApartment({
  apartmentId,
  baseAmount,
  dueDay,
  monthsBack,
  monthsForward,
  paidRatio,
  residentName,
}) {
  for (let back = monthsBack; back >= 0; back -= 1) {
    const { year, month } = monthAgo(back);
    await upsertDueMonth({
      apartmentId,
      year,
      month,
      amount: baseAmount,
      dueDay,
      preferPaid:
        back >= 1
          ? deterministicPaid(apartmentId, year, month, Math.min(0.85, paidRatio + 0.2))
          : deterministicPaid(apartmentId, year, month, paidRatio),
      overdueIfPast: true,
      residentName,
    });
  }
  for (let fwd = 1; fwd <= monthsForward; fwd += 1) {
    const d = new Date(Y, M - 1 + fwd, 1);
    await upsertDueMonth({
      apartmentId,
      year: d.getFullYear(),
      month: d.getMonth() + 1,
      amount: baseAmount,
      dueDay,
      preferPaid: false,
      overdueIfPast: false,
      residentName,
    });
  }
}

async function upsertDueMonth({
  apartmentId,
  year,
  month,
  amount,
  dueDay,
  preferPaid,
  overdueIfPast,
  residentName,
}) {
  const existing = await prisma.due.findFirst({
    where: { apartmentId, year, month },
  });
  const dd = dueDateFor(year, month, dueDay);
  const isPast = dd.getTime() < NOW.getTime();
  let status = "PENDING";
  let paidAt = null;
  let overdueDays = 0;
  if (preferPaid) {
    status = "PAID";
    paidAt = new Date(year, month - 1, Math.min(dueDay + 2, 28));
  } else if (overdueIfPast && isPast) {
    status = "OVERDUE";
    overdueDays = Math.max(
      1,
      Math.floor((NOW.getTime() - dd.getTime()) / (24 * 60 * 60 * 1000))
    );
  }

  if (existing) {
    return prisma.due.update({
      where: { id: existing.id },
      data: {
        amount,
        status,
        paidAt,
        overdueDays,
        dueDate: dd,
        residentNameSnapshot: residentName ?? existing.residentNameSnapshot,
      },
    });
  }
  return prisma.due.create({
    data: {
      apartmentId,
      amount,
      currency: "TRY",
      month,
      year,
      dueDate: dd,
      status,
      paidAt,
      overdueDays,
      residentNameSnapshot: residentName ?? null,
    },
  });
}

async function createAptsWithLayout(buildingId, floors, perFloor, seedKey) {
  const apts = [];
  let unitNumber = 1;
  for (let f = 1; f <= floors; f += 1) {
    for (let i = 0; i < perFloor; i += 1) {
      // ID anahtarı eski harf şemasıyla aynı kalsın (upsert sürekliliği).
      const letter = String.fromCharCode(65 + i);
      const number = String(unitNumber);
      const id = stableUuid(`${seedKey}-apt-${f}${letter}`);
      const apt = await prisma.apartment.upsert({
        where: { id },
        update: { number, floor: f, buildingId },
        create: { id, number, floor: f, buildingId },
      });
      apts.push(apt);
      unitNumber += 1;
    }
  }
  return apts;
}

async function buildReceiptPdf({
  outPath,
  title,
  amount,
  sender,
  receiver,
  iban,
  ref,
  dateLabel,
  aptLabel,
}) {
  await new Promise((resolve, reject) => {
    const doc = new PDFDocument({ size: "A4", margin: 50 });
    const stream = fs.createWriteStream(outPath);
    doc.pipe(stream);
    doc.fontSize(18).fillColor("#111").text("Havale / EFT Dekontu", { align: "center" });
    doc.moveDown();
    doc.fontSize(11).fillColor("#333");
    doc.text(title);
    doc.moveDown(0.5);
    doc.text(`İşlem tarihi: ${dateLabel}`);
    doc.text(`Referans no: ${ref}`);
    doc.text(`Gönderen: ${sender}`);
    doc.text(`Alıcı: ${receiver}`);
    doc.text(`Alıcı IBAN: ${iban}`);
    doc.text(`Açıklama: ${aptLabel} aidat`);
    doc.moveDown();
    doc
      .fontSize(15)
      .fillColor("#0a5")
      .text(
        `Tutar: ${Number(amount).toLocaleString("tr-TR", {
          minimumFractionDigits: 2,
          maximumFractionDigits: 2,
        })} TL`
      );
    doc.moveDown(2);
    doc
      .fontSize(9)
      .fillColor("#888")
      .text("Bu dekont elektronik ortamda üretilmiştir.");
    doc.end();
    stream.on("finish", resolve);
    stream.on("error", reject);
  });
}

async function ensureDekontWithPdf({
  buildingId,
  apartmentNumber,
  referenceNumber,
  status,
  receiverIban,
  receiverTitle,
  managerId,
}) {
  await fs.promises.mkdir(LOCAL_TMP, { recursive: true });
  const apt = await prisma.apartment.findFirst({
    where: { buildingId, number: apartmentNumber },
    include: {
      resident: true,
      dues: { where: { year: Y, month: M }, take: 1 },
      building: { select: { name: true, collectionAccountTitle: true } },
    },
  });
  if (!apt?.resident || !apt.dues[0]) {
    log("dekont", `atlandı ${referenceNumber} (${apartmentNumber})`);
    return null;
  }

  const due = apt.dues[0];
  // İnceleme / onay demosu için aidat açık kalsın (oran seed'i PAID yapmış olabilir).
  if (status === "NEEDS_MANAGER_REVIEW" || status === "MATCHED") {
    await prisma.duePayment.deleteMany({ where: { dueId: due.id } });
    await prisma.dekontDueAllocation.deleteMany({
      where: { dueId: due.id },
    });
    await prisma.due.update({
      where: { id: due.id },
      data: {
        status: "OVERDUE",
        paidAt: null,
        overdueDays: Math.max(
          1,
          Math.floor(
            (NOW.getTime() - new Date(due.dueDate).getTime()) /
              (24 * 60 * 60 * 1000)
          )
        ),
      },
    });
  }

  let dekont = await prisma.dekont.findFirst({ where: { referenceNumber } });
  const fileHash = createHash("sha256")
    .update(`ap-hv-pdf-${referenceNumber}`)
    .digest("hex");

  if (!dekont) {
    dekont = await prisma.dekont.create({
      data: {
        buildingId,
        apartmentId: apt.id,
        uploadedById: apt.resident.id,
        dueId: due.id,
        status,
        source: "RESIDENT_UPLOAD",
        storedPath: "pending",
        originalFilename: `havale-${apartmentNumber}.pdf`,
        mimeType: "application/pdf",
        sizeBytes: 0,
        fileHash,
        referenceNumber,
        parsedAmount: due.amount,
        receiverIban,
        transactionDate: NOW,
        aiConfidence: 0.94,
        rawText: `HAVALE ${referenceNumber} TUTAR ${due.amount} IBAN ${receiverIban}`,
        parsedJson: { amount: Number(due.amount), referenceNumber },
      },
    });
    await prisma.dekontDueAllocation.create({
      data: { dekontId: dekont.id, dueId: due.id },
    });
  }

  const relativePath = `Binalar/${buildingId}/Sakinler/${dekont.id}.pdf`;
  const localPdf = path.join(LOCAL_TMP, `${dekont.id}.pdf`);
  await buildReceiptPdf({
    outPath: localPdf,
    title: `${apt.building.name} aidat ödemesi`,
    amount: due.amount,
    sender: apt.resident.name,
    receiver:
      receiverTitle || apt.building.collectionAccountTitle || "Apartman Yönetimi",
    iban: receiverIban,
    ref: referenceNumber,
    dateLabel: NOW.toLocaleDateString("tr-TR"),
    aptLabel: apartmentNumber,
  });
  const sizeBytes = (await fs.promises.stat(localPdf)).size;

  const remoteDir = `${REMOTE_DEKONT_ROOT}/Binalar/${buildingId}/Sakinler`;
  execFileSync(
    "ssh",
    [
      "-i",
      SSH_KEY,
      "-o",
      "StrictHostKeyChecking=no",
      SSH_TARGET,
      `mkdir -p '${remoteDir}'`,
    ],
    { stdio: "inherit" }
  );
  execFileSync(
    "scp",
    [
      "-i",
      SSH_KEY,
      "-o",
      "StrictHostKeyChecking=no",
      localPdf,
      `${SSH_TARGET}:${remoteDir}/${dekont.id}.pdf`,
    ],
    { stdio: "inherit" }
  );

  dekont = await prisma.dekont.update({
    where: { id: dekont.id },
    data: {
      storedPath: relativePath,
      sizeBytes,
      status,
      mimeType: "application/pdf",
      originalFilename: `havale-${apartmentNumber}.pdf`,
      fileHash,
      parsedAmount: due.amount,
      dueId: due.id,
      apartmentId: apt.id,
    },
  });

  if (status === "NEEDS_MANAGER_REVIEW") {
    const existingNotif = await prisma.notification.findFirst({
      where: {
        userId: managerId,
        data: { path: ["dekontId"], equals: dekont.id },
      },
    });
    if (!existingNotif) {
      await prisma.notification.create({
        data: {
          userId: managerId,
          code: "DEKONT_NEEDS_REVIEW",
          title: "Dekont inceleme bekliyor",
          body: `${apt.building.name} — ${apartmentNumber} dairesinden yeni dekont geldi.`,
          type: "DEKONT_NEEDS_REVIEW",
          data: { dekontId: dekont.id, buildingId },
        },
      });
    }
  }

  log("dekont", `${referenceNumber} → ${relativePath}`);
  return dekont;
}

async function remumberApartmentsSequential(buildingId) {
  const apts = await prisma.apartment.findMany({
    where: { buildingId },
    orderBy: [{ floor: "asc" }, { number: "asc" }],
  });
  if (apts.length === 0) return apts;
  const needsRemumber = apts.some((a) => /[A-Za-z]/.test(String(a.number)));
  if (!needsRemumber) return apts;

  apts.sort((a, b) => {
    const floorA = a.floor ?? 0;
    const floorB = b.floor ?? 0;
    if (floorA !== floorB) return floorA - floorB;
    return String(a.number).localeCompare(String(b.number), "tr", {
      numeric: true,
    });
  });

  let n = 1;
  for (const apt of apts) {
    const next = String(n);
    if (apt.number !== next) {
      await prisma.apartment.update({
        where: { id: apt.id },
        data: { number: next },
      });
      apt.number = next;
    }
    n += 1;
  }
  return apts;
}

async function enrichVefa(manager, passwordHash) {
  const vefa = await prisma.building.findFirst({
    where: { managerId: manager.id, name: "Vefa Apartman" },
    include: {
      apartments: { include: { resident: true }, orderBy: { number: "asc" } },
    },
  });
  if (!vefa) {
    log("vefa", "bulunamadı — atlandı");
    return null;
  }

  await cleanVefaArtifacts(vefa.id);
  vefa.apartments = await remumberApartmentsSequential(vefa.id);

  const residents = [
    { apt: "2", name: "Ayşe Demir", phone: "5550101002", key: "vefa-1b" },
    { apt: "3", name: "Mehmet Yılmaz", phone: "5550101003", key: "vefa-2a" },
    { apt: "4", name: "Zeynep Kaya", phone: "5550101004", key: "vefa-2b" },
    { apt: "5", name: "Ali Çelik", phone: "5550101005", key: "vefa-3a" },
    { apt: "6", name: "Fatma Arslan", phone: "5550101006", key: "vefa-3b" },
    { apt: "7", name: "Emre Şahin", phone: "5550101007", key: "vefa-4a" },
  ];

  for (const row of residents) {
    const apt = vefa.apartments.find((a) => a.number === row.apt);
    if (!apt) continue;
    await ensureResident({
      id: stableUuid(`resident-${row.key}`),
      name: row.name,
      phone: row.phone,
      apartmentId: apt.id,
      passwordHash,
    });
    await ensureDuesForApartment({
      apartmentId: apt.id,
      baseAmount: Number(vefa.dueAmount) || 500,
      dueDay: vefa.dueDay || 5,
      monthsBack: 2,
      monthsForward: Math.max(0, 12 - M),
      paidRatio: 0.55,
      residentName: row.name,
    });
    await upsertInvite(
      apt.id,
      `APB${row.apt.replace(/\D/g, "")}${row.apt.slice(-1)}F1A2`.slice(0, 12).toUpperCase()
    );
  }

  // Boş dairelere de bu ay aidatı (tahsilat oranı hesabı için 8 kayıt → %75)
  for (const apt of vefa.apartments) {
    const hasDue = await prisma.due.findFirst({
      where: { apartmentId: apt.id, year: Y, month: M },
    });
    if (!hasDue) {
      await upsertDueMonth({
        apartmentId: apt.id,
        year: Y,
        month: M,
        amount: Number(vefa.dueAmount) || 500,
        dueDay: vefa.dueDay || 5,
        preferPaid: false,
        overdueIfPast: true,
        residentName: apt.resident?.name || null,
      });
    }
  }

  const expenseTitles = [
    { title: "Merdiven temizliği", category: "CLEANING", amount: 1800 },
    { title: "Asansör periyodik bakım", category: "ELEVATOR", amount: 3200 },
    { title: "Ortak alan elektrik", category: "ELECTRICITY", amount: 1450 },
    { title: "Su kaçağı tamiri", category: "REPAIR", amount: 950 },
  ];
  for (const item of expenseTitles) {
    await createExpenseService(vefa.id, manager.id, {
      ...item,
      date: new Date(Y, M - 1, 3).toISOString(),
      targetMonth: M,
      targetYear: Y,
      note: null,
      confirmPaidImpact: true,
    });
  }

  const ticketSeed = [
    {
      apt: "1",
      title: "Asansör garip ses çıkarıyor",
      description: "3. kattan itibaren inerken metal sürtünme sesi duyuluyor.",
      category: "MALFUNCTION",
      status: "IN_PROGRESS",
      update: "Teknisyen randevusu pazartesi sabahına alındı.",
    },
    {
      apt: "3",
      title: "Merdiven aydınlatması yanmıyor",
      description: "2. kat merdiven lambası iki gündür yanmıyor.",
      category: "REQUEST",
      status: "OPEN",
    },
    {
      apt: "6",
      title: "Kapı önü su birikintisi",
      description: "Yağmur sonrası girişte su birikiyor, kayma riski var.",
      category: "COMPLAINT",
      status: "RESOLVED",
      update: "Yağmur oluğu temizlendi, sorun giderildi.",
    },
  ];
  for (const t of ticketSeed) {
    const apt = await prisma.apartment.findFirst({
      where: { buildingId: vefa.id, number: t.apt },
      include: { resident: true },
    });
    if (!apt?.resident) continue;
    const ticket = await prisma.ticket.create({
      data: {
        apartmentId: apt.id,
        userId: apt.resident.id,
        title: t.title,
        description: t.description,
        category: t.category,
        status: t.status,
      },
    });
    if (t.update) {
      await prisma.ticketUpdate.create({
        data: { ticketId: ticket.id, message: t.update, fromRole: "MANAGER" },
      });
    }
  }

  await prisma.notification.createMany({
    data: [
      {
        userId: manager.id,
        code: "DUE_REMINDER",
        title: "Ödenmemiş aidatlar var",
        body: "Vefa Apartman — bu ay henüz ödenmemiş aidatlar bulunuyor.",
        type: "DUE_REMINDER",
        isRead: false,
        data: { buildingId: vefa.id },
      },
    ],
  });

  log("vefa", "zenginleştirildi");
  return vefa;
}

async function seedSiteAndBlocks(manager, passwordHash) {
  const site = await prisma.site.upsert({
    where: { id: ids.site },
    update: {
      name: "Bahçeli Evler Sitesi",
      address: "Bahçelievler Mah. 15. Cadde No:8",
      city: "İstanbul",
      district: "Bahçelievler",
      dueAmount: 850,
      dueDay: 1,
      currency: "TRY",
      collectionIban: "TR330006100519786457841326",
      collectionAccountTitle: "Bahçeli Evler Yönetimi",
      collectionIbanLabel: "İş Bankası",
      collectionVerifiedAt: NOW,
      managerId: manager.id,
    },
    create: {
      id: ids.site,
      name: "Bahçeli Evler Sitesi",
      address: "Bahçelievler Mah. 15. Cadde No:8",
      city: "İstanbul",
      district: "Bahçelievler",
      dueAmount: 850,
      dueDay: 1,
      currency: "TRY",
      collectionIban: "TR330006100519786457841326",
      collectionAccountTitle: "Bahçeli Evler Yönetimi",
      collectionIbanLabel: "İş Bankası",
      collectionVerifiedAt: NOW,
      managerId: manager.id,
    },
  });

  const blocks = [
    { id: ids.blockA, label: "A Blok", floors: 4, perFloor: 2, due: 850, key: "a" },
    { id: ids.blockB, label: "B Blok", floors: 4, perFloor: 2, due: 900, key: "b" },
    { id: ids.blockC, label: "C Blok", floors: 3, perFloor: 2, due: 800, key: "c" },
  ];

  const allApts = [];
  for (const block of blocks) {
    await prisma.building.upsert({
      where: { id: block.id },
      update: {
        name: block.label,
        address: site.address,
        city: site.city,
        district: site.district,
        totalFloors: block.floors,
        apartmentsPerFloor: block.perFloor,
        dueAmount: block.due,
        dueDay: 1,
        currency: "TRY",
        managerId: manager.id,
        siteId: site.id,
        blockLabel: block.label,
      },
      create: {
        id: block.id,
        name: block.label,
        address: site.address,
        city: site.city,
        district: site.district,
        totalFloors: block.floors,
        apartmentsPerFloor: block.perFloor,
        dueAmount: block.due,
        dueDay: 1,
        currency: "TRY",
        managerId: manager.id,
        siteId: site.id,
        blockLabel: block.label,
      },
    });
    const apts = await createAptsWithLayout(
      block.id,
      block.floors,
      block.perFloor,
      `block-${block.key}`
    );
    allApts.push(...apts.map((a) => ({ ...a, block, due: block.due })));
  }

  const residentProfiles = [
    { name: "Elif Aksoy", phone: "5550202001" },
    { name: "Burak Özkan", phone: "5550202002" },
    { name: "Selin Aydın", phone: "5550202003" },
    { name: "Can Yıldız", phone: "5550202004" },
    { name: "Deniz Kara", phone: "5550202005" },
    { name: "Gülşen Mutlu", phone: "5550202006" },
    { name: "Hakan Erdem", phone: "5550202007" },
    { name: "İrem Taş", phone: "5550202008" },
    { name: "Kemal Uçar", phone: "5550202009" },
    { name: "Leyla Bilgin", phone: "5550202010" },
    { name: "Murat Sezer", phone: "5550202011" },
    { name: "Nazan Güler", phone: "5550202012" },
  ];

  let ri = 0;
  for (const apt of allApts) {
    const fill = apt.floor <= 2 || apt.number.endsWith("A");
    if (!fill || ri >= residentProfiles.length) {
      await ensureDuesForApartment({
        apartmentId: apt.id,
        baseAmount: apt.due,
        dueDay: 1,
        monthsBack: 1,
        monthsForward: Math.max(0, 12 - M),
        paidRatio: 0.4,
        residentName: null,
      });
      continue;
    }
    const profile = residentProfiles[ri++];
    await ensureResident({
      id: stableUuid(`resident-site-${String(ri).padStart(2, "0")}`),
      name: profile.name,
      phone: profile.phone,
      apartmentId: apt.id,
      passwordHash,
    });
    await ensureDuesForApartment({
      apartmentId: apt.id,
      baseAmount: apt.due,
      dueDay: 1,
      monthsBack: 2,
      monthsForward: Math.max(0, 12 - M),
      paidRatio: 0.6,
      residentName: profile.name,
    });
    await upsertInvite(
      apt.id,
      `APB${apt.block.key.toUpperCase()}${apt.number}${String(ri).padStart(2, "0")}`.slice(0, 12)
    );
  }

  const siteExpenses = [
    { title: "Site bahçe bakımı", category: "GARDEN", amount: 4800 },
    { title: "Site güvenlik", category: "OTHER", amount: 12000 },
    { title: "Havuz kimyasal ve temizlik", category: "CLEANING", amount: 3600 },
    { title: "Site sigortası (aylık pay)", category: "INSURANCE", amount: 2200 },
  ];
  for (const se of siteExpenses) {
    await createSiteExpenseService(
      site.id,
      manager.id,
      {
        ...se,
        date: new Date(Y, M - 1, 2).toISOString(),
        targetMonth: M,
        targetYear: Y,
        note: null,
      },
      { confirmPaidImpact: true, carryForwardPolicy: "NONE" }
    );
  }

  await createExpenseService(ids.blockA, manager.id, {
    title: "A Blok asansör bakımı",
    category: "ELEVATOR",
    amount: 2800,
    date: new Date(Y, M - 1, 4).toISOString(),
    targetMonth: M,
    targetYear: Y,
    note: null,
    confirmPaidImpact: true,
  });

  const samples = [
    {
      buildingId: ids.blockA,
      number: "1",
      title: "Otopark aydınlatması",
      description: "A Blok otopark giriş lambası yanmıyor.",
      category: "REQUEST",
      status: "OPEN",
    },
    {
      buildingId: ids.blockB,
      number: "4",
      title: "Su basıncı düşük",
      description: "Akşam saatlerinde musluk basıncı çok düşüyor.",
      category: "COMPLAINT",
      status: "IN_PROGRESS",
      update: "Su deposu kontrolü için firma yönlendirildi.",
    },
    {
      buildingId: ids.blockC,
      number: "1",
      title: "Çatı izolasyon talebi",
      description: "Son yağmurda damlama oldu, izolasyon kontrolü istiyoruz.",
      category: "REQUEST",
      status: "OPEN",
    },
  ];
  for (const s of samples) {
    const apt = await prisma.apartment.findFirst({
      where: { buildingId: s.buildingId, number: s.number },
      include: { resident: true },
    });
    if (!apt?.resident) continue;
    const ticket = await prisma.ticket.create({
      data: {
        apartmentId: apt.id,
        userId: apt.resident.id,
        title: s.title,
        description: s.description,
        category: s.category,
        status: s.status,
      },
    });
    if (s.update) {
      await prisma.ticketUpdate.create({
        data: { ticketId: ticket.id, message: s.update, fromRole: "MANAGER" },
      });
    }
  }

  log("site", "Bahçeli Evler Sitesi kuruldu");
  return site;
}

async function seedLale(manager, passwordHash) {
  await prisma.building.upsert({
    where: { id: ids.lale },
    update: {
      name: "Lale Apartmanı",
      address: "Caddebostan Mah. Bağdat Cad. No:120",
      city: "İstanbul",
      district: "Kadıköy",
      totalFloors: 5,
      apartmentsPerFloor: 2,
      dueAmount: 1250,
      dueDay: 10,
      currency: "TRY",
      managerId: manager.id,
      collectionIban: "TR460006400000112345678901",
      collectionAccountTitle: "Lale Apt. Yönetimi",
      collectionIbanLabel: "İş Bankası",
      collectionVerifiedAt: NOW,
      siteId: null,
      blockLabel: null,
    },
    create: {
      id: ids.lale,
      name: "Lale Apartmanı",
      address: "Caddebostan Mah. Bağdat Cad. No:120",
      city: "İstanbul",
      district: "Kadıköy",
      totalFloors: 5,
      apartmentsPerFloor: 2,
      dueAmount: 1250,
      dueDay: 10,
      currency: "TRY",
      managerId: manager.id,
      collectionIban: "TR460006400000112345678901",
      collectionAccountTitle: "Lale Apt. Yönetimi",
      collectionIbanLabel: "İş Bankası",
      collectionVerifiedAt: NOW,
    },
  });

  const apts = await createAptsWithLayout(ids.lale, 5, 2, "lale");
  const names = [
    ["Seda Koç", "5550303001"],
    ["Onur Akar", "5550303002"],
    ["Pınar Er", "5550303003"],
    ["Rıza Demirtaş", "5550303004"],
    ["Sibel Öztürk", "5550303005"],
    ["Tolga Yavuz", "5550303006"],
    ["Hande Polat", "5550303007"],
    ["Cem Aydın", "5550303008"],
    ["Ece Yılmaz", "5550303009"],
    ["Barış Tekin", "5550303010"],
  ];
  for (let i = 0; i < Math.min(names.length, apts.length); i += 1) {
    const [name, phone] = names[i];
    await ensureResident({
      id: stableUuid(`resident-lale-${i + 1}`),
      name,
      phone,
      apartmentId: apts[i].id,
      passwordHash,
    });
    await ensureDuesForApartment({
      apartmentId: apts[i].id,
      baseAmount: 1250,
      dueDay: 10,
      monthsBack: 2,
      monthsForward: Math.max(0, 12 - M),
      paidRatio: 0.5,
      residentName: name,
    });
  }

  await createExpenseService(ids.lale, manager.id, {
    title: "Çatı izolasyonu",
    category: "REPAIR",
    amount: 8500,
    date: new Date(Y, M - 1, 6).toISOString(),
    targetMonth: M,
    targetYear: Y,
    note: null,
    confirmPaidImpact: true,
  });
  await createExpenseService(ids.lale, manager.id, {
    title: "Temizlik şirketi",
    category: "CLEANING",
    amount: 2400,
    date: new Date(Y, M - 1, 5).toISOString(),
    targetMonth: M,
    targetYear: Y,
    note: null,
    confirmPaidImpact: true,
  });

  const apt = await prisma.apartment.findFirst({
    where: { buildingId: ids.lale, number: "1" },
    include: { resident: true },
  });
  if (apt?.resident) {
    await prisma.ticket.create({
      data: {
        apartmentId: apt.id,
        userId: apt.resident.id,
        title: "Interkom çalışmıyor",
        description: "Daire içi interkom ses vermiyor.",
        category: "MALFUNCTION",
        status: "OPEN",
      },
    });
  }

  log("lale", `Lale Apartmanı kuruldu (${ids.lale})`);
  return ids.lale;
}

async function printSummary(managerId) {
  const sites = await prisma.site.count({ where: { managerId } });
  const buildings = await prisma.building.findMany({
    where: { managerId },
    select: { id: true, name: true },
  });
  console.log("\n── Özet ─────────────────────────────────");
  console.log(`  Siteler: ${sites}`);
  for (const b of buildings) {
    const dues = await prisma.due.groupBy({
      by: ["status"],
      where: { apartment: { buildingId: b.id }, year: Y, month: M },
      _count: true,
    });
    const total = dues.reduce((s, x) => s + x._count, 0);
    const paid = dues.find((x) => x.status === "PAID")?._count || 0;
    const pct = total ? Math.round((100 * paid) / total) : 0;
    console.log(`  ${b.name}: ${b.id} | bu ay ${paid}/${total} (%${pct})`);
  }
  console.log(`  Sakin şifre: ${RESIDENT_PASSWORD}`);
  console.log("─────────────────────────────────────────\n");
}

async function main() {
  console.log("🎬 Tanıtım verisi (UUID) başlıyor...");
  console.log(`  Lale ID: ${ids.lale}`);

  const manager = await prisma.user.findFirst({
    where: { email: MANAGER_EMAIL, role: "MANAGER", deletedAt: null },
  });
  if (!manager) throw new Error(`MANAGER bulunamadı: ${MANAGER_EMAIL}`);
  log("manager", `${manager.name} (${manager.id})`);

  // UUID geçişi için eski ağacı temizle (FORCE olmasa da legacy string ID'ler silinir)
  await deleteShowcaseTree(manager.id);

  const sub = await grantBusiness(manager.id);
  log("sub", `Business → ${sub.currentPeriodEnd.toISOString().slice(0, 10)}`);

  const passwordHash = await bcrypt.hash(RESIDENT_PASSWORD, 10);
  const vefa = await enrichVefa(manager, passwordHash);
  await seedSiteAndBlocks(manager, passwordHash);
  await seedLale(manager, passwordHash);

  // Tüm yönetici binalarında harf şeması kalıntısı varsa 1…N'e çevir.
  const managerBuildings = await prisma.building.findMany({
    where: { managerId: manager.id },
    select: { id: true, name: true },
  });
  for (const b of managerBuildings) {
    const updated = await remumberApartmentsSequential(b.id);
    const sample = updated
      .slice(0, 4)
      .map((a) => a.number)
      .join(", ");
    log("numbers", `${b.name}: ${updated.length} daire → ${sample}${updated.length > 4 ? "…" : ""}`);
  }

  for (const buildingId of [ids.blockA, ids.blockB, ids.blockC, ids.lale]) {
    await recalculateBuildingDuesForMonth(buildingId, M, Y);
  }
  if (vefa) await recalculateBuildingDuesForMonth(vefa.id, M, Y);

  if (vefa) {
    log(
      "rate",
      `Vefa ${JSON.stringify(await applyExactPaidRatio(vefa.id, Y, M, 0.75, { dueDay: vefa.dueDay || 5, unpaidAs: "OVERDUE", exactCount: 8 }))}`
    );
  }
  log(
    "rate",
    `Lale ${JSON.stringify(await applyExactPaidRatio(ids.lale, Y, M, 0.75, { dueDay: 10, unpaidAs: "AUTO", exactCount: 10 }))}`
  );
  log(
    "rate",
    `A ${JSON.stringify(await applyExactPaidRatio(ids.blockA, Y, M, 0.62, { unpaidAs: "OVERDUE" }))}`
  );
  log(
    "rate",
    `B ${JSON.stringify(await applyExactPaidRatio(ids.blockB, Y, M, 0.5, { unpaidAs: "OVERDUE" }))}`
  );
  log(
    "rate",
    `C ${JSON.stringify(await applyExactPaidRatio(ids.blockC, Y, M, 0.83, { unpaidAs: "OVERDUE" }))}`
  );

  await ensureDekontWithPdf({
    buildingId: ids.lale,
    apartmentNumber: "1",
    referenceNumber: `AP-HV-${Y}${String(M).padStart(2, "0")}-18421`,
    status: "NEEDS_MANAGER_REVIEW",
    receiverIban: "TR460006400000112345678901",
    receiverTitle: "Lale Apt. Yönetimi",
    managerId: manager.id,
  });
  if (vefa) {
    await ensureDekontWithPdf({
      buildingId: vefa.id,
      apartmentNumber: "1",
      referenceNumber: `AP-HV-${Y}${String(M).padStart(2, "0")}-19003`,
      status: "NEEDS_MANAGER_REVIEW",
      receiverIban: vefa.collectionIban || "TR190001500158007357665813",
      receiverTitle: vefa.collectionAccountTitle || manager.name,
      managerId: manager.id,
    });
  }
  await ensureDekontWithPdf({
    buildingId: ids.lale,
    apartmentNumber: "3",
    referenceNumber: `AP-HV-${Y}${String(M).padStart(2, "0")}-18455`,
    status: "MATCHED",
    receiverIban: "TR460006400000112345678901",
    receiverTitle: "Lale Apt. Yönetimi",
    managerId: manager.id,
  });

  await printSummary(manager.id);
  console.log("✅ Tamamlandı — Lale detayı artık UUID ile açılmalı.");
}

main()
  .catch((err) => {
    console.error("❌ Seed hatası:", err);
    process.exitCode = 1;
  })
  .finally(async () => {
    await disconnectDB();
  });
