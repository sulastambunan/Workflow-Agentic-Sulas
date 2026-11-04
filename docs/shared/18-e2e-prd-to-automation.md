# 18 — End-to-End Flow: PRD → Automation Live

**Goal:** Complete flow from PRD to automated test running on stg/dev with upstream prevention at each gate.

---

## 🎯 Overview: 3 GATES + 6 PHASES

```
INPUT: PRD (Product Requirements Document)
       ↓
┌─────────────────────────────────────┐
│ GATE A: TSD-writer                  │
│ Convert PRD → TSD (validated)       │
│ Tool: repos/staffinc/skills/tsd-writer
│ Output: TSD file + self-check       │
└─────────────────────────────────────┘
       ↓
┌─────────────────────────────────────┐
│ GATE B: testcase-writer             │
│ Convert TSD → TC (canonical)        │
│ Tool: repos/staffinc/skills/testcase-writer
│ Output: TC + PRE files              │
└─────────────────────────────────────┘
       ↓
┌─────────────────────────────────────┐
│ GATE C: Automation Workflow         │
│ Phase 0-6: Grounding → Live         │
│ Tool: Workflow phases               │
│ Output: Automated test live         │
└─────────────────────────────────────┘
       ↓
OUTCOME: TC marked automated, test running on stg/dev
```

---

## GATE A: TSD-writer (PRD → TSD)

**Input:** PRD document  
**Tool:** `skills/tsd-writer/SKILL.md`  
**Output:** TSD file (validated) + self-check results

### Steps I Will Do:

#### 1. **Read PRD Completely**
```
├─ Requirements: What user can/should do?
├─ Acceptance Criteria: How to verify feature works?
├─ Boundary conditions: Edge cases, limits?
├─ Dependencies: Other features, permissions, data?
├─ Non-functional: Performance, security, UI/UX?
└─ Constraints: Budget, timeline, technical limits?
```

#### 2. **Create TSD File**

Location: `domain/[web|mobile|api]/[module]/TSD-<FEATURE>.md`

Example: `domain/web/pm/TSD-CREATE-EMPLOYEE.md`

Content sections:
```markdown
# TSD: Create Employee

## 1. Feature Title & Description
- From PRD: "Manager dapat membuat employee baru"
- Scope: Web platform only, manager role
- Out of scope: API, mobile, employee edit

## 2. Acceptance Criteria (from PRD)
- AC#1: Form tersedia untuk manager
- AC#2: Valid data accepted, record created
- AC#3: Invalid data rejected with error
- AC#4: Notification sent to HR

## 3. Preconditions (what must be true)
- PRE#1: Manager user exists
- PRE#2: Test environment ready (stg/dev)
- PRE#3: Email service available

## 4. Test Scenarios

### POS-001: Create with valid data
- **Given:** Manager logged in, form open
- **When:** Fill name, email, department
- **Then:** Record created, notification sent
- **Data:** From FACTORY (not hardcoded)

### NEG-001: Create with invalid email
- **Given:** Manager logged in, form open
- **When:** Fill invalid email format
- **Then:** Error shown, record NOT created

### EDG-001: Duplicate email
- **Given:** Manager, existing email in DB
- **When:** Try create with same email
- **Then:** Error: "Email exists"

## 5. Dependencies
- Feature X (must be done first)
- Permission API (endpoint must be stable)
- Test data: Employee schema finalized

## 6. Data & State
- Test email: faker.person.email() (varied)
- Test name: faker.person.fullName() (varied)
- State: Fresh DB per test (cleanup)
```

#### 3. **Self-Check (TSD Quality)**

Before handoff, verify:

```
[ ] 12 TSD sections present?
[ ] AC extracted from PRD (not invented)?
[ ] Scope: Included/excluded clear?
[ ] Scenarios: POS/NEG/EDG covered?
[ ] PRE: What setup needed? (data, state, permissions)
[ ] Data: Varied (FACTORY), not hardcoded?
[ ] Given/When/Then: Observable, testable, clear?
[ ] References: PRD cited with page/section?
[ ] Count: N scenarios, N AC, N PRE
[ ] Status: DRAFT or VALIDATED?
```

**Output:** TSD file + self-check checklist

---

## GATE B: testcase-writer (TSD → TC)

