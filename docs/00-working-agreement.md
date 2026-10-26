# 00 — Working agreement

Dokumen ini adalah kontrak kerja untuk AI agent yang mengerjakan automation di repo ini.
Baca `docs/01` sampai `docs/08` setelah ini, lalu ikuti fase yang relevan di `workflow/`.

Tiga repo yang terlibat: ledger `staffinc-testcase` (sumber TC), codebase produk (sumber
perilaku), dan repo automation tempat test ditulis (`staffinc-automation` untuk track Staffinc,
`internaltools-automation` untuk track INP). Lihat `docs/01-pipeline-overview.md`.

## Read order

1. `docs/00-working-agreement.md` (this file)
2. The phase file you are executing under `workflow/`
3. The matching rule doc under `docs/`
4. The target repo's own conventions — they win on local details

## The 3-layer contract

```
SPEC (.spec.ts)              Layer 1  orchestration + assertions + traceability
  -> USECASE (.usecase.ts)   Layer 2  business logic, returns UsecaseResult
    -> COMPONENT / PAGE / SCREEN  Layer 3  HTTP / DOM / device interaction only
```

FACTORY is not a layer. It may be imported by SPEC (fixtures) and by USECASE
(data generation). It must not call APIs, contain flows, or assert.

| Layer | May | Must not |
|---|---|---|
| SPEC | call usecases, import factories, assert, `test.step` | touch page/screen/component, hold business logic |
| USECASE | orchestrate layer 3, call other usecases, validate via `HttpResult` | contain `expect()`, call axios/fetch directly, hardcode test data |
| Layer 3 | locators, clicks, fills, HTTP calls, return raw values | assert, decide business order |
| FACTORY | generate data, apply overrides | API calls, flows, assertions |

## Definition of done

- [ ] Scenario written in the spec file the human named (one TC = one owning spec)
- [ ] Every test carries `// @covers <TC-ID>` (or `// @no-covers <reason>` for seeding-only)
- [ ] Assertions fail when the behaviour regresses — no `toBeDefined()`-only, no `||` fallbacks
- [ ] Every Then/And claim in the ledger has an assertion (or the TC is `partial` with a note)
- [ ] `@covers` lists every TC the test really executes — no missing, no invented IDs
- [ ] App-vs-TC differences were raised to the human (fix TC or log defect), not silently absorbed
- [ ] The relevant test was actually executed; verdict quoted from real output
- [ ] Evidence exists if the human asked for it (video/artifact named after the TC)
- [ ] `scripts/check_agent_rules.py` passes on the changed files

If an item cannot be satisfied, say so explicitly and name the blocker. Never fill the gap
with a plausible-sounding result.

## Operating rules

1. **Act, don't narrate.** If you say you will run something, run it in the same turn.
2. **Verify before claiming.** Read state from the system (git, CI, DB, browser), not memory.
3. **One decision, one question.** Ask only when the answer changes what you build; batch
   independent questions into one message.
4. **Never fabricate output.** No invented results, file contents, or IDs.
5. **Respect shared working trees.** Never `git checkout`/`reset --hard` to undo someone else's
   work. Read other branches from git objects (`git show`, `git archive`).
6. **Push only when asked.** Never merge a PR without an approving review.
7. **Code English, chat human.**

## Forbidden patterns (auto-rejected in review)

- `expect(true)`, truthiness-only assertions, tolerated status sets
- `test.only` / `describe.only`
- hardcoded JWT, bearer token, password, environment URL
- `console.log` (use the repo logger)
- emoji in source, comments, or logs
- a spec importing a page/screen/component directly
- test data hardcoded inside a usecase (`' EDITED'`, `'X'.repeat(51)`)

## Reporting format

```
CHANGED: <files>
RAN: <exact command + verdict>
EVIDENCE: <path or "none requested">
OPEN: <decisions or blockers for the human>
```

Anything not covered by `RAN` is not verified. Say it plainly.
