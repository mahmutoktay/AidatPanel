-- CreateTable
CREATE TABLE "DekontDueAllocation" (
    "id" TEXT NOT NULL,
    "dekontId" TEXT NOT NULL,
    "dueId" TEXT NOT NULL,
    "allocatedAmount" DECIMAL(12,2),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "DekontDueAllocation_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "DekontDueAllocation_dekontId_idx" ON "DekontDueAllocation"("dekontId");

-- CreateIndex
CREATE INDEX "DekontDueAllocation_dueId_idx" ON "DekontDueAllocation"("dueId");

-- CreateIndex
CREATE UNIQUE INDEX "DekontDueAllocation_dekontId_dueId_key" ON "DekontDueAllocation"("dekontId", "dueId");

-- AddForeignKey
ALTER TABLE "DekontDueAllocation" ADD CONSTRAINT "DekontDueAllocation_dekontId_fkey" FOREIGN KEY ("dekontId") REFERENCES "Dekont"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "DekontDueAllocation" ADD CONSTRAINT "DekontDueAllocation_dueId_fkey" FOREIGN KEY ("dueId") REFERENCES "Due"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- Backfill: existing dekonts with dueId
INSERT INTO "DekontDueAllocation" ("id", "dekontId", "dueId", "allocatedAmount", "createdAt")
SELECT gen_random_uuid()::text, d."id", d."dueId", NULL, CURRENT_TIMESTAMP
FROM "Dekont" d
WHERE d."dueId" IS NOT NULL
ON CONFLICT ("dekontId", "dueId") DO NOTHING;
