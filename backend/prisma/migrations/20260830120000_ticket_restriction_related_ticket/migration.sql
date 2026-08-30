-- AlterTable
ALTER TABLE "TicketCreationRestriction" ADD COLUMN "relatedTicketId" TEXT;

-- AddForeignKey
ALTER TABLE "TicketCreationRestriction" ADD CONSTRAINT "TicketCreationRestriction_relatedTicketId_fkey" FOREIGN KEY ("relatedTicketId") REFERENCES "Ticket"("id") ON DELETE SET NULL ON UPDATE CASCADE;
