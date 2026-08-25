/**
 * Müşteri demo hesabı — tek bina, gerçekçi veri.
 *
 * Yönetici: abdullah@demo.com / Demo123. (Abdullah Aslan)
 *
 * Kullanım (Postgres tüneli 5433):
 *   node scripts/seed-customer-demo.js
 *
 * Yerel 5432 için:
 *   DEMO_DB_PORT=5432 node scripts/seed-customer-demo.js
 */

import { config } from "dotenv";
import bcrypt from "bcryptjs";
import { createHash } from "crypto";

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
const { recalculateBuildingDuesForMonth } = await import(
  "../src/services/dueExpenseRecalcService.js"
);
const { computeOverdueDays, endOfDueDayIstanbul } = await import(
  "../src/utils/trDueDate.js"
);

const MANAGER_EMAIL = "abdullah@demo.com";
const MANAGER_NAME = "Abdullah Aslan";
const MANAGER_PASSWORD = "Demo123.";
const MANAGER_PHONE = "5551000000";
const RESIDENT_PASSWORD = "Demo123.";

const NOW = new Date();
const Y = NOW.getFullYear();
const M = NOW.getMonth() + 1;
/** Bu ay aidat son günü — gecikme en fazla 5 gün kalsın. */
const DUE_DAY = Math.max(1, Math.min(28, NOW.getDate() - 3));
const BASE_DUE = 950;

function stableUuid(seed) {
  const hash = createHash("sha1").update(`aidatpanel-customer-demo:${seed}`).digest();
  const b = Buffer.from(hash);
  b[6] = (b[6] & 0x0f) | 0x50;
  b[8] = (b[8] & 0x3f) | 0x80;
  const h = b.toString("hex");
  return `${h.slice(0, 8)}-${h.slice(8, 12)}-${h.slice(12, 16)}-${h.slice(16, 20)}-${h.slice(20, 32)}`;
}

function daysAgo(n) {
  const d = new Date(NOW);
  d.setDate(d.getDate() - n);
  d.setHours(12, 0, 0, 0);
  return d;
}

function dueDateFor(year, month, day) {
  return endOfDueDayIstanbul(year, month, day);
}

function log(step, msg) {
  console.log(`  [${step}] ${msg}`);
}

const IDS = {
  building: stableUuid("building-camlik"),
  manager: stableUuid("manager-abdullah"),
};

const RESIDENTS = [
  { name: "Ayşe Demir", phone: "5551001001" },
  { name: "Mehmet Yılmaz", phone: "5551001002" },
  { name: "Zeynep Kaya", phone: "5551001003" },
  { name: "Ali Çelik", phone: "5551001004" },
  { name: "Fatma Arslan", phone: "5551001005" },
  { name: "Emre Şahin", phone: "5551001006" },
  { name: "Elif Aksoy", phone: "5551001007" },
  { name: "Burak Özkan", phone: "5551001008" },
  { name: "Selin Aydın", phone: "5551001009" },
  { name: "Can Yıldız", phone: "5551001010" },
];

const EXPENSES = [
  { title: "Merdiven ve ortak alan temizliği", category: "CLEANING", amount: 4200 },
  { title: "Asansör periyodik bakım", category: "ELEVATOR", amount: 3800 },
  { title: "Ortak alan elektrik faturası", category: "ELECTRICITY", amount: 2650 },
  { title: "Su deposu ve ortak sayaç", category: "WATER", amount: 1850 },
  { title: "Bina ferdi kaza / yangın sigortası (aylık)", category: "INSURANCE", amount: 2100 },
  { title: "Giriş kapısı kilit tamiri", category: "REPAIR", amount: 1450 },
  { title: "Bahçe çim biçme ve budama", category: "GARDEN", amount: 1600 },
  { title: "Çöp konteyneri taşıma ücreti", category: "OTHER", amount: 900 },
];

