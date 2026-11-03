# 20 — Fix PR from Feedback: Fixing Automation After PR Review Comments

**Goal:** When PR review finds issues, systematically fix based on feedback and re-verify before merging.

---

## 🔄 Scenario: PR Review → REQUEST_CHANGES → Fix → Merge

```
PR Submitted (automation engineer)
  ↓
PR Review Runs (lead/QA with automation-pr-review skill)
  ↓
Review Result: REQUEST_CHANGES ⚠️
  ├─ Finding 1: Missing assertion for TC clause
  ├─ Finding 2: Hardcoded value in FACTORY
  ├─ Finding 3: Swallowed error in USECASE
  └─ Finding 4: Precondition not executed
  ↓
Engineer Fixes Issues
  ├─ Fix assertion
  ├─ Remove hardcoded
  ├─ Propagate error
  ├─ Execute PRE
  └─ Re-run test
  ↓
Engineer Re-checks AUTOMATION-CHECKLIST
  ├─ All TC clauses covered? ✓
  ├─ Red flags scanned? ✓
  ├─ Test PASSED? ✓
  └─ Status: Ready for re-review
  ↓
Engineer Pushes Fix Commit
  ↓
Lead Re-reviews
  ↓
Decision: APPROVED → Merge
```

---

## Step 1: Read PR Review Feedback

**What you receive:**

```
PR Review Result: REQUEST_CHANGES

Finding #1: MISSING ASSERTION
  Layer: SPEC
  Line: 26
  Message: "TC Then#1 'Status DRAFT' has no assertion"
  Reference: docs/shared/16-assertion-design.md
  Action: Add assertion for status == DRAFT

Finding #2: HARDCODED VALUE
  Layer: FACTORY
  Line: 45
  Message: "Email hardcoded 'test@test.co', must use faker"
  Reference: docs/shared/16-assertion-design.md#Rule-3
  Action: Use faker.internet.email()

Finding #3: SWALLOWED ERROR
  Layer: USECASE
  Line: 78
  Message: ".catch(() => false) hides error"
  Reference: docs/shared/16-assertion-design.md#Rule-2
  Action: Let error propagate with context

Finding #4: PRECONDITION NOT EXECUTED
  Layer: SPEC
  Line: 12
  Message: "PRE called but no assertion verify success"
  Reference: docs/shared/14-executability-principle.md
  Action: Add expect(preResult.id).toBeTruthy()
```

---

## Step 2: Categorize Issues by Layer

**Group findings by DDD layer:**

### **FACTORY Issues** (Data generation)

```
Finding #2: Hardcoded email
  File: domain/web/pm/factories/employee-data.factory.ts:45
  Current: const email = 'test@test.co'
  Fix: const email = faker.internet.email()
  Reason: Data must be varied, not hardcoded
  Reference: docs/shared/16-assertion-design.md#Rule-3
```

### **USECASE Issues** (Business logic)

```
Finding #3: Swallowed error
  File: domain/web/pm/usecases/create-employee.usecase.ts:78
  Current: .catch(() => false)
  Fix: .catch(e => { throw new Error(`Create failed: ${e.message}`) })
  Reason: Error must propagate, not hide
  Reference: docs/shared/16-assertion-design.md#Rule-2
```

### **SPEC Issues** (Test assertions)

```
Finding #1: Missing assertion
  File: domain/web/pm/tests/create-employee.spec.ts:26
  Missing: expect(result.status).toBe('DRAFT')
  TC Clause: Then#1 "Status must be DRAFT"
  Reason: Every TC clause must have corresponding assertion
  Reference: docs/shared/16-assertion-design.md#Rule-1

Finding #4: Precondition not verified
  File: domain/web/pm/tests/create-employee.spec.ts:12
  Missing: expect(preResult.id).toBeTruthy()
  Reason: Precondition execution must be asserted
  Reference: docs/shared/14-executability-principle.md
```

---

## Step 3: Fix Each Issue

### **Fix #1: Add Missing Assertion (SPEC)**

**Before:**
```typescript
test('@covers DF-M1-POS-001', async () => {
  const data = generateEmployee()
  const result = await usecase.execute(data)
  
  expect(result.id).toBeTruthy()
  // Missing: expect(result.status).toBe('DRAFT')
})
```

**After:**
```typescript
test('@covers DF-M1-POS-001', async () => {
  const data = generateEmployee()
  const result = await usecase.execute(data)
  
  // // expect: DF-M1-POS-001 Then#1
  expect(result.status).toBe('DRAFT')
  
  // // expect: DF-M1-POS-001 Then#2
  expect(result.id).toBeTruthy()
})
```

