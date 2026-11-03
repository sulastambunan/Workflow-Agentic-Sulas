# 19 — PR Review Prerequisites: Locate TC & Understand Context

**Goal:** Reviewer MUST read & understand Test Case from staffinc-testcase BEFORE running automation-pr-review skill.

---

## 🚨 Critical: Review Process is TC-Centric

```
WRONG:
PR received → Run skill automation-pr-review → Review
           ❌ Don't understand what TC expects

RIGHT:
PR received 
  ↓
Find TC in staffinc-testcase
  ↓
Read TC: Given/When/Then
  ↓
Understand requirements
  ↓
Run skill automation-pr-review
  ↓
Review with TC context ✓
```

---

## Step 1: Find TC ID from PR

**From PR description**, extract TC ID:

```
PR Title: "test: automate DF-M1-POS-001 (create employee)"
         
Look for:
- TC ID: DF-M1-POS-001
- Reference: @covers DF-M1-POS-001
- AUTOMATION-CHECKLIST: AUTOMATION-CHECKLIST-DF-M1-POS-001.md
```

---

## Step 2: Locate TC in staffinc-testcase Repository

**Path format:**
```
testcase/[domain]/[module]/TC-<FEATURE>-<SCENARIO>.md
```

**Examples:**
```
testcase/web/pm/TC-CREATE-EMPLOYEE-POS-001.md
testcase/api/auth/TC-LOGIN-POS-001.md
testcase/mobile/dashboard/TC-VIEW-METRICS-NEG-001.md
```

### How to Find:

**Option 1: Search by TC ID**
```bash
cd staffinc-testcase
grep -r "TC-ID: DF-M1-POS-001" testcase/
grep -r "@covers DF-M1-POS-001" testcase/

# Result:
# testcase/web/pm/TC-CREATE-EMPLOYEE-POS-001.md:TC ID: DF-M1-POS-001
```

**Option 2: Browse directory structure**
```
staffinc-testcase/
├─ testcase/
│  ├─ web/
│  │  ├─ pm/
│  │  │  ├─ TC-CREATE-EMPLOYEE-POS-001.md
│  │  │  ├─ TC-CREATE-EMPLOYEE-NEG-001.md
│  │  │  └─ TC-CREATE-EMPLOYEE-EDG-001.md
│  │  └─ auth/
│  │     └─ TC-LOGIN-POS-001.md
│  ├─ api/
│  ├─ mobile/
```

**Option 3: Check PR description**
```
PR mentions:
"Automate TC: testcase/web/pm/TC-CREATE-EMPLOYEE-POS-001.md"
```

---

## Step 3: Read TC Completely

Open TC file and read **all sections**:

### Template: What to Read

```markdown
# Test Case: DF-M1-POS-001

## Given (Preconditions)
- What MUST be true before user action
- Example: Manager user exists, form endpoint available
- VERIFY: Can be set up in dev/stg? YES

## When (User Actions)
- Observable sequence of actions
- Example: Navigate → Fill form → Submit
- VERIFY: Can be executed in dev/stg? YES

## Then/And (Expected Results)
- What should be true after actions
- Example: Record created, status = DRAFT, notification sent
- COUNT: How many assertions? (3 in example)

## Preconditions (PRE)
- Specific setup required
- Example: preconditionManagerUser()
- VERIFY: PRE files exist? YES

## Data & State
- Test data sources
- Example: faker.internet.email() (varied, not hardcoded)

## Execution Environment
- Where TC runs: dev/stg/prod?
```

### Checklist: Understanding TC

Before moving to review PR, verify you understand:

```
[ ] TC ID clear? (DF-M1-POS-001)
[ ] Feature clear? (Create employee)
[ ] Scenario type? (POS = positive / NEG = negative / EDG = edge case)
[ ] Given: What must be true before test?
[ ] When: What actions does user do? (sequence clear?)
[ ] Then: What should happen? (How many expected results?)
[ ] And: Additional expected results?
[ ] PRE: What preconditions needed? (count)
[ ] Data: From FACTORY or hardcoded? (MUST be FACTORY)
[ ] Executable: Can this run in dev/stg? YES
[ ] All values in Then from TC? YES (not code assumption)
```

---

## Step 4: Map PR to TC

Before running automation-pr-review skill:

### Verify PR Matches TC

```
TC Expected:
├─ Given #1: Manager user exists
├─ Given #2: Form endpoint available
├─ When #1: Navigate to /pm/employees/create
├─ When #2: Fill name, email
├─ When #3: Click submit
├─ Then #1: Record created (status DRAFT)
├─ Then #2: Notification sent
└─ PRE: 2 preconditions

PR Code Should Have:
├─ test('@covers DF-M1-POS-001')
├─ preconditionManagerUser() called?
├─ preconditionFormAvailable() called?
├─ page.navigate() to /pm/employees/create?
├─ page.fill() for name, email?
├─ page.click() submit?
├─ expect(result.status).toBe('DRAFT')?
├─ expect(emailQueue).toContainEqual(...)?
└─ AUTOMATION-CHECKLIST-DF-M1-POS-001.md exists?
```

### What Should Match:

```
✅ Test name has @covers TC-ID
✅ All Given (PRE) are called
✅ All When (actions) are in code
✅ All Then (assertions) exist and match TC
✅ Data from FACTORY, not hardcoded
✅ AUTOMATION-CHECKLIST complete
❌ Missing any TC clause = REQUEST_CHANGES
```