/** Flutter: kategori seçilmez (hep REQUEST), başlık açıklamadan türetilir, yönetici not eklemez. */
function deriveTicketTitle(description) {
  const trimmed = String(description ?? "").trim();
  if (!trimmed) return "Talep";
  const firstLine = trimmed.split(/\r?\n/)[0].trim();
  if (!firstLine) return "Talep";
  if (firstLine.length <= 120) return firstLine;
  return `${firstLine.slice(0, 117)}...`;
}

const TICKETS = [
  {
    apt: 1,
    description:
      "Asansör 3. kattan itibaren inerken metal sürtünme sesi çıkarıyor. Özellikle akşam saatlerinde daha belirgin, kontrol edilmesini rica ederim.",
    status: "IN_PROGRESS",
  },
  {
    apt: 3,
    description:
      "2. kat merdiven sahanlığındaki lamba iki gündür yanmıyor. Gece iniş çıkış zorlaşıyor, değiştirilmesini rica ederim.",
    status: "OPEN",
  },
  {
    apt: 5,
    description:
      "Yağmur sonrası girişte kapı önünde su birikiyor, kayma riski var. Yağmur oluğu tıkanmış olabilir.",
    status: "RESOLVED",
  },
  {
    apt: 6,
    description:
      "Daire içi interkom ses vermiyor, kapı açma da çalışmıyor. Mümkünse bakıma bakabilir misiniz?",
    status: "OPEN",
  },
  {
    apt: 8,
    description:
      "Bodrum otopark girişindeki lamba yanmıyor, araç manevrası tehlikeli hale geldi. Aydınlatmanın onarılmasını istiyorum.",
    status: "IN_PROGRESS",
  },
  {
    apt: 10,
    description:
      "Gece 23.00’ten sonra yüksek sesle müzik açılıyor. Komşuya uyarı yapılmasını rica ediyoruz.",
    status: "OPEN",
  },
];

const ANNOUNCEMENTS = [
  {
    body: "Değerli komşularımız, bu ay aidat son ödeme günü ayın " +
      `${DUE_DAY}'idir. Elden veya havale ile ödemelerinizi zamanında yapmanızı rica ederiz.`,
    daysAgo: 8,
  },
  {
    body: "Asansör bakımı 28 Ağustos Perşembe saat 09:00–12:00 arasında yapılacaktır. Bu süre boyunca asansör kullanılamayacaktır.",
    daysAgo: 5,
  },
  {
    body: "Çatı izolasyon kontrolü için firmadan keşif randevusu alındı. 30 Ağustos Cumartesi bina genelinde kısa süreli gürültü olabilir.",
    daysAgo: 3,
  },
  {
    body: "Ortak alan temizlik programı güncellendi: Pazartesi–Cuma 08:30–10:00 arası merdiven ve giriş holü temizlenecektir.",
    daysAgo: 1,
  },
];

async function ensureManager(passwordHash) {
  const existing = await prisma.user.findFirst({
    where: { email: MANAGER_EMAIL },
  });
  if (existing) {
    return prisma.user.update({
      where: { id: existing.id },
      data: {
        name: MANAGER_NAME,
        phone: MANAGER_PHONE,
        passwordHash,
        role: "MANAGER",
        deletedAt: null,
        language: "tr",
      },
    });
  }
  return prisma.user.create({
    data: {
      id: IDS.manager,
      email: MANAGER_EMAIL,
      name: MANAGER_NAME,
      phone: MANAGER_PHONE,
      passwordHash,
      role: "MANAGER",
      language: "tr",
    },
  });
}

async function grantSubscription(managerId) {
  const end = new Date(NOW);
  end.setDate(end.getDate() + 180);
  return prisma.subscription.upsert({
    where: { userId: managerId },
    create: {
      userId: managerId,
      status: "ACTIVE",
      plan: "business_annual",
      platform: "admin_grant",
      currentPeriodStart: NOW,
      currentPeriodEnd: end,
    },
    update: {
      status: "ACTIVE",
      plan: "business_annual",
      platform: "admin_grant",
      currentPeriodStart: NOW,
      currentPeriodEnd: end,
    },
  });
}

