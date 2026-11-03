# 15 — Test failure reporting: Detailed error debugging

**Goal:** Ketika test gagal, error harus dilaporkan dengan detail lengkap dan actionable, bukan generic "test failed". Setiap failure harus traceable ke TC, layer, dan root cause yang jelas.

---

## Rule Utama

1. **Gagal = Detail.** Error message, stack trace, screenshot, video — semuanya harus attached.
2. **Layer identification.** Harus jelas: PRE fail? FACTORY fail? USECASE fail? Layer 3 fail? SPEC assertion fail?
3. **@covers TC-ID required.** Error harus link ke TC yang sedang dijalankan.
4. **Root cause analysis.** "Kenapa gagal?" harus dijawab, bukan diabaikan.
5. **Decision tree.** Kalau gagal, apa action yang harus diambil? Tetap terstruktur.
6. **No silent failures.** Tidak ada exception ditelan, tidak ada tautology, tidak ada assertion semu.

---

## Failure Report Format (Standard)

```
════════════════════════════════════════════════════════════════
TEST FAILURE REPORT
════════════════════════════════════════════════════════════════

@covers: [TC-ID] — [TC Title]
Module: [module-name]
Environment: [dev|stg]
Timestamp: [YYYY-MM-DD HH:mm:ss]
Duration: [XX.XXs]

WHICH LAYER FAILED?
  Layer: [SPEC | USECASE | Layer3-PAGE | Layer3-COMPONENT | FACTORY | PRE]
  Severity: [BLOCKER | MAJOR | MINOR]

TEST STEP SEQUENCE:
  ✅ PRE: setup manager user — PASSED (2.3s)
  ✅ SPEC.step('Navigate'): goto('/form') — PASSED (1.1s)
  ✅ SPEC.step('Fill form'): fillName('John') — PASSED (0.8s)
  ❌ SPEC.step('Submit'): clickSubmit() — FAILED (timeout 30s)
  ⏹️  SPEC.step('Verify'): checkStatus() — NOT EXECUTED

ERROR MESSAGE:
  Timeout 30000ms exceeded.
  Waiting for locator('button:has-text("Submit")').click()
  
SELECTOR/ENDPOINT INVOLVED:
  button:has-text("Submit")
  Expected to exist: yes
  Actually found: no
  Waited: 30000ms
  Element visible: no

ROOT CAUSE ANALYSIS:
  Layer 3 PAGE.submitForm() — Selector not found in DOM
  
  Expected selector (from code):
    domain/web/pm/pages/create-employee.page.ts:42
    await page.click('button:has-text("Submit")')
    // src: kerjaan-client-portal/src/pages/CreateEmployee.tsx:52
  
  Actual selector (from live inspection):
    button:has-text("Save & Continue")
    (button text berbeda!)
  
  Analysis:
    ❌ Grounding phase found: "Submit"
    ✅ Live DOM shows: "Save & Continue"
    → Selector outdated atau app changed

DECISION POINT:
  Option A: Fix selector di PAGE layer
    └─ Command: grep -r "Save & Continue" kerjaan-client-portal/src/
    └─ Verify: re-ground selector dengan app terbaru
    └─ Update: pages/create-employee.page.ts:42
  
  Option B: Re-check grounding
    └─ App berubah sejak grounding phase?
    └─ Re-ground TC scenario terhadap app terbaru
  
  Option C: Escalate
    └─ UI text mismatch TC expected vs actual
    └─ Decision: TC salah atau app berubah?

EVIDENCE ATTACHED:
  Screenshot: outputs/evidence/2025-01-15/PM-C-001__create-employee__submit-fail.png
             (Shows DOM state saat selector tidak ketemu)
  
  Video: outputs/evidence/2025-01-15/PM-C-001__create-employee__submit-fail.webm
         (Shows full flow sampai timeout)
  
  Browser console:
    Network: No failed requests before timeout
    Console: No JS errors
    Performance: All steps executed normally until submit button

RUN INFORMATION:
  Command: playwright test domain/web/pm/tests/create-employee.spec.ts -g "PM-C-001"
  Browser: chromium v130.0.6723.119
  OS: darwin (macOS)
  Node: v20.11.0
  Playwright: 1.48.0

ENVIRONMENT DETAILS:
  URL: https://dev-staffinc.local
  Database: dev postgres (seeded this run)
  Cache: cleared before test
  Network: stable (no timeouts observed elsewhere)

═══════════════════════════════════════════════════════════════
ACTION REQUIRED: [BLOCKED | NEEDS DECISION | FIX REQUIRED]
Assignee: [automation-engineer | QA-lead | developer]
═══════════════════════════════════════════════════════════════
```

