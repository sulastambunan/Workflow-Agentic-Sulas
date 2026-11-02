---
name: automation-pr-review
description: >
  Review someone else's pull request in the staffinc-automation repository (Playwright web/API
  specs, Appium mobile specs, usecases, pages, fixtures) step by step: pin the PR head and every
  assumption first, check each @covers test against its canonical staffinc-testcase testcase,
  hunt tests that stay green when the feature is broken, check env/time/data pitfalls, run the
  repo quality gate, and write an evidence-backed review that is posted only on request. Use
  whenever the user asks to review, re-review or check an automation PR or a teammate's test PR,
  e.g. "review PR 355", "re-review after the fixes", a github.com/sampingantech/staffinc-automation/pull/N
  link; requests may arrive in Indonesian. Not for product-code PRs (client-portal, hcmsvc,
  kerjaan-android: those need PR-driven testing) and not for a self-check of your own work in progress.
---

# Automation PR review

A review is only as good as what it pins down before reading code. Most wrong reviews come from a
silent assumption: the wrong head commit, the wrong testcase version, the wrong environment, or a
PR description taken as evidence. So this skill starts with intake and keeps an assumption ledger
that ends up in the report, next to the findings.

The testcase is the oracle. A test is judged by whether it would fail when the feature is broken,
not by whether it is green.

## Prerequisites

Check these at intake. A missing source never silently drops a step: record it in the assumption
ledger and the report's Gates section, and keep the findings it would have proved as "reported, not
verified" or `assumed`.

| Prerequisite | Needed for | Without it |
| --- | --- | --- |
| The PR number or URL | everything | ask for it |
| A staffinc-automation clone | fetching the head, scans, `pr_guard` | stop: no review is possible |
| A clean checkout of staffinc-testcase `main` | the clause table (step 4) | stop; or, if the user agrees, a code-only smell review that says every `@covers` claim is unchecked |
| `gh` CLI signed in to `sampingantech` | PR metadata, body claims, CI, posting | work from `git fetch` only; claims and CI stay `assumed`; no posting |
| `python3` | `pr_guard` (standard library only) | gate skipped |
| Installed dependencies (`bun install`) | type-check | type-check skipped |
| Product sources (client-portal, hcmsvc, kerjaan-android, staffinc-design-system-android) | proving findings that depend on product code: per-env flags, conditional rendering, token lifetime, mobile accessibility ids | those findings cannot become verified blockers |
| A Staffinc knowledge MCP or the PRD export | PRD/AC context; whether a later PRD superseded a testcase | a testcase-vs-app mismatch is reported as "needs a PRD check", not as a bug |
| Target environment and test accounts | an executed review | stay code-only (the default) |

Read product sources at the branch deployed to the target environment (usually the default branch)
and note the commit you read; a local checkout may be stale. For a PR older than a few days, also
read the product as of the author's run (`git rev-list -1 --before=<date> origin/<branch>`); a
difference between the two is an environment finding, not an author error.

## Workflow

Run the steps in order and keep a short checklist. Details live in the references; read the one a
step names when you reach it.

### 0. Intake: pin the review before reading code

Read `references/intake-and-assumptions.md`. Pin: repository and PR type, head SHA and base, paired
PRs (the testcase PR that adds the `@covers` ids, stacked automation PRs), scope, review basis
(code-only or executed), target environment, and output (chat report or GitHub post). Use the
defaults in that file for anything the user did not say and write each one into the assumption
ledger. Ask the user once, in one batched message, only when an answer would change the review and
cannot be found in the PR or the repos.

If the PR is not in staffinc-automation, stop and say which workflow fits instead. Earlier reviews:
note that they exist, but read them only after step 7 so they do not anchor yours.

### 1. Fetch read-only

Never check the PR out in a shared working tree; other sessions may have dirty files there.

```bash
git fetch -q origin pull/<N>/head && H=$(git rev-parse FETCH_HEAD)
gh pr view <N> --json title,author,state,isDraft,baseRefName,headRefName,headRefOid,additions,deletions,changedFiles,statusCheckRollup,createdAt,body
BASE=<baseRefName>; git fetch -q origin develop "$BASE"; B="origin/$BASE"
git merge-base --is-ancestor origin/develop "$H" || echo "PR is behind develop"
git diff --stat "$B...$H"     # this PR's own changes; for a stacked PR, not the whole stack
git show "$H":<path>
```

