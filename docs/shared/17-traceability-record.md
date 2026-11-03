# 17 — Traceability record: Automation to TC

**Goal:** Every automation must be traceable back to canonical TC. Record verification in centralized checklist.

---

## What to Record

### 1. AUTOMATION-CHECKLIST-<TC-ID>.md (Centralized)

Location: `domain/[web|mobile|api]/[module]/AUTOMATION-CHECKLIST-<TC-ID>.md`

Example: `domain/web/pm/AUTOMATION-CHECKLIST-DF-M1-POS-001.md`

---

## Template: AUTOMATION-CHECKLIST

```markdown
# Automation Checklist: <TC-ID>

TC: <TC-ID> — <TC Title>
Automation engineer: [name]
Date: [YYYY-MM-DD]

## Given (Preconditions)

- [ ] PRE: [what precondition]
  - Factory: `preconditionXxx()`
  - Location: [file:line]
  - Endpoint: [POST /v1/...]
  - Status code: 201 ✓
  - DB mutation verified: ✓

## When (Actions)

- [ ] Action: [navigate/fill/click/submit]
  - Code: [file:line]
  - Selector: [data-testid="..."]
  - Grounded: // src: [codebase/file:line] ✓
  - Can fail: YES ✓

## Then/And (Expected Results)

### Then#1: [TC clause]
- [ ] Assertion: `expect(...).toBe(...)`
  - Location: [file:line]
  - Comment: // expect: <TC-ID> Then#1
  - Can fail: YES ✓
  - From TC: YES ✓
  - Tautology: NO ✓

### And#1: [TC clause]
- [ ] Assertion: `expect(...).toBe(...)`
  - Location: [file:line]
  - Comment: // expect: <TC-ID> And#1
  - Can fail: YES ✓
  - From TC: YES ✓

## Red Flag Prevention

- [ ] Tautology: NO ✓
- [ ] Swallowed error: NO ✓
- [ ] Hardcoded value: NO ✓
- [ ] DDD broken: NO ✓

## Summary

- Total TC clauses: [N]
- Assertions implemented: [N/N] ✓
- Coverage: 100% ✓
- Status: READY FOR PR ✓
```

---

### 2. Code Comments (Distributed)

Scattered dalam SPEC/USECASE/PAGE/FACTORY:

```typescript
// @covers <TC-ID>
test('...', async () => {
  // // expect: <TC-ID> Then#1
  expect(...).toBe(...)
})

// src: filepath:line (selector)
await page.fill('[data-testid="..."]', value)
```

---

### 3. Pre-push Checklist

In `docs/shared/11-pre-push-review.md`:

```
[ ] AUTOMATION-CHECKLIST-<TC-ID>.md exist?
[ ] All TC clauses covered?
[ ] Code comments (@covers, // expect:, // src:) present?
[ ] Red flags scanned (tautology, swallowed error)?
[ ] Test result: PASSED?
```

---

## Verification Process

### Phase 4: Implement

```
1. Write code (SPEC/USECASE/Layer3/FACTORY)
2. Add comments (@covers, // expect:, // src:)
3. Create AUTOMATION-CHECKLIST-<TC-ID>.md
4. Fill checklist: every TC clause → assertion mapping
5. Self-verify: can fail? meaningful? from TC?
6. Self-sign: engineer mark ✓
```

### Phase 5: Verify

```
1. Run test → PASSED (or debug + fix)
2. Verify PRE executed ✓
3. Collect evidence (video, logs)
4. Check AUTOMATION-CHECKLIST complete ✓
```

### Phase 6: PR Review

```
1. Read AUTOMATION-CHECKLIST
2. Confirm: verification done upstream ✓
3. No blocker: APPROVED
4. Merge → Automation status = true
```

---

## Red Flags in Checklist

If any of these unchecked = REQUEST_CHANGES:

```
❌ Total TC clauses ≠ Assertions implemented
   → Missing assertion for some clause

❌ Tautology: YES
   → Fix: make assertion meaningful

❌ Swallowed error: YES
   → Fix: let error propagate

❌ Hardcoded value: YES
   → Fix: use FACTORY or from TC

❌ Can fail: NO
   → Fix: assertion must be able to fail

❌ From TC: NO
   → Fix: expected value must be from TC

❌ Test result: FAILED or SKIPPED
   → Fix: run test, get PASSED only
```

---

## Sample AUTOMATION-CHECKLIST

```markdown
# Automation Checklist: DF-M1-POS-001

TC: DF-M1-POS-001 — Create employee with valid data
Automation engineer: [name]
Date: 2026-01-15

## Given (Preconditions)

- [x] PRE: Manager user exists
  - Factory: `preconditionManagerUser()`
  - Location: domain/web/pm/factories/preconditions.factory.ts:23
  - Endpoint: POST /v1/admin/seed/user
  - Status code: 201 ✓
  - DB mutation verified: users.role = 'manager' ✓

## When (Actions)

- [x] Navigate to form
  - Code: domain/web/pm/tests/create-employee.spec.ts:15
  - Selector: [data-testid="create-form"]
  - Grounded: // src: kerjaan-client-portal/src/pages/.../CreateEmployee.tsx:42 ✓

- [x] Fill name
  - Code: domain/web/pm/tests/create-employee.spec.ts:18
  - Selector: [data-testid="employee-name"]
  - Data: 'John Smith' (from TC Given) ✓

- [x] Submit
  - Code: domain/web/pm/tests/create-employee.spec.ts:21
  - Wait: networkidle ✓

## Then/And (Expected Results)

### Then#1: "Status DRAFT"
- [x] Assertion: `expect(result.status).toBe('DRAFT')`
  - Location: domain/web/pm/tests/create-employee.spec.ts:26
  - Comment: // expect: DF-M1-POS-001 Then#1 ✓
  - Can fail: YES ✓
  - From TC: YES ✓
  - Tautology: NO ✓

### Then#2: "Employee ID returned"
- [x] Assertion: `expect(result.id).toBeTruthy()`
  - Location: domain/web/pm/tests/create-employee.spec.ts:27
  - Comment: // expect: DF-M1-POS-001 Then#2 ✓
  - Can fail: YES ✓

## Red Flag Prevention

- [x] Tautology: NO ✓
- [x] Swallowed error: NO ✓
- [x] Hardcoded value: NO ✓
- [x] DDD broken: NO ✓

## Summary

- Total TC clauses: 2 (2 Then)
- Assertions implemented: 2/2 ✓
- Coverage: 100% ✓
- Status: READY FOR PR ✓

Self-reviewed by: [engineer name]
Date: 2026-01-15 ✓
```

---

## Reference

- Assertion design: `docs/shared/16-assertion-design.md`
- Pre-push review: `docs/shared/11-pre-push-review.md`
- Implementation: `workflow/04-implement.md`
- Failure reporting: `docs/shared/15-test-failure-reporting.md`
