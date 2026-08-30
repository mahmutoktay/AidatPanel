-- AlterTable
ALTER TABLE "Ticket" ADD COLUMN "needsReview" BOOLEAN NOT NULL DEFAULT false;
ALTER TABLE "Ticket" ADD COLUMN "isReported" BOOLEAN NOT NULL DEFAULT false;

-- AlterTable
ALTER TABLE "TicketUpdate" ADD COLUMN "needsReview" BOOLEAN NOT NULL DEFAULT false;

-- CreateTable
CREATE TABLE "TicketReport" (
    "id" TEXT NOT NULL,
    "ticketId" TEXT NOT NULL,
    "ticketUpdateId" TEXT,
    "reporterId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "TicketReport_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "TicketCreationRestriction" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "buildingId" TEXT NOT NULL,
    "managerId" TEXT NOT NULL,
    "reason" TEXT NOT NULL,
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "liftedAt" TIMESTAMP(3),
    "liftedById" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "TicketCreationRestriction_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "TicketRestrictionAuditLog" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "managerId" TEXT,
    "buildingId" TEXT NOT NULL,
    "action" TEXT NOT NULL,
    "reason" TEXT,
    "expiresAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "TicketRestrictionAuditLog_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "Ticket_isReported_createdAt_idx" ON "Ticket"("isReported", "createdAt");

-- CreateIndex
CREATE INDEX "Ticket_needsReview_createdAt_idx" ON "Ticket"("needsReview", "createdAt");

-- CreateIndex
CREATE INDEX "TicketReport_ticketId_createdAt_idx" ON "TicketReport"("ticketId", "createdAt");

-- CreateIndex
CREATE UNIQUE INDEX "TicketReport_ticketId_ticketUpdateId_reporterId_key" ON "TicketReport"("ticketId", "ticketUpdateId", "reporterId");

-- CreateIndex
CREATE INDEX "TicketCreationRestriction_userId_expiresAt_idx" ON "TicketCreationRestriction"("userId", "expiresAt");

-- CreateIndex
CREATE INDEX "TicketCreationRestriction_buildingId_idx" ON "TicketCreationRestriction"("buildingId");

-- CreateIndex
CREATE INDEX "TicketRestrictionAuditLog_userId_createdAt_idx" ON "TicketRestrictionAuditLog"("userId", "createdAt");

-- CreateIndex
CREATE INDEX "TicketRestrictionAuditLog_buildingId_createdAt_idx" ON "TicketRestrictionAuditLog"("buildingId", "createdAt");

-- AddForeignKey
ALTER TABLE "TicketReport" ADD CONSTRAINT "TicketReport_ticketId_fkey" FOREIGN KEY ("ticketId") REFERENCES "Ticket"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TicketReport" ADD CONSTRAINT "TicketReport_ticketUpdateId_fkey" FOREIGN KEY ("ticketUpdateId") REFERENCES "TicketUpdate"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TicketReport" ADD CONSTRAINT "TicketReport_reporterId_fkey" FOREIGN KEY ("reporterId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TicketCreationRestriction" ADD CONSTRAINT "TicketCreationRestriction_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TicketCreationRestriction" ADD CONSTRAINT "TicketCreationRestriction_buildingId_fkey" FOREIGN KEY ("buildingId") REFERENCES "Building"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TicketCreationRestriction" ADD CONSTRAINT "TicketCreationRestriction_managerId_fkey" FOREIGN KEY ("managerId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;