**Input:** Validated TSD  
**Tool:** `skills/testcase-writer/SKILL.md`  
**Output:** TC files + PRE files in `staffinc-testcase` repo

### Steps I Will Do:

#### 1. **Read TSD + TC Schema**

- TSD from GATE A
- TC contract: `staffinc-testcase/SCHEMA.md`
- PRE contract: `staffinc-testcase/PRECONDITIONS.md`

#### 2. **Create TC File per Scenario**

Location: `testcase/[domain]/[module]/TC-<FEATURE>-<SCENARIO>.md`

Example: `testcase/web/pm/TC-CREATE-EMPLOYEE-POS-001.md`

Content:
```markdown
# Test Case: DF-M1-POS-001

**Title:** Create employee with valid data (from TSD POS-001)

**TSD Reference:** domain/web/pm/TSD-CREATE-EMPLOYEE.md#POS-001

## Given (Preconditions)

What must be true before user action:

```
1. Manager user exists (email: mgr-xxx@test.co)
   - Factory: preconditionManagerUser()
   - Endpoint: POST /v1/admin/seed/user
   - Expected status: 201
   - DB: users.role = 'manager' verified
   - Executable: YES (dev/stg)

2. Form endpoint available
   - Endpoint: GET /v1/pm/create-form
   - Expected status: 200
   - Executable: YES (dev/stg)
```

## When (User Actions)

Observable sequence of actions:

```
1. Navigate to create employee form
   - URL: /pm/employees/create
   - Observable: Form element visible
   - Selector: [data-testid="create-form"]

2. Fill name field
   - Action: page.fill('[data-testid="name"]', name)
   - Data: 'John Smith' (from FACTORY, varied)
   - Observable: Input value = 'John Smith'

3. Fill email field
   - Action: page.fill('[data-testid="email"]', email)
   - Data: faker.internet.email() (varied per run)
   - Observable: Input value = email

4. Click submit button
   - Action: page.click('[data-testid="submit"]')
   - Wait: network idle, response 201

5. Verify notification sent
   - Observable: Toast message appears
   - Text: "Employee created successfully"
```

## Then/And (Expected Results)

What should be true after actions:

```
### Then#1: Record Created
- API Response: status 201
- Response body: { id: <uuid>, status: 'DRAFT' }
- Observable: Record in DB with correct data

### Then#2: Status is DRAFT
- Assertion: result.status === 'DRAFT'
- From TC: ✅ (TSD specifies)
- Can fail: ✅ (if code sets ACTIVE)

### And#1: Notification Sent
- Email sent: YES
- Recipient: HR team email
- Content: "New employee: John Smith"
```

## Preconditions (PRE) Reconciliation

```
PRE#1: Manager user exists
  Status: REUSE existing precondition
  File: domain/web/pm/factories/preconditions.factory.ts
  Function: preconditionManagerUser()
  
PRE#2: Form endpoint available
  Status: NEW precondition needed
  File: domain/web/pm/factories/preconditions.factory.ts
  Function: preconditionFormAvailable() [TO BE CREATED]
  Action: GET /v1/pm/create-form, verify 200
```

## Execution Environment

```
Environments where this TC must be executable:
- dev: YES (full control, reset DB)
- stg: YES (test data available)
- prod: NO (read-only, no creation)

Data setup:
- Test account: manager-xxx@test.co (varied per run)
- Test data: From FACTORY (not hardcoded)
- Cleanup: Delete created record after test
```

## Coverage Summary

```
TC ID: DF-M1-POS-001
TSD Scenario: POS-001 (Create with valid data)
AC covered: AC#2 (valid data accepted)
PRE count: 2 (both reusable/new identified)
Action count: 5
Expected result count: 3
Executable: YES (dev/stg)
```
```

#### 3. **Precondition Reconciliation**

For each PRE in TSD:

```
┌─ REUSE: Precondition exists
│  ├─ File: domain/web/pm/factories/preconditions.factory.ts
│  ├─ Function: preconditionManagerUser()
│  ├─ Verify: Executable in dev/stg? YES
│  └─ Ref: Link in TC "PRE#1"
│
├─ EXTEND: Precondition exists but needs expansion
│  ├─ Current: preconditionUserExists()
│  ├─ Extend: Add manager role assignment
│  └─ Action: Update function + document change
│
└─ NEW: Precondition doesn't exist
   ├─ Name: preconditionFormAvailable()
   ├─ Action: Create new function
   ├─ Verify: Executable (GET /v1/pm/create-form → 200)
   └─ Add to factories/preconditions.factory.ts
```

