#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

mkdir -p e2e-data
rm -f e2e-data/reset.jsonl

echo ">>> docker compose build + up"
docker compose up -d --build

echo ">>> API bekleniyor (127.0.0.1:4200)..."
for i in $(seq 1 90); do
  if curl -sS --max-time 2 "http://127.0.0.1:4200/" >/dev/null 2>&1; then
    echo ">>> API ayakta"
    break
  fi
  if [[ "$i" -eq 90 ]]; then
    echo "API zaman aşımı — log: docker compose logs api" >&2
    exit 1
  fi
  sleep 1
done

export AIDATPANEL_API_BASE="${AIDATPANEL_API_BASE:-http://127.0.0.1:4200/api/v1}"
export AIDATPANEL_E2E_RESET_LOG="${AIDATPANEL_E2E_RESET_LOG:-$ROOT/e2e-data/reset.jsonl}"

echo ">>> test.py (AIDATPANEL_API_BASE=$AIDATPANEL_API_BASE)"
python3 "$ROOT/test.py"
code=$?

if [[ "$code" -ne 0 ]]; then
  echo ">>> test.py başarısız — docker compose logs api" >&2
fi
exit "$code"
