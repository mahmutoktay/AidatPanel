-- Expense: aidat hedef ay alanları
ALTER TABLE "Expense" ADD COLUMN "targetMonth" INTEGER NOT NULL DEFAULT 1;
ALTER TABLE "Expense" ADD COLUMN "targetYear" INTEGER NOT NULL DEFAULT 2026;
ALTER TABLE "Expense" ADD COLUMN "perUnitAmount" DECIMAL(10,2);
ALTER TABLE "Expense" ADD COLUMN "splitGroupId" TEXT;
ALTER TABLE "Expense" ADD COLUMN "sourceExpenseId" TEXT;

-- Mevcut kayıtlar: date'ten targetMonth/Year türet
UPDATE "Expense"
SET
  "targetMonth" = EXTRACT(MONTH FROM "date")::INTEGER,
  "targetYear" = EXTRACT(YEAR FROM "date")::INTEGER;

-- perUnitAmount backfill (daire sayısına böl; amount null ise atla)
UPDATE "Expense" e
SET "perUnitAmount" = ROUND(e."amount" / NULLIF(ap.cnt, 0), 2)
FROM (
  SELECT b.id AS "buildingId", COUNT(a.id)::DECIMAL AS cnt
  FROM "Building" b
  LEFT JOIN "Apartment" a ON a."buildingId" = b.id
  GROUP BY b.id
) ap
WHERE e."buildingId" = ap."buildingId"
  AND e."amount" IS NOT NULL
  AND ap.cnt > 0;

CREATE INDEX "Expense_buildingId_targetYear_targetMonth_idx"
  ON "Expense"("buildingId", "targetYear", "targetMonth");

-- Carryforward tablosu
CREATE TABLE "DueExpenseCarryforward" (
  "id" TEXT NOT NULL,
  "expenseId" TEXT NOT NULL,
  "apartmentId" TEXT NOT NULL,
  "fromMonth" INTEGER NOT NULL,
  "fromYear" INTEGER NOT NULL,
  "toMonth" INTEGER NOT NULL,
  "toYear" INTEGER NOT NULL,
  "amount" DECIMAL(10,2) NOT NULL,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT "DueExpenseCarryforward_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX "DueExpenseCarryforward_expenseId_apartmentId_key"
  ON "DueExpenseCarryforward"("expenseId", "apartmentId");

CREATE INDEX "DueExpenseCarryforward_apartmentId_toYear_toMonth_idx"
  ON "DueExpenseCarryforward"("apartmentId", "toYear", "toMonth");

ALTER TABLE "DueExpenseCarryforward"
  ADD CONSTRAINT "DueExpenseCarryforward_expenseId_fkey"
  FOREIGN KEY ("expenseId") REFERENCES "Expense"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "DueExpenseCarryforward"
  ADD CONSTRAINT "DueExpenseCarryforward_apartmentId_fkey"
  FOREIGN KEY ("apartmentId") REFERENCES "Apartment"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