async function main() {
  console.log("🏢 Müşteri demo seed başlıyor...");
  console.log(`  DB port: ${DEMO_DB_PORT}`);

  const passwordHash = await bcrypt.hash(MANAGER_PASSWORD, 10);
  const manager = await ensureManager(passwordHash);
  log("manager", `${manager.name} <${manager.email}>`);

  await grantSubscription(manager.id);
  log("sub", "Business annual (180 gün)");

  const building = await prisma.building.upsert({
    where: { id: IDS.building },
    update: {
      name: "Çamlık Apartmanı",
      address: "Çamlık Mah. Gül Sokak No:14",
      city: "Ankara",
      district: "Çankaya",
      totalFloors: 5,
      apartmentsPerFloor: 2,
      dueAmount: BASE_DUE,
      dueDay: DUE_DAY,
      currency: "TRY",
      managerId: manager.id,
      collectionIban: "TR640006400000123456789012",
      collectionAccountTitle: "Çamlık Apt. Yönetimi",
      collectionIbanLabel: "İş Bankası",
      collectionVerifiedAt: NOW,
    },
    create: {
      id: IDS.building,
      name: "Çamlık Apartmanı",
      address: "Çamlık Mah. Gül Sokak No:14",
      city: "Ankara",
      district: "Çankaya",
      totalFloors: 5,
      apartmentsPerFloor: 2,
      dueAmount: BASE_DUE,
      dueDay: DUE_DAY,
      currency: "TRY",
      managerId: manager.id,
      collectionIban: "TR640006400000123456789012",
      collectionAccountTitle: "Çamlık Apt. Yönetimi",
      collectionIbanLabel: "İş Bankası",
      collectionVerifiedAt: NOW,
    },
  });
  log("building", `${building.name} — ${building.address}, ${building.district}/${building.city}`);

  const apartments = [];
  for (let i = 1; i <= 10; i += 1) {
    const id = stableUuid(`apt-${i}`);
    const apt = await prisma.apartment.upsert({
      where: { id },
      update: {
        number: String(i),
        floor: Math.ceil(i / 2),
        buildingId: building.id,
      },
      create: {
        id,
        number: String(i),
        floor: Math.ceil(i / 2),
        buildingId: building.id,
      },
    });
    apartments.push(apt);

    const expiresAt = new Date(NOW);
    expiresAt.setFullYear(expiresAt.getFullYear() + 1);
    const code = `APCM${String(i).padStart(2, "0")}D1A2`;
    const existingInvite = await prisma.inviteCode.findUnique({ where: { code } });
    if (!existingInvite) {
      await prisma.inviteCode.create({
        data: { code, apartmentId: apt.id, expiresAt },
      });
    }
  }
  log("apts", `${apartments.length} daire`);

  const residents = [];
  for (let i = 0; i < RESIDENTS.length; i += 1) {
    const profile = RESIDENTS[i];
    const apt = apartments[i];
    const id = stableUuid(`resident-${i + 1}`);
    const existingPhone = await prisma.user.findFirst({
      where: { phone: profile.phone },
    });
    let user;
    if (existingPhone) {
      user = await prisma.user.update({
        where: { id: existingPhone.id },
        data: {
          name: profile.name,
          passwordHash,
          role: "RESIDENT",
          apartmentId: apt.id,
          deletedAt: null,
          language: "tr",
        },
      });
    } else {
      const existingId = await prisma.user.findUnique({ where: { id } });
      if (existingId) {
        user = await prisma.user.update({
          where: { id },
          data: {
            name: profile.name,
            phone: profile.phone,
            passwordHash,
            role: "RESIDENT",
            apartmentId: apt.id,
            deletedAt: null,
          },
        });
      } else {
        user = await prisma.user.create({
          data: {
            id,
            name: profile.name,
            phone: profile.phone,
            passwordHash,
            role: "RESIDENT",
            apartmentId: apt.id,
            language: "tr",
          },
        });
      }
    }
    residents.push({ ...user, apartment: apt });
  }
  log("residents", `${residents.length} sakin`);

  // Önceki ay — tamamı ödenmiş (dashboard geçmişi)
  const prev = new Date(Y, M - 2, 1);
  const prevY = prev.getFullYear();
  const prevM = prev.getMonth() + 1;
  for (const r of residents) {
    const dd = dueDateFor(prevY, prevM, DUE_DAY);
    const paidAt = new Date(prevY, prevM - 1, Math.min(DUE_DAY + 1, 28));
    const due = await prisma.due.create({
      data: {
        apartmentId: r.apartment.id,
        amount: BASE_DUE,
        currency: "TRY",
        month: prevM,
        year: prevY,
        dueDate: dd,
        status: "PAID",
        paidAt,
        overdueDays: 0,
        residentNameSnapshot: r.name,
      },
    });
    await prisma.duePayment.create({
      data: {
        dueId: due.id,
        amount: BASE_DUE,
        paidAt,
        currency: "TRY",
        note: iParityCash(r.apartment.number) ? "Elden tahsilat" : "Havale ile ödeme",
      },
    });
  }
  log("dues", `önceki ay ${prevM}/${prevY} — %100 ödenmiş`);

  // Bu ay aidatları (önce base, giderlerden sonra yeniden hesap)
  for (const r of residents) {
    await prisma.due.create({
      data: {
        apartmentId: r.apartment.id,
        amount: BASE_DUE,
        currency: "TRY",
        month: M,
        year: Y,
        dueDate: dueDateFor(Y, M, DUE_DAY),
        status: "PENDING",
        overdueDays: 0,
        residentNameSnapshot: r.name,
      },
    });
  }

  const aptCount = apartments.length;
  for (const item of EXPENSES) {
    const perUnit = Math.round((item.amount / aptCount) * 100) / 100;
    await prisma.expense.create({
      data: {
        buildingId: building.id,
        title: item.title,
        category: item.category,
        amount: item.amount,
        date: daysAgo(6),
        targetMonth: M,
        targetYear: Y,
        perUnitAmount: perUnit,
        note: null,
        storedPaths: [],
      },
    });
  }
  await recalculateBuildingDuesForMonth(building.id, M, Y);
  log("expenses", `${EXPENSES.length} kategori gider + aidat yeniden hesap`);

  // Ödeme oranı %75 → 10 daireden 8 ödenmiş, 2 gecikmiş (≤5 gün)
  const dues = await prisma.due.findMany({
    where: { year: Y, month: M, apartment: { buildingId: building.id } },
    include: {
      apartment: { include: { resident: true } },
    },
    orderBy: { apartment: { number: "asc" } },
  });
  dues.sort((a, b) =>
    String(a.apartment.number).localeCompare(String(b.apartment.number), "tr", {
      numeric: true,
    })
  );

  const targetPaid = Math.round(dues.length * 0.75); // 8
  for (let i = 0; i < dues.length; i += 1) {
    const due = dues[i];
    const aptNo = Number(due.apartment.number);
    const amount = Number(due.amount);

    const sharedDueDate = dueDateFor(Y, M, DUE_DAY);

    if (i < targetPaid) {
      const isCash = i % 2 === 0; // elden / havale karışık
      // Geç ödeme: aynı vadeden sonra farklı günlerde ödenmiş olabilir (gerçekçi).
      const lateDays = i === 2 || i === 5 ? (i === 2 ? 3 : 4) : 0;
      const paidAt = new Date(sharedDueDate);
      paidAt.setUTCDate(paidAt.getUTCDate() + lateDays);
      paidAt.setUTCHours(11, 30, 0, 0);
      if (paidAt > NOW) paidAt.setTime(NOW.getTime() - 3600_000);

      await prisma.due.update({
        where: { id: due.id },
        data: {
          status: "PAID",
          paidAt,
          dueDate: sharedDueDate,
          overdueDays: lateDays,
        },
      });

      let dekontId = null;
      if (!isCash && due.apartment.resident) {
        const ref = `AP-DEMO-${Y}${String(M).padStart(2, "0")}-${String(aptNo).padStart(3, "0")}`;
        const fileHash = createHash("sha256").update(`demo-dekont-${ref}`).digest("hex");
        const dekont = await prisma.dekont.create({
          data: {
            buildingId: building.id,
            apartmentId: due.apartmentId,
            uploadedById: due.apartment.resident.id,
            dueId: due.id,
            status: "PAYMENT_APPLIED",
            source: "RESIDENT_UPLOAD",
            storedPath: `demo/havale-${aptNo}.pdf`,
            originalFilename: `havale-daire-${aptNo}.pdf`,
            mimeType: "application/pdf",
            sizeBytes: 12_480,
            fileHash,
            referenceNumber: ref,
            parsedAmount: amount,
            receiverIban: building.collectionIban,
            transactionDate: paidAt,
            aiConfidence: 0.93,
            rawText: `HAVALE ${ref} TUTAR ${amount}`,
            parsedJson: { amount, referenceNumber: ref },
          },
        });
        dekontId = dekont.id;
        await prisma.dekontDueAllocation.create({
          data: {
            dekontId: dekont.id,
            dueId: due.id,
            allocatedAmount: amount,
          },
        });
      }

      await prisma.duePayment.create({
        data: {
          dueId: due.id,
          dekontId,
          amount,
          paidAt,
          currency: "TRY",
          note: isCash
            ? lateDays > 0
              ? `Elden tahsilat (${lateDays} gün gecikmeli)`
              : "Elden tahsilat"
            : lateDays > 0
              ? `Havale ile ödeme (${lateDays} gün gecikmeli)`
              : "Havale ile ödeme",
        },
      });
    } else {
      // Aynı bina + aynı aidat günü → tüm açık aidatlarda aynı gecikme günü.
      const overdueDays = Math.min(5, Math.max(1, computeOverdueDays(sharedDueDate, NOW)));
      await prisma.due.update({
        where: { id: due.id },
        data: {
          status: "OVERDUE",
          paidAt: null,
          overdueDays,
          dueDate: sharedDueDate,
        },
      });
    }
  }
  log("payments", `${targetPaid}/${dues.length} ödenmiş (%${Math.round((100 * targetPaid) / dues.length)}) — elden+havale`);

  // Talepler (Flutter: yalnızca açıklama + opsiyonel görsel; kategori REQUEST; yönetici notu yok)
  for (const t of TICKETS) {
    const apt = apartments.find((a) => a.number === String(t.apt));
    const resident = residents.find((r) => r.apartment.id === apt?.id);
    if (!apt || !resident) continue;
    await prisma.ticket.create({
      data: {
        apartmentId: apt.id,
        userId: resident.id,
        title: deriveTicketTitle(t.description),
        description: t.description,
        category: "REQUEST",
        status: t.status,
        createdAt: daysAgo(7 - Math.min(t.apt, 6)),
      },
    });
  }
  log("tickets", `${TICKETS.length} talep`);

  // Duyurular → sakin bildirimleri
  const residentIds = residents.map((r) => r.id);
  for (const ann of ANNOUNCEMENTS) {
    const createdAt = daysAgo(ann.daysAgo);
    await prisma.notification.createMany({
      data: residentIds.map((userId) => ({
        userId,
        code: "announcement_custom",
        title: "Duyuru",
        body: ann.body,
        type: "ANNOUNCEMENT",
        isRead: ann.daysAgo > 4,
        data: { buildingId: building.id, route: "/resident-dashboard" },
        createdAt,
      })),
    });
  }
  log("announcements", `${ANNOUNCEMENTS.length} duyuru → ${residentIds.length} sakin`);

  // Yönetici bildirimleri (maks 6)
  const ticketByApt = Object.fromEntries(
    TICKETS.map((t) => [t.apt, deriveTicketTitle(t.description)])
  );
  const managerNotifs = [
    {
      code: "TICKET_CREATED",
      title: "Yeni talep",
      body: `Çamlık Apartmanı — Daire 1: ${ticketByApt[1]}`,
      type: "TICKET_CREATED",
      isRead: false,
      daysAgo: 2,
    },
    {
      code: "TICKET_CREATED",
      title: "Yeni talep",
      body: `Çamlık Apartmanı — Daire 6: ${ticketByApt[6]}`,
      type: "TICKET_CREATED",
      isRead: false,
      daysAgo: 1,
    },
    {
      code: "TICKET_CREATED",
      title: "Yeni talep",
      body: `Çamlık Apartmanı — Daire 10: ${ticketByApt[10]}`,
      type: "TICKET_CREATED",
      isRead: true,
      daysAgo: 4,
    },
    {
      code: "DUE_REMINDER",
      title: "Ödenmemiş aidatlar var",
      body: "Çamlık Apartmanı — bu ay henüz ödenmemiş 2 daire aidatı bulunuyor.",
      type: "DUE_REMINDER",
      isRead: false,
      daysAgo: 0,
    },
    {
      code: "DEKONT_NEEDS_REVIEW",
      title: "Dekont inceleme bekliyor",
      body: "Çamlık Apartmanı — Daire 4’ten yeni havale dekontu geldi.",
      type: "DEKONT_NEEDS_REVIEW",
      isRead: false,
      daysAgo: 1,
    },
    {
      code: "TICKET_UPDATE",
      title: "Talep güncellendi",
      body: `Daire 5 — talep yapıldı olarak işaretlendi.`,
      type: "TICKET_UPDATE",
      isRead: true,
      daysAgo: 3,
    },
  ];

  await prisma.notification.createMany({
    data: managerNotifs.map((n) => ({
      userId: manager.id,
      code: n.code,
      title: n.title,
      body: n.body,
      type: n.type,
      isRead: n.isRead,
      data: { buildingId: building.id },
      createdAt: daysAgo(n.daysAgo),
    })),
  });
  log("manager-notif", `${managerNotifs.length} bildirim`);

  const paidCount = await prisma.due.count({
    where: {
      year: Y,
      month: M,
      status: "PAID",
      apartment: { buildingId: building.id },
    },
  });
  const overdueCount = await prisma.due.count({
    where: {
      year: Y,
      month: M,
      status: "OVERDUE",
      apartment: { buildingId: building.id },
    },
  });
  const cashPays = await prisma.duePayment.count({
    where: {
      dekontId: null,
      due: { year: Y, month: M, apartment: { buildingId: building.id } },
    },
  });
  const transferPays = await prisma.duePayment.count({
    where: {
      dekontId: { not: null },
      due: { year: Y, month: M, apartment: { buildingId: building.id } },
    },
  });

  console.log("\n── Demo özet ────────────────────────────");
  console.log(`  Yönetici: ${MANAGER_EMAIL} / ${MANAGER_PASSWORD}`);
  console.log(`  Bina: ${building.name} (${building.id})`);
  console.log(`  Bu ay: ${paidCount} ödenmiş, ${overdueCount} gecikmiş`);
  console.log(`  Ödeme kanalı: ${cashPays} elden, ${transferPays} havale`);
  console.log(`  Aidat günü: ayın ${DUE_DAY}'i`);
  console.log(`  Sakin şifre: ${RESIDENT_PASSWORD} (telefon ile giriş)`);
  console.log("─────────────────────────────────────────\n");
  console.log("✅ Müşteri demo hazır.");
}

function iParityCash(apartmentNumber) {
  return Number(apartmentNumber) % 2 === 1;
}

main()
  .catch((err) => {
    console.error("❌ Seed hatası:", err);
    process.exitCode = 1;
  })
  .finally(async () => {
    await disconnectDB();
  });