---

## Failure Types & Diagnosis

### **Type 1: PRE (Precondition) Failed**

```
@covers: DF-M1-POS-001
WHICH LAYER FAILED? PRE (Precondition Setup)

ERROR:
  POST /v1/admin/seed/user HTTP 500
  Response body: {
    "error": "Database connection timeout",
    "code": "DB_TIMEOUT"
  }

ROOT CAUSE:
  Precondition endpoint tidak responding di environment
  
  Endpoint: hcmsvc/internal/admin/handler.go:234
  // src: hcmsvc/internal/admin/handler.go:234
  
  Expected: HTTP 201, users row inserted
  Actual: HTTP 500, no data inserted

DATABASE STATE:
  Before: users table — 42 rows
  After: users table — 42 rows (no insert)
  Conclusion: PRE mutation did NOT happen

DECISION NEEDED:
  ❌ PRE BLOCKED — Cannot proceed to test scenario
  ❌ TC STATUS REMAINS: planned (NOT automated)
  
  Action items:
    1. Check database connection in [environment]
    2. Check /v1/admin/seed/user endpoint uptime
    3. Retry PRE after environment fixed
    4. Only then try test scenario

NEVER:
  ❌ Skip PRE and "assume" it worked
  ❌ Use hardcoded user ID yang mungkin sudah exist
  ❌ Mark TC as "automated" kalau PRE tidak setup
```

### **Type 2: FACTORY Data Invalid**

```
@covers: DF-M1-POS-002
WHICH LAYER FAILED? FACTORY (Test Data Generation)

ERROR:
  Data validation failed during INSERT:
  
  INSERT INTO employees (name, email, role)
  VALUES ('John Doe', 'john@test', 'employee')
  
  Error: Invalid email format 'john@test'
  Constraint: email LIKE '%@%.%'

FACTORY CODE:
  domain/web/pm/factories/employee-data.factory.ts:28
  
  export function generateEmployee(overrides = {}) {
    return {
      name: faker.person.fullName(),
      email: faker.internet.email(),  ← Generated invalid: "john@test"
      role: 'employee',
      ...overrides
    }
  }

DATA GENERATED (Attempt #1):
  name: "John Doe" ✓
  email: "john@test" ✗ (invalid format)
  role: "employee" ✓

ROOT CAUSE:
  faker.internet.email() occasionally generates invalid format
  (Unlikely but possible with certain seed values)

DECISION:
  Option A: Retry test
    └─ FACTORY failure di 1 attempt = usually one-off
    └─ Run test again, sama FACTORY generate data lagi
  
  Option B: Enhance FACTORY validation
    └─ Add validator sebelum return data
    └─ Validate email format sebelum INSERT
  
  Option C: Use static test data
    └─ Replace faker dengan hardcoded valid data
    └─ Trade-off: less variety, more reliability

RECOMMENDATION:
  Retry test dulu (one-off failure kemungkinan besar)
  Jika terjadi 2+ kali, enhance FACTORY validator
```

### **Type 3: USECASE Logic Error**

