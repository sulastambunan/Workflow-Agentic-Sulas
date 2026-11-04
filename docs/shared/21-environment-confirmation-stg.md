# 21 — Environment Confirmation: Dev → STG → Regression Ready

**Goal:** After automation passes in dev, MUST verify it works in staging for regression testing before marking as complete.

---

## 🚀 Critical: Automation NOT "Done" Until STG-Ready

```
WRONG:
  Test passes in dev
  → "Automation complete!"
  → Code merged
  → Deployed to stg
  → Test FAILS in stg ⚠️
  → Emergency fix needed
  → Delayed regression testing

RIGHT:
  Test passes in dev ✓
    ↓
  Setup confirmed in stg ✓
    ↓
  Test passes in stg ✓
    ↓
  Regression ready ✓
    ↓
  Code merged
  → "Automation complete AND regression-ready!"
```

---

## Phase 5.5: Environment Confirmation (NEW PHASE)

**When:** After Phase 5 Verify (test passing in dev)  
**Before:** Phase 6 (PR Review)  
**Responsibility:** Automation engineer + QA lead

---

## Step 1: Identify Environment Dependencies

**Before running in stg, document what's needed:**

### **Checklist: Environment Requirements**

```
Test Data:
  [ ] Manager user needed? (role, email domain)
  [ ] Employee sample data needed? (count, state)
  [ ] Initial state in DB? (tables pre-populated?)
  [ ] Test data cleanup policy? (delete after / reuse)

Infrastructure:
  [ ] API endpoint same as dev?
  [ ] Database accessible from test runner?
  [ ] Queue system available? (async processing)
  [ ] Email service available? (send/capture)
  [ ] File storage available? (S3, local)

Configuration:
  [ ] Environment variables different? (API_URL, DB_HOST)
  [ ] Feature flags different in stg? (enabled/disabled)
  [ ] Rate limiting applied in stg? (might fail tests)
  [ ] Network restrictions? (VPN needed, firewall)

Data Parity:
  [ ] Schema same as dev?
  [ ] Default values same?
  [ ] Constraints same? (unique constraints, FK)
  [ ] Sequences reset? (ID generation)

Cleanup:
  [ ] Previous test data present?
  [ ] Need data isolation strategy?
  [ ] Transaction rollback? or delete records?
  [ ] Orphaned data from failed runs?
```

---

## Step 2: Prepare STG Environment

**Setup test data and state in staging:**

### **Example: Create Employee Test in STG**

```bash
# 1. Verify connectivity to stg
curl -X GET https://stg.api.hcm.internal/health
# Expected: 200 OK

# 2. Verify database access
mysql -h stg-db.internal -u test_user -p << EOF
SELECT VERSION();
SELECT COUNT(*) FROM users;
EOF

# 3. Create manager user (precondition) in stg
curl -X POST https://stg.api.hcm.internal/v1/admin/seed/user \
  -H "Authorization: Bearer stg-test-token" \
  -H "Content-Type: application/json" \
  -d '{
    "role": "manager",
    "email": "mgr-stg-test-'$(date +%s)'@test.hcm.internal",
    "name": "STG Test Manager"
  }'
# Expected: 201 Created

# 4. Verify precondition worked
mysql -h stg-db.internal -u test_user -p << EOF
SELECT id, role, email FROM users WHERE role='manager' 
  AND email LIKE 'mgr-stg-test-%';
EOF
# Expected: 1 row returned

# 5. Document state for test
cat > domain/web/pm/STG-ENVIRONMENT-SETUP.md << 'EOF'
# STG Environment Setup: DF-M1-POS-001

## Verified Date: 2026-01-20 10:30 UTC

### Connectivity
- [x] API endpoint: stg.api.hcm.internal (200 OK)
- [x] Database: stg-db.internal:3306 (accessible)
- [x] Queue: stg-queue.internal:5672 (accessible)

### Preconditions
- [x] Manager user created
  - ID: user_123
  - Email: mgr-stg-test-1234567890@test.hcm.internal
  - Verified in DB: YES

### Data State
- [x] users table: 15 records (clean)
- [x] employees table: 0 records (clean)
- [x] audit_log: ready

### Configuration
- [x] API_URL=https://stg.api.hcm.internal
- [x] DB_HOST=stg-db.internal
- [x] FEATURE_FLAG_NEW_FORM=enabled
- [x] RATE_LIMIT=1000/min (should not affect test)

### Ready for Test
Status: YES ✓
Confirmed by: automation_engineer
Date: 2026-01-20 10:30 UTC
EOF
```