**Commit message:**
```
test: add missing assertion for DF-M1-POS-001 Then#1 (status = DRAFT)

- Added expect(result.status).toBe('DRAFT')
- Comment: // expect: DF-M1-POS-001 Then#1
- From TC: staffinc-testcase/testcase/web/pm/DF-M1-POS-001.md
- Fixes: PR review finding #1
```

---

### **Fix #2: Remove Hardcoded Value (FACTORY)**

**Before:**
```typescript
export function generateEmployee(overrides = {}) {
  return {
    name: faker.person.fullName(),
    email: 'test@test.co',  // ❌ Hardcoded
    phone: faker.phone.number(),
    ...overrides
  }
}
```

**After:**
```typescript
export function generateEmployee(overrides = {}) {
  return {
    name: faker.person.fullName(),
    email: faker.internet.email(),  // ✅ Varied per run
    phone: faker.phone.number(),
    ...overrides
  }
}
```

**Commit message:**
```
refactor: replace hardcoded email with faker.internet.email()

- Changed: email from 'test@test.co' to faker.internet.email()
- Reason: Data must be varied, not hardcoded (red flag prevention)
- Reference: docs/shared/16-assertion-design.md#Rule-3
- Fixes: PR review finding #2
```

---

### **Fix #3: Propagate Error (USECASE)**

**Before:**
```typescript
export class CreateEmployeeUsecase {
  async execute(data: EmployeeInput) {
    try {
      const res = await http.post('/v1/employees', data)
      return res.json()
    } catch (e) {
      console.log(e)  // ❌ Swallowed error
      return { success: false }
    }
  }
}
```

**After:**
```typescript
export class CreateEmployeeUsecase {
  async execute(data: EmployeeInput) {
    try {
      const res = await http.post('/v1/employees', data)
      if (!res.ok()) {
        throw new Error(`API error: ${res.status()}`)
      }
      return res.json()
    } catch (e) {
      // ✅ Error propagates with context
      throw new Error(`Create failed: ${e.message}`)
    }
  }
}
```

**Commit message:**
```
fix: propagate error instead of swallowing in create employee usecase

- Removed: console.log() + silent return
- Added: Explicit error with context message
- Changed: .catch() now throws instead of returns false
- Reason: Errors must propagate for visibility (red flag prevention)
- Reference: docs/shared/16-assertion-design.md#Rule-2
- Fixes: PR review finding #3
```

---

### **Fix #4: Verify Precondition Execution (SPEC)**

**Before:**
```typescript
test('@covers DF-M1-POS-001', async () => {
  const user = await preconditionManagerUser()  // PRE called but not verified
  
  const data = generateEmployee()
  const result = await usecase.execute(data)
  
  expect(result.id).toBeTruthy()
})
```

**After:**
```typescript
test('@covers DF-M1-POS-001', async () => {
  // PRE must execute successfully (asserted)
  const user = await preconditionManagerUser()
  expect(user.id).toBeTruthy()  // ✅ Verify PRE worked
  expect(user.role).toBe('manager')
  
  const data = generateEmployee()
  const result = await usecase.execute(data)
  
  expect(result.id).toBeTruthy()
})
```

**Commit message:**
```
test: add precondition execution verification for DF-M1-POS-001

- Added: expect(user.id).toBeTruthy() after PRE
- Added: expect(user.role).toBe('manager')
- Reason: Precondition must be verified before scenario (executability)
- Reference: docs/shared/14-executability-principle.md
- Fixes: PR review finding #4
```

---

## Step 4: Update AUTOMATION-CHECKLIST

**After fixes, update the AUTOMATION-CHECKLIST-<TC-ID>.md:**

```markdown
# Automation Checklist: DF-M1-POS-001

## Fixes Applied (from PR review)

- [x] Fix #1: Added assertion for status = DRAFT (line 26)
- [x] Fix #2: Removed hardcoded email, use faker (employee.factory.ts:45)
- [x] Fix #3: Propagate error in usecase (create-employee.usecase.ts:78)
- [x] Fix #4: Added PRE verification (line 12)

## Updated Assertions

### Then#1: Status = DRAFT
- [x] Assertion: expect(result.status).toBe('DRAFT')
- [x] Location: create-employee.spec.ts:26
- [x] Comment: // expect: DF-M1-POS-001 Then#1
- [x] Can fail? YES ✓
- [x] From TC? YES ✓
- [x] Fixed: Was missing, now added ✓

### PRE Verification
- [x] Assertion: expect(user.id).toBeTruthy()
- [x] Location: create-employee.spec.ts:12
- [x] Can fail? YES ✓
- [x] Fixed: Was not verified, now explicit ✓

## Status

- Red flags checked: 0 ✓
- All TC clauses: 3/3 ✓
- Test result: PASSED ✓
- Ready for re-review: YES ✓

Updated by: [engineer name]
Date: [YYYY-MM-DD]
PR Review feedback incorporated: ALL ✓
```