```
@covers: DF-M1-POS-003
WHICH LAYER FAILED? USECASE (Business Logic)

ERROR:
  CreateEmployeeUsecase.execute() returned:
  {
    success: false,
    error: "Validation failed: email already exists"
  }

USECASE CODE:
  domain/web/pm/usecases/create-employee.usecase.ts:15
  
  async execute(data: EmployeeInput): Promise<UsecaseResult> {
    const existing = await query('SELECT * FROM employees WHERE email=?', data.email)
    if (existing.length > 0) {
      return createErrorResult('Validation failed: email already exists')
    }
    const result = await http.post('/v1/employees', data)
    return { success: true, data: result.data }
  }

CALL SEQUENCE:
  ✅ FACTORY.generateEmployee()
     └─ Generated: { name: "John Doe", email: "john@test.co" }
  
  ❌ USECASE.execute(data)
     └─ Check: email "john@test.co" already exists in DB
     └─ Return: error (did not call HTTP endpoint)

ROOT CAUSE OPTIONS:
  
  Option A: Database contamination
    └─ DB tidak dibersihkan antara test run
    └─ Email "john@test.co" dari test sebelumnya masih exist
    └─ Solution: Clean DB before each test run
  
  Option B: FACTORY reuse
    └─ Same FACTORY instance reused across tests
    └─ Solution: Generate fresh data per test
  
  Option C: USECASE validation wrong
    └─ Validation rule tidak sesuai TC expected behavior
    └─ Solution: Review TC, check if "email exists" check is expected

DECISION TREE:
  1. Check: TC expected behavior apa?
     └─ TC bilang: "Create dengan email unik" → OK (error is expected)
     └─ TC bilang: "Create langsung dengan email any" → FAIL (validation wrong)
  
  2. Check: Database state
     └─ SELECT COUNT(*) FROM employees WHERE email='john@test.co'
     └─ If > 0: Database contamination
     └─ If = 0: Something else wrong
  
  3. Check: FACTORY consistency
     └─ Every call generateEmployee() should return unique email
     └─ If not: FACTORY returns same email

NEXT STEPS:
  If validation expected: Mark test as PASSED (error is correct)
  If validation unexpected: Fix USECASE or DB cleanup
```

### **Type 4: Layer 3 (PAGE/COMPONENT) Failed**

```
@covers: DF-M1-POS-004
WHICH LAYER FAILED? Layer 3 — PAGE (UI Interaction)

ERROR:
  Timeout 30000ms exceeded.
  page.fill('[data-testid="employee-name"]')
  
  Element: [data-testid="employee-name"]
  Status: NOT FOUND

PAGE CODE:
  domain/web/pm/pages/create-employee.page.ts:42
  
  async fillName(name: string) {
    await page.fill('[data-testid="employee-name"]', name)
  }
  // src: kerjaan-client-portal/src/pages/CreateEmployee.tsx:52

GROUNDING EVIDENCE:
  Grounding phase found:
    ✅ Selector: [data-testid="employee-name"]
    ✅ Located: kerjaan-client-portal/src/pages/CreateEmployee.tsx:52
    ✅ Element visible in live inspection
  
  Current app state:
    ❌ Selector: [data-testid="employee-name"] — NOT FOUND
    ✅ Selector: [data-testid="first-name"] — FOUND
    
  Analysis:
    Grounding found "employee-name"
    Live app has "first-name"
    → Selector outdated OR app changed since grounding

ROOT CAUSE:
  
  Sub-cause A: Selector in code is wrong
    └─ PAGE layer has typo or old selector
    └─ Fix: Update PAGE layer with correct selector
  
  Sub-cause B: App UI changed
    └─ data-testid attribute changed in app
    └─ Fix: Re-ground selector against current app version
  
  Sub-cause C: Grounding was wrong
    └─ Original grounding found wrong selector
    └─ Fix: Re-ground TC scenario from scratch

HTTP INTERACTION (if applicable):
  Before timeout, network calls:
    ✅ GET /form — 200 OK (page loaded)
    ✅ GET /form/fields — 200 OK (schema loaded)
    ❌ After: No more requests (stuck at fill)

DOM INSPECTION (screenshot):
  Live DOM at failure time:
    <form>
      <input data-testid="first-name" />
      <input data-testid="last-name" />
      <input data-testid="email" />
    </form>
  
  Expected element: [data-testid="employee-name"]
  Found element: [data-testid="first-name"]

DECISION:
  Option A: Fix PAGE layer selector
    └─ Update: [data-testid="employee-name"]
    └─ To: [data-testid="first-name"]
    └─ Verify: Re-run test
  
  Option B: Re-ground selector
    └─ Run grounding phase again
    └─ Update grounding notes
    └─ Verify selector actually exists in current app
  
  Option C: Verify TC matches app
    └─ TC says: "Fill employee name field"
    └─ App shows: "Fill first name field"
    └─ Decision: TC or app wrong?
```

