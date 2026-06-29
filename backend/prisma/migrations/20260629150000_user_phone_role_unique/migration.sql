-- Aynı telefon hem yönetici hem sakin hesabında kullanılabilsin (rol başına tekil)
DROP INDEX IF EXISTS "User_phone_key";

CREATE UNIQUE INDEX "User_phone_role_key" ON "User"("phone", "role");
