import { prisma } from "./src/config/db.js";

async function main() {
  try {
    const building = await prisma.building.findFirst({
      where: { name: { contains: "cepe", mode: "insensitive" } },
    });

    if (!building) {
      console.log("Cepe building not found!");
      return;
    }

    console.log(`Found building: ${building.name} (ID: ${building.id})`);
    console.log(`Total Apartments: ${building.totalApartments}`);

    const apartments = await prisma.apartment.findMany({
      where: { buildingId: building.id },
      include: {
        resident: true,
      },
    });

    console.log(`\nApartments in DB: ${apartments.length}`);
    for (const apt of apartments) {
      console.log(`- Apartment ${apt.number}: Floor ${apt.floor}, Resident: ${apt.resident?.name || "None"}`);
    }

    const now = new Date();
    const currentMonth = now.getMonth() + 1;
    const currentYear = now.getFullYear();

    const dues = await prisma.due.findMany({
      where: {
        apartment: { buildingId: building.id },
      },
      include: {
        apartment: true,
        payments: true,
      },
    });

    console.log(`\nAll Dues found: ${dues.length}`);
    const currentMonthDues = dues.filter(d => d.month === currentMonth && d.year === currentYear);
    console.log(`Current month dues (${currentMonth}/${currentYear}): ${currentMonthDues.length}`);

    for (const d of dues) {
      if (d.month === currentMonth && d.year === currentYear) {
        console.log(`- Due for Apartment ${d.apartment.number}: Month ${d.month}/${d.year}, Amount: ${d.amount}, Status: ${d.status}, PaidAt: ${d.paidAt}`);
        if (d.payments.length > 0) {
          console.log(`  Payments:`);
          for (const p of d.payments) {
            console.log(`    * Payment Amount: ${p.amount}, PaidAt: ${p.paidAt}, DekontId: ${p.dekontId}`);
          }
        }
      }
    }

    const allPayments = await prisma.duePayment.findMany({
      where: {
        due: {
          apartment: { buildingId: building.id }
        }
      },
      include: {
        due: {
          include: {
            apartment: true
          }
        }
      }
    });

    console.log(`\nAll payments for this building: ${allPayments.length}`);
    for (const p of allPayments) {
      console.log(`- Payment for Apt ${p.due.apartment.number} (${p.due.month}/${p.due.year}): Amount: ${p.amount}, PaidAt: ${p.paidAt}, DueStatus: ${p.due.status}`);
    }

    const allDekonts = await prisma.dekont.findMany({
      where: { buildingId: building.id },
      include: {
        apartment: true,
      }
    });

    console.log(`\nAll receipts (dekonts) for this building: ${allDekonts.length}`);
    for (const d of allDekonts) {
      console.log(`- Dekont ID: ${d.id}, Apt: ${d.apartment?.number || "None"}, Amount: ${d.parsedAmount}, Status: ${d.status}, DueID: ${d.dueId}`);
    }

  } catch (error) {
    console.error("Error in diagnose script:", error);
  } finally {
    await prisma.$disconnect();
  }
}

main();
