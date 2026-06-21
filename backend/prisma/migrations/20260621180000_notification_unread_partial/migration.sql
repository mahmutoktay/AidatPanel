-- Partial index: sadece okunmamis bildirimler icin.
-- Mevcut composite index (userId, isRead, createdAt) yerine daha dar ve hizli.
-- 10k+ bildirim tablosunda "WHERE isRead = false" sorgulari 10x hizlanir.

CREATE INDEX IF NOT EXISTS "Notification_userId_unread_idx"
ON "Notification" ("userId", "createdAt" DESC)
WHERE "isRead" = false;
