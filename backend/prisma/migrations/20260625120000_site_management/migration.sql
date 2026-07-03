-- CreateTable
CREATE TABLE "Site" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "address" TEXT NOT NULL,
    "city" TEXT NOT NULL,
    "managerId" TEXT NOT NULL,
    "dueAmount" DECIMAL(10,2),
    "dueDay" INTEGER NOT NULL DEFAULT 1,
    "currency" TEXT NOT NULL DEFAULT 'TRY',
    "collectionIban" TEXT,
    "collectionAccountTitle" TEXT,
    "paymentReferenceTemplate" TEXT,
    "collectionVerifiedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Site_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "SiteExpense" (
    "id" TEXT NOT NULL,
    "siteId" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "amount" DECIMAL(10,2),
    "category" "ExpenseCategory" NOT NULL,
    "date" TIMESTAMP(3) NOT NULL,
    "targetMonth" INTEGER NOT NULL DEFAULT 1,
    "targetYear" INTEGER NOT NULL DEFAULT 2026,
    "perUnitAmount" DECIMAL(10,2),
    "splitGroupId" TEXT,
    "sourceExpenseId" TEXT,
    "note" TEXT,
    "receiptUrl" TEXT,
    "storedPaths" JSONB DEFAULT '[]',
    "rawText" TEXT,
    "parsedJson" JSONB,
    "parsedAmount" DECIMAL(12,2),
    "transactionDate" TIMESTAMP(3),
    "aiConfidence" DOUBLE PRECISION,
    "ocrReceiptsJson" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "SiteExpense_pkey" PRIMARY KEY ("id")
);

-- AlterTable
ALTER TABLE "Building" ADD COLUMN "siteId" TEXT,
ADD COLUMN "blockLabel" TEXT,
ADD COLUMN "addressExtra" TEXT;

-- AlterTable: make expenseId nullable and add siteExpenseId
ALTER TABLE "DueExpenseCarryforward" ALTER COLUMN "expenseId" DROP NOT NULL;
ALTER TABLE "DueExpenseCarryforward" ADD COLUMN "siteExpenseId" TEXT;

-- CreateIndex
CREATE INDEX "Site_managerId_idx" ON "Site"("managerId");

-- CreateIndex
CREATE INDEX "Building_siteId_idx" ON "Building"("siteId");

-- CreateIndex
CREATE INDEX "SiteExpense_siteId_idx" ON "SiteExpense"("siteId");
CREATE INDEX "SiteExpense_siteId_date_idx" ON "SiteExpense"("siteId", "date");
CREATE INDEX "SiteExpense_siteId_targetYear_targetMonth_idx" ON "SiteExpense"("siteId", "targetYear", "targetMonth");

-- CreateIndex
CREATE UNIQUE INDEX "DueExpenseCarryforward_siteExpenseId_apartmentId_key" ON "DueExpenseCarryforward"("siteExpenseId", "apartmentId");

-- AddForeignKey
ALTER TABLE "Site" ADD CONSTRAINT "Site_managerId_fkey" FOREIGN KEY ("managerId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Building" ADD CONSTRAINT "Building_siteId_fkey" FOREIGN KEY ("siteId") REFERENCES "Site"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SiteExpense" ADD CONSTRAINT "SiteExpense_siteId_fkey" FOREIGN KEY ("siteId") REFERENCES "Site"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "DueExpenseCarryforward" ADD CONSTRAINT "DueExpenseCarryforward_siteExpenseId_fkey" FOREIGN KEY ("siteExpenseId") REFERENCES "SiteExpense"("id") ON DELETE CASCADE ON UPDATE CASCADE;
