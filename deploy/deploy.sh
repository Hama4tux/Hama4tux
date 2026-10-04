#!/usr/bin/env bash
# Nasazení webu na lokální Apache server přes SSH.
# Použití:  bash deploy/deploy.sh
# Volitelně: DEPLOY_USER=martin DEPLOY_HOST=192.168.101.8 bash deploy/deploy.sh
set -euo pipefail

HOST="${DEPLOY_HOST:-192.168.101.8}"
TARGET="/var/www/martin"
FILES=(index.html)

cd "$(dirname "$0")/.."

VERSION="$(tr -d '[:space:]' < VERSION)"
DEST="${DEPLOY_USER:+$DEPLOY_USER@}$HOST"

if ! grep -q "id=\"version\">v$VERSION<" index.html; then
  echo "Chyba: verze v patičce index.html neodpovídá VERSION ($VERSION)." >&2
  exit 1
fi

if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
  echo "Varování: v repozitáři jsou necommitnuté změny."
fi

echo "Nasazuji v$VERSION → $DEST:$TARGET"
tar -czf - "${FILES[@]}" VERSION | ssh "$DEST" "test -d $TARGET -a -w $TARGET || { echo 'Složka $TARGET neexistuje nebo není zapisovatelná, viz První nasazení v AGENTS.md' >&2; exit 1; }; tar -xzf - -C $TARGET --no-same-owner"
echo "Hotovo. Ověření: curl -s http://martin.hamanovi.cz/VERSION"
