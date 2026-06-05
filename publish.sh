#!/usr/bin/env bash
# publish.sh — sync the vault's Garden/ into this repo's content/,
# commit, push, and let GitHub Actions deploy.
#
# The vault's Garden/ is the editing surface (live with the rest of
# Obsidian — backlinks, graph, daily-note ties). content/ is just the
# CI-visible mirror; never edit it directly.

set -euo pipefail

GARDEN_REPO="${GARDEN_REPO:-$HOME/workspace/garden}"
VAULT_GARDEN="${VAULT_GARDEN:-$HOME/workspace/Obsidian/Garden}"

if [ ! -d "$VAULT_GARDEN" ]; then
  echo "vault Garden/ not found at $VAULT_GARDEN" >&2
  exit 1
fi

# Mirror: copy new + changed files, delete anything removed from the vault.
rsync -a --delete --exclude '.obsidian' --exclude '.DS_Store' \
  "$VAULT_GARDEN/" "$GARDEN_REPO/content/"

cd "$GARDEN_REPO"
git add content/

if git diff --cached --quiet; then
  echo "no garden changes to publish"
  exit 0
fi

stamp="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
git commit -m "publish: $stamp"
git push

echo "deploy kicked off → https://github.com/Anlexis/garden/actions"
echo "live in ~2 min  → https://anlexis.github.io/garden/"
