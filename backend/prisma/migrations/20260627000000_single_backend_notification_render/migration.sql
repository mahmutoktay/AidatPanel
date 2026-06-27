-- Move notification rendering to a single backend-rendered structure.
-- Existing templateKey/templateParams data is preserved as code/params.
-- Legacy rows keep their already-rendered title/body as params snapshot.

ALTER TABLE "Notification"
  ADD COLUMN "code" TEXT,
  ADD COLUMN "params" JSONB;

UPDATE "Notification"
SET
  "code" = COALESCE(NULLIF("templateKey", ''), 'legacy_notification'),
  "params" = CASE
    WHEN "templateKey" IS NULL OR "templateKey" = '' THEN jsonb_build_object(
      'title', "title",
      'body', "body"
    )
    ELSE COALESCE("templateParams", '{}'::jsonb)
  END;

ALTER TABLE "Notification"
  ALTER COLUMN "code" SET NOT NULL;

ALTER TABLE "Notification"
  DROP COLUMN "templateKey",
  DROP COLUMN "templateParams";
