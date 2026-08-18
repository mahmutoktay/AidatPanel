-- Telefon numarası tüm roller arasında tekil (sakin numarası yönetici hesabında kullanılamaz).
-- Mevcut çift kayıtlar: yönetici telefonunu temizle, sakin kaydı koru.
UPDATE "User" AS m
SET phone = NULL
FROM "User" AS r
WHERE m.phone IS NOT NULL
  AND r.phone IS NOT NULL
  AND m.phone = r.phone
  AND m.role = 'MANAGER'
  AND r.role = 'RESIDENT'
  AND m."deletedAt" IS NULL
  AND r."deletedAt" IS NULL;

DROP INDEX IF EXISTS "User_phone_role_key";

CREATE UNIQUE INDEX "User_phone_key" ON "User"("phone") WHERE "phone" IS NOT NULL;
