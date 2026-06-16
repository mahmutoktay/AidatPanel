import { prisma } from "../src/config/db.js";

async function main() {
  try {
    const managers = await prisma.user.findMany({
      where: { role: "MANAGER" },
      select: { id: true, name: true, email: true, role: true }
    });

    console.log(`Managers in database: ${managers.length}`);
    for (const m of managers) {
      console.log(`- ID: ${m.id}, Name: ${m.name}, Email: ${m.email}`);
    }

    const residents = await prisma.user.findMany({
      where: { role: "RESIDENT" },
      select: { id: true, name: true, email: true, role: true }
    });
    console.log(`Residents in database: ${residents.length}`);
    for (const r of residents) {
      console.log(`- ID: ${r.id}, Name: ${r.name}, Email: ${r.email}`);
    }

  } catch (error) {
    console.error("Error running script:", error);
  } finally {
    await prisma.$disconnect();
  }
}

main();
