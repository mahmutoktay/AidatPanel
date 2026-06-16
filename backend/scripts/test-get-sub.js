import { prisma } from "../src/config/db.js";
import { generateAccessToken } from "../src/utils/generateTokens.js";

async function main() {
  try {
    const manager = await prisma.user.findFirst({
      where: { role: "MANAGER" }
    });

    if (!manager) {
      console.log("No manager found in DB");
      return;
    }

    console.log(`Using manager: ${manager.name} (${manager.email}) - ID: ${manager.id}`);
    const token = generateAccessToken(manager);
    console.log(`Generated Access Token: ${token}`);

    // Call localhost:4200/api/v1/me/subscription
    const res = await fetch("http://localhost:4200/api/v1/me/subscription", {
      headers: {
        "Authorization": `Bearer ${token}`
      }
    });

    console.log(`Status Code: ${res.status}`);
    console.log(`Headers:`, Object.fromEntries(res.headers.entries()));
    const bodyText = await res.text();
    console.log(`Body: ${bodyText}`);

  } catch (error) {
    console.error("Error running test-get-sub:", error);
  } finally {
    await prisma.$disconnect();
  }
}

main();