#### 4. **Validation: validator-tsd-sync.py**

Before handoff, run:

```bash
python validator-tsd-sync.py \
  --tsd domain/web/pm/TSD-CREATE-EMPLOYEE.md \
  --tc testcase/web/pm/TC-CREATE-EMPLOYEE-*.md

# Output:
# ✅ TC count matches TSD scenarios: 3/3
# ✅ Given/When/Then all present: 100%
# ✅ PRE documented: 2/2
# ✅ Data from FACTORY: 100%
# ✅ Executability verified: dev/stg
```

#### 5. **Handoff Checklist**

Before passing to GATE C:

```
[ ] TSD validated (self-check done)?
[ ] TC files created per scenario?
[ ] Given/When/Then complete per TC?
[ ] PRE reconciliation done (REUSE/EXTEND/NEW)?
[ ] Validator passed?
[ ] All TC executable in dev/stg?
[ ] Data varied (FACTORY, not hardcoded)?
[ ] TC references TSD section?
[ ] Status: READY FOR AUTOMATION
```

**Output:** TC files + PRE files (committed to staffinc-testcase)

---

## GATE C: Automation Workflow (Phase 0-6)

**Input:** Validated TC + PRE files  
**Tool:** `workflow/XX-*.md` phases  
**Output:** Automated test live on stg/dev

### Phase 0: Intake

**Input:** TC file from GATE B  
**Output:** Automation intake document

#### Steps:

```
1. Read TC completely
   - Scenario understanding
   - PRE requirements
   - Environment needs

2. Ask environment & data questions
   - Target environment: dev/stg/both?
   - Test account: role, email source?
   - Test data: available, setup needed?
   - Cleanup: delete after test, reuse data?
   - Unique identifiers: email randomization?

3. Verify automation status
   - TC marked: "Ready for automation"?
   - PRE available: all PRE files exist?
   - Dependencies: other TC blocked on this?

4. Create intake document
   - File: domain/web/pm/INTAKE-DF-M1-POS-001.md
   - Content: questions answered, decisions made
   - Status: READY FOR GROUNDING
```

**Checklist:**
```
[ ] TC read completely?
[ ] Environment questions answered?
[ ] PRE verified available?
[ ] Data setup plan clear?
[ ] Cleanup policy decided?
[ ] No blockers?
```

---

### Phase 1: Grounding

**Input:** Intake document  
**Output:** Grounding document with citations

#### Steps:

```
1. Ground Given (preconditions)
   - PRE#1: preconditionManagerUser()
     Location: domain/web/pm/factories/preconditions.factory.ts:23
     Endpoint: POST /v1/admin/seed/user
     Verify: Can execute in dev/stg? YES
   
   - PRE#2: preconditionFormAvailable()
     Location: domain/web/pm/factories/preconditions.factory.ts:45
     Endpoint: GET /v1/pm/create-form
     Verify: Can execute in dev/stg? YES

2. Ground When (UI selectors & actions)
   - Navigate to /pm/employees/create
     Observable in: kerjaan-client-portal/src/pages/CreateEmployee.tsx
     Selector: [data-testid="create-form"]
     Line: src/pages/CreateEmployee.tsx:42
   
   - Fill name field
     Selector: [data-testid="name"]
     Codebase location: CreateEmployee.tsx:65 (input element)
     Verify: Can interact in dev/stg? YES

3. Ground Then (API response & DB state)
   - Record created in DB
     API: POST /v1/employees
     Response: 201 + { id, status }
     DB table: employees
     Verify: Can read DB in dev/stg? YES

4. Ground data sources
   - Manager email: faker.internet.email() ✓
   - Employee name: faker.person.fullName() ✓
   - From TC: All values traceable to TC ✓
```

