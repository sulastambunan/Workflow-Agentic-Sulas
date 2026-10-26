# 04 — PR review loop

The review is a loop, not a checkbox. An automated reviewer re-reviews every push and quotes the
commit hash it judged.

## 1. Read the newest review, not the one you remember

```bash
gh pr view <n> --json reviews -q '.reviews[-1].body'
gh pr view <n> --json reviews -q '.reviews[] | "\(.submittedAt) \(.author.login)"'
```

Dump it to a file and read it whole. Note the `Base/head: <base>..<sha>` line: the review is
PINNED to that hash. Commits pushed after it are unjudged — check again before declaring findings closed.

## 2. Re-test every finding against the CURRENT tree

```bash
git log --oneline <reviewed-sha>..HEAD
```

For each finding, run one concrete command that proves or disproves it in the current code:

- grep the guarded string (`git grep -n 'test.skip' -- domain/`)
- grep the hardcoded value the review names
- the type-check scope
- `git status` / `git grep` for what the finding claims is still there

Report a fixed / not-fixed table with the command output. Working down the review text blindly
re-does findings a later commit already closed, and misses the ones the fix commit introduced.

## 3. Verify "removed by the merge" claims against the base branch

```bash
git show develop:<path> | grep -n <entry>
git show HEAD:<path> | grep -n <entry>
```

Present in base and absent from HEAD = a real regression worth fixing. Absent from both = the
reviewer mis-read an unrelated commit; "restoring" it adds noise.

## 4. Price the suggested fix before applying it

A suggestion can widen a shared gate (tsconfig `include`, lint scope) and surface long-standing
errors in modules the PR never touched. Count them first, then bring the choice to the human:
scope the gate to this PR's modules, or clear the whole backlog. Never silently redden CI.

## 5. Fix in waves, one commit per wave

Commit messages map finding → fix. Then post a PR comment with the same mapping plus evidence:
real run output, the valid version from the registry, the repo variable that carries the credential.

Example:

```text
1. "usecase contains expect()"      -> moved assertion to spec            (a1b2c3)
2. "hardcoded employee id"          -> id now flows from stage result     (d4e5f6)
3. "@covers missing on new spec"    -> added @covers C07-POS-001           (d4e5f6)
```

## 6. Separate VERIFIED from PENDING

If a run could not be executed (no device, endpoint down), say so in the commit message AND the
PR comment. Never present an unrun fix as passing.

## 7. Decisions belong to the human

Product/human calls — which token to standardise on, 4-digit vs 6-digit code, demoting a ledger
entry, whether the app or the TC sheet is right — go to the human. Do not guess and do not pick
silently.

## 8. Never merge

Merging waits for an approving review from the reviewer. An agent may sync the branch, push
fixes, and post the mapping. Nothing else.

## 9. When the branch no longer merges

Prove there is a conflict before "fixing" one:

```bash
gh pr view <n> --json mergeable,mergeStateStatus,headRefOid
```

- `CONFLICTING` + `DIRTY` → real conflict.
- `MERGEABLE` + `BLOCKED` → no conflict; the PR is waiting on review. Do not start a merge.

Resolve in a throwaway detached worktree so a shared working tree is untouched:

```bash
git worktree add --detach /tmp/merge-<n> HEAD
cd /tmp/merge-<n> && git merge origin/<base>
```

Resolve by UNION, not by picking a side: both branches usually carry something real (source-cited
locators vs a flow proven on device). Make the switch between strategies explicit.

Konvensi kerja paralel dan aturan kebersihan worktree: `docs/shared/09-worktree.md`.
