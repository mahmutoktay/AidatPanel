#!/usr/bin/env bash
# AidatPanel backend — VPS deploy (Git Bash / WSL / macOS / Linux)
#
# Kullanım (repo kökünden):
#   bash backend/scripts/deploy.sh
#   bash backend/scripts/deploy.sh --sync-only
#   bash backend/scripts/deploy.sh --restart-only
#   bash backend/scripts/deploy.sh --logs
#
# İlk kurulum: deploy.config.example.json → deploy.local.json

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CONFIG_PATH="$SCRIPT_DIR/deploy.local.json"
EXAMPLE_PATH="$SCRIPT_DIR/deploy.config.example.json"

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
  echo ""
  echo "HATA: deploy.local.json bulunamadi."
  echo "  cp \"$EXAMPLE_PATH\" \"$CONFIG_PATH\""
  echo ""
  exit 1
fi

# jq yoksa Node ile config oku (backend projesinde Node zaten var).
read_config() {
  node - "$CONFIG_PATH" <<'NODE'
const fs = require("fs");
const path = process.argv[2];
const c = JSON.parse(fs.readFileSync(path, "utf8"));
for (const key of ["host", "user", "remotePath"]) {
  if (!c[key]) {
    console.error(`deploy.local.json icinde '${key}' eksik.`);
    process.exit(1);
  }
}
const out = {
  host: c.host,
  user: c.user,
  port: c.port ?? 22,
  remotePath: c.remotePath,
  pm2Name: c.pm2Name ?? "aidapanel-api",
  method: c.method ?? "sync",
  healthUrl: c.healthUrl ?? "",
  sshKeyPath: c.sshKeyPath ?? "",
  gitBranch: c.gitBranch ?? "main",
  restartMethod: c.restartMethod ?? "pm2",
};
console.log(JSON.stringify(out));
NODE
}

CONFIG_JSON="$(read_config)"
HOST="$(node -e "console.log(JSON.parse(process.argv[1]).host)" "$CONFIG_JSON")"
USER="$(node -e "console.log(JSON.parse(process.argv[1]).user)" "$CONFIG_JSON")"
PORT="$(node -e "console.log(JSON.parse(process.argv[1]).port)" "$CONFIG_JSON")"
REMOTE_PATH="$(node -e "console.log(JSON.parse(process.argv[1]).remotePath)" "$CONFIG_JSON")"
PM2_NAME="$(node -e "console.log(JSON.parse(process.argv[1]).pm2Name)" "$CONFIG_JSON")"
METHOD="$(node -e "console.log(JSON.parse(process.argv[1]).method)" "$CONFIG_JSON")"
HEALTH_URL="$(node -e "console.log(JSON.parse(process.argv[1]).healthUrl)" "$CONFIG_JSON")"
SSH_KEY_RAW="$(node -e "console.log(JSON.parse(process.argv[1]).sshKeyPath)" "$CONFIG_JSON")"
GIT_BRANCH="$(node -e "console.log(JSON.parse(process.argv[1]).gitBranch)" "$CONFIG_JSON")"
RESTART_METHOD="$(node -e "console.log(JSON.parse(process.argv[1]).restartMethod)" "$CONFIG_JSON")"

to_unix_path() {
  local p="$1"
  if [[ -z "$p" ]]; then
    echo ""
    return
  fi
  if command -v cygpath >/dev/null 2>&1; then
    cygpath -u "$p"
  else
    echo "$p"
  fi
}

SSH_KEY="$(to_unix_path "$SSH_KEY_RAW")"

SSH_OPTS=(-o BatchMode=yes -o StrictHostKeyChecking=accept-new)
[[ "$PORT" != "22" ]] && SSH_OPTS+=(-p "$PORT")
if [[ -n "$SSH_KEY" ]]; then
  if [[ ! -f "$SSH_KEY" ]]; then
    echo "HATA: SSH anahtari bulunamadi: $SSH_KEY_RAW"
    exit 1
  fi
  SSH_OPTS+=(-i "$SSH_KEY")
fi

TARGET="${USER}@${HOST}"
REMOTE_TAR="/tmp/aidatpanel-backend-deploy.tar.gz"

ssh_cmd() {
  ssh "${SSH_OPTS[@]}" "$TARGET" "$@"
}

scp_to_remote() {
  scp "${SSH_OPTS[@]}" "$1" "$TARGET:$2"
}