**Output:** Grounding document
```
# Grounding: DF-M1-POS-001

## Given
- [x] PRE#1: preconditionManagerUser() @ factories/preconditions.factory.ts:23
- [x] PRE#2: preconditionFormAvailable() @ factories/preconditions.factory.ts:45

## When
- [x] Navigate /pm/employees/create → CreateEmployee.tsx:42
- [x] Fill [data-testid="name"] → CreateEmployee.tsx:65
- [x] Fill [data-testid="email"] → CreateEmployee.tsx:68
- [x] Click [data-testid="submit"] → CreateEmployee.tsx:71

## Then
- [x] API POST /v1/employees → endpoint available? YES
- [x] DB: employees table exists? YES
- [x] Response: status field? YES

## Data
- [x] Manager email: faker.internet.email() (varied)
- [x] Employee name: faker.person.fullName() (varied)
- [x] All from TC, traceable

Status: GROUNDED ✓
```

**Checklist:**
```
[ ] All PRE cited with file:line?
[ ] All selectors cited with file:line?
[ ] All API endpoints verified?
[ ] All data from TC (not memory)?
[ ] Executability verified per layer?
[ ] No hardcoded values?
```

---

### Phase 2: Design

**Input:** Grounding document  
**Output:** Design document with architecture plan

#### Steps:

```
1. Design assertion for each Then clause
   
   Then#1: "Record created"
   - Observable: result.id exists
   - Expected: string (UUID)
   - Assertion: expect(result.id).toBeTruthy()
   - Can fail? YES ✓
   - From TC? YES ✓
   
   Then#2: "Status is DRAFT"
   - Observable: result.status field
   - Expected: 'DRAFT' (from TC)
   - Assertion: expect(result.status).toBe('DRAFT')
   - Can fail? YES ✓ (if code sets ACTIVE)
   - From TC? YES ✓
   
   And#1: "Notification sent"
   - Observable: Email in queue
   - Expected: recipient = HR team
   - Assertion: expect(emailQueue).toContainEqual({to: 'hr@...'})
   - Can fail? YES ✓
   - From TC? YES ✓

2. Design architecture (DDD layers)
   
   SPEC layer (test):
   - Import usecase
   - Call with data
   - Assert result
   
   USECASE layer (domain):
   - Call API POST /v1/employees
   - Handle response
   - Send notification event
   
   Layer3 (page):
   - Page object for form
   - fill(), click() methods
   - No business logic
   
   FACTORY layer:
   - generateEmployee() with varied data
   - preconditionManagerUser()
   - preconditionFormAvailable()

3. Error handling plan
   - PRE fails: throw immediately (not swallow)
   - API error: throw with message
   - Assertion fail: let error propagate
```

**Output:** Design document
```
# Design: DF-M1-POS-001

## Assertions (per Then clause)

| TC Clause | Observable | Expected | Assertion | Can Fail? |
|-----------|-----------|----------|-----------|-----------|
| "Record created" | result.id | truthy | expect(result.id).toBeTruthy() | ✅ |
| "Status DRAFT" | result.status | 'DRAFT' | expect(result.status).toBe('DRAFT') | ✅ |
| "Notification sent" | email queue | recipient=HR | expect(emailQueue).toContainEqual(...) | ✅ |

## Architecture (DDD)

```
SPEC (test)
  ├─ Import CreateEmployeeUsecase
  ├─ Get data from FACTORY
  ├─ Call usecase.execute(data)
  └─ Assert response

USECASE
  ├─ POST /v1/employees
  ├─ Get response 201
  ├─ Emit notification event
  └─ Return { id, status, ... }

Layer3 (CreateEmployeePage)
  ├─ fill(name, email)
  ├─ click(submit)
  ├─ wait for response
  └─ No business logic

FACTORY
  ├─ generateEmployee() → { name, email }
  ├─ preconditionManagerUser()
  ├─ preconditionFormAvailable()
  └─ All data varied
```

## Error Handling

- PRE: throw immediately
- USECASE API error: throw with context
- Assertion: let fail, don't swallow
```

**Checklist:**
```
[ ] Assertion per Then clause?
[ ] Can fail? YES for all?
[ ] From TC? YES for all?
[ ] DDD layers clear?
[ ] Error handling per layer?
[ ] No hardcoded values?
```

---

### Phase 3: Mapping

**Input:** Design document  
**Output:** Layer mapping (file structure plan)

#### Steps:

