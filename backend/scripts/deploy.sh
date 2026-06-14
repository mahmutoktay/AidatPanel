#!/usr/bin/env bash
# AidatPanel backend — VPS deploy (Linux / macOS / WSL)
# Kullanım: ./backend/scripts/deploy.sh [--sync-only|--restart-only|--logs]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CONFIG_PATH="$SCRIPT_DIR/deploy.local.json"

RESTART_ONLY=false
SYNC_ONLY=false
LOGS=false
LOG_LINES=80

for arg in "$@"; do
  case "$arg" in
    --restart-only) RESTART_ONLY=true ;;
    --sync-only) SYNC_ONLY=true ;;
    --logs) LOGS=true ;;
  esac
done

if [[ ! -f "$CONFIG_PATH" ]]; then
  echo "HATA: deploy.local.json bulunamadi."
  echo "  cp $SCRIPT_DIR/deploy.config.example.json $CONFIG_PATH"
  exit 1
fi

HOST=$(jq -r '.host' "$CONFIG_PATH")
USER=$(jq -r '.user' "$CONFIG_PATH")
PORT=$(jq -r '.port // 22' "$CONFIG_PATH")
REMOTE_PATH=$(jq -r '.remotePath' "$CONFIG_PATH")
PM2_NAME=$(jq -r '.pm2Name' "$CONFIG_PATH")
METHOD=$(jq -r '.method // "sync"' "$CONFIG_PATH")
HEALTH_URL=$(jq -r '.healthUrl // empty' "$CONFIG_PATH")
SSH_KEY=$(jq -r '.sshKeyPath // empty' "$CONFIG_PATH")
GIT_BRANCH=$(jq -r '.gitBranch // "main"' "$CONFIG_PATH")

SSH_OPTS=(-o BatchMode=yes -o StrictHostKeyChecking=accept-new)
[[ "$PORT" != "22" ]] && SSH_OPTS+=(-p "$PORT")
[[ -n "$SSH_KEY" && "$SSH_KEY" != "null" ]] && SSH_OPTS+=(-i "$SSH_KEY")

TARGET="${USER}@${HOST}"

ssh_cmd() {
  ssh "${SSH_OPTS[@]}" "$TARGET" "$@"
}

if [[ "$LOGS" == true ]]; then
  ssh_cmd "pm2 logs '$PM2_NAME' --lines $LOG_LINES --nostream"
  exit 0
fi

echo ""
echo "AidatPanel Backend Deploy"
echo "  hedef: $TARGET:$REMOTE_PATH"
echo ""

if [[ "$RESTART_ONLY" != true ]]; then
  if [[ "$METHOD" == "git" ]]; then
    PARENT="${REMOTE_PATH%/backend}"
    echo ">> Git deploy..."
    ssh_cmd "cd '$PARENT' && git fetch origin && git checkout $GIT_BRANCH && git pull origin $GIT_BRANCH"
  else
    echo ">> Sync deploy (tar)..."
    TAR_FILE="$(mktemp /tmp/aidatpanel-backend.XXXXXX.tar.gz)"
    tar -czf "$TAR_FILE" \
      --exclude=node_modules \
      --exclude=.env \
      --exclude=.env.* \
      --exclude='uploads/dekonts/*' \
      --exclude=e2e-data \
      --exclude=coverage \
      -C "$BACKEND_ROOT" .
    scp "${SSH_OPTS[@]}" "$TAR_FILE" "$TARGET:/tmp/aidatpanel-backend-deploy.tar.gz"
    rm -f "$TAR_FILE"
    ssh_cmd "mkdir -p '$REMOTE_PATH' && cd '$REMOTE_PATH' && tar -xzf /tmp/aidatpanel-backend-deploy.tar.gz && rm -f /tmp/aidatpanel-backend-deploy.tar.gz"
  fi
fi

if [[ "$SYNC_ONLY" != true ]]; then
  echo ">> npm + prisma + pm2..."
  ssh_cmd "set -e
cd '$REMOTE_PATH'
npm ci --omit=dev
npx prisma migrate deploy
npx prisma generate
if pm2 describe '$PM2_NAME' >/dev/null 2>&1; then
  pm2 restart '$PM2_NAME'
else
  pm2 start index.js --name '$PM2_NAME'
fi
pm2 save"

  if [[ -n "$HEALTH_URL" ]]; then
    echo ">> Health: $HEALTH_URL"
    curl -sf -o /dev/null -w "HTTP %{http_code}\n" "$HEALTH_URL" || echo "UYARI: health yanit vermedi"
  fi
  echo "Deploy tamam."
else
  echo "Sync tamam (restart atlanmadi)."
fi

echo ""
