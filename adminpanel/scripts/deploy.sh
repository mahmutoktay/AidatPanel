#!/usr/bin/env bash
# AidatPanel admin UI — VPS deploy (Node + PM2)
#
# Kullanım (repo kökünden veya adminpanel/):
#   bash adminpanel/scripts/deploy.sh
#   bash adminpanel/scripts/deploy.sh --sync-only
#   bash adminpanel/scripts/deploy.sh --restart-only
#   bash adminpanel/scripts/deploy.sh --logs
#
# İlk kurulum: deploy.config.example.json → deploy.local.json
# .env ASLA üzerine yazılmaz.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ADMIN_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
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
  remoteOwner: c.remoteOwner ?? "aidatpanel-admin:aidatpanel-admin",
  pm2User: c.pm2User ?? "aidatpanel-admin",
  pm2Name: c.pm2Name ?? "aidat-admin",
  healthUrl: c.healthUrl ?? "https://admin.aidatpanel.com/",
  sshKeyPath: c.sshKeyPath ?? "",
};
console.log(JSON.stringify(out));
NODE
}

CONFIG_JSON="$(read_config)"
HOST="$(node -e "console.log(JSON.parse(process.argv[1]).host)" "$CONFIG_JSON")"
USER="$(node -e "console.log(JSON.parse(process.argv[1]).user)" "$CONFIG_JSON")"
PORT="$(node -e "console.log(JSON.parse(process.argv[1]).port)" "$CONFIG_JSON")"
REMOTE_PATH="$(node -e "console.log(JSON.parse(process.argv[1]).remotePath)" "$CONFIG_JSON")"
REMOTE_OWNER="$(node -e "console.log(JSON.parse(process.argv[1]).remoteOwner)" "$CONFIG_JSON")"
PM2_USER="$(node -e "console.log(JSON.parse(process.argv[1]).pm2User)" "$CONFIG_JSON")"
PM2_NAME="$(node -e "console.log(JSON.parse(process.argv[1]).pm2Name)" "$CONFIG_JSON")"
HEALTH_URL="$(node -e "console.log(JSON.parse(process.argv[1]).healthUrl)" "$CONFIG_JSON")"
SSH_KEY_RAW="$(node -e "console.log(JSON.parse(process.argv[1]).sshKeyPath)" "$CONFIG_JSON")"

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
REMOTE_TAR="/tmp/aidatpanel-admin-deploy.tar.gz"

ssh_cmd() {
  ssh "${SSH_OPTS[@]}" "$TARGET" "$@"
}

scp_to_remote() {
  scp "${SSH_OPTS[@]}" "$1" "$TARGET:$2"
}

temp_tar_file() {
  local base="${TMP:-${TEMP:-/tmp}}"
  if command -v cygpath >/dev/null 2>&1 && [[ "$base" =~ ^[A-Za-z]: ]]; then
    base="$(cygpath -u "$base")"
  fi
  echo "${base}/aidatpanel-admin-$$.tar.gz"
}

pm2_as_user() {
  local remote_cmd="$1"
  ssh_cmd "sudo -u '$PM2_USER' bash -lc 'source ~/.nvm/nvm.sh 2>/dev/null || true; $remote_cmd'"
}

if [[ "$LOGS" == true ]]; then
  pm2_as_user "pm2 logs '$PM2_NAME' --lines $LOG_LINES --nostream"
  exit 0
fi

echo ""
echo "AidatPanel Admin Deploy"
echo "  hedef: $TARGET:$REMOTE_PATH"
echo "  pm2: $PM2_USER / $PM2_NAME"
echo ""

if [[ "$RESTART_ONLY" != true ]]; then
  echo ">> Sync deploy (tar): adminpanel/ -> $REMOTE_PATH"
  TAR_FILE="$(temp_tar_file)"
  tar -czf "$TAR_FILE" \
    --exclude=node_modules \
    --exclude=.env \
    --exclude=.env.* \
    --exclude=scripts/deploy.local.json \
    --exclude='*.zip' \
    --exclude='Arşiv.zip' \
    --exclude=.git \
    --exclude=coverage \
    --exclude='*.log' \
    --exclude=test-results \
    --exclude=playwright-report \
    -C "$ADMIN_ROOT" .
  SIZE_KB="$(du -k "$TAR_FILE" | cut -f1)"
  echo "   arsiv: ${SIZE_KB} KB"
  scp_to_remote "$TAR_FILE" "$REMOTE_TAR"
  rm -f "$TAR_FILE"
  ssh_cmd "set -e
mkdir -p '$REMOTE_PATH'
cd '$REMOTE_PATH'
tar -xzf '$REMOTE_TAR'
rm -f '$REMOTE_TAR'
chown -R '$REMOTE_OWNER' '$REMOTE_PATH'
# .env sahiplik koru
if [[ -f '$REMOTE_PATH/.env' ]]; then
  chown '$REMOTE_OWNER' '$REMOTE_PATH/.env'
  chmod 640 '$REMOTE_PATH/.env'
fi
"
fi

if [[ "$SYNC_ONLY" != true ]]; then
  echo ">> npm ci + PM2 restart ($PM2_NAME)..."
  ssh_cmd "set -e
sudo -u '$PM2_USER' bash -lc \"
  set -e
  source ~/.nvm/nvm.sh 2>/dev/null || true
  cd '$REMOTE_PATH'
  npm ci --omit=dev 2>/dev/null || npm install --omit=dev
  if pm2 describe '$PM2_NAME' >/dev/null 2>&1; then
    pm2 restart '$PM2_NAME'
  else
    pm2 start src/app.js --name '$PM2_NAME'
  fi
  pm2 save
\"
"

  if [[ -n "$HEALTH_URL" ]]; then
    echo ">> Saglik kontrolu: $HEALTH_URL"
    if curl -sf -o /dev/null -w "HTTP %{http_code}\n" -L "$HEALTH_URL"; then
      :
    else
      echo "   UYARI: admin panel yanit vermedi (login sayfasi beklenir)."
    fi
  fi

  echo ""
  echo "Deploy tamam."
  echo "  Log: bash adminpanel/scripts/deploy.sh --logs"
else
  echo ""
  echo "Sync tamam (restart atlanmadi)."
fi

echo ""
