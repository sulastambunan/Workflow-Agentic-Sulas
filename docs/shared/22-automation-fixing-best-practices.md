# 22 — Automation Fixing: Best Practices for Runtime Failures

**Goal:** When automation fails at runtime, systematically diagnose and fix using canonical TC as source of truth.

---

## 🚨 Critical Principle

```
Automation failures have 3 possible causes:

1. ❌ TEST CODE/SETUP BUG
   → Fix automation code + setup/data
   → Keep TC unchanged (TC is correct)

2. ❌ TC DIFFERS FROM IMPLEMENTATION
   → Document difference clearly
   → Decide: update TC or product defect?
   → Don't silently accept wrong result

3. ⚠️ PRODUCT DEFECT
   → Keep TC (TC requirement correct)
   → Report product bug with evidence
   → Block automation until fixed
   → Don't make test "pass" by accepting defect

NEVER: Make test pass by changing expected value to match wrong result ❌
```

---

## 10 Best Practices for Automation Fixing

### **1️⃣ Run Actual Scenarios, Not Just Checks**

❌ **WRONG:**
```bash
npm run lint
npm run type-check
npm run test -- --collect-only  # Just collect, no execute
```

✅ **RIGHT:**
```bash
npm test -- create-employee.spec.ts --project=chromium
# Actually run, watch it execute, see what happens
```

**Why:** Type-check passes ≠ automation works. Only real execution reveals runtime issues.

---

### **2️⃣ Run Sequentially, No Retry, Stop at First Failure**

❌ **WRONG:**
```bash
npm test -- create-employee.spec.ts --retries=3  # Retry failures
npm test -- --parallel=4  # Run in parallel, hide failures
```

✅ **RIGHT:**
```bash
npm test -- create-employee.spec.ts  # Single run, sequential
# First failure: STOP, diagnose, fix
# Then rerun
```

**Why:** 
- Retries hide flaky tests (band-aid, not fix)
- Parallel runs hide order/state dependencies
- First failure is where the real problem is

---

### **3️⃣ When Test Fails: Open TC and Document**

**Step 1: Open canonical TC from staffinc-testcase**

```markdown
# Test Case: DF-M1-POS-001

TC Location: staffinc-testcase/testcase/web/pm/DF-M1-POS-001.md

**Given (Preconditions):**
- Manager user exists
- Form endpoint available

**When (Actions):**
1. Navigate to /pm/employees/create
2. Fill name = 'John Smith'
3. Fill email = 'john@test.co'
4. Click submit

**Then (Expected):**
- Record created in DB
- Status = DRAFT (from requirement)
- Employee ID returned
```

**Step 2: Document failure context**

```markdown
# Failure Report: DF-M1-POS-001

## Runtime Failure

**Test:** @covers DF-M1-POS-001
**Failure:** Expected status = 'DRAFT', got 'PENDING'
**Error:** AssertionError: expect(status).toBe('DRAFT')

## Reproduction

### Preconditions (from TC Given):
- [✓] Manager user: email=mgr-123@test.co, id=user_456
- [✓] Form endpoint: GET /v1/pm/create-form → 200 OK
- [✓] DB state: clean, no existing records

### Reproduction Steps (from TC When):
1. Navigate: http://localhost:3000/pm/employees/create
   Result: Form loaded ✓
2. Fill name: 'John Smith'
   Observed: Input shows 'John Smith' ✓
3. Fill email: 'john@test.co'
   Observed: Input shows 'john@test.co' ✓
4. Click submit button
   Observed: Form submitted, HTTP 201 received ✓

### Expected (from TC Then):
```json
{
  "id": "emp_xxx",
  "status": "DRAFT",
  "name": "John Smith",
  "createdBy": "mgr-123"
}
```

### Actual (from runtime):
```json
{
  "id": "emp_789",
  "status": "PENDING",    // ❌ WRONG: should be DRAFT
  "name": "John Smith",
  "createdBy": "mgr-123"
}
```

### Error Details:
```
Error: expect(status).toBe('DRAFT')
Expected: 'DRAFT'
Actual: 'PENDING'
Location: create-employee.spec.ts:26
```

### Evidence:
- Screenshot: outputs/evidence/failure-screenshot.png
- Video: outputs/evidence/failure-video.webm
- Logs: outputs/logs/test-failure.log
```

