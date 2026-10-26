#!/usr/bin/env python3
"""Deterministic checks for agent-written automation specs.

Rules enforced on every changed *.spec.ts:
  1. traceability  -> // @covers <ID> or // @no-covers <reason>
  2. no focused    -> test.only / describe.only / it.only
  3. no console.log
  4. no secrets    -> JWT, bearer token literal, gh*_ / sk- keys
  5. not a stub    -> at least one real assertion (not only toBeDefined/toBeTruthy/toBeFalsy)
  6. ascii only    -> no emoji / non-ASCII characters in source

Usage:
  python3 scripts/check_agent_rules.py --base origin/develop
  python3 scripts/check_agent_rules.py --path domain/web/module/pjp/tests
  python3 scripts/check_agent_rules.py --files a.spec.ts b.spec.ts

Exit code 0 = clean, 1 = violations, 2 = usage error.
"""

import argparse
import os
import re
import subprocess
import sys

STRONG_ASSERT = re.compile(
    r"expect\s*\([^\n]*\)\s*\.\s*(toBe|toEqual|toStrictEqual|toContain|toMatch|toMatchObject|"
    r"toHaveLength|toHaveProperty|toThrow|toHaveText|toHaveValue|toHaveURL|toBeVisible|"
    r"toBeHidden|toBeEnabled|toBeDisabled|toHaveCount|toHaveAttribute|toHaveClass)(?!\w)"
)
WEAK_ASSERT = re.compile(r"expect\s*\([^\n]*\)\s*\.\s*(toBeDefined|toBeTruthy|toBeFalsy|not\.toBeNull)")
SECRET_PATTERNS = [
    (re.compile(r"\beyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}"), "hardcoded JWT"),
    (re.compile(r"Bearer\s+[A-Za-z0-9._-]{20,}"), "hardcoded bearer token"),
    (re.compile(r"\bgh[pousr]_[A-Za-z0-9]{20,}"), "hardcoded GitHub token"),
    (re.compile(r"\bsk-[A-Za-z0-9_-]{20,}"), "hardcoded API key"),
]
FOCUSED = re.compile(r"\b(test|describe|it)\s*\.\s*(only|skip)\b")
NON_ASCII = re.compile(r"[^\x00-\x7F]")


def changed_specs(base):
    def run(*args):
        out = subprocess.run(args, capture_output=True, text=True)
        return out.stdout.splitlines() if out.returncode == 0 else []

    files = set()
    files.update(run("git", "diff", "--name-only", f"{base}...HEAD"))
    files.update(run("git", "diff", "--name-only", "HEAD"))
    files.update(run("git", "ls-files", "--others", "--exclude-standard"))
    return sorted(f for f in files if f.endswith(".spec.ts") and os.path.isfile(f))


def check_file(path):
    problems = []
    try:
        text = open(path, encoding="utf-8").read()
    except UnicodeDecodeError:
        return ["file is not valid UTF-8"]

    lines = text.splitlines()

    covers = [ln for ln in lines if "@covers" in ln or "@no-covers" in ln]
    if not covers:
        problems.append("missing // @covers <TC-ID> (or // @no-covers <reason>)")

    for n, ln in enumerate(lines, 1):
        code = ln.split("//")[0]
        if FOCUSED.search(code):
            problems.append(f"line {n}: focused/disabled test ({code.strip()})")
        if "console.log" in code:
            problems.append(f"line {n}: console.log (use the repo logger)")

    for pattern, label in SECRET_PATTERNS:
        if pattern.search(text):
            problems.append(f"{label} committed in source")

    expects = re.findall(r"expect\s*\(", text)
    if not expects:
        problems.append("no expect() at all — test asserts nothing")
    elif not STRONG_ASSERT.search(text):
        weak = "only weak assertions" if WEAK_ASSERT.search(text) else "no comparable assertion"
        problems.append(f"{weak} — add an assertion that fails on regression")

    non_ascii = [ln for ln in lines if NON_ASCII.search(ln)]
    if non_ascii:
        problems.append(f"non-ASCII characters on line(s): {', '.join(str(i + 1) for i, ln in enumerate(lines) if NON_ASCII.search(ln))[:80]}")

    return problems


def collect(args):
    if args.files:
        return [f for f in args.files if f.endswith(".spec.ts")]
    if args.path:
        found = []
        for root, dirs, names in os.walk(args.path):
            dirs[:] = [d for d in dirs if d not in ("node_modules", ".git", "test-results")]
            found += [os.path.join(root, n) for n in names if n.endswith(".spec.ts")]
        return sorted(found)
    return changed_specs(args.base)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--base", default="origin/develop", help="git ref to diff against")
    parser.add_argument("--path", help="scan a directory instead of the git diff")
    parser.add_argument("--files", nargs="+", help="explicit files to check")
    args = parser.parse_args()

    specs = collect(args)
    if not specs:
        print("no changed *.spec.ts files — nothing to check")
        return 0

    failed = 0
    for path in specs:
        problems = check_file(path)
        if problems:
            failed += 1
            print(f"FAIL  {path}")
            for p in problems:
                print(f"      - {p}")
        else:
            print(f"PASS  {path}")

    print(f"\n{len(specs) - failed}/{len(specs)} spec files clean")
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
