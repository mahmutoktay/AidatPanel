-- Expense.updatedAt: Prisma şemasında @updatedAt; init migration'da eksikti.
ALTER TABLE "Expense" ADD COLUMN IF NOT EXISTS "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP;