---

### **4️⃣ Trace Codebase to Find Explanation**

**Compare TC requirement with actual implementation:**

```
TC Expected: status = 'DRAFT'
Actual: status = 'PENDING'

Where does status get set?
→ Search codebase for "PENDING"
```

**Search & find:**

```
$ grep -r "PENDING" domain/web/pm/
domain/web/pm/usecases/create-employee.usecase.ts:42
  if (request.source === 'import') {
    employee.status = 'PENDING'  // ← HERE!
  } else {
    employee.status = 'DRAFT'
  }
```

**Analyze:**

```markdown
## Code Trace

### File: domain/web/pm/usecases/create-employee.usecase.ts:42

```typescript
export class CreateEmployeeUsecase {
  async execute(data: EmployeeInput) {
    const employee = new Employee(data)
    
    // Line 42: Status logic
    if (request.source === 'import') {
      employee.status = 'PENDING'  // ← Bug: where does 'request' come from?
    } else {
      employee.status = 'DRAFT'
    }
    
    await db.employees.insert(employee)
    return employee
  }
}
```

### Issue Found:

Line 42 checks `request.source === 'import'` but:
- TC Given: User = manager (manual creation via UI)
- Code: request.source is NOT passed from UI layer
- Result: request.source is undefined
- Fallback: `undefined === 'import'` is FALSE
- Expected path taken: else → status = 'DRAFT'
- BUT: Actual status = 'PENDING'

Hmm, logic says should be DRAFT, but actual is PENDING. Let me check PAGE layer.
```

**Continue tracing:**

```
$ grep -r "'PENDING'" domain/web/pm/
domain/web/pm/pages/create-employee.page.ts:85
domain/web/pm/usecases/create-employee.usecase.ts:42
domain/web/pm/factories/employee-data.factory.ts:12  // ← Suspicious!
```

**Found it:**

```typescript
// domain/web/pm/factories/employee-data.factory.ts:12
export function generateEmployee(overrides = {}) {
  return {
    name: faker.person.fullName(),
    email: faker.internet.email(),
    status: 'PENDING',  // ← HARDCODED! Overrides usecase logic!
    ...overrides
  }
}
```

**Root Cause:** FACTORY hardcodes status = 'PENDING', overriding usecase logic.

---

### **5️⃣ Distinguish the Cause**

**Is it automation/setup/data issue?**

```
✓ YES: Factory hardcodes wrong status
  → Fix: Remove hardcoded status from factory
  → FACTORY should NOT set status (let USECASE decide)
  → Scope: Automation code fix (within approval)
```

**OR is TC different from implementation?**

```
✗ NO: This is not a TC vs implementation mismatch
  - TC says: status should be DRAFT
  - Implementation says: status should be DRAFT
  - Factory says: status = PENDING (BUG in automation code)
```

**OR is it a product defect?**

```
✗ NO: Product code is correct (USECASE sets DRAFT)
  - Automation code (FACTORY) is wrong
```

---

### **6️⃣ After Fixing: Rerun Failed Scenario FIRST**

**Fix applied:**

```typescript
// domain/web/pm/factories/employee-data.factory.ts:12
export function generateEmployee(overrides = {}) {
  return {
    name: faker.person.fullName(),
    email: faker.internet.email(),
    // REMOVED: status: 'PENDING'  ← Now usecase decides
    ...overrides
  }
}
```

**Rerun ONLY the failed scenario:**

```bash
npm test -- create-employee.spec.ts --grep "@covers DF-M1-POS-001"
# NOT: Run all tests yet
# WAIT: Verify this ONE scenario passes first
```

**Result:**

```
✓ Create employee with valid data -> created (45.2s)
✓ Status: DRAFT ✓
✓ ID: emp_123 ✓

→ This scenario FIXED
```

**Only THEN run next scenario:**

```bash
npm test -- create-employee.spec.ts --grep "@covers DF-M1-NEG-001"
# Continue with next test
```

---

### **7️⃣ Don't Ask User to Debug What Runtime/Codebase Shows**

❌ **WRONG:**
```
Q: "Why is status PENDING instead of DRAFT? 
    I don't know, can you check?"
```

