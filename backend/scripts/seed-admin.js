#!/usr/bin/env node
/**
 * İlk SUPER_ADMIN kullanıcısı oluşturur.
 * Kullanım: ADMIN_SEED_EMAIL=... ADMIN_SEED_PASSWORD=... node scripts/seed-admin.js
 */
import { config } from "dotenv";
config();

import bcrypt from "bcryptjs";
import { prisma } from "../src/config/db.js";

const email = process.env.ADMIN_SEED_EMAIL || "admin@aidatpanel.com";
const password = process.env.ADMIN_SEED_PASSWORD || "Admin123!ChangeMe";
const name = process.env.ADMIN_SEED_NAME || "Super Admin";

async function main() {
  const existing = await prisma.adminUser.findUnique({ where: { email } });
  if (existing) {
    console.log("Admin zaten mevcut:", email);
    return;
  }

  const passwordHash = await bcrypt.hash(password, 10);
  const admin = await prisma.adminUser.create({
    data: {
      email,
      passwordHash,
      name,
      role: "SUPER_ADMIN",
    },
  });

  console.log("SUPER_ADMIN oluşturuldu:", admin.email, admin.id);
  if (!process.env.ADMIN_SEED_PASSWORD) {
    console.warn("Varsayılan şifre kullanıldı — production'da ADMIN_SEED_PASSWORD ile değiştirin.");
  }
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
