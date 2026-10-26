#!/usr/bin/env bash
# Workspace helper for the automation repos.
#
#   ./bootstrap-workspace.sh check
#   ./bootstrap-workspace.sh clone --dest "$HOME/Documents/AUTOMATION-INP - commercial"
#   ./bootstrap-workspace.sh worktree <repo> <branch> <dest>
#   ./bootstrap-workspace.sh worktrees
#
# Never deletes or moves an existing clone.

set -euo pipefail

ROOT="${WORKSPACE_ROOT:-$HOME/Documents}"

# name|github slug|role
MANIFEST=(
  "staffinc-testcase|sampingantech/staffinc-testcase|ledger"
  "staffinc-automation|sampingantech/staffinc-automation|automation"
  "internaltools-automation|sampingantech/internaltools-automation|automation"
  "hcmsvc|sampingantech/hcmsvc|codebase"
  "hcmworker|sampingantech/hcmworker|codebase"
  "kerjaan-client-portal|sampingantech/kerjaan-client-portal|codebase"
  "seamless-admin-portal|sampingantech/seamless-admin-portal|codebase"
  "kerjaan-sdd|sampingantech/kerjaan-sdd|docs"
  "kerjaan-android|sampingantech/kerjaan-android|codebase"
  "ios-kerjaan|sampingantech/ios-kerjaan|codebase"
  "utilitysvc|sampingantech/utilitysvc|codebase"
  "utility-portal|sampingantech/utility-portal|codebase"
  "utilityapp|sampingantech/utilityapp|codebase"
  "kartographer-mcp|rotaigalp/kartographer-mcp|tooling"
  "skills|sampingantech/skills|tooling"
)

find_repo() {
  local name="$1"
  find "$ROOT" -maxdepth 4 -type d -name "$name" \
    -not -path '*/node_modules/*' -not -path '*/.git/*' 2>/dev/null | head -n 1
}

branch_of() {
  git -C "$1" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "-"
}

cmd_check() {
  printf '%-27s %-8s %-58s %s\n' "REPO" "STATUS" "PATH" "BRANCH"
  printf '%-27s %-8s %-58s %s\n' "---------------------------" "------" "----------------------------------------------------------" "------"
  local missing=0
  for entry in "${MANIFEST[@]}"; do
    IFS='|' read -r name slug role <<< "$entry"
    local path
    path="$(find_repo "$name")"
    if [ -n "$path" ]; then
      printf '%-27s %-8s %-58s %s\n' "$name" "FOUND" "${path/#$HOME/~}" "$(branch_of "$path")"
    else
      printf '%-27s %-8s %-58s %s\n' "$name" "MISSING" "-" "-"
      missing=$((missing + 1))
    fi
  done
  echo
  echo "$missing repo(s) missing under $ROOT"
}

cmd_clone() {
  local dest="$ROOT"
  while [ $# -gt 0 ]; do
    case "$1" in
      --dest) dest="$2"; shift 2 ;;
      *) echo "unknown argument: $1" >&2; exit 2 ;;
    esac
  done
  mkdir -p "$dest"
  for entry in "${MANIFEST[@]}"; do
    IFS='|' read -r name slug role <<< "$entry"
    if [ -n "$(find_repo "$name")" ]; then
      echo "skip  $name (already present)"
      continue
    fi
    echo "clone $slug -> $dest/$name"
    gh repo clone "$slug" "$dest/$name" -- --filter=blob:none
  done
}

cmd_worktree() {
  [ $# -eq 3 ] || { echo "usage: $0 worktree <repo> <branch> <dest>" >&2; exit 2; }
  local name="$1" branch="$2" dest="$3" clone
  clone="$(find_repo "$name")"
  [ -n "$clone" ] || { echo "repo not found: $name" >&2; exit 1; }
  if git -C "$clone" show-ref --verify --quiet "refs/heads/$branch"; then
    git -C "$clone" worktree add "$dest" "$branch"
  else
    git -C "$clone" worktree add "$dest" -b "$branch"
  fi
}

cmd_worktrees() {
  for entry in "${MANIFEST[@]}"; do
    IFS='|' read -r name slug role <<< "$entry"
    local path
    path="$(find_repo "$name")"
    [ -n "$path" ] || continue
    echo "== $name"
    git -C "$path" worktree list
  done
}

case "${1:-check}" in
  check)     cmd_check ;;
  clone)     shift; cmd_clone "$@" ;;
  worktree)  shift; cmd_worktree "$@" ;;
  worktrees) cmd_worktrees ;;
  *) echo "usage: $0 {check|clone|worktree|worktrees}" >&2; exit 2 ;;
esac
