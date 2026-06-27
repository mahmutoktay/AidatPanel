-- Add templateKey and templateParams columns to Notification table
-- These enable client-side i18n rendering of notifications in the user's current language.

ALTER TABLE "Notification"
  ADD COLUMN "templateKey"    TEXT,
  ADD COLUMN "templateParams" JSONB;
