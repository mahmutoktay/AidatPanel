-- AlterTable: Add lastTokenHash to UserSession for replay attack detection
ALTER TABLE "UserSession" ADD COLUMN "lastTokenHash" TEXT;