```
1. Map to SPEC layer
   - File: domain/web/pm/tests/create-employee.spec.ts
   - Test name: test('@covers DF-M1-POS-001', async () => {...})
   - Import usecase & page & factory

2. Map to USECASE layer
   - File: domain/web/pm/usecases/create-employee.usecase.ts
   - Class: CreateEmployeeUsecase
   - Method: execute(data: EmployeeInput)

3. Map to Layer3 (page)
   - File: domain/web/pm/pages/CreateEmployeePage.ts
   - Methods: fill(), click(), waitForResponse()

4. Map to FACTORY layer
   - File: domain/web/pm/factories/employee.factory.ts
   - Function: generateEmployee()
   - File: domain/web/pm/factories/preconditions.factory.ts
   - Function: preconditionManagerUser(), preconditionFormAvailable()
```

**Output:** Mapping document
```
# Mapping: DF-M1-POS-001

## SPEC Layer
- File: domain/web/pm/tests/create-employee.spec.ts
- Test: test('@covers DF-M1-POS-001')
- Imports:
  - CreateEmployeeUsecase
  - CreateEmployeePage
  - { generateEmployee }

## USECASE Layer
- File: domain/web/pm/usecases/create-employee.usecase.ts
- Class: CreateEmployeeUsecase
- Method: execute(data)
  - POST /v1/employees
  - Emit event
  - Return result

## Layer3 (PAGE)
- File: domain/web/pm/pages/CreateEmployeePage.ts
- Methods:
  - fill(name, email)
  - click()
  - waitForResponse()

## FACTORY Layer
- File: domain/web/pm/factories/employee.factory.ts
  - generateEmployee()
- File: domain/web/pm/factories/preconditions.factory.ts
  - preconditionManagerUser()
  - preconditionFormAvailable()
```

---

### Phase 4: Implement

**Input:** Mapping document  
**Output:** Code + AUTOMATION-CHECKLIST

#### Steps:

```
1. Implement per layer (DDD rules)
   
   ✅ FACTORY (independent):
      export function generateEmployee(overrides = {}) {
        return {
          name: faker.person.fullName(),
          email: faker.internet.email(),
          ...overrides
        }
      }
   
   ✅ USECASE (domain logic):
      async execute(data: EmployeeInput) {
        const res = await http.post('/v1/employees', data)
        if (!res.ok()) throw new Error(`API error: ${res.status()}`)
        this.eventBus.emit('employee.created', res.json())
        return res.json()
      }
   
   ✅ Layer3 (page interactions):
      async fill(name: string, email: string) {
        await page.fill('[data-testid="name"]', name)
        await page.fill('[data-testid="email"]', email)
      }
      
      async click() {
        await page.click('[data-testid="submit"]')
      }
   
   ✅ SPEC (test assertions):
      test('@covers DF-M1-POS-001', async () => {
        const data = generateEmployee()
        const result = await usecase.execute(data)
        
        // Then#1: Record created
        expect(result.id).toBeTruthy()
        
        // Then#2: Status DRAFT
        expect(result.status).toBe('DRAFT')
        
        // And#1: Notification
        expect(emailQueue).toContainEqual({to: 'hr@...'})
      })

2. Add code comments
   - @covers <TC-ID>
   - // src: filepath:line (selector, endpoint)
   - // expect: <TC-ID> Then#n (assertion)

3. Create AUTOMATION-CHECKLIST-DF-M1-POS-001.md
   - Map TC clauses to assertions
   - Check: can fail? from TC? no tautology?
   - Self-review: engineer verify complete

4. Run test + collect evidence
   - Test status: PASSED (not skipped/failed)
   - PRE executed: YES
   - Video: recorded (optional)
```

**Output:** Code files + AUTOMATION-CHECKLIST

---

### Phase 5: Verify & Fixing

**Input:** Code + AUTOMATION-CHECKLIST  
**Output:** Evidence + test result

⚠️ **If Test Fails:** See `22-automation-fixing-best-practices.md` for systematic diagnosis and fixing approach.

#### Steps:

```
1. Run test
   - npm test -- create-employee.spec.ts
   - Result: PASSED ✓

2. Verify PRE executed
   - Log: "PRE: Manager user created" ✓
   - Log: "PRE: Form endpoint available" ✓

3. Verify assertions meaningful
   - Assertion #1: status = DRAFT ✓ (can fail)
   - Assertion #2: id exists ✓ (can fail)
   - Assertion #3: email sent ✓ (can fail)

4. Collect evidence
   - Screenshot: form filled + success message
   - Video: full flow (optional)
   - Logs: PRE, USECASE, assertion output

5. Check AUTOMATION-CHECKLIST
   - All TC clauses covered? YES
   - Red flags scanned? YES (no tautology, swallowed error, hardcoded)
   - Test status: PASSED? YES
```

