-- Deduplicate same fileHash per building (keep newest).
DELETE FROM "Dekont" a
USING "Dekont" b
WHERE a."buildingId" = b."buildingId"
  AND a."fileHash" = b."fileHash"
  AND a."fileHash" IS NOT NULL
  AND a."createdAt" < b."createdAt";

-- CreateIndex
CREATE UNIQUE INDEX "Dekont_buildingId_fileHash_key" ON "Dekont"("buildingId", "fileHash");