### **Type 5: SPEC Assertion Failed**

```
@covers: DF-M1-POS-005
WHICH LAYER FAILED? SPEC (Assertion)

ASSERTION THAT FAILED:
  expect(result.status).toBe('DRAFT')
  
  Expected: 'DRAFT'
  Actual: 'PENDING'

SPEC CODE:
  domain/web/pm/tests/create-employee.spec.ts:52
  
  test('@covers DF-M1-POS-005', async () => {
    const result = await createEmployeeUsecase.execute(data)
    expect(result.status).toBe('DRAFT')  ← ASSERTION FAILED
  })

TC EXPECTED RESULT:
  From staffinc-testcase/testcases/web/pm/DF-M1-POS-005.md:
  
  "Then: Employees harus dibuat dengan status DRAFT"

ACTUAL BEHAVIOR:
  When POST /v1/employees called:
    Response: { id: 123, name: "John", status: 'PENDING' }
    
  Database: employees table, id=123, status='PENDING'

MISMATCH ANALYSIS:
  
  TC says: Status DRAFT after create
  Code does: Status PENDING after create
  
  Question: Kenapa status PENDING, bukan DRAFT?
  
  Option A: App workflow changed
    └─ Employees now auto-transition to PENDING on create
    └─ This is a DEFECT (app behavior ≠ TC requirement)
    └─ Action: Report defect, update TC, or fix app
  
  Option B: TC is outdated
    └─ Requirement changed but TC not updated
    └─ Action: Update TC expected result
    └─ But: Verify with Product/QA first
  
  Option C: Assertion is wrong
    └─ Maybe code is correct, assertion misread
    └─ But: Unlikely if assertion directly from TC

DECISION TREE (critical):
  
  🚫 WRONG ACTION:
     ❌ Change assertion to: expect(result.status).toBe('PENDING')
     ❌ Use loose matcher: expect(result.status).toBeTruthy()
     ❌ Comment out assertion
     ❌ Ignore mismatch and mark as "passed"
     
     ALL OF ABOVE = forgery, test is not valid
  
  ✅ RIGHT ACTION:
     1. Verify TC: Open staffinc-testcase/testcases/web/pm/DF-M1-POS-005.md
        └─ Check: Expected Result says DRAFT? Confirms
     
     2. Check codebase: Why is status PENDING?
        └─ Search: hcmsvc/internal/employee/handler.go
        └─ Find: POST /v1/employees endpoint
        └─ Check: Default status = PENDING?
        └─ Find: Is there workflow auto-transition?
     
     3. Decide with team:
        A) App is correct: Update TC expected result
           └─ Edit: staffinc-testcase/testcases/web/pm/DF-M1-POS-005.md
           └─ Change: Expected Result → "status PENDING"
           └─ Reason: App behavior changed, TC must reflect reality
        
        B) TC is correct: App has defect
           └─ Create: defect ticket
           └─ Description: "Create employee returns PENDING, should be DRAFT"
           └─ Reference: TC DF-M1-POS-005
           └─ Action: Fix app, then test passes
        
        C) Confusion on requirement:
           └─ Escalate to Product/QA
           └─ Clarify: What should status be after create?
           └─ Update: TC based on clarification

NEVER (repeat: NEVER):
  ❌ "Let me just change assertion to PENDING"
  ❌ "The test passes now"
  ❌ This is AUTOMATION FORGERY
  ❌ Root cause: App behavior ≠ TC requirement
  ❌ Hiding it = covering up defect
```

