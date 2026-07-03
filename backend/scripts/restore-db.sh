#!/usr/bin/env bash
# PostgreSQL yedek geri yükleme — YALNIZCA SSH üzerinden kullanın.
# Panelden geri yükleme desteklenmez.
set -euo pipefail

BACKUP_FILE="${1:-}"
if [[ -z "$BACKUP_FILE" || ! -f "$BACKUP_FILE" ]]; then
  echo "Kullanım: ./scripts/restore-db.sh /path/to/backup.sql.gz"
  exit 1
fi

if [[ -z "${DATABASE_URL:-}" ]]; then
  echo "DATABASE_URL tanımlı değil."
  exit 1
fi

echo "UYARI: Bu işlem mevcut veritabanını siler. 10 saniye içinde Ctrl+C ile iptal edin."
sleep 10

gunzip -c "$BACKUP_FILE" | psql "$DATABASE_URL"
echo "Geri yükleme tamamlandı."
