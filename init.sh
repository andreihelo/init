#!/bin/bash
# bash

set -euo pipefail

if [ -t 2 ]; then
  RED='\033[0;31m'
  YELLOW='\033[0;33m'
  GREEN='\033[0;32m'
  BLUE='\033[0;34m'
  BOLD='\033[1m'
  RESET='\033[0m'
else
  RED='' YELLOW='' GREEN='' BLUE='' BOLD='' RESET=''
fi

info()  { printf "%b\n" "${BLUE}${BOLD}INFO:${RESET} $*"  >&2; }
warn()  { printf "%b\n" "${YELLOW}${BOLD}WARN:${RESET} $*"  >&2; }
error() { printf "%b\n" "${RED}${BOLD}ERROR:${RESET} $*" >&2; }

hr() {
  local label="${1:-}"
  local cols
  cols=$(tput cols 2>/dev/null || echo 80)

  local char='-'
  [[ "${LANG:-}" == *UTF-8* ]] && char='─'

  if [ -z "$label" ]; then
    printf '%*s\n' "$cols" '' | tr ' ' "$char" >&2
    return
  fi

  local padded=" ${label} "
  local pad_len=${#padded}
  local left=$(( (cols - pad_len) / 2 ))
  [ "$left" -lt 0 ] && left=0
  local right=$(( cols - left - pad_len ))
  [ "$right" -lt 0 ] && right=0

  printf '%*s' "$left" '' | tr ' ' "$char" >&2
  printf '%s' "$padded" >&2
  printf '%*s\n' "$right" '' | tr ' ' "$char" >&2
}

if command -v omz >/dev/null 2>&1 || command -v brew >/dev/null 2>&1; then
  info "Running: omz update; brew update; brew outdated; brew upgrade; brew cleanup\n"
  (
    set +e
    command -v omz >/dev/null 2>&1 && omz update
    if command -v brew >/dev/null 2>&1; then
      brew update
      brew outdated || true
      brew upgrade || true
      brew cleanup || true
    fi
  )
fi

readonly REPO_DIR="$HOME/workspace"
readonly SETUP_REPO="$REPO_DIR/setup"
readonly WORK_REPO="$REPO_DIR/my-repo"

[[ -d "$WORK_REPO" ]] || { echo "The directory does not exist \`$WORK_REPO\`"; exit 1; }
[[ -d "$REPO_DIR" ]] || { echo "The directory does not exist \`$REPO_DIR\`"; exit 1; }
[[ -d "$SETUP_REPO" ]] || { echo "The directory does not exist \`$SETUP_REPO\`"; exit 1; }

if git -C "$WORK_REPO" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  (
    if [[ -n "$(git -C "$WORK_REPO" status --porcelain)" ]]; then
      hr
      current_date=$(date -u +%Y-%m-%dT%H:%M:%SZ)
      warn "Pending changes were detected. They will saved with the current date: $current_date\n"
      git -C "$WORK_REPO" stash push -u -m "Init stash created on $current_date"
    fi

    hr
    info "Applying checkout for the working repository\n"
    if git -C "$WORK_REPO" show-ref --verify --quiet refs/heads/staging; then
      git -C "$WORK_REPO" checkout staging
    elif git -C "$WORK_REPO" show-ref --verify --quiet refs/heads/main; then
      git -C "$WORK_REPO" checkout main
    else
      error "Neither staging nor main exist in \`$WORK_REPO\` — skipping branch checkout\n"
    fi
  )
else
  error "Not a git repository: \`$WORK_REPO\` — skipping work setup\n"
fi

hr
info "Applying soft update on found repositories\n"
for repo in "$REPO_DIR"/*/; do
  [[ -d "$repo" ]] || continue
  echo "$repo:"
  git -C "$repo" fetch --prune --all
  git -C "$repo" pull --ff-only || git -C "$repo" pull
  git -C "$repo" status --short --branch
done
