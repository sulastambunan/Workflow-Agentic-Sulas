# Review checks: clause table, red flags, pitfalls and scan recipes

Contents: clause table · testcase version · red flags · status rule · vacuous-pass pitfalls ·
environment, time and data pitfalls · mapping pitfalls · mobile selector grounding · gates ·
scan recipes.

## Clause table

One table per test, one row per outcome clause of its `@covers` testcase, in order: every Then, and
every And that follows a Then. An And under a Given or When is setup or an action: check that the
test performs it, but do not count it as an outcome. Each row holds the clause quoted, the assertion
that checks it (file:line, ideally tagged `// <TC-ID> Then#n`), and a verdict:

- `asserted`: same observable outcome, same expected value as the clause;
- `weaker`: something is checked, but less than the clause says (visibility instead of value,
  truthiness, partial text, a count without content, an OR the clause does not allow);
- `missing`: nothing checks it;
- `extra`: an assertion no clause asks for that could fail for unrelated reasons.

Given and When clauses must be performed as written. A replaced action (Next instead of Save, an
API call instead of the UI action, a seeded state instead of the user flow the testcase describes)
makes the dependent Then clause `missing`. Respect OR branches in the testcase and do not invent
scope it does not ask for. A test passes review only when every clause is `asserted`.

Also check per testcase: `lifecycleStatus`, `supersededBy` and `duplicateOf`. A `@covers` on a
deprecated, superseded or duplicate testcase is a mapping finding.

List `extra` assertions only when they could cause a false FAIL; do not count every anchor.

## Testcase version

The oracle is the testcase on staffinc-testcase `main` today, because that is what `@covers` will
claim once the PR merges. Testcases can change after a PR is opened (a later PRD adds variants or
supersedes an oracle), so split the verdict by who owns the gap:

```bash
git -C <staffinc-testcase> log --since=<PR createdAt> --format='%h %ad %s' --date=short -- <testcase file>
```

- Clauses that existed when the PR was opened and are not `asserted`: findings against the PR.
- Clauses added after the PR was opened: "testcase changed after the PR, N new clauses uncovered".
  Not the author's defect, but they must be covered, or the `@covers` dropped, before the testcase
  can be `automated`.
- A testcase with several variant blocks: every active variant is an oracle. A block marked
  superseded or historical-only is not; a test that asserts only that block covers nothing current.

Say in the ledger which testcase commit you used and how many testcases changed after the PR.

## Red flags

List each hit with file:line, or write "none".

- ❌ an assertion removed, negated or loosened compared with the base branch
- ❌ an expected value that differs from the testcase, or was derived from the app's own response,
  code or constants
- ❌ skipped or focused tests: `test.skip(` / `test.fixme(` / `.only`, skip wrappers, conditional skips,
  `if (x) expect(...)`. A missing precondition is a FAIL or a reported blocker, never a skip
- ❌ swallowed errors: `.catch(() => {})`, `.catch(() => false)`, `.catch(() => '')`, `.catch(() => 0)`,
  try/catch around an action or an asserted value, `|| true`
- ❌ `{ force: true }`, clicks through `evaluate`, `.first()` / `.last()` / `.nth()` without a stated reason
- ❌ fixed sleeps (`waitForTimeout(`, `driver.pause(`) used as synchronisation, retry loops,
  `--retries` overrides, rerun-until-green
- ❌ tautologies and stubs: `expect(true)`, bare `toBeDefined()` / `toBeTruthy()` on a locator,
  `toBeGreaterThanOrEqual(0)`, asserting on data the test generated itself
- ❌ a mock standing in for a Then clause about backend behaviour, data flow or persistence
- ❌ hardcoded credentials, tokens or JWTs; hardcoded fixture ids without an existence check
- ❌ debug or inspection specs, `console.log` in specs, leftover screenshots or traces in the diff
- ❌ DDD broken: a spec touching `page` / components directly, a usecase bypassing its page object,
  business logic in a spec or component (repo rule: spec → usecase → page/screen/component)
- ❌ in a testcase diff: any change outside `automationStatus`, `automationRef`, `automationNote`, or
  generated `indexes/*.json` / `reports/**` files

## Status rule