### 2. Inventory and claims

- Classify every changed file: spec, usecase, page/screen/component, fixture/factory/test-data,
  config/runner, script, docs, testcase mapping.
- List every test with its `@covers` / `@no-covers` / `@tsd` tag.
- Copy each claim in the PR body (pass counts, `@covers` counts, "known product bugs", "verified on
  STG") into a claims list. A claim is something to verify, not evidence.

### 3. Split large PRs

For 20+ files or several modules, split by area (UI flows that mutate state; list/config/read-only
screens; API layer and fixtures) and review in parallel if your tool supports sub-agents. Give each
reviewer the head SHA, its file list, the testcase location, the product sources, and "read-only: no
checkout, no edits, no GitHub posts". Their findings are reported, not verified, until step 7.

### 4. Testcase faithfulness

For each `@covers` id, open the canonical testcase (`<ID>-*.md` under `testcases/` on
staffinc-testcase `main`, or the paired testcase PR head when the id is new) and build the clause
table from `references/review-checks.md`. Every Then/And clause gets `asserted`, `weaker`,
`missing` or `extra`; a Given or When performed differently from the testcase makes the dependent
clause `missing`. Also flag `@covers` on a deprecated, superseded or duplicate testcase. When a
testcase changed after the PR was opened or holds several variants, follow "Testcase version" in
that file. If a paired testcase PR exists, check its diff against the status rule there.

### 5. Code checks

Run the scan recipes and walk the pitfall lists in `references/review-checks.md`: red flags,
vacuous passes, environment/time/data assumptions, DDD and hygiene, mobile selector grounding.
Read pages and usecases too, not only specs: assertions and swallowed errors often hide in helpers.

### 6. Gates

Run them in a temporary detached worktree of the head (`git worktree add --detach <tmp> "$H"`);
the commands, the missing-script fallback and the cleanup are in `references/review-checks.md`, Gates.

- `pr_guard` against the real base `$B` (this PR's own lines). For a stacked PR, run it again
  against `origin/develop` and report the two separately: only the first belongs to this PR.
- Type-check the head and report only errors in files the PR changed (the repo carries
  pre-existing errors).
- Read what CI actually ran (`statusCheckRollup` and the workflow triggers at the head) instead of
  assuming. A stacked or older branch may run an old gate or none, and no PR workflow executes the
  suites. A green PR is not a passing suite.
- Execute tests only when intake said so, against the agreed environment and accounts.

### 7. Verify before reporting

Personally open the line that proves every blocker and major finding: the PR line, the testcase
clause, or the product source. Downgrade or drop what you cannot prove. Keep sub-reviewer findings
you did not re-check in a separate "reported, not verified" list.

### 8. Report

Write the report with `references/report-and-posting.md`: verdict, basis, assumption ledger,
verified findings with file:line and evidence, reported-not-verified, coverage per `@covers`, what
checks out, and questions for the author. Write a chat report in the user's language and a GitHub
post in English unless told otherwise; keep code and quotes as they are.

### 9. Post only on request

Post only when the user asks. Default to a COMMENT review; never approve or request changes unless
asked. Re-check that the head SHA is unchanged right before posting, strip local paths, and confirm
the review landed. Rules: `references/report-and-posting.md`.

## Re-review

When the author pushed fixes: fetch the new head, diff it against the head you reviewed
(`git diff <old>..<new>`), give every earlier finding a status (fixed, partly fixed, not fixed,
no longer applicable) with the line that proves it, then review only the changed lines plus
anything they could break. Do not repeat an unchanged review.

When an earlier review exists on the same head and nothing was pushed since, do a full independent
review, then compare after step 7: list what is new, what it confirms, and what it got wrong.

## Boundaries

- Read-only: do not push to the author's branch, edit the PR, or fix code unless the user asks
  for that as a separate task.
- Do not run tests on shared accounts or devices without checking who else is using them.
- An unclear or outdated testcase is a testcase finding for the author and QA owner, not a reason
  to accept a weaker assertion. When the testcase and the app disagree, check whether a later PRD
  superseded the testcase before calling either side a bug.
