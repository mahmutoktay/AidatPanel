-- Expense OCR alanları (şemada vardı, migration eksikti → list findMany P2022)
ALTER TABLE "Expense" ADD COLUMN IF NOT EXISTS "rawText" TEXT;
ALTER TABLE "Expense" ADD COLUMN IF NOT EXISTS "parsedJson" JSONB;
ALTER TABLE "Expense" ADD COLUMN IF NOT EXISTS "parsedAmount" DECIMAL(12,2);
ALTER TABLE "Expense" ADD COLUMN IF NOT EXISTS "transactionDate" TIMESTAMP(3);
ALTER TABLE "Expense" ADD COLUMN IF NOT EXISTS "aiConfidence" DOUBLE PRECISION;
ALTER TABLE "Expense" ADD COLUMN IF NOT EXISTS "ocrReceiptsJson" JSONB;
