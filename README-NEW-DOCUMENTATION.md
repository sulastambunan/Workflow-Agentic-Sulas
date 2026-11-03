# New Automation Documentation: Upstream Prevention & Detailed Diagnostics

**Date:** 2026-01-15  
**Status:** Ready for PR  
**Scope:** 6 new/updated documentation files for Workflow-Agentic-Sulas

---

## 📋 Overview

Dokumentasi baru ini fokus pada **upstream prevention** (prevent bugs saat grounding/implementation) dan **detailed diagnostics** (jelas bagaimana handle kalau test fail).

**Problem solved:**
- ❌ Tautology hanya detect di PR review → NOW prevent di grounding
- ❌ Swallowed errors hanya detect di PR review → NOW prevent di implementation
- ❌ Hardcoded values hanya detect di PR review → NOW prevent di design
- ❌ Test failure unclear saat runtime → NOW detailed diagnosis framework
- ❌ Automation tidak traceable ke TC → NOW centralized verification checklist
- ❌ Environment issues surprise saat verify → NOW ask Phase 0

---

## 📁 Files to Create/Update

### **NEW FILES** (6)

```
docs/shared/14-executability-principle.md
  └─ RULE: EVERYTHING must be executable in dev/stg
  └─ Covers: SPEC, USECASE, Layer3, FACTORY, PRE
  └─ Verify: All layers tested in SAME environment
  └─ Checklists per phase (grounding, design, implement, verify)

docs/shared/15-test-failure-reporting.md ✅ CREATED
  └─ Standard failure report format
  └─ 5 failure types: PRE fail, FACTORY fail, USECASE error, Layer3 fail, SPEC assertion fail
  └─ Decision tree: "What to do when test fails?"
  └─ Evidence requirements: screenshot, video, logs, stack trace

docs/shared/16-assertion-design.md
  └─ RULE: Every assertion must be able to FAIL
  └─ RULE: Every error must PROPAGATE
  └─ RULE: Every value from TC (not code)
  └─ Prevent: Tautology, swallowed error, hardcoded value
  └─ Error handling patterns per layer
  └─ Checklist: Before implementing code

docs/shared/17-traceability-record.md
  └─ AUTOMATION-CHECKLIST-<TC-ID>.md template
  └─ Given/When/Then mapping
  └─ Red flag prevention checklist
  └─ Self-review before push
  └─ Centralized verification (not scattered in code)

INTEGRATION-MAP.md (move to docs/shared/)
  └─ How new docs integrate with skill automation-pr-review
  └─ 3-layer review system: static code → executability → runtime
  └─ Where to add executability checks in skill
  └─ Updated files list
```

### **FILES TO UPDATE** (5)

```
workflow/00-ledger-intake.md
  └─ ADD: Step 6 — Environment & Data Setup questionnaire
  └─ ASK: target environment, test account, test data, env config, cleanup policy
  └─ Output: Environment & data documented before Phase 1
  └─ Goal: Prevent surprise in Phase 5 (Verify)

workflow/04-implement.md
  └─ ADD: Implementation Output section
  └─ Create: AUTOMATION-CHECKLIST-<TC-ID>.md
  └─ Create: Code comments (@covers, // src:, // expect:)
  └─ Reference: 14-executability-principle.md, 16-assertion-design.md
  └─ Link: workflow/05-verify-evidence.md → 15-test-failure-reporting.md

workflow/05-verify-evidence.md
  └─ ADD: Failure Diagnosis section
  └─ Reference: docs/shared/15-test-failure-reporting.md (detailed error diagnosis)
  └─ Link: failure report format, decision tree, evidence requirements

docs/shared/11-pre-push-review.md
  └─ ADD: Traceability Verification checklist
  └─ Check: AUTOMATION-CHECKLIST-<TC-ID>.md exist?
  └─ Check: Clause table complete? Red flags scanned?
  └─ Reference: docs/shared/17-traceability-record.md

skills/automation-pr-review/SKILL.md
  └─ ADD: Section 5.1 Executability validation
  └─ ADD: Section 6.1 When tests have been executed
  └─ ADD: Section 8 Failure diagnosis & executability findings
  └─ Reference: docs/shared/14-executability-principle.md, 15-test-failure-reporting.md
  └─ Link: new docs in report template
```