---

## Decision Tree: What to Do When Test Fails?

```
TEST FAILED
    ↓
╔═══════════════════════════════════════════════════════════════╗
║ STEP 1: Identify which LAYER failed                           ║
╠═══════════════════════════════════════════════════════════════╣
║                                                               ║
║  A) PRE (Precondition)                                        ║
║     └─ Setup failed, test scenario cannot run                 ║
║     └─ Check: /v1/admin/seed/user endpoint                    ║
║     └─ Check: Database state after PRE                        ║
║     └─ Action: Fix environment, then RETRY                    ║
║     └─ TC Status: remains PLANNED (not automated)             ║
║                                                               ║
║  B) FACTORY (Data Generation)                                 ║
║     └─ Generated data invalid                                 ║
║     └─ Check: Data matches schema?                            ║
║     └─ Check: Data unique (no conflicts)?                     ║
║     └─ Action: RETRY (usually one-off)                        ║
║                └─ If repeats: enhance FACTORY validation      ║
║                                                               ║
║  C) USECASE (Business Logic)                                  ║
║     └─ Logic returned error                                   ║
║     └─ Check: Error expected per TC?                          ║
║     └─ Check: USECASE logic matches TC?                       ║
║     └─ Check: Input data valid?                               ║
║     └─ Action: FIX USECASE or DB cleanup                      ║
║                                                               ║
║  D) Layer 3 (PAGE/COMPONENT/Endpoint)                         ║
║     └─ Selector not found OR endpoint 404/500                 ║
║     └─ Check: Selector exists in current app?                 ║
║     └─ Check: Endpoint still exists?                          ║
║     └─ Check: Grounding outdated?                             ║
║     └─ Action: RE-GROUND selector/endpoint                    ║
║                └─ Or: UPDATE Layer 3 code                     ║
║                                                               ║
║  E) SPEC (Assertion)                                          ║
║     └─ Expected value ≠ Actual value                          ║
║     └─ Check: TC expected result accurate?                    ║
║     └─ Check: App behavior matches TC?                        ║
║     └─ Decision: UPDATE TC or REPORT DEFECT                   ║
║     └─ 🚫 NEVER adjust assertion to pass                      ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
    ↓
╔═══════════════════════════════════════════════════════════════╗
║ STEP 2: Gather evidence                                       ║
╠═══════════════════════════════════════════════════════════════╣
║                                                               ║
║  Screenshot: outputs/evidence/[YYYY-MM-DD]/[TC-ID].png        ║
║  Video: outputs/evidence/[YYYY-MM-DD]/[TC-ID].webm            ║
║  Console logs: Browser errors                                 ║
║  Network logs: HTTP requests/responses                        ║
║  Stack trace: Full error stack                                ║
║  Command: Exact command that was run                          ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
    ↓
╔═══════════════════════════════════════════════════════════════╗
║ STEP 3: Root cause analysis                                   ║
╠═══════════════════════════════════════════════════════════════╣
║                                                               ║
║  ❓ What exactly failed?                                       ║
║     └─ Not "test failed", but "Layer X → reason Y"            ║
║                                                               ║
║  ❓ Why did it fail?                                           ║
║     └─ Selector wrong? Endpoint not responding? Data invalid? ║
║                                                               ║
║  ❓ Is failure expected per TC?                                ║
║     └─ If yes: Assertion should verify it                     ║
║     └─ If no: Something is broken                             ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
    ↓
╔═══════════════════════════════════════════════════════════════╗
║ STEP 4: Decision & Action                                     ║
╠═══════════════════════════════════════════════════════════════╣
║                                                               ║
║  BLOCKER (do not pass):                                       ║
║    ❌ PRE setup failed — environment issue                    ║
║    ❌ SPEC assertion fail (app ≠ TC) — needs decision         ║
║    ❌ Layer 3 selector wrong — needs fix                      ║
║    ❌ @covers TC-ID missing — spec issue                      ║
║                                                               ║
║  ACTIONABLE (fix and retry):                                  ║
║    ✅ FACTORY data invalid — enhance FACTORY                  ║
║    ✅ USECASE error (expected) — fix if TC changed            ║
║    ✅ Layer 3 outdated — re-ground and update                 ║
║                                                               ║
║  DECISION NEEDED (escalate):                                  ║
║    ⚠️  App behavior ≠ TC expected — product decision           ║
║    ⚠️  Requirement unclear — QA lead decision                  ║
║    ⚠️  Environment down — ops decision                         ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
```

