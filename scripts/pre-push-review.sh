#!/usr/bin/env bash
# Deterministic half of the pre-push review.
# Usage: scripts/pre-push-review.sh [base-ref]   (default: origin/develop)
# Exit 1 = REQUEST_CHANGES (do not push). Exit 0 = deterministic checks pass.
# GWT/assertion fidelity to the testcase is semantic and still needs the manual pass.

set -uo pipefail

BASE="${1:-origin/develop}"
ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || { echo "not inside a git repo"; exit 2; }
cd "$ROOT" || exit 2

blockers=0
warnings=0

block() { printf 'BLOCKER  %s\n' "$1"; blockers=$((blockers + 1)); }
warn()  { printf 'WARNING  %s\n' "$1"; warnings=$((warnings + 1)); }

echo "== pre-push review =="
echo "repo: $ROOT"
echo "base: $BASE"
echo

# ---- changed files -------------------------------------------------------
changed="$( { git diff --name-only "$BASE"...HEAD 2>/dev/null
              git diff --name-only 2>/dev/null
              git diff --cached --name-only 2>/dev/null
              git ls-files --others --exclude-standard 2>/dev/null; } | sort -u )"

specs="$(printf '%s\n' "$changed" | grep -E '\.spec\.ts$' || true)"

if [ -z "$specs" ]; then
  warn "no changed *.spec.ts in this diff"
fi

# ---- conflict markers ----------------------------------------------------
conflict_out="$(git grep -nE '^(<{7}|={7}|>{7})' -- . ':!node_modules' 2>/dev/null || true)"
if [ -n "$conflict_out" ]; then
  block "conflict markers found"
  printf '%s\n' "$conflict_out"
fi

# ---- secrets -------------------------------------------------------------
secret_out="$(printf '%s\n' "$changed" | while IFS= read -r f; do
  [ -n "$f" ] && [ -f "$f" ] || continue
  grep -nE 'ghp_[A-Za-z0-9]{20,}|github_pat_[A-Za-z0-9_]{20,}|AKIA[0-9A-Z]{16}|-----BEGIN [A-Z ]*PRIVATE KEY-----' "$f" 2>/dev/null \
    | sed "s|^|$f:|"
done)"
if [ -n "$secret_out" ]; then
  block "possible secret in changed files"
  printf '%s\n' "$secret_out"
fi

# ---- per spec file -------------------------------------------------------
if [ -n "$specs" ]; then
  while IFS= read -r f; do
    [ -n "$f" ] && [ -f "$f" ] || continue

    only_out="$(grep -nE '\b(test|it|describe)\.only[[:space:]]*\(' "$f" 2>/dev/null || true)"
    if [ -n "$only_out" ]; then
      block "$f: focused test (.only)"
      printf '%s\n' "$only_out"
    fi

    log_out="$(grep -n 'console\.log' "$f" 2>/dev/null || true)"
    if [ -n "$log_out" ]; then
      block "$f: console.log in spec"
      printf '%s\n' "$log_out"
    fi

    decl="$(grep -cE '^[[:space:]]*(it|test)(\.(only|skip))?[[:space:]]*\(' "$f" 2>/dev/null || true)"
    covers="$(grep -c '@covers' "$f" 2>/dev/null || true)"
    decl="${decl:-0}"; covers="${covers:-0}"
    if [ "$decl" -gt 0 ] && [ "$covers" -lt "$decl" ]; then
      block "$f: $decl test declaration(s) but $covers @covers tag(s)"
    fi

    taut_out="$(grep -nE 'expect\(true\)\.toBe\(true\)|expect\([0-9]+\)\.toBe\([0-9]+\)|expect\([^;]*\|\||expect\(\[[0-9]+, *[0-9]+.*\]\)\.toContain' "$f" 2>/dev/null || true)"
    if [ -n "$taut_out" ]; then
      warn "$f: possible tautological/permissive assertion - inspect"
      printf '%s\n' "$taut_out"
    fi
  done <<< "$specs"
fi

# ---- throwing stubs in changed source -----------------------------------
stub_out="$(printf '%s\n' "$changed" | while IFS= read -r f; do
  [ -n "$f" ] && [ -f "$f" ] || continue
  [[ "$f" == *.spec.ts ]] && continue
  grep -n 'throw new Error' "$f" 2>/dev/null | sed "s|^|$f:|"
done)"
if [ -n "$stub_out" ]; then
  warn "throw new Error in changed source (confirm it is not on a happy path)"
  printf '%s\n' "$stub_out"
fi

# ---- @covers must exist in the ledger ------------------------------------
LEDGER="${LEDGER_DIR:-}"
if [ -z "$LEDGER" ]; then
  for candidate in ../staffinc-testcase repos/automation-code/staffinc-testcase ../automation-code/staffinc-testcase; do
    if [ -d "$candidate/testcases" ]; then LEDGER="$candidate"; break; fi
  done
fi

if [ -n "$LEDGER" ] && [ -n "$specs" ]; then
  ids="$(grep -hoE '@covers[[:space:]]+[A-Za-z0-9._-]+' $specs 2>/dev/null | awk '{print $2}' | sort -u)"
  for id in $ids; do
    if ! grep -rqE "^id:[[:space:]]*${id}[[:space:]]*$" "$LEDGER/testcases" 2>/dev/null; then
      block "@covers $id not found in ledger ($LEDGER/testcases)"
    fi
  done
elif [ -z "$LEDGER" ]; then
  warn "ledger not found (set LEDGER_DIR=/path/to/staffinc-testcase); @covers existence not verified"
fi

# ---- verdict -------------------------------------------------------------
echo
if [ "$blockers" -gt 0 ]; then
  echo "VERDICT: REQUEST_CHANGES - $blockers blocker(s), $warnings warning(s). Do not push."
  exit 1
fi

echo "VERDICT: PASS (deterministic checks) - $warnings warning(s)."
echo "Still required: GWT and assertion fidelity against staffinc-testcase, DDD layering."
exit 0
