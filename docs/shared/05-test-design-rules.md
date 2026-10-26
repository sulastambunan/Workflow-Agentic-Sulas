# 02 — Test design rules

## Source of truth

Scenarios come from the test case ledger or the ticket — never invented. If a scenario is not
traceable to a TC or an AC, put it in a separate "derived" list and get it approved before it is
counted as coverage.

## Scenario types

- **POS** — the happy path the AC promises.
- **NEG** — a stated rule is violated (validation, permission, forbidden transition).
- **No EDGE type.** Boundary/rare states are written as NEG.

Not every AC yields all types. Skip what the product cannot express instead of padding the sheet.

## One rule = one test

Split by RULE, not by field. "All invalid fields at once" is a UX scenario, not a rule test: when
it goes red you cannot tell which rule died, and the first failure masks the rest.

Two framings coexist, by level:

- A test that walks the app like a tester (`create → detail → assertions per surface`) is ONE journey.
- Within a surface, never merge two unrelated validations into one assertion block.

## Preconditions over repetition

Steps already executed once must not be re-run inside every other scenario.

- Group preconditions by STATE, not by data: `login` → `record exists` → `record + participant`
  → `record started`. Anything needing the next state cannot reuse the previous one, especially
  when the app locks configuration after leaving Draft.
- Different DATA → factory variant. Different FLOW → usecase method.
- Genuinely un-mergeable: a toggle written at creation and locked afterwards (two records),
  guards with conflicting preconditions (peer max=1 vs start guard min=2), a step that re-logs
  in as another role (must be last).

State only moves forward. Order the merged flow: negative/guard attempts first (the form stays
editable), then the happy path, then transitions, then post-transition assertions.

## Journey test shape

```ts
test('Create review → detail → edit shows saved values', async () => {
  const created = await test.step('create', () => usecase.create(input));
  const detail = await test.step('open detail', () => usecase.readDetail(created.id));

  expect.soft(detail.status, 'status after create').toBe('DRAFT');
  expect.soft(detail.title, 'title persisted').toBe(input.title);
});
```

- `test.step` names the stage so a red run reads as a journey step, not a line number.
- `expect.soft` reports every checkpoint together and still fails the test.
- Compare a whole surface with `toMatchObject` (subset match; long text via `stringContaining`).
- Prove the shared contract once (tabs/columns/empty state), later journeys assert only their delta.

## Traceability when a test covers many TCs

- One test covering several TCs loses per-TC pass/fail: wrap each in
  `test.step('<TC-ID> — <title>')` and keep the `@covers` list.
- Near-identical TCs = N thin tests plus ONE shared journey function — never a `for` loop over a
  data table. A templated `// @covers ${id}` is invisible to the grep the reviewer and the ledger use.

## Honest coverage

- `manual` + `automationRef: null` for what cannot be automated (third-party e-signature,
  server-side fault injection, inbox-only verification).
- `partial` when the flow is drivable but part of the Then cannot be machine-verified
  (email dispatch, wet signature). Name which half is covered and how the rest is evidenced.
- Never leave a skipped test claiming coverage. A red `test.fail()` proving a real product bug is
  a green script, not a conforming feature — say that out loud.

## Assertion fidelity to the ledger

Assertion bukan "yang penting ada expect". Setiap assertion harus bisa ditelusuri ke satu baris
`## Expected Results` di TC.

- Satu klaim Then/And = satu checkpoint yang bisa gagal sendiri.
- Jangan memparafrase klaim menjadi assertion yang lebih longgar (mis. TC minta teks error persis,
  test hanya mengecek status 200).
- Jangan meng-assert nilai yang ditulis oleh test itu sendiri (data buatan test bukan bukti app).
- Klaim yang tidak bisa dibuktikan harness → jangan dihapus diam-diam: pindahkan TC ke `partial`
  dan sebutkan di `## Notes / Gaps`.
- Test yang meng-cover beberapa TC: tulis semua ID di `@covers` (boleh berurutan), dan pastikan
  tiap TC punya minimal satu checkpoint yang mewakilinya.

Kalau app berperilaku beda dari TC, berhenti dan angkat ke manusia (lihat `docs/shared/02-ledger-contract.md`,
bagian "Kalau implementasi dev berbeda dari TC") — jangan menyesuaikan assertion sendiri.

## Before writing assertions

Probe the app first. A doc rule like "Title > 50 rejected" may be an HTML `maxlength` (the bad
value cannot even be typed) or an on-submit server check. Write the assertion the app can actually
express — the attribute, or the field error after submit. A test that cannot fail is worse than no test.

Matcher semantics worth verifying with a throwaway probe before trusting them: `expect.soft`
(all failures reported, test still fails), `toMatchObject` (subset, arrays still strict, new field
tolerated), `stringMatching` nested inside an object.