`automationStatus: automated` is correct only when the automation PR is merged to `develop`, the
testcase's `@covers` is on `develop`, its `automationRef.command` `--grep` matches at least one test
there, the run was clean (every selected test passed on the first attempt, nothing skipped or flaky)
and the clause review passed. Flag `automated` set on a branch, in the same PR as the automation,
after a flaky or retried run, or for a testcase with `weaker` or `missing` clauses.

Check the paired testcase PR against this rule: `gh pr diff <N> -R sampingantech/staffinc-testcase`.
Its diff may touch only those three fields (other frontmatter such as `lifecycleReason` is a
finding), and `automated` for a testcase this PR does not fully assert is a blocker.

## Vacuous-pass pitfalls (tests that stay green when the feature is broken)

Each entry: symptom to grep, why it is vacuous, the fix to suggest.

- **Not-found read as false.** `.catch(() => false)` after `isEnabled()` / `isVisible()` /
  `waitFor()`, or `return locator.isEnabled().catch(() => false)`. A renamed testid or a blank/error
  page makes "Approve is disabled" or "menu is hidden" pass. Fix: assert a positive anchor first
  (card status, the button visible-and-disabled, the page heading).
- **`isVisible({ timeout })`.** Playwright ignores that timeout; the read is instant. Negative reads
  pass while the page still renders; positive reads flake. Fix: `locator.waitFor({ state, timeout })`
  or web-first `expect(locator).toBeVisible()`.
- **Conditional render.** Sub-items that exist only while a group is expanded (client-portal sidebar
  sub-menus render only on `!collapsed && isOpen`, `SidebarNavGroup.tsx`), tab panels, accordions.
  "Link is hidden" is always true unless the test expands the group. Fix: expand first, or assert
  on something rendered unconditionally.
- **Negative-only access checks.** Menu hidden for a no-access user, with no positive control on an
  account that has access, and menus that depend on feature flags loaded after the layout. Also
  check whether the testcase expects the direct URL to show "Access denied" / "Back to Client
  Portal" (client-portal `withActivityReportFlag` → `/no-access`); a sidebar-only test leaves that
  guard untested.
- **Status-agnostic API negatives.** `expect(result.success).toBe(false)` or `!success` for "the
  server refuses X". A 401 (expired token), 500 or network error also passes. Fix: assert the exact
  status (409, 422) and error code.
- **Empty-result filters.** "Every row has status X" over a filter that may return zero rows.
  Fix: seed each status, or assert `rows.length > 0` with the seeded id present.
- **Loading looks like empty.** A table that renders the same placeholder row while loading and when
  empty (client-portal `Datatable`) makes `rowCount === 0` pass on a table that never loaded.
  Fix: wait for the loading state to end, then assert the empty-state text or the seeded rows.
- **Hardcoded value asserted back.** The usecase sets a literal on a fallback branch
  (`tables = 0` when navigation failed, `section: CONST`) and the spec asserts that literal. It
  counts as an assertion for `pr_guard` but can never fail. Fix: assert a value read from the page
  or API, and fail the usecase when navigation fails.
- **Wrong record for the Given.** The test opens "the first employee in the list" (or any arbitrary
  record) while the testcase needs a record in a specific state, then asserts that a section or
  control is absent. It passes on whatever empty record comes first. Fix: provision or look up a
  record that matches the Given, and assert it is the one opened.
- **Inverted Given.** The testcase says the permission or toggle is OFF; the test reads a
  configuration with it ON and asserts the ON behaviour. Compare each Given's literal value with the
  fixture or config the test uses.
- **OR-proofs.** `url.includes(id) || pageText.includes(id)` when the list page already shows the id.
- **Negative assertions on locators that never matched.** `not.toBeVisible()` / `toHaveCount(0)` on
  a selector that is wrong, or on the wrong page (login redirect, `/no-access`, error page, empty
  state). Fix: a positive anchor on the same page first.
- **Over-strict "no live update".** Asserting nothing changes without refresh, when the testcase
  only says a live update is not required.
- **`expect.soft`.** It still fails the test at the end, but a soft check of a rule the product
  deliberately lacks makes the testcase FAIL for the wrong reason, and soft checks invite ignoring
  failures. Prefer collecting violations into an array and asserting `toEqual([])`.
