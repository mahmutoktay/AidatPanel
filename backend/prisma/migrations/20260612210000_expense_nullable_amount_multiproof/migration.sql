-- Expense.amount nullable yapildi (OCR'dan otomatik dolacak)
ALTER TABLE "Expense" ALTER COLUMN "amount" DROP NOT NULL;

-- Çoklu makbuz dosyalarının yolları (JSON array)
ALTER TABLE "Expense" ADD COLUMN IF NOT EXISTS "storedPaths" JSONB DEFAULT '[]'::jsonb;

-- Her fişin OCR detayı (JSON array)
ALTER TABLE "Expense" ADD COLUMN IF NOT EXISTS "ocrReceiptsJson" JSONB;
