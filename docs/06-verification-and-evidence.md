# 03 — Verification and evidence

## The rule

A claim is only as good as the command that produced it. "Sudah dites" means a real run happened
in this session, and the verdict is quoted from its output. A type-check is not a run. A green CI
on an older commit is not a run of your fix.

## Before trusting a result

1. **Which code ran?** Compare the artifact folder's mtime with the edited file's mtime; match
   numbers in the error against the code version (a `30000ms` timeout in the stack is not your
   15000ms helper). A run that finished before the patch says nothing about the patch.
2. **Is the environment the same?** After a URL change, failures are usually DATA and PERMISSION,
   not code: roles, approvers, element ids/versions, tax rules live in each environment's database.
   Compare 403/404 with what the app itself renders before editing selectors.
3. **Is the server up?** A host answering 5xx ends probing. Never write assertions for a form you
   could not open — report the blocker and do the work that needs no server.

## Artifacts

- Video is recorded only when the run enables it (`ENABLE_VIDEOS=true`, or `video: 'on'`).
  A green run without the flag leaves no video — re-run with it if evidence is owed.
- Artifact folders are cleared at the start of every run. Send the evidence in the same turn, or
  re-capture with a targeted run of just that test.
- Name evidence after the scenario/TC: `<TC-ID>__<spec>__<title-slug>.webm`. A video called
  `video.webm` proves nothing six weeks later.
- Package evidence as one ZIP with a `MANIFEST.txt` (file → test → covers). Ship only when the
  mapping is 1:1: folders ↔ tests with zero duplicates, and unique TC count equals the module's
  `@covers` count. If they disagree, the mapping is wrong — fix it, don't ship it.
- Tests with no TC of their own (setup/precondition) get `SETUP__<spec>__<title>.webm`,
  never a borrowed ID.

## Reporting a result

```text
RAN: bunx playwright test module/pjp/tests/pjp-c36-create.spec.ts --workers=1
RESULT: 1 passed (42.3s)
EVIDENCE: outputs/evidence/C36-POS-004__pjp-c36-create__save-draft.webm
NOT VERIFIED: mobile suite (no device attached)
```

- State explicitly what was NOT run. An unrun fix is never "passing".
- If a run fails, quote the failing step and the assertion message — not "there was an error".
- After a fix, re-run the SPECIFIC test. Full-suite runs mint data and wipe artifacts you still owe.

## Environment hygiene

- Never put a credential on a command line; read it from `process.env` inside a script and source
  `.env` once in the shell.
- Do not copy live cookies/tokens from a pasted curl into a probe, a fixture, or a commit.
- Keep probes out of the test tree. A throwaway spec inside `tests/` is discovered, turns CI red,
  and needs cleanup you may not be able to perform. Use a gitignored `outputs/probes/` (or `/tmp`
  where module resolution allows) and delete it once the selectors are written down.