- **Zero-assertion tests.** Mobile/Mocha uses `it(`, web uses `test(`; scan both. Mobile pattern to
  watch: `it()` blocks that only call `usecase.verifySomething()` or log a result: observation
  scripts, not tests. An assertion inside a called helper is fine once you have read the helper.

## Environment, time and data pitfalls (tests that fail or pass for the wrong reason)

- **Feature flags differ per environment.** An asserted disabled/hidden state must hold on the
  environment the suite targets: check client-portal `.env.<env>` (for example Report Scoring is
  disabled only when `NEXT_PUBLIC_ENABLE_PK160` is off) and remote flag allow-lists.
- **Timezone.** Text with "WIB" or a formatted local time but no
  `test.use({ timezoneId: 'Asia/Jakarta' })` gives a false FAIL on a UTC runner. A backend
  `report_date` derived in UTC shifts submissions made 00:00–06:59 WIB to the previous day.
- **Date boundaries.** "now − 365 days" normalised to midnight can land on the 1st of a month, so
  "day 1 is disabled" fails on some dates. Compute the boundary from the same rule the product uses.
- **Client query cache.** After an out-of-band API mutation (employee revises, admin saves via API),
  client-side navigation can show cached data (React Query `staleTime`, for example 60 s).
  Fix: `page.reload()`.
- **Stale responses.** A GET started before a mutation can resolve after it with old data. Match
  responses to requests initiated after the mutation response.
- **Shared counts under `fullyParallel`.** Summary cards or tab totals read seconds apart while other
  workers seed data. Fix: compare against the test's own seeded ids, or serialise those specs.
- **Token lifetime.** Fixtures that log in once per worker: the hcmsvc agent access token lives
  15 minutes (`module/core/usecase/agent_auth/tokens.go`), so long runs hit 401 mid-suite. Fix:
  refresh on expiry. Local CLI tokens expire after 24 h ("Token file not found or expired").
- **Fixture hygiene.** Forms or reports created every run and never deactivated or deleted,
  especially forms "assigned to all employees" of a shared client; drafts left behind on failure;
  hardcoded fixture ids per environment without an existence check.
- **Shared-account safety.** PIN login retried with a stale PIN (hcmsvc locks after 3 failures);
  PIN, phone or temporary tokens written to curl logs or report attachments (check the redaction
  pattern and `x-suppress-error-log`).

## Mapping pitfalls

- **Read every `@covers` against the canonical testcase.** One test claiming two ids
  (`@covers A, B` above a loop) claims both per run; each needs its clauses asserted.
- **`@tsd` tags** are traceability only; compare them with the TSD scenario text.
- **`pr_guard` header blind spot.** An `@no-covers` (or `@covers`) in the comment block above the
  first test sits in the file header, so it opts the whole file out of the covers check; later
  tests and empty `test.fixme` escape the gate.
- **Stale comments** naming ids from another PRD (for example a PK158 id in a PK156 spec).

## Mobile selector grounding (Appium)

- Every accessibility id must exist: a literal `contentDescription` / `testTag` in kerjaan-android,
  or one synthesised by a staffinc-design-system-android component from the call site's
  `accessibilityIdPrefix` (for example `"<prefix>button-"`). A call site that omits the prefix yields
  a generic id (`"button-"`) shared by every such component, so a feature-specific selector there is
  fabricated. Check the design-system version the app actually depends on.
- UiAutomator2 does not support CSS-like attribute filters on `~id` selectors; read attributes on
  the matched elements instead. Editable fields: `getText()` can be empty; read `getAttribute('text')`.
- No cross-domain imports from web/api into mobile; shared data goes to `domain/shared`.

## Gates

Run gates in a temporary detached worktree of the head, never in a shared checkout:

```bash
git worktree add --detach <tmp> "$H"
cd <tmp> && python3 scripts/quality/pr_guard.py --check all --base "$B"            # this PR's own lines
python3 scripts/quality/pr_guard.py --check all --base origin/develop               # stacked PR only
```

