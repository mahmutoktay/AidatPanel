-- Telefon ile kayıt/giriş: e-posta artık zorunlu değil (schema.prisma ile uyum)
ALTER TABLE "User" ALTER COLUMN "email" DROP NOT NULL;