---

## Step 3: Run Test in STG

**Execute test in staging environment:**

```bash
# 1. Set environment to staging
export ENVIRONMENT=stg
export API_URL=https://stg.api.hcm.internal
export DB_HOST=stg-db.internal
export TEST_ACCOUNT_EMAIL=mgr-stg-test-1234567890@test.hcm.internal

# 2. Run test
npm test -- create-employee.spec.ts --project=chromium

# Expected output:
# ✓ Create employee with valid data -> created (45.2s) [STG]

# If FAILED:
# - Capture error + screenshot
# - Check: Is it test code issue or stg environment issue?
# - Follow doc 22-automation-fixing-best-practices.md for systematic diagnosis
#   (Distinguish: local code bug vs environment parity vs product defect)
# - Investigate root cause
# - Fix and re-run

# 3. Document result
cat > domain/web/pm/STG-TEST-RUN-RESULT.md << 'EOF'
# STG Test Run: DF-M1-POS-001

## Test Execution: 2026-01-20 10:45 UTC

### Environment
- Environment: STG
- API: stg.api.hcm.internal
- Database: stg-db.internal

### Test Result
Status: PASSED ✓
Duration: 45.2s
Platform: Chromium
Test: @covers DF-M1-POS-001 — Create employee with valid data

### Assertions
- [x] PRE executed: manager user created
- [x] Action: Navigate → Fill → Submit
- [x] Then#1: status = DRAFT
- [x] Then#2: id exists
- [x] And#1: createdBy = current user

### Evidence (See doc 23-evidence-collection-standards)
- Video (COMPLETE): outputs/evidence/2026-01-20/DF-M1-POS-001-complete.webm
  - From: PRE execution → Steps → Final result
  - Not: Partial or cut segments
- Screenshot: outputs/evidence/2026-01-20/success.png
- Logs: outputs/logs/2026-01-20/DF-M1-POS-001-stg.log

### Data Created
- Employee ID: emp_456
- Status: DRAFT
- Created in DB: YES ✓

### Cleanup
- Test data deleted: YES
- Rollback: Complete ✓
- State after test: Clean ✓

Confirmed by: automation_engineer
Date: 2026-01-20 10:45 UTC
EOF
```

---

## Step 4: Verify Regression Readiness

**Confirm automation is ready for regression testing:**

### **Checklist: Regression Ready**

```
Code Quality:
  [ ] Test passing in dev? YES
  [ ] Test passing in stg? YES
  [ ] No hardcoded values? YES
  [ ] No environment-specific logic? YES
  [ ] Assertions meaningful? YES

Environment Compatibility:
  [ ] Works in dev? YES
  [ ] Works in stg? YES
  [ ] Precondition executable in stg? YES
  [ ] Data isolation working? YES
  [ ] Cleanup working? YES

Documentation:
  [ ] AUTOMATION-CHECKLIST complete? YES
  [ ] STG-ENVIRONMENT-SETUP documented? YES
  [ ] STG-TEST-RUN-RESULT documented? YES
  [ ] Precondition documented? YES
  [ ] Data cleanup documented? YES

Maintenance:
  [ ] Instructions for running: Clear? YES
  [ ] Troubleshooting guide: Present? YES
  [ ] Known issues: None? YES
  [ ] Flakiness: None observed? YES

Ready for Regression:
  [ ] Can run daily? YES
  [ ] Can run against new code changes? YES
  [ ] Can scale to multiple runs? YES
  [ ] Will catch regressions? YES
```

---

## Step 5: Document for QA/Regression Team

**Create runbook for regression testing:**

```markdown
# Regression Test Runbook: DF-M1-POS-001

## Test Overview
- **ID:** DF-M1-POS-001
- **Feature:** Create Employee
- **Scenario:** Create employee with valid data
- **Test Status:** Automated ✓
- **Environment:** STG (primary) + DEV (development)
- **Regression Frequency:** Daily (every commit)

## How to Run

### Prerequisites
```bash
export ENVIRONMENT=stg
export API_URL=https://stg.api.hcm.internal
export DB_HOST=stg-db.internal
```

### Command
```bash
npm test -- create-employee.spec.ts --project=chromium