---

## Step 5: Run automation-pr-review Skill

**NOW you're ready.** Run skill with TC context:

```bash
/automation-pr-review \
  --pr-url https://github.com/sulastambunan/staffinc-automation/pull/123 \
  --tc-id DF-M1-POS-001 \
  --tc-file testcase/web/pm/TC-CREATE-EMPLOYEE-POS-001.md
```

**Or in chat:**

```
@automation-pr-review

PR: #123 (test: automate DF-M1-POS-001)
TC: testcase/web/pm/TC-CREATE-EMPLOYEE-POS-001.md

Context:
- Feature: Create employee
- Scenario: POS-001 (create with valid data)
- PRE: 2 (manager user + form endpoint)
- Assertions: 3 (id, status, notification)

Run review with TC context.
```

---

## Pre-Review Checklist for Reviewer

### Before Running Skill:

```
TC Location & Understanding:
[ ] TC ID extracted from PR? (DF-M1-POS-001)
[ ] TC file located in staffinc-testcase? (path known?)
[ ] TC read completely? (all sections understood?)
[ ] Given/When/Then understood? (requirements clear?)
[ ] Preconditions identified? (count: 2, 3, N?)
[ ] Data strategy understood? (FACTORY or hardcoded?)
[ ] Execution environment understood? (dev/stg/both?)

Context Verification:
[ ] PR title mentions TC-ID? YES
[ ] PR description has TC reference? YES
[ ] AUTOMATION-CHECKLIST mentioned? YES
[ ] TC file exists in staffinc-testcase? YES (verified by grep)
[ ] TC matches feature branch? (feature/create-employee matches TC)

Ready for Review?
[ ] Understand exactly what TC expects? YES
[ ] Can trace PR code back to TC clauses? YES (ready)
[ ] Know what red flags to look for? YES (tautology, swallowed error)
[ ] Know what quality gates apply? YES (3 layers)

→ PROCEED TO SKILL
```

---

## Example: Review Flow

### Scenario: PR #123 arrives

```
1. Read PR title: "test: automate DF-M1-POS-001 (create employee)"
   Extract: TC ID = DF-M1-POS-001

2. Search in staffinc-testcase:
   $ grep -r "DF-M1-POS-001" testcase/
   → testcase/web/pm/TC-CREATE-EMPLOYEE-POS-001.md

3. Read TC file completely:
   - Given: Manager user exists, form available
   - When: Navigate → Fill → Submit
   - Then: Record created (status DRAFT), notification sent
   - PRE: preconditionManagerUser(), preconditionFormAvailable()
   - Data: faker.internet.email() (not hardcoded)
   - Executable: YES (dev/stg available)

4. Understand expectations:
   - Need 2 assertions minimum (status + notification)
   - Need 2 PRE calls
   - Data must be from FACTORY
   - No hardcoded values

5. Review PR code mentally:
   - ✓ @covers DF-M1-POS-001 present
   - ✓ PRE called: preconditionManagerUser()
   - ✓ PRE called: preconditionFormAvailable()
   - ✓ Actions match TC: navigate, fill, click
   - ✓ Assertions match TC: status DRAFT, notification sent
   - ✓ Data from FACTORY: generateEmployee()
   - ✓ AUTOMATION-CHECKLIST exists

6. Run skill with context:
   /automation-pr-review --tc-id DF-M1-POS-001
   
7. Skill output aligns with TC understanding:
   - Layer 1: Static code looks good
   - Layer 2: Traceability complete
   - Layer 3: (if executed) All pass
   
   → APPROVED
```

---

## Red Flags When TC Not Understood

```
❌ "Test looks OK" (without reading TC)
   → WRONG: You don't know what test should do

❌ "Assertion looks reasonable" (assuming from code)
   → WRONG: Must match TC expected value, not code

❌ "Data looks varied" (without checking FACTORY)
   → WRONG: Must verify FACTORY, not just appearance

❌ "PRE not needed" (without reading Given)
   → WRONG: TC Given specifies exactly what PRE needed

✅ "Test matches DF-M1-POS-001 Given/When/Then"
   → RIGHT: You've read and understood TC
```

---

## Summary: Reviewer Workflow

| Step | Action | Tool | Output |
|------|--------|------|--------|
| 1 | Extract TC ID from PR | Manual read PR | TC-ID: DF-M1-POS-001 |
| 2 | Locate TC in staffinc-testcase | grep/browse | File path found |
| 3 | Read TC completely | Manual read TC | Understanding: Given/When/Then clear |
| 4 | Verify PR matches TC | Manual trace PR→TC | Checklist: all clauses covered? |
| 5 | Run automation-pr-review skill | /automation-pr-review | Review findings |
| 6 | Make decision | APPROVED/REQUEST_CHANGES | Decision with TC context |

---

## References

- **18-e2e-prd-to-automation.md** — TC created from TSD in GATE B
- **skills/automation-pr-review/SKILL.md** — Review skill (run after TC understanding)
- **17-traceability-record.md** — AUTOMATION-CHECKLIST verifies TC → code mapping
- **staffinc-testcase repo** — Source of truth for test cases

---

## Key Principle

```
🚀 SKILL automation-pr-review is 80% effective only if reviewer
   has 100% understanding of TC first.

Reviewer without TC understanding = Flying blind.
Reviewer with TC understanding = Can spot every gap.
```

**Always read TC first. Always.**