**Output:** Verification evidence
```
# Verification: DF-M1-POS-001

✅ Test PASSED
✅ PRE executed (2/2)
✅ All assertions meaningful
✅ AUTOMATION-CHECKLIST complete
✅ Evidence collected

Status: READY FOR PR
```

---

### Phase 6: Pre-Push Review & PR

**Input:** Code + evidence + checklist  
**Output:** PR created + reviewed

#### Steps:

```
1. Self-review (engineer)
   - AUTOMATION-CHECKLIST complete? YES
   - Red flags? NO (no tautology, swallowed error, hardcoded)
   - Test PASSED? YES
   - Code comments present? YES (@covers, // expect:, // src:)
   - DDD layers correct? YES

2. Create PR
   - Branch: feature/create-employee-automation
   - Title: "test: automate DF-M1-POS-001 (create employee)"
   - Description:
     * TC ID: DF-M1-POS-001
     * Scenarios: POS-001
     * PRE: 2 (manager user + form endpoint)
     * Assertions: 3 (all can fail)
     * Test status: PASSED
     * AUTOMATION-CHECKLIST: complete

3. Reviewer checks (automation-pr-review skill)
   
   Layer 1 (static code):
   - No tautology? ✓
   - No swallowed error? ✓
   - No hardcoded value? ✓
   - All assertions from TC? ✓
   
   Layer 2 (traceability):
   - AUTOMATION-CHECKLIST exist? ✓
   - All clauses covered? ✓
   - Red flags checked? ✓
   
   Layer 3 (executability):
   - PRE executed? ✓
   - FACTORY valid? ✓
   - USECASE endpoint real? ✓
   - Layer3 selectors found? ✓
   - SPEC assertions passed? ✓
   
   Decision: APPROVED ✓

4. Merge PR
   - TC marked: automated = true
   - Test added to CI
   - Running on stg/dev daily
```

---

## 🎯 Summary: E2E Flow

| Gate/Phase | Input | Output | Key Prevention |
|-----------|-------|--------|-----------------|
| **GATE A** | PRD | TSD + self-check | Requirement clarity, scope, PRE |
| **GATE B** | TSD | TC + PRE + validation | Data mapping, executability |
| **GATE C-0** | TC | Intake doc | Environment questions early |
| **GATE C-1** | Intake | Grounding doc | Executability verified per layer |
| **GATE C-2** | Grounding | Design doc | Assertions designed, error handling |
| **GATE C-3** | Design | Layer mapping | Architecture clear, DDD rules |
| **GATE C-4** | Mapping | Code + checklist | Red flags prevented, traceability |
| **GATE C-5** | Code | Evidence + result | Test passing, PRE executed |
| **GATE C-6** | Evidence | PR + review | Upstream quality confirmed |

---

## ✅ Quality Gates (Upstream Prevention)

```
✅ Gate A quality:
   - TSD complete (12 sections)
   - AC from PRD (not invented)
   - Scenarios POS/NEG/EDG covered
   - PRE identified

✅ Gate B quality:
   - TC per scenario
   - Given/When/Then complete
   - PRE reconciled (REUSE/EXTEND/NEW)
   - Data varied (not hardcoded)
   - Validator passed

✅ Gate C quality:
   - Phase 0: Environment clear
   - Phase 1: Everything grounded
   - Phase 2: Assertions designed
   - Phase 3: Architecture clear
   - Phase 4: Red flags prevented
   - Phase 5: Test passing
   - Phase 6: PR reviewed upstream
```

---

## References

- **14-executability-principle.md** — Every layer must be executable
- **15-test-failure-reporting.md** — If test fails, diagnose per layer
- **16-assertion-design.md** — Design assertions, prevent red flags
- **17-traceability-record.md** — AUTOMATION-CHECKLIST per TC
- **skills/tsd-writer** — PRD → TSD
- **skills/testcase-writer** — TSD → TC
- **workflow/** — Phases 0-6
