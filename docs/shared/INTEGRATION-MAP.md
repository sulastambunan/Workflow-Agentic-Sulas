# Integration Map: Review Skill + 3 New Documentation Layers

Dokumentasi baru (14-executability-principle.md, 15-test-failure-reporting.md) harus integrate dengan skill automation-pr-review yang sudah ada.

---

## Review Layers

```
LAYER 1: Static Code Review (SKILL automation-pr-review)
  ├─ Input: PR diff (code only)
  ├─ Checks: Clause table, red flags, vacuous pass, pitfalls, gates, DDD
  ├─ Scope: Does code look right? (syntax, logic, coverage)
  ├─ Outcome: PASS / REQUEST_CHANGES / CONDITIONAL
  └─ Reference: skills/automation-pr-review/SKILL.md
  
  NEVER runs tests. Code-only review by default.

LAYER 2: Executability Principle Validation
  ├─ Input: Code + grounding evidence + TC expectations
  ├─ Checks: Is this actually executable in target env?
  ├─ Scope: SPEC executable? USECASE calls real endpoint? Layer3 selectors exist? FACTORY data valid? PRE works?
  ├─ Applied at: Code review (secondary check), Grounding phase (primary)
  ├─ Outcome: BLOCKED (not executable) / PASS (executable)
  └─ Reference: docs/shared/14-executability-principle.md (TO BE CREATED)

LAYER 3: Runtime Failure Diagnosis (when tests are run)
  ├─ Input: Test execution result (pass/fail)
  ├─ Checks: If fail, identify layer, root cause, what to do
  ├─ Scope: Detailed error diagnosis with evidence
  ├─ Applied at: Runtime, feedback to code/grounding if needed
  ├─ Outcome: Root cause identified, action item clear
  └─ Reference: docs/shared/15-test-failure-reporting.md (CREATED)
```

---

## Relationship Matrix

| Doc | Applied By | When | Scope | Links To |
|-----|-----------|------|-------|----------|
| **skills/automation-pr-review/SKILL.md** | Lead reviewer | PR open | Static code review (clause table, red flags, pitfalls) | → references/ (3 files) |
| **14-executability-principle.md** (NEW) | Both (coder + reviewer) | Grounding + code review | Is code executable in real env? | → skill review (Layer2), → 15 (runtime) |
| **15-test-failure-reporting.md** (CREATED) | Automation engineer | Runtime (test fails) | How to diagnose & report failure | ← 14 (executability), ← skill review |

---

## Skill PR Review: Where to Add Executability Checks

### **Step 5: Code checks → ADD subsection**

Current:
```markdown
### 5. Code checks

Run the scan recipes and walk the pitfall lists in `references/review-checks.md`: red flags,
vacuous passes, environment/time/data assumptions, DDD and hygiene, mobile selector grounding.
```

ADD:
```markdown
### 5.1 Executability validation (code-only check)

Even without running tests, code review can check executability signals:

- **SPEC layer:** 
  - ✅ Every `expect()` has `// expect: <TC-ID> Then#n` comment?
  - ✅ Expected values from TC, not from code?
  - ❌ Tautology or stub assertion? (red flag)

- **USECASE layer:**
  - ✅ Calls real endpoint (not mocked)?
  - ✅ Response validated?
  - ❌ Exception swallowed? (red flag)

- **Layer 3 (PAGE/COMPONENT):**
  - ✅ Selector has `// src: filepath:line` comment?
  - ✅ Selector was grounded (not memory)?
  - ❌ Selector from code constant/import (not hardcoded string)?

- **FACTORY:**
  - ✅ Generates data per schema?
  - ✅ Data is varied (not hardcoded)?
  - ❌ Calls API or business logic? (red flag)

- **PRE:**
  - ✅ Setup endpoint explicitly called?
  - ✅ Database state asserted after PRE?
  - ❌ PRE skipped or assumed? (red flag)

Reference: `docs/shared/14-executability-principle.md`
```

---

### **Step 6: Gates → ADD note for executed reviews**

Current:
```markdown
### 6. Gates

Run them in a temporary detached worktree of the head...
```

ADD:
```markdown
### 6.1 When tests have been executed (optional in intake)

If intake says review basis is "executed" (tests actually ran):

1. **Executability checkpoint:** Did test execution match code expectations?
   - PRE: did setup endpoint respond? Did DB mutation happen?
   - USECASE: did it call real endpoint or mock?
   - Layer3: did selectors find elements?
   - FACTORY: did generated data pass validation?

   Reference: `docs/shared/14-executability-principle.md`

2. **Runtime failures:** If test failed, diagnose using failure report format
   - Which layer failed?
   - Root cause?
   - Is this blocker or needs decision?

   Reference: `docs/shared/15-test-failure-reporting.md`

3. **Evidence:** Screenshot/video must show
   - Full test execution flow
   - Exact moment of failure
   - Error message (browser console, network log)
   - Browser + environment info
```

---

### **Step 8: Report → ADD executability & failure sections**

Current findings format:
```markdown
### 8. Report

