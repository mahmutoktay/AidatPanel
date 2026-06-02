-- AlterTable
ALTER TABLE "Dekont" ADD COLUMN     "fileHash" TEXT,
ADD COLUMN     "referenceNumber" TEXT,
ADD COLUMN     "senderIban" TEXT,
ADD COLUMN     "receiverIban" TEXT,
ADD COLUMN     "parsedAmount" DECIMAL(12,2),
ADD COLUMN     "transactionDate" TIMESTAMP(3),
ADD COLUMN     "aiConfidence" DOUBLE PRECISION,
ADD COLUMN     "reviewedById" TEXT,
ADD COLUMN     "reviewedAt" TIMESTAMP(3),
ADD COLUMN     "reviewNote" TEXT,
ADD COLUMN     "rejectionReason" TEXT;

-- CreateIndex
CREATE INDEX "Dekont_fileHash_idx" ON "Dekont"("fileHash");

-- CreateIndex
CREATE UNIQUE INDEX "Dekont_buildingId_referenceNumber_key" ON "Dekont"("buildingId", "referenceNumber");

-- AddForeignKey
ALTER TABLE "Dekont" ADD CONSTRAINT "Dekont_reviewedById_fkey" FOREIGN KEY ("reviewedById") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;