# Or with filtering:
npm test -- --grep "@covers DF-M1-POS-001"
```

### Expected Duration
- 45-50 seconds (includes PRE setup + test + cleanup)

## What It Tests
1. **Precondition:** Manager user exists
2. **Action:** Navigate to create form → Fill → Submit
3. **Expected Results:**
   - Employee record created
   - Status = DRAFT (not ACTIVE)
   - Employee ID assigned
   - Created by current user

## Success Criteria
- [x] Test passes (green ✓)
- [x] No network errors
- [x] No database errors
- [x] Data cleanup complete (no orphaned records)

## Failure Diagnosis

### If Test Fails
1. **Check precondition:**
   - Is manager user API responding?
   - Can test access database?
   ```bash
   curl https://stg.api.hcm.internal/health
   mysql -h stg-db.internal -u test_user -p -e "SELECT 1"
   ```

2. **Check UI changes:**
   - Did selectors change?
   - Is form still at /employees/create?
   - Check: git log --oneline domain/web/pm/

3. **Check feature regression:**
   - Is status field still created?
   - Is it still set to DRAFT on creation?
   - Check: Employee creation logic

4. **Capture evidence:**
   - Screenshot (included automatically)
   - Video (included automatically)
   - Logs: ./outputs/logs/

### Common Failures
- ❌ "Selector not found": UI changed, update grounding
- ❌ "HTTP 500": API error, check server logs
- ❌ "Timeout": Network issue, check connectivity
- ❌ "Status = ACTIVE": Code regression, check logic

## Maintenance

### When to Update Test
- [ ] UI selector changed → Update PAGE layer
- [ ] API response format changed → Update USECASE layer
- [ ] Expected value changed → Update TC + SPEC layer
- [ ] Precondition changed → Update FACTORY layer

### Who to Contact
- **Automation Issues:** @automation-team
- **Feature Regression:** @pm-team
- **Infrastructure Issues:** @devops-team

## History
- **Created:** 2026-01-15
- **Last Run:** 2026-01-20 10:45 UTC
- **Status:** Passing consistently
- **Flakiness:** None observed
```

---

## Step 6: Confirm with QA Lead

**Get approval before marking complete:**

```markdown
QA Lead Verification Checklist:

- [ ] Test passes in STG? YES/NO
- [ ] Preconditions working? YES/NO
- [ ] Data cleanup complete? YES/NO
- [ ] No flakiness observed? YES/NO
- [ ] Documentation clear? YES/NO
- [ ] Runbook ready? YES/NO
- [ ] Ready for daily regression? YES/NO

Approval: ✓ APPROVED FOR REGRESSION
Signed by: [QA Lead Name]
Date: [YYYY-MM-DD HH:MM UTC]

Status: Automation complete + regression-ready
```

---

## Phase 5.5 Complete: Environment Confirmation Done ✓

**At this point:**

```
✅ Test passes in dev
✅ Test passes in stg
✅ Preconditions verified in stg
✅ Data isolation working
✅ Cleanup working
✅ Documentation complete
✅ Regression runbook ready
✅ QA lead approved

→ READY FOR PHASE 6 (PR Review + Merge)
```

---

## What Changes from DEV to STG?

**Only configuration, NOT code:**

```
❌ WRONG: Different test code for stg
  if (process.env.ENVIRONMENT === 'stg') {
    // different assertions
  }

✅ RIGHT: Same test code, different config
  API_URL=https://stg.api.hcm.internal
  DB_HOST=stg-db.internal
  (test code exactly same)
```

---

## Why This Matters for Regression

```
Regression test runs EVERY commit:
  1. Engineer makes code change
  2. CI runs automation tests
  3. Test runs in STG
  4. If fails: regression detected, PR blocked
  5. Engineer must fix regression
  6. Test passes: no regression, PR approved

For this to work:
  ✅ Test must be reliable in stg
  ✅ No flakiness
  ✅ Preconditions always work
  ✅ Data always gets cleaned up
  ✅ Assertions always meaningful
  
If ANY of above fails:
  ❌ Regression tests become noisy
  ❌ False positives → engineers ignore results
  ❌ Real regressions slip through
  ❌ QA finds bugs in prod 💥
```

---

## References

- **14-executability-principle.md** — Why "everything executable in stg"
- **05-verify-evidence.md** — Evidence collection in dev
- **skills/automation-pr-review/SKILL.md** → Now can check: "does it work in stg?"
- **regression-testing-strategy.md** (future) — How to run automation daily
