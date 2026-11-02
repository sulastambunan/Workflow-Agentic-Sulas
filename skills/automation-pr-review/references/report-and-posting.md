# Report and posting

The author needs to act on every finding without asking a follow-up: exact file:line, the test name
or code, the proof, and a concrete fix. "28 tests have no assertions" without the list of 28 is not
actionable.

## Severity

| Severity | Use for |
| --- | --- |
| blocker | a covered clause can pass while the feature is broken (vacuous pass, including a hardcoded or tautological assertion that is the clause's only check); an inverted or wrong-record Given; an expected value contradicts the testcase or comes from the app; `@covers` claims a testcase whose Then clauses are `missing`; secrets or credentials in the diff; a fixture that damages shared data or accounts; `automated` set prematurely |
| major | a `weaker` clause; flaky by design (shared counts under parallel workers, ignored `isVisible` timeout, sleeps as synchronisation); an environment or time assumption that fails or passes for the wrong reason; data created every run without cleanup on a shared client; a status-agnostic negative |
| minor | DDD/layering, duplicated helpers, `console.log`, stale comments or ids, naming; a tautological assertion that is not a clause's only check |
| nit | style only; leave out unless the user wants everything |

## Verdict

- **Ready to merge**: no blocker or major; every `@covers` clause `asserted`.
- **Merge after fixes**: majors or minors that can be fixed in place; no blocker.
- **Not ready**: any blocker, or `@covers` claims that are false for several tests.

State the basis next to the verdict: "code review only, the PR tests were not executed" unless
you ran them, and then where, with which accounts, and the real result.

## Report template

```markdown
## Review: staffinc-automation#<N> · <title>

**Head** `<sha>` · **Base** `<base>` · **Basis** code review only | executed on <env> · **Verdict** <verdict>

<2–4 lines: what the PR does, the main risk, what must change>

### Assumption ledger
| # | Assumption | Status | Evidence |
|---|---|---|---|

### Findings (verified)
| # | Sev | Where | Finding | Evidence |
|---|---|---|---|---|
| 1 | blocker | `pk156-e-access-denied.spec.ts:45` | `taskReport === false` can never fail | CP `SidebarNavGroup.tsx:215` renders sub-items only on `!collapsed && isOpen` |

### Detail
<one block per finding that repeats or needs a fix sketch; see "Repeated findings">

### Reported by reviewers (not re-verified)
<finding, confidence, why it was not verified>

### Coverage per @covers
| Test | @covers | asserted | weaker | missing | extra | Note |
|---|---|---|---|---|---|---|
<count outcome clauses only; extra = only those that could cause a false FAIL;
 clauses added to the testcase after the PR was opened go in Note as "+N new, uncovered">

### Paired testcase PR
<staffinc-testcase#M: fields touched, testcases set to `automated`, status-rule result; or "none">

### Earlier reviews
<none | for each: reviewer, head it saw, and what this review adds (new), confirms, or corrects>

### Gates
- pr_guard on head: <result against the real base; for a stacked PR also against develop; blind spots that apply>
- type-check (PR-changed files only): <result>
- PR CI: <checks that ran, and what CI does not cover>
- tests executed: no | <command, env, exit code, pass/fail/skip counts>
- missing prerequisites or shortcuts: none | <what was missing or substituted, and which checks it limited>

### PR claims
| Claim | Result |
|---|---|

### What checks out
<things done well, so the author knows what to keep>

### Questions for the author
<only what the code, testcase and product sources cannot answer>
```

### Repeated findings

List every occurrence; never "and N more".

```markdown
### #N · Issue title
**`path/to/file.spec.ts`**
| Line | Test name / code |
|------|------------------|
| L68  | `C.1 - Export Template` |

**Fix:** <concrete fix>
```

## Re-review

Put the earlier findings first, then anything new:

```markdown
| # | Earlier finding | Status | Proof at `<new sha>` |
|---|---|---|---|
| 1 | vacuous sidebar check | fixed | `pk156-e-access-denied.spec.ts:47` expands the group first |
| 2 | no timezoneId | not fixed | `report-list.spec.ts` still asserts "WIB" without it |
```

Status values: fixed, partly fixed, not fixed, no longer applicable.

## Posting (only when the user asks)

- Re-check the head right before posting: `gh pr view <N> --json headRefOid`. If it moved, review
  the new commits first.
- Default: `gh pr review <N> -R sampingantech/staffinc-automation --comment --body-file <file>`.
  Use `--request-changes` only when the user asks to block; never approve on the user's behalf
  unless asked.
- GitHub limits a body to 65,536 characters. Keep the verdict, the ledger, the verified table and
  the highlights on top; put per-area detail in `<details><summary>…</summary> … </details>`, or post
  it as a second `gh pr comment`.
- Strip local paths (`/tmp/…`, home directories, scratch folders), personal data and anything a
  sub-reviewer copied from logs (tokens, phone numbers, PINs).
- Confirm the review landed: `gh pr view <N> --json reviews`.