- **Script missing at the head** (the branch predates the gate): run `develop`'s copy against the
  head worktree. `ROOT` comes from the script's location unless `AUTO_ROOT` is set:
  `git show origin/develop:scripts/quality/pr_guard.py > <scratch>/pr_guard.py`, then
  `AUTO_ROOT=<tmp> python3 <scratch>/pr_guard.py --check all --base "$B"`. Record it in the ledger.
- **Trust the output, not only the exit code.** Real output carries `pr-guard` annotations or its
  summary table; a dump of `git` usage text means the gate did not run. Never read the exit code
  through a pipe (`| tail` returns the pipe's status).
- **Type-check:** `bun run type-check` in `<tmp>`; report only errors in PR-changed files. A fresh
  `bun install` is slow; symlinking an existing checkout's `node_modules` is an accepted shortcut,
  recorded in the ledger as possible version skew.
- **Cleanup:** remove a `node_modules` symlink first, then `git worktree remove <tmp>`.
- **CI:** read `statusCheckRollup` and the workflow files at the head (`.github/workflows/`); note
  which gate ran, on which event, and what it does not cover.

## Scan recipes

Run against `git show "$H":<file>` output or an extracted copy of the PR head
(`git archive "$H" | tar -x -C <scratch-dir>`). Scan pages and usecases too, not only specs.

Whole-file scans also hit code the PR did not touch. Scan the added lines to find findings, and
treat hits on unchanged lines as context, not as the author's defects:

```bash
git diff "$B...$H" -- <files> | grep -E '^\+' | grep -E "<pattern>"   # then locate each hit with git show
```

```bash
# Not-found-as-false probes and ignored isVisible timeouts
grep -nE "\.catch\(\(\) => (false|undefined|null|0|''|\"\"|\{\})\)" <files>
grep -nE "isVisible\(\{ *timeout" <files>
# Status-agnostic negatives (also matches expect(x.success, 'message').toBe(false))
grep -nE "\.success\b.*\)\.toBe\(false\)|expect\(!" <spec files>
# WIB text without a pinned timezone: the WIB string often lives in a format helper,
# so check across all PR files, then look for timezoneId in the specs and the Playwright config
grep -lE "WIB|Asia/Jakarta" <files> && { grep -l timezoneId <spec files> domain/web/playwright.config.ts || echo "NO-TZ: WIB asserted but no timezoneId pinned"; }
# Conditional skips inside test bodies
grep -nE "^\s+(test|it)\.(skip|fixme)\(" <spec files>
# Weak or tautological assertions
grep -nE "toBeGreaterThanOrEqual\(0\)|toBeDefined\(\)|expect\(true|\|\| *true|expect\.soft" <files>
# Creation without cleanup (compare counts per file)
grep -nE "create(Form|Report|Employee)\(" <files>; grep -nE "cleanup|delete|deactivate" <files>
```

Zero-assertion candidates (then read each candidate's helpers):

```bash
for f in <spec files>; do
  tests=$(grep -cE "(^|\s)(test|it)\(" "$f"); expects=$(grep -c "expect(" "$f")
  [ "$expects" -lt "$tests" ] && echo "CHECK: $f (tests=$tests expects=$expects)"
done
```

Repository rules:

```bash
grep -n "page\.\(locator\|goto\|click\|fill\)" <spec files>            # DDD: spec touches page
grep -n "this\.page\.\(locator\|goto\|click\|fill\)" <usecase files>   # DDD: usecase bypasses page
grep -rn "waitForTimeout\|driver\.pause" <module dir>                    # hard waits (pages/usecases too)
grep -n "console\.log" <spec files>                                      # forbidden in specs
grep -n "require('axios')" <spec files>                                  # inline require
grep -n "password.*=.*[[:alnum:]]" <files> | grep -v "process\.env"      # hardcoded credentials
```

Testcase lookup for every `@covers` id:

```bash
# Not every testcase sits in a module folder, so search the whole tree
grep -ohE "@covers [A-Z0-9, -]+" <spec files> | tr ', ' '\n\n' | grep -E '^[A-Z]+(-[A-Z0-9]+)+-[0-9]{3,}$' | sort -u > ids.txt
while read -r id; do
  f=$(find <staffinc-testcase>/testcases -name "$id-*.md" | head -1)
  [ -n "$f" ] && echo "$id $f" || echo "NOT ON MAIN: $id"
done < ids.txt
```