---

## Step 5: Run Test Again

**Verify all fixes work:**

```bash
# Run test
npm test -- create-employee.spec.ts

# Expected output:
# ✓ Create employee with valid data -> created (42.3s)
# 1 passed

# If FAILED:
# - Read error message
# - Identify which fix didn't work
# - Debug + re-run
# - Update AUTOMATION-CHECKLIST with new finding
```

---

## Step 6: Create Fix Commit

**Bundle all fixes in one commit:**

```bash
# Stage all changed files
git add domain/web/pm/tests/create-employee.spec.ts
git add domain/web/pm/usecases/create-employee.usecase.ts
git add domain/web/pm/factories/employee-data.factory.ts
git add domain/web/pm/AUTOMATION-CHECKLIST-DF-M1-POS-001.md

# Commit with clear message referencing PR review
git commit -m "fix: address PR review findings for DF-M1-POS-001

- Fix #1: Add assertion for status = DRAFT (missing Then#1)
- Fix #2: Replace hardcoded email with faker.internet.email()
- Fix #3: Propagate error instead of swallowing in usecase
- Fix #4: Verify precondition execution in test
- Updated: AUTOMATION-CHECKLIST-DF-M1-POS-001.md with fixes

All PR review findings addressed. Test passing. Ready for re-review.

Reference: https://github.com/.../pull/123/files#r123456789
"
```

---

## Step 7: Push & Re-request Review

```bash
# Push fix commit to same PR branch
git push origin feature/create-employee-automation

# GitHub will automatically:
# - Show new commit in PR
# - Mark previous review as stale
# - Ready for lead to re-review
```

**Comment on PR:**

```markdown
@lead-reviewer

All findings from PR review #1 addressed:

✅ Fix #1: Added assertion for status = DRAFT
   - Commit: abc1234
   - File: create-employee.spec.ts:26

✅ Fix #2: Replaced hardcoded email with faker
   - Commit: abc1234
   - File: employee-data.factory.ts:45

✅ Fix #3: Propagated error in usecase
   - Commit: abc1234
   - File: create-employee.usecase.ts:78

✅ Fix #4: Added PRE verification
   - Commit: abc1234
   - File: create-employee.spec.ts:12

Test re-run: PASSED ✓
AUTOMATION-CHECKLIST updated: YES ✓

Ready for re-review.
```

---

## Step 8: Lead Re-reviews

**Lead reviewer:**

1. ✅ Reads new commit
2. ✅ Verifies each fix addresses finding
3. ✅ Runs automation-pr-review skill again (optional, should pass)
4. ✅ Decision: APPROVED
5. ✅ Merges PR

---

## 📋 Checklist: Fixing PR from Feedback

```
Issues Received:
[ ] All findings read and understood?
[ ] Categorized by layer (FACTORY/USECASE/SPEC)?
[ ] Priority determined (blocker vs nice-to-have)?

Each Fix:
[ ] Issue understood (what + why)?
[ ] Root cause fixed (not just symptom)?
[ ] Code tested (test still passes)?
[ ] Comment added (reference to finding)?
[ ] AUTOMATION-CHECKLIST updated?

Before Re-review:
[ ] All findings addressed?
[ ] Test PASSED?
[ ] No new issues introduced?
[ ] Commit message clear?
[ ] Push to same PR branch?
[ ] Comment on PR requesting re-review?
```

---

## 🎯 Key Points

```
✅ Fixes are UPSTREAM PREVENTION applied DOWNSTREAM
   - Should have been caught at Phase 4 (Implement)
   - But caught at Phase 6 (PR Review)
   - Still better than production bug!

✅ Each fix must be TRACEABLE to PR finding
   - Commit message references finding
   - Code comment references TC + finding
   - AUTOMATION-CHECKLIST updated

✅ No band-aids
   - Fix ROOT cause, not symptom
   - Don't just make test pass
   - Make test meaningful per TC

✅ Re-run test AFTER each fix
   - Don't assume fix works
   - Verify with actual execution
```

---

## References

- **16-assertion-design.md** — Why each fix matters (rules)
- **14-executability-principle.md** — Why PRE must be verified
- **17-traceability-record.md** — AUTOMATION-CHECKLIST update
- **skills/automation-pr-review/SKILL.md** — Where findings come from
