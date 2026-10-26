# 05 — CI gates

## What blocks a PR

Every new or changed test must answer three questions:

1. **Traceability** — does it carry `// @covers <TC-ID>`? A seeding/fixture test that automates
   no TC uses `// @no-covers <reason>` instead. A fabricated ID is worse than no ID.
2. **Substance** — does it assert something that can fail? Truthiness-only assertions,
   `expect(true)`, tolerated status sets (`[200,401,404].toContain`), and `.at.least(1)` weak
   counts are rejected as stubs.
3. **Hygiene** — no `test.only`, no hardcoded JWT/bearer token/key, no committed `.env`.

CI also runs the repo's type-check and lint. A green test run does NOT prove the tree type-checks:
renames leave dead type references in paths no test executes, and shadowed variables only surface
as TS2448/TS2454.

## Local run

```bash
python3 scripts/check_agent_rules.py --base origin/develop
```

Add to the repo's own gates:

```bash
npm run check-all        # or: bun run type-check && bun run lint
```

### Per track

```bash
# Staffinc — staffinc-automation
npm run check-all
cd domain/web && ./node_modules/.bin/playwright test module/<module>/tests/<spec>.spec.ts

# INP — internaltools-automation
bun run check-all
./node_modules/.bin/playwright test --config=playwright.web.config.ts --project=inp <spec>
```

Di `internaltools-automation`, `--project=inp` wajib: tanpa itu project `partner-*` ikut
globalSetup dan mencetak kegagalan autentikasi partner yang bukan bagian dari test kamu.
`HEADLESS=false` hanya untuk run headed — shell env menang atas `.env`.

## What CI does not prove

- That the test exercises the intended scenario (a passing test can assert nothing meaningful).
- That the environment has the data the scenario needs — a skip or an empty-state pass is not coverage.
- That the fix you just pushed is the code that ran (artifacts from an earlier run are cleared).

## Registering new specs

- Playwright: add the new spec to whatever list the repo uses (`.github/test-specs.json` or the
  runner's catalog). An unregistered spec is silently not run.
- Mobile: the runner resolves paths through a spec-support catalog; moving or renaming without
  updating it silently drops the spec. Re-list after any path change:
  `bun mobile list --platform=android`.

## Evidence in CI

- Keep `test-results/` and the HTML report as artifacts with a retention policy.
- Upload only on failure for routine PR runs; enable video/trace on demand, because a green run
  with video enabled is expensive.
- Never attach artifacts that contain credentials, cookies, or personal data.