---

## Evidence Requirements

Ketika test gagal, HARUS attach evidence:

### **Screenshot**
```
Lokasi: outputs/evidence/[YYYY-MM-DD]/
Nama: [TC-ID]__[spec-name]__[failure-point].png

Contoh: PM-C-001__create-employee__selector-not-found.png

Requirement:
  ✅ Show DOM state saat gagal
  ✅ Show error message (kalau ada di UI)
  ✅ Include browser dev tools console (errors visible)
  ✅ Timestamp visible (metadata bar)
  ✅ Full viewport (tidak cropped)
```

### **Video**
```
Lokasi: outputs/evidence/[YYYY-MM-DD]/
Nama: [TC-ID]__[spec-name]__[scenario].webm

Contoh: PM-C-001__create-employee__full-flow.webm

Requirement:
  ✅ Full test execution (PRE → scenario → failure)
  ✅ Show exact moment of failure (pause frame)
  ✅ Include network tab (HTTP calls visible)
  ✅ Duration < 5 minutes (reasonable length)
  ✅ Format: webm or mp4
```

### **Logs**
```
Browser Console:
  - All errors printed
  - All network errors
  - All warnings related to test
  - Example:
    Error: fill: element not found <selector>
    at page.fill() [createEmployee.page.ts:42]

Network Log:
  - All HTTP requests
  - Response status + headers
  - Response body (JSON/error)
  - Timing info
  - Example:
    POST /v1/employees HTTP 500
    Response: { error: "Validation failed" }
    Timing: 234ms

Stack Trace:
  - Full stack (bukan truncated)
  - Include file paths + line numbers
  - Include layer info (Layer3 / USECASE / SPEC)
```

### **Run Information**
```
Command: 
  playwright test domain/web/pm/tests/create-employee.spec.ts -g "PM-C-001"
  
Output:
  1 failed (42.3s)
  [chromium] › domain/web/pm/tests/create-employee.spec.ts:42:3
  › 01  [UI] Create employee with valid data
  
  Error: Timeout 30000ms exceeded.
```

---

## Reporting to Team/Channel

### ❌ **BAD Report:**
```
"Test PM-001 gagal"
"Ada error di create employee"
"Selector tidak ketemu, kelihatannya app berubah"
"Udah coba diulangi tapi tetap gagal"
```

### ✅ **GOOD Report:**
```
TEST FAILURE: DF-M1-POS-001

@covers: DF-M1-POS-001 — Create employee with valid data
Layer: Layer 3 — PAGE.fillName()
Error: Timeout 30000ms | selector [data-testid="employee-name"] not found

ROOT CAUSE:
  Grounding found: [data-testid="employee-name"]
  Live app shows: [data-testid="first-name"]
  Diagnosis: Selector outdated OR app changed

EVIDENCE:
  Screenshot: outputs/evidence/2025-01-15/DF-M1-POS-001.png
  Video: outputs/evidence/2025-01-15/DF-M1-POS-001.webm
  Command: playwright test domain/web/pm/tests/create-employee.spec.ts -g "DF-M1-POS-001"

ACTION NEEDED:
  Option A: Fix PAGE layer → update selector to [data-testid="first-name"]
  Option B: Re-ground → verify selector against current app
  Option C: Check TC → does TC describe "employee name" or "first name"?

ASSIGNMENT:
  Automation engineer: Update selector if app UI finalized
  QA lead: Verify TC accuracy
  Developer: Confirm UI is intentional change
```

---

## Checklist: Sebelum Report "Test Failed"

