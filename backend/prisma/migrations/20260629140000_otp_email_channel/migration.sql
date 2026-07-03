-- E-posta OTP: telefon veya e-posta ile doğrulama
ALTER TABLE "PhoneOtpToken" ALTER COLUMN "phone" DROP NOT NULL;
ALTER TABLE "PhoneOtpToken" ADD COLUMN IF NOT EXISTS "email" TEXT;
CREATE INDEX IF NOT EXISTS "PhoneOtpToken_email_purpose_idx" ON "PhoneOtpToken"("email", "purpose");
