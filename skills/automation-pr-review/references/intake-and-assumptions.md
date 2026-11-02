# Intake and the assumption ledger

Intake turns "review this PR" into a review with a known target. Everything you pin here goes into
the assumption ledger, and the ledger goes into the report. That way the author and the user can
see which conclusions rest on a fact and which rest on a default.

## Intake fields

Fill every row before step 1. "Default" is what you use when the user did not say; record it in
the ledger as `assumed`. Ask only in the cases in the last column, all questions in one message.

| Field | How to find it | Default when unstated | Ask when |
| --- | --- | --- | --- |
| Repository and PR type | PR URL, `gh pr view` | — | the number exists in several repos and the user named none |
| Head SHA, state, base | `headRefOid`, `state`, `isDraft`, `baseRefName` | review the current head | — |
| Paired PRs | PR body links; `gh pr list -R sampingantech/staffinc-testcase --search "<ID>"`; a base branch other than `develop` | none | — |
| Scope | the user's words | the whole PR | — |
| Depth | the user's words | full review | — |
| Basis | the user's words | code-only (static review + gates, no test execution) | the user wants an executed review but no environment or accounts are known |
| Target environment | per-env fixture files (`*.stg.json`), env keys used, PR body ("verified on STG") | the environment the PR names; otherwise `unknown` | — |
| Testcase source | staffinc-testcase `main`; the paired testcase PR head for ids not on `main` | `main` | — |
| Output | the user's words | a report in chat, in the user's language | — |
| Posting | the user's words | do not post | the user said "post" but not whether to block |
| Earlier reviews | `gh pr view <N> --json reviews,comments,commits` (note which head each review saw) | new commits since → Re-review; same head → full independent review, compared after step 7 | — |

### PR type routing

- **staffinc-automation**: this skill.
- **staffinc-testcase, mapping only** (`automationStatus` / `automationRef` / `automationNote`): check
  only that the diff stays inside those three fields, that no generated `indexes/` or `reports/`
  files are committed, and the status rule in `review-checks.md`.
- **Product repositories** (client-portal, hcmsvc, hcmworker, kerjaan-android, design system): this
  is not an automation review. Say so and switch to PR-driven testing (impact map, test matrix,
  baseline attribution) if your environment has that workflow.
- **Stacked PR** (base is not `develop`): review against its real base, and say in the report that
  the result depends on the parent PR.

## Assumption ledger

One row per assumption, in the report under the verdict:

```markdown
| # | Assumption | Status | Evidence |
|---|---|---|---|
| A1 | Reviewed head is `1a2b3c4`, still the PR head at posting time | verified | `gh pr view 355 --json headRefOid` before and after |
| A2 | Canonical testcases come from staffinc-testcase `main` at `9f8e7d6` | verified | 41/43 ids found on main; 2 only in testcase#387 head `5c6d7e8` |
| A3 | Suite targets STG | assumed | fixture file `form-lengkap-app-answer.stg.json`; PR body says "verified on STG" |
| A4 | PK160 flag is on in STG | contradicted | client-portal `.env.staging` has the flag off |
```

Status values: `verified` (you saw the evidence), `assumed` (a default or an unproven claim),
`contradicted` (the evidence says otherwise; this usually becomes a finding).

Start every ledger with these rows, then add the PR's own:

1. the reviewed head SHA, re-checked when the report was written (and again right before posting);
2. the testcase source (`main` SHA, or the paired PR head), and how many testcases changed after
   the PR was opened;
3. the target environment and the feature flags the tests depend on;
4. the review basis (code-only or executed, where and with which accounts);
5. each missing prerequisite or shortcut (SKILL.md, Prerequisites; for example `pr_guard` copied from
   `develop`, or a symlinked `node_modules`) and the steps it limits;
6. the product source commits you read (repository, branch, SHA, and the as-of-run commit for an
   older PR), if any;
7. each PR-body claim you relied on.

## Wrong assumptions this prevents

Each line: the assumption, then the check that replaces it.

- "The branch I have checked out is the PR." Review the fetched head SHA; a local branch can be
  stale or belong to another session.
- "The PR has not changed since I fetched it." Re-read `headRefOid` right before posting.
- "The PR body numbers are true." Verify each claim in the claims list, or mark it `assumed`.
- "CI is green, so the tests pass." Read what CI ran. No PR workflow executes the suites, and the
  `pr_guard` Quality Gate triggers only on pull requests to `develop`: a stacked or older branch may
  show an old gate, or none.
- "The PR's base is `develop`." Use `baseRefName`. Against `develop`, a stacked PR's diff and
  `pr_guard` include every parent PR's changes, and the review blames this PR for them.
- "`pr_guard` passed, so `@covers` is right." The gate checks that a tag exists, not that the test
  asserts the testcase; it also has a header blind spot (`review-checks.md`, mapping pitfalls).
- "The testcase on `main` is the one this PR targets." New ids may live only in an open testcase PR,
  and a testcase may have changed on `main` after the PR was written. Follow "Testcase version" in
  `review-checks.md` and say which version you used.
- "Earlier reviewers already found everything." Read earlier reviews only after your own step 7;
  an earlier review can rest on a stale product checkout.
- "The expected value is right because the app shows it." The testcase is the oracle; an expected
  value derived from the app's response, code or constants is a red flag.
- "Testcase and app disagree, so the app is wrong." A later PRD may have superseded the testcase.
  Trace the PRD chain first; a stale testcase is a testcase finding, not a test bug.
- "Older specs in the repo show the right pattern." Legacy specs are examples of style at best, never
  a source of expected values.
- "The flag is on where I looked, so it is on in the target environment." Feature flags differ per
  environment (front-end env files, remote flag services); check the target one.
- "The same accounts and fixture ids exist in every environment." Check per-env fixture files and
  hardcoded ids.
- "A sub-reviewer's finding is real." It is `reported` until you open the line that proves it.
- "One green local run proves it." Only a first-attempt run with nothing retried, skipped or flaky is
  a clean pass, and only for the environment it ran on.
- "No hit in the knowledge base means no business rule." A query miss proves nothing; try exact ids
  and module terms, then read the source.