Write the report with `references/report-and-posting.md`: verdict, basis, assumption ledger,
verified findings with file:line and evidence, reported-not-verified, coverage per `@covers`,
what checks out, and questions for the author.
```

ADD section to report template:
```markdown
## Executability findings (if tests executed)

Per `docs/shared/14-executability-principle.md`:

- PRE execution: [blocked | passed | skipped]
  - If failed: database state not mutated
  - Action: [fix environment | update PRE | escalate]

- FACTORY validation: [blocked | passed]
  - If failed: data schema invalid
  - Action: [fix FACTORY | use static data]

- USECASE execution: [blocked | passed]
  - If failed: endpoint not responding OR logic error
  - Action: [environment issue | code fix | defect]

- Layer3 grounding: [verified | outdated | fabricated]
  - If outdated: selector changed in app
  - Action: [re-ground | update code]

- SPEC assertions: [all asserted | weaker | missing | extra]
  - If assertion fail: compare TC vs actual behavior
  - Action: [update TC | report defect | decision needed]

## Failure diagnosis (if test failed)

Per `docs/shared/15-test-failure-reporting.md`:

- Failed test: [@covers TC-ID]
- Layer: [SPEC | USECASE | Layer3 | FACTORY | PRE]
- Error: [message + screenshot + video]
- Root cause: [diagnosis from evidence]
- Action: [fix code | re-ground | escalate | known issue]
```

---

## Precondition Execution: Specific Skill Updates

Skill automation-pr-review should explicitly check precondition execution:

### **Add to step 4 (Testcase faithfulness):**

```markdown
### 4.1 Precondition validation

For each testcase that the PR @covers:

1. **Check PRE definition:**
   - staffinc-testcase/preconditions/*.md for PRE needed
   - Is PRE executable (endpoint + database mutation)?
   - Is PRE sitasi'd in SPEC code (which FACTORY method)?

2. **Check PRE execution in code:**
   - SPEC has test.step('PRE: ...') before scenario?
   - PRE await'd and assert status?
   - PRE failure stops test (not skipped)?

3. **Check PRE evidence (if tests executed):**
   - Did PRE endpoint respond?
   - Did database mutation happen?
   - Does PRE step.passed in run output?

4. **Decision if PRE not executable:**
   - PRE blocked = TC remains PLANNED (not AUTOMATED)
   - Do not claim automation if PRE setup fails
   - Status field in TC must reflect this

Reference: `docs/shared/14-executability-principle.md` — PRE execution rule
```

---

## Filing & References

### **Update existing docs to cross-link:**

In `docs/shared/11-pre-push-review.md`:
```markdown
Adaptasi self-review sebelum push (Staffinc)

(existing content...)

Untuk runtime failure handling, lihat `docs/shared/15-test-failure-reporting.md`.
Untuk executability validation, lihat `docs/shared/14-executability-principle.md`.
```

In `skills/automation-pr-review/SKILL.md`:
```markdown
## References

- reviews of code-only PRs: `references/` (3 files in this skill)
- executability principle: `docs/shared/14-executability-principle.md`
- runtime failure diagnosis: `docs/shared/15-test-failure-reporting.md`
```

In `workflow/04-implement.md` (or wherever Layer 3 is discussed):
```markdown
Layer 3 implementation must be executable in target environment.
See: `docs/shared/14-executability-principle.md` - Layer 3 checks
```

In `workflow/05-verify-evidence.md`:
```markdown
When test fails, follow detailed failure reporting format.
See: `docs/shared/15-test-failure-reporting.md`
```

---

## Summary: 3-Layer Review Checklist

```
BEFORE opening PR (Self-check):
  └─ Use: pre-push review script + 14-executability-principle.md
  └─ Check: Code looks executable? Every layer verified?

AFTER opening PR (Lead review):
  └─ Use: SKILL automation-pr-review (static code review)
  └─ Then: 14-executability-principle.md (executability signals)
  └─ Then: 15-test-failure-reporting.md (if tests ran + failed)

WHEN test fails (Runtime diagnosis):
  └─ Use: 15-test-failure-reporting.md (detailed error format)
  └─ Report: Which layer? Root cause? Evidence? Action?
  └─ Feedback: Update code / re-ground / escalate
```

---

## Files to Create/Update

### CREATE (New docs):
- `docs/shared/14-executability-principle.md` ← NEEDED
- `docs/shared/15-test-failure-reporting.md` ← CREATED ✅

### UPDATE (Add cross-links):
- `skills/automation-pr-review/SKILL.md` 
  - Add 5.1 Executability validation
  - Add 6.1 When tests executed
  - Add references to new docs
  
- `docs/shared/11-pre-push-review.md`
  - Add link to 15-test-failure-reporting.md
  
- `workflow/05-verify-evidence.md`
  - Add link to 15-test-failure-reporting.md

---

## Why This Integration Matters

```
Without integration:
- Static code review find issues, but not know if executable at runtime
- Tests run and fail, but no standard diagnosis process
- Skill + docs live separate, gap between code review + runtime

With integration:
- Code review includes executability checks
- Runtime failures have diagnosis framework
- Skill + docs aligned: Layer1 (code) → Layer2 (executable) → Layer3 (runtime)
- Clear decision tree: "this failed because X, action is Y"
```