```
REQUIRED:
  [ ] @covers TC-ID ada dan benar?
  [ ] Tahu layer mana yang fail? (PRE/FACTORY/USECASE/Layer3/SPEC)
  [ ] Error message lengkap (bukan truncated)?
  [ ] Evidence attached (screenshot/video)?
  [ ] Root cause analyzed (bukan "dunno")?
  [ ] Decision path clear (action item defined)?
  [ ] Command yang dijalankan dicatat?

RED FLAGS (do not pass):
  [ ] "Assertion agar pass" — NEVER
  [ ] "Silent failure" — NEVER
  [ ] "Exception ditelan" — NEVER
  [ ] "Tautology assertion" — expect(true).toBe(true)
  [ ] "@covers missing" — BLOCKER
  [ ] "Tidak ada evidence" — BLOCKER
  [ ] "Root cause tidak jelas" — BLOCKER
```

---

## Anti-Patterns: What NOT to Do

### ❌ **Silent Failures**
```
WRONG:
  test('Create employee', async () => {
    try {
      await page.fill('[data-testid="name"]', 'John')
    } catch (e) {
      console.log(e)  // Error logged but test continues
    }
    expect(true).toBe(true)  // Always passes
  })

Result: Test passes even though selector failed

RIGHT:
  test('Create employee', async () => {
    await page.fill('[data-testid="name"]', 'John')
    // No try/catch — let error propagate
    expect(page.locator('[data-testid="name"]')).toHaveValue('John')
    // Explicit assertion
  })
```

### ❌ **Tautology Assertions**
```
WRONG:
  expect(result).toBeDefined()  // Always true if reached
  expect(result.id > 0).toBeTruthy()  // True for any positive number
  expect(true).toBe(true)  // Always passes

RIGHT:
  expect(result.status).toBe('DRAFT')  // Can fail if status is PENDING
  expect(result.id).toBe(expectedId)  // Specific value check
  expect(employees).toHaveLength(expectedCount)  // Countable
```

### ❌ **Assertion Forgery**
```
WRONG:
  // TC says: status DRAFT
  // App returns: status PENDING
  // Solution: change assertion
  
  expect(result.status).toBe('PENDING')  ← FORGERY
  // Now test passes, but TC requirement is violated

RIGHT:
  // Keep assertion as per TC
  expect(result.status).toBe('DRAFT')
  
  // If test fails: decision point
  - Is TC wrong? Update TC (with approval)
  - Is app wrong? Report defect (fix app)
  - Never silently change assertion
```

### ❌ **Hidden Dependencies**
```
WRONG:
  test('Create', async () => {
    const result = await create(data)  // Assume success
    expect(result.id).toBeTruthy()  // But what if create failed?
  })

Result: If create returns error, assertion misleading

RIGHT:
  test('Create', async () => {
    const result = await create(data)
    expect(result.success).toBe(true)  // Verify create succeeded
    expect(result.id).toBeTruthy()  // Then verify ID exists
  })
```

---

## Summary: Executability Principle + Debuggability

```
Automation testing prinsip:

1. EXECUTABLE
   └─ Test harus bisa run di dev/stg
   └─ Tidak ada assumption, semua verified

2. DEBUGGABLE
   └─ Kalau fail, error jelas dan actionable
   └─ Harus tahu: layer mana? kenapa? apa action-nya?

3. TRACEABLE
   └─ Error → @covers TC → root cause
   └─ Evidence lengkap (screenshot/video)

4. ACCOUNTABLE
   └─ Tidak ada silent failures
   └─ Tidak ada assertion forgery
   └─ Tidak ada "magic" atau assumption
```

---

## Next Document

Dokumentasi ini mengasumsikan test sudah written dan dijalankan. Untuk error handling di **grounding phase** dan **layer design phase**, lihat:
- `docs/shared/03-codebase-grounding.md` — ground dulu sebelum code
- `docs/shared/04-three-layer-architecture.md` — DDD rules per layer
- `workflow/01-grounding.md` — grounding phase detail