temp_tar_file() {
  local base="${TMP:-${TEMP:-/tmp}}"
  # Git Bash (MSYS): Windows TEMP → /c/Users/...
  if command -v cygpath >/dev/null 2>&1 && [[ "$base" =~ ^[A-Za-z]: ]]; then
    base="$(cygpath -u "$base")"
  fi
  echo "${base}/aidatpanel-backend-$$.tar.gz"
}

if [[ "$LOGS" == true ]]; then
  if [[ "$RESTART_METHOD" == "pm2" ]]; then
    ssh_cmd "source ~/.nvm/nvm.sh 2>/dev/null || true; pm2 logs '$PM2_NAME' --lines $LOG_LINES --nostream"
  else
    ssh_cmd "tail -n $LOG_LINES '$REMOTE_PATH/logs/app.log' 2>/dev/null || echo 'log dosyasi henuz yok'"
  fi
  exit 0
fi

echo ""
echo "AidatPanel Backend Deploy"
echo "  hedef: $TARGET:$REMOTE_PATH"
echo ""

if [[ "$RESTART_ONLY" != true ]]; then
  if [[ "$METHOD" == "git" ]]; then
    PARENT="${REMOTE_PATH%/backend}"
    [[ "$PARENT" == "$REMOTE_PATH" ]] && PARENT="$(dirname "$REMOTE_PATH")"
    echo ">> Git deploy: uzak repodan cekiliyor..."
    ssh_cmd "cd '$PARENT' && git fetch origin && git checkout '$GIT_BRANCH' && git pull origin '$GIT_BRANCH'"
  else
    echo ">> Sync deploy (tar): backend/ -> $REMOTE_PATH"
    TAR_FILE="$(temp_tar_file)"
    tar -czf "$TAR_FILE" \
      --exclude=node_modules \
      --exclude=.env \
      --exclude=.env.* \
      --exclude='uploads/dekonts/**' \
      --exclude='*-firebase-adminsdk-*.json' \
      --exclude=scripts/deploy.local.json \
      --exclude=e2e-data \
      --exclude=coverage \
      --exclude='*.log' \
      -C "$BACKEND_ROOT" .
    SIZE_KB="$(du -k "$TAR_FILE" | cut -f1)"
    echo "   arsiv: ${SIZE_KB} KB"
    scp_to_remote "$TAR_FILE" "$REMOTE_TAR"
    rm -f "$TAR_FILE"
    ssh_cmd "mkdir -p '$REMOTE_PATH' && cd '$REMOTE_PATH' && tar -xzf '$REMOTE_TAR' && rm -f '$REMOTE_TAR'"
  fi
fi

if [[ "$SYNC_ONLY" != true ]]; then
  if [[ "$RESTART_ONLY" == true && "$RESTART_METHOD" == "pm2" ]]; then
    echo ">> PM2 restart: $PM2_NAME"
    ssh_cmd "source ~/.nvm/nvm.sh 2>/dev/null || true; pm2 restart '$PM2_NAME'"
  else
    echo ">> Sunucuda npm + prisma + restart ($RESTART_METHOD)..."
  ssh_cmd "set -e
source ~/.nvm/nvm.sh 2>/dev/null || true
cd '$REMOTE_PATH'
npm ci --omit=dev 2>/dev/null || npm install --omit=dev
npx prisma migrate deploy
npx prisma generate
if pm2 describe '$PM2_NAME' >/dev/null 2>&1; then
  pm2 restart '$PM2_NAME'
else
  pm2 start index.js --name '$PM2_NAME'
fi
pm2 save"
  fi

  if [[ -n "$HEALTH_URL" ]]; then
    echo ">> Saglik kontrolu: $HEALTH_URL"
    if curl -sf -o /dev/null -w "HTTP %{http_code}\n" "$HEALTH_URL"; then
      :
    else
      echo "   UYARI: health endpoint yanit vermedi."
    fi
  elif [[ "$RESTART_METHOD" == "pm2" ]]; then
    echo ">> Process kontrolu (pm2)..."
    ssh_cmd "source ~/.nvm/nvm.sh 2>/dev/null || true; pm2 describe '$PM2_NAME' 2>/dev/null || true" | head -10
  fi

  echo ""
  echo "Deploy tamam."
  echo "  Log: bash backend/scripts/deploy.sh --logs"
else
  echo ""
  echo "Sync tamam (restart atlanmadi)."
fi

echo ""
