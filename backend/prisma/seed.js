/**
 * AidatPanel — Seed Script
 *
 * Geliştirme ve test ortamı için örnek veri oluşturur.
 *
 * Kullanım:
 *   npx prisma db seed
 *   # veya
 *   node prisma/seed.js
 *
 * Oluşturulan veriler:
 *   - 1 yönetici (yonetici@aidatpanel.test / Test1234!)
 *   - 1 bina (Güneş Apartmanı, İstanbul)
 *   - 8 daire (1-8 numaralı)
 *   - Mevcut ay için aidat kayıtları (5'i ödenmiş, 3'ü bekliyor)
 *   - 1 sakin (sakin@aidatpanel.test / Test1234!) — 1 numaralı daire
 *
 * IDEMPOTENT: upsert kullanır — tekrar çalıştırılabilir.
 */

import { PrismaClient } from "@prisma/client";
import bcrypt from "bcryptjs";

const prisma = new PrismaClient();

const TEST_PASSWORD = "Test1234!";

async function main() {
  console.log("🌱 Seed başlıyor...");

  // 1. Yönetici kullanıcısı
  const hashedPassword = await bcrypt.hash(TEST_PASSWORD, 10);

  const manager = await prisma.user.upsert({
    where: { email: "yonetici@aidatpanel.test" },
    update: {},
    create: {
      email: "yonetici@aidatpanel.test",
      name: "Test Yönetici",
      phone: "5551234567",
      passwordHash: hashedPassword,
      role: "MANAGER",
    },
  });
  console.log(`  ✅ Yönetici: ${manager.email}`);

  // 2. Bina
  const building = await prisma.building.upsert({
    where: { id: "seed-building-1" },
    update: {},
    create: {
      id: "seed-building-1",
      name: "Güneş Apartmanı",
      address: "Bağdat Caddesi No:42, Kadıköy",
      city: "İstanbul",
      managerId: manager.id,
      dueAmount: 750,
      dueDay: 1,
      currency: "TRY",
      totalFloors: 4,
      apartmentsPerFloor: 2,
    },
  });
  console.log(`  ✅ Bina: ${building.name}`);

  // 3. Daireler ve aidatlar
  const now = new Date();
  const currentMonth = now.getMonth() + 1;
  const currentYear = now.getFullYear();
  const dueAmount = 750;

  for (let i = 1; i <= 8; i++) {
    const aptId = `seed-apt-${i}`;

    await prisma.apartment.upsert({
      where: { id: aptId },
      update: {},
      create: {
        id: aptId,
        number: `${i}`,
        floor: Math.ceil(i / 2),
        buildingId: building.id,
      },
    });

    // Aidat kaydı
    const dueId = `seed-due-${i}-${currentYear}-${currentMonth}`;
    const isPaid = i <= 5;

    await prisma.due.upsert({
      where: { id: dueId },
      update: {},
      create: {
        id: dueId,
        apartmentId: aptId,
        amount: dueAmount,
        currency: "TRY",
        month: currentMonth,
        year: currentYear,
        dueDate: new Date(currentYear, currentMonth - 1, 10),
        status: isPaid ? "PAID" : "PENDING",
        paidAt: isPaid ? new Date(currentYear, currentMonth - 1, i + 2) : null,
      },
    });
  }
  console.log(`  ✅ 8 daire + ${currentMonth}/${currentYear} aidatları oluşturuldu`);

  // 4. Sakin kullanıcısı (1 numaralı daire)
  const resident = await prisma.user.upsert({
    where: { email: "sakin@aidatpanel.test" },
    update: {},
    create: {
      email: "sakin@aidatpanel.test",
      name: "Test Sakin",
      phone: "5559876543",
      passwordHash: hashedPassword,
      role: "RESIDENT",
      apartmentId: "seed-apt-1",
    },
  });
  console.log(`  ✅ Sakin: ${resident.email} → Daire 1`);

  // 5. Örnek giderler (bu ay)
  const expenseCategories = [
    { title: "Temizlik hizmeti", category: "CLEANING", amount: 1200 },
    { title: "Asansör bakımı", category: "ELEVATOR", amount: 2500 },
    { title: "Elektrik faturası (ortak)", category: "ELECTRICITY", amount: 850 },
  ];

  for (const exp of expenseCategories) {
    await prisma.expense.create({
      data: {
        buildingId: building.id,
        title: exp.title,
        amount: exp.amount,
        category: exp.category,
        date: new Date(currentYear, currentMonth - 1, 5),
        targetMonth: currentMonth,
        targetYear: currentYear,
        perUnitAmount: exp.amount / 8,
      },
    });
  }
  console.log(`  ✅ 3 örnek gider oluşturuldu`);

  console.log("\n🎉 Seed tamamlandı!");
  console.log("─".repeat(50));
  console.log("  Yönetici: yonetici@aidatpanel.test / Test1234!");
  console.log("  Sakin:    sakin@aidatpanel.test   / Test1234!");
  console.log("  Bina:     Güneş Apartmanı (8 daire)");
  console.log("─".repeat(50));
}

main()
  .catch((e) => {
    console.error("❌ Seed hatası:", e);
    process.exit(1);
  })
  .finally(() => prisma.$disconnect());
