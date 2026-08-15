#!/usr/bin/env bash
# AidatPanel landing (web/) — VPS static deploy
#
# Kullanım (repo kökünden veya web/):
#   bash web/scripts/deploy.sh
#   bash web/scripts/deploy.sh --sync-only
#   bash web/scripts/deploy.sh --include-well-known
#
# İlk kurulum: deploy.config.example.json → deploy.local.json
# Not: .well-known varsayılan hariç (uzak SHA-256 silinmesin).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WEB_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CONFIG_PATH="$SCRIPT_DIR/deploy.local.json"
EXAMPLE_PATH="$SCRIPT_DIR/deploy.config.example.json"

SYNC_ONLY=false
INCLUDE_WELL_KNOWN=false

for arg in "$@"; do
  case "$arg" in
    --sync-only) SYNC_ONLY=true ;;
    --include-well-known) INCLUDE_WELL_KNOWN=true ;;
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
  remoteOwner: c.remoteOwner ?? "aidatpanel:aidatpanel",
  healthUrl: c.healthUrl ?? "https://aidatpanel.com/",
  sshKeyPath: c.sshKeyPath ?? "",
  excludeWellKnown: c.excludeWellKnown !== false,
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
HEALTH_URL="$(node -e "console.log(JSON.parse(process.argv[1]).healthUrl)" "$CONFIG_JSON")"
SSH_KEY_RAW="$(node -e "console.log(JSON.parse(process.argv[1]).sshKeyPath)" "$CONFIG_JSON")"
EXCLUDE_WK="$(node -e "console.log(JSON.parse(process.argv[1]).excludeWellKnown)" "$CONFIG_JSON")"

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
REMOTE_TAR="/tmp/aidatpanel-web-deploy.tar.gz"

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
  echo "${base}/aidatpanel-web-$$.tar.gz"
}

EXCLUDE_WELL_KNOWN_EFFECTIVE="$EXCLUDE_WK"
if [[ "$INCLUDE_WELL_KNOWN" == true ]]; then
  EXCLUDE_WELL_KNOWN_EFFECTIVE=false
fi

echo ""
echo "AidatPanel Landing Deploy"
echo "  hedef: $TARGET:$REMOTE_PATH"
echo "  .well-known hariç: $EXCLUDE_WELL_KNOWN_EFFECTIVE"
echo ""

TAR_FILE="$(temp_tar_file)"
TAR_ARGS=(
  -czf "$TAR_FILE"
  --exclude=scripts/deploy.local.json
  --exclude='*.zip'
  --exclude='Arşiv.zip'
  --exclude=archive.zip
  --exclude=.git
)
if [[ "$EXCLUDE_WELL_KNOWN_EFFECTIVE" == true ]]; then
  TAR_ARGS+=(--exclude=.well-known)
fi
TAR_ARGS+=(-C "$WEB_ROOT" .)

tar "${TAR_ARGS[@]}"
SIZE_KB="$(du -k "$TAR_FILE" | cut -f1)"
echo ">> Sync: web/ -> $REMOTE_PATH (${SIZE_KB} KB)"
scp_to_remote "$TAR_FILE" "$REMOTE_TAR"
rm -f "$TAR_FILE"

ssh_cmd "set -e
mkdir -p '$REMOTE_PATH'
cd '$REMOTE_PATH'
tar -xzf '$REMOTE_TAR'
rm -f '$REMOTE_TAR'
chown -R '$REMOTE_OWNER' '$REMOTE_PATH'
find '$REMOTE_PATH' -type d -exec chmod 755 {} \\;
find '$REMOTE_PATH' -type f -exec chmod 644 {} \\;
"

if [[ "$SYNC_ONLY" != true && -n "$HEALTH_URL" ]]; then
  echo ">> Saglik kontrolu: $HEALTH_URL"
  if curl -sf -o /dev/null -w "HTTP %{http_code}\n" -L "$HEALTH_URL"; then
    :
  else
    echo "   UYARI: landing yanit vermedi."
  fi
fi

echo ""
echo "Deploy tamam."
echo ""