✅ **RIGHT:**
```
Found: FACTORY hardcodes status='PENDING' (file:line)
       but TC expects DRAFT (per usecase logic)
Cause: Line 12 of employee-data.factory.ts
Fix: Removed hardcoded status, let USECASE decide
Rerun: PASSED ✓
```

**Only ask user when:**
- ❓ Requirement decision: "TC says DRAFT, code says PENDING. Which is correct?"
- ❓ Access/data unavailable: "Need test account in STG to continue"
- ❓ Permission: "Need access to staging environment"

---

### **8️⃣ Distinguish Local vs Deployed Code**

**When reporting:** Always mention version

```markdown
## Test Environment

**Local Code:**
```bash
git status
# On branch feature/create-employee-automation
# HEAD: 3a1bc2f (fix: remove hardcoded status in factory)
```

**Deployed Code (STG):**
```bash
curl https://stg.api.hcm.internal/version
# {"version": "v2.1.4", "deployedAt": "2026-11-03 10:00 UTC"}
```

**Note:** Local code is 1 commit ahead of deployed.
- Local: Fix applied ✓
- STG: Still old code (fix not deployed yet)
```

**Why:** Local pass ≠ STG pass. Must test both.

---

### **9️⃣ Separate Reporting: What's Fixed vs What's Blocked**

❌ **WRONG:**
```
"Fixed all issues! Automation ready!"
(But actually: only local tests pass, STG not tested, 3 other scenarios not run)
```

✅ **RIGHT:**
```markdown
## Status Report

### ✓ FIXED
- Scenario DF-M1-POS-001: status issue
  - Root cause: Factory hardcoded status='PENDING'
  - Fix: Removed hardcoding
  - Local rerun: PASSED ✓
  - STG: NOT YET (deploy pending)

### ⏳ BLOCKED
- Scenario DF-M1-POS-002: Not run yet (waiting for DF-M1-POS-001 fix)
- Scenario DF-M1-NEG-001: Not run yet
- STG verification: Waiting for deploy to staging

### 📊 Progress
- Scenarios fixed: 1/3
- Local verified: 1/3
- STG verified: 0/3
- Ready for PR: NO (need STG verification)
```

---

### **🔟 Deployment Still Needs Separate Permission**

```
Local test pass ✓
  → "Can I deploy?"
  → NO, need deploy permission

Automation fix in code ✓
  → "Can I merge PR?"
  → YES (if review approved)

Code merged to main ✓
  → "Can I deploy?"
  → Separate question, separate permission needed
```

---

## 📋 Automation Fixing Checklist

```
Test Failure:
[ ] Run actual scenario (not just type-check)
[ ] Scenario fails? STOP at first failure
[ ] Open canonical TC
[ ] Document: preconditions, steps, expected, actual, error
[ ] Search codebase: trace where issue originates
[ ] Find exact file:line of the problem
[ ] Understand cause: code bug? TC mismatch? product defect?

Fix Applied:
[ ] Fix code (in automation or product?)
[ ] Rerun ONLY the failed scenario
[ ] Scenario now passes? ✓
[ ] Update AUTOMATION-CHECKLIST
[ ] Commit with clear message

Next Scenario:
[ ] Continue with next failed scenario
[ ] OR run full suite if previous fixed
[ ] Report separately: fixed vs blocked

Before PR:
[ ] All scenarios run locally? ✓
[ ] All pass locally? ✓
[ ] STG version tested? ✓
[ ] STG environment confirmed? ✓
[ ] AUTOMATION-CHECKLIST updated? ✓
[ ] Ready for review? ✓
```

---

## 🎯 Key Discipline

```
NEVER:
  ❌ Retry tests to hide failures
  ❌ Ignore TC and accept wrong result
  ❌ Silently change expected value
  ❌ Deploy local-only fixes
  ❌ Merge without STG verification

ALWAYS:
  ✅ Compare code against TC (source of truth)
  ✅ Run scenarios sequentially, stop at first fail
  ✅ Trace root cause in codebase
  ✅ Report: what's fixed, what's blocked, what's tested
  ✅ Test both locally AND in STG before PR
```

---

## References

- **20-fix-pr-from-feedback.md** — Fixing after PR review
- **17-traceability-record.md** — AUTOMATION-CHECKLIST tracking
- **14-executability-principle.md** — Understanding layers
- **21-environment-confirmation-stg.md** — STG testing after local
