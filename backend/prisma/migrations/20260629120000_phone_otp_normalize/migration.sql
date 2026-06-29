-- PhoneOtpToken + telefon normalizasyonu (10 hane)
CREATE TABLE "PhoneOtpToken" (
    "id" TEXT NOT NULL,
    "phone" TEXT NOT NULL,
    "purpose" TEXT NOT NULL,
    "tokenHash" TEXT NOT NULL,
    "payload" JSONB,
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "usedAt" TIMESTAMP(3),
    "attempts" INTEGER NOT NULL DEFAULT 0,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "PhoneOtpToken_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX "PhoneOtpToken_tokenHash_key" ON "PhoneOtpToken"("tokenHash");
CREATE INDEX "PhoneOtpToken_phone_purpose_idx" ON "PhoneOtpToken"("phone", "purpose");

-- +90 / 0 prefix telefonları 10 haneye
UPDATE "User"
SET phone = REGEXP_REPLACE(phone, '^(\+90|0)?', '')
WHERE phone IS NOT NULL
  AND phone ~ '^(\+90|0)?5[0-9]{9}$';