---

## 🎯 Core Principles

### 1. Executability Principle (doc 14)

```
NOT: "Assume code will work"
BUT: "Verify everything works in REAL environment"

Every assertion, endpoint, selector, value, precondition
must be VERIFIED IN REAL ENVIRONMENT before code.
```

### 2. Assertion Quality (doc 16)

```
Rule 1: Every assertion must be able to FAIL
        ✅ expect(status).toBe('DRAFT')
        ❌ expect(true).toBe(true)

Rule 2: Every error must PROPAGATE
        ✅ throw new Error(`Failed: ${msg}`)
        ❌ .catch(() => false)

Rule 3: Every value from TC (not code)
        ✅ From TC Then clause
        ❌ From code assumption
```

### 3. Detailed Failure Diagnosis (doc 15)

```
When test FAILS at runtime:
  1. Identify LAYER (PRE, FACTORY, USECASE, Layer3, SPEC)
  2. Root cause analysis
  3. Evidence (screenshot, video, logs, stack trace)
  4. Decision tree (fix code? re-ground? escalate?)
  
Not: "Test failed"
But: "SPEC assertion fail at line 26: expect(status).toBe('DRAFT') 
      actual='PENDING'. Decision: update TC or report defect?"
```

### 4. Centralized Traceability (doc 17)

```
NOT: Comments scattered in code
BUT: AUTOMATION-CHECKLIST-<TC-ID>.md
     ├─ Explicit: TC clause → assertion mapping
     ├─ Self-reviewed: engineer verify match
     └─ Centralized: one place to see full coverage

Plus: Code comments as backup (@covers, // expect:, // src:)
```

---

## 📊 Integration: Where Each Doc Is Used

```
Phase 0: INTAKE
  └─ workflow/00-ledger-intake.md (Step 6 — ask environment + data)

Phase 1: GROUNDING
  └─ doc 14-executability-principle.md (selector, endpoint, value ground)
  └─ workflow/01-grounding.md → output grounding file

Phase 2: DESIGN
  └─ doc 14-executability-principle.md (verify executability signals)
  └─ doc 16-assertion-design.md (design assertion template)

Phase 3: MAPPING
  └─ doc 14-executability-principle.md (DDD per layer)
  └─ workflow/03-layer-mapping.md

Phase 4: IMPLEMENT
  └─ doc 14-executability-principle.md (checklist per layer)
  └─ doc 16-assertion-design.md (error handling pattern)
  └─ workflow/04-implement.md (add implementation output)
  └─ doc 17-traceability-record.md (create AUTOMATION-CHECKLIST)

Phase 5: VERIFY
  └─ workflow/05-verify-evidence.md (run test)
  └─ doc 15-test-failure-reporting.md (IF test fails, diagnose)
  └─ doc 17-traceability-record.md (verify checklist complete)

Phase 6: PRE-PUSH REVIEW
  └─ docs/shared/11-pre-push-review.md (traceability checklist)
  └─ skill automation-pr-review/SKILL.md (confirm upstream done)

PR REVIEW (lead)
  └─ skill automation-pr-review/SKILL.md
  └─ doc 14-executability-principle.md (executability findings)
  └─ doc 15-test-failure-reporting.md (IF tests executed + failed)
```

---

## 💡 Key Changes from Previous Workflow

### **Before (Downstream Detection)**
```
Code → Test → PR Review (FIRST catch red flags)
                ↑ Detect: tautology, swallowed error, hardcoded
                ↑ Fix needed, rework
```

### **After (Upstream Prevention + Detailed Diagnosis)**
```
Grounding (verify executability)
  ↓
Design (assertion design template, error handling plan)
  ↓
Implement (follow checklist, prevent red flags)
  ↓
Verify (run test, IF fail → detailed diagnosis)
  ↓
Pre-push (centralized traceability checklist)
  ↓
PR Review (confirm, should rarely find issue)

Result: Quality at source, clear diagnosis if fail
```

---

## 📝 Summary: What's New

| Aspect | Before | After |
|--------|--------|-------|
| **Executability** | Assumed | Verified per phase (doc 14) |
| **Assertion design** | Trial and error | Template before code (doc 16) |
| **Error handling** | Surprise at runtime | Planned per layer (doc 16) |
| **Failure diagnosis** | Vague error message | Structured report (doc 15) |
| **TC traceability** | Scattered in code | Centralized checklist (doc 17) |
| **Environment setup** | Ask Phase 5 | Ask Phase 0 intake |
| **Red flag detection** | PR review | Upstream prevention |
| **Skill integration** | Static code only | +Executability +Failure diagnosis |

---

## 🚀 Implementation Plan

### Step 1: Create New Files
```bash
# docs/shared/14-executability-principle.md
# docs/shared/16-assertion-design.md
# docs/shared/17-traceability-record.md
# INTEGRATION-MAP.md → docs/shared/
```

### Step 2: Update Existing Files
```bash
# workflow/00-ledger-intake.md (add Step 6)
# workflow/04-implement.md (add Implementation Output)
# workflow/05-verify-evidence.md (add Failure Diagnosis)
# docs/shared/11-pre-push-review.md (add Traceability Check)
# skills/automation-pr-review/SKILL.md (add Executability + Failure sections)
```

### Step 3: Create PR
```bash
# Commit message:
# "docs: add upstream prevention & detailed failure diagnostics
#  
#  - New: 14-executability-principle.md (EVERYTHING executable)
#  - New: 16-assertion-design.md (prevent tautology/swallowed error)
#  - New: 17-traceability-record.md (centralized verification)
#  - Update: workflow/00,04,05 + docs/11 + skill review
#  - Integration: 3-layer review system documented
#
#  Goal: Prevent bugs upstream, diagnose clearly at runtime."
```

---

## ✅ Checklist Before PR

```
[ ] All 3 new .md files created (14, 16, 17)
[ ] INTEGRATION-MAP.md moved to docs/shared/
[ ] workflow/00-ledger-intake.md updated (Step 6)
[ ] workflow/04-implement.md updated (Implementation Output)
[ ] workflow/05-verify-evidence.md updated (Failure Diagnosis)
[ ] docs/shared/11-pre-push-review.md updated (Traceability Check)
[ ] skills/automation-pr-review/SKILL.md updated (Executability + Failure)
[ ] All internal links verified (cross-references work)
[ ] README-NEW-DOCUMENTATION.md created (this file)
[ ] Git commit with descriptive message
[ ] PR created with summary
```

---

## 📚 Reading Order

**For automation engineers:**
1. doc 14-executability-principle.md (know what's executable)
2. doc 16-assertion-design.md (design before code)
3. doc 17-traceability-record.md (create AUTOMATION-CHECKLIST)
4. workflow/04-implement.md (reference for Phase 4)
5. doc 15-test-failure-reporting.md (IF test fails)

**For QA lead/reviewer:**
1. INTEGRATION-MAP.md (understand 3-layer review)
2. skill automation-pr-review/SKILL.md (updated sections)
3. doc 14-executability-principle.md (what to look for)
4. doc 15-test-failure-reporting.md (failure diagnosis)
5. doc 17-traceability-record.md (what to verify)

---

## 🎯 Expected Outcomes

✅ **Upstream prevention:**
- Tautology prevented in grounding/design
- Swallowed error prevented in design
- Hardcoded value prevented in design
- Executability verified per phase

✅ **Detailed diagnostics:**
- Test failure clear (layer identified, root cause known)
- Evidence collected (screenshot, video, logs)
- Decision tree clear (fix? re-ground? escalate?)

✅ **Quality gate enforcement:**
- Centralized AUTOMATION-CHECKLIST verified
- Pre-push script checks executability signals
- PR review confirms, rarely finds new issue

✅ **Faster automation cycle:**
- Less rework (quality upstream)
- Faster debugging (clear failure reports)
- Confident deployment (traceable to TC)

---

**Next step:** Review documentation, push to repo, create PR ✅
