# 📚 DOCUMENTATION INDEX (Clear Version)

---

## 1️⃣ WORKFLOW: Create Automation from Scratch until Finish

**When:** Kamu kasih PRD, saya buat automation sampai bisa dijalankan di STG

### Step 1.1: Understand Big Picture (5 min)
**Tujuan:** Tahu workflow dari PRD → automation live

📖 **Read:**
- `18-e2e-prd-to-automation.md` → Section "Overview: 3 GATES + 6 PHASES"

**Apa yang dipelajari:**
- GATE A: PRD → TSD (saya buat TSD dari PRD)
- GATE B: TSD → TC (saya buat test case dari TSD)
- GATE C: Phase 0-6 (saya create automation code)
- Phase 5.5: Confirm STG (setup test di staging)

---

### Step 1.2: Understand Rule - Apa itu "Executable" (10 min)
**Tujuan:** Tahu apa yang harus executable saat bikin automation

📖 **Read:**
- `14-executability-principle.md` → Keseluruhan

**Apa yang dipelajari:**
- SPEC layer: Assertions harus meaningful (bisa fail)
- USECASE layer: API calls real endpoint (bukan mock)
- PAGE layer: Selectors harus ada di UI
- FACTORY layer: Data harus varied (bukan hardcoded)
- PRE layer: Preconditions harus executable di dev/stg

---

### Step 1.3: Understand Red Flags - Apa yang DILARANG saat code (10 min)
**Tujuan:** Tahu apa mistakes yang harus dihindari

📖 **Read:**
- `16-assertion-design.md` → Keseluruhan

**Apa yang dipelajari:**
- ❌ TAUTOLOGY: expect(true).toBe(true) — dilarang!
- ❌ SWALLOWED ERROR: .catch(() => false) — dilarang!
- ❌ HARDCODED VALUE: const email = 'test@test.co' — dilarang!
- ✅ Gimana design assertion yang benar

---

### Step 1.4: GATE A - Convert PRD → TSD (30 min)
**Tujuan:** Saya create TSD file (test scenario definition) dari PRD kamu

📖 **Read:**
- `18-e2e-prd-to-automation.md` → Section "GATE A: TSD-writer (PRD → TSD)"

**Apa yang saya lakukan:**
1. Read PRD kamu
2. Create TSD file dengan 12 sections
3. Self-check quality
4. Output: TSD file (ask your approval)

**Kamu perlu:** Review TSD, kasih approval atau clarify

---

### Step 1.5: GATE B - Convert TSD → TC (30 min)
**Tujuan:** Saya create test case + preconditions dari TSD

📖 **Read:**
- `18-e2e-prd-to-automation.md` → Section "GATE B: testcase-writer (TSD → TC)"

**Apa yang saya lakukan:**
1. Create TC file (test case) per scenario
2. Create/reuse PRE (preconditions) files
3. Validate dengan validator-tsd-sync.py
4. Push ke staffinc-testcase repo

**Kamu perlu:** Informed saja, auto-commit

---

### Step 1.6: GATE C Phase 0 - Intake (15 min)
**Tujuan:** Confirm scope dan ask environment questions

📖 **Read:**
- `18-e2e-prd-to-automation.md` → Section "Phase 0: Intake"

**Apa yang saya lakukan:**
1. Read TC dari staffinc-testcase
2. Ask questions: target env, test account, test data, cleanup
3. Create intake document

**Kamu perlu:** Answer environment questions

---

### Step 1.7: GATE C Phase 1 - Grounding (20 min)
**Tujuan:** Verify bahwa setiap selector, endpoint, value bisa ditemukan di codebase

📖 **Read:**
- `18-e2e-prd-to-automation.md` → Section "Phase 1: Grounding"
- `14-executability-principle.md` → Section "Layer 1: SPEC" ... "Layer 5: PRE"

**Apa yang saya lakukan:**
1. Find selector di UI code (cite file:line)
2. Find endpoint di API code (cite file:line)
3. Find expected values di TC
4. Create grounding document

**Kamu perlu:** Review grounding, approve atau flag yang gk bisa ditemukan

---

### Step 1.8: GATE C Phase 2 - Design (20 min)
**Tujuan:** Design assertion per TC clause, error handling plan

📖 **Read:**
- `18-e2e-prd-to-automation.md` → Section "Phase 2: Design"
- `16-assertion-design.md` → Keseluruhan

**Apa yang saya lakukan:**
1. Design assertion per Then/And clause
2. Verify: can fail? meaningful? from TC?
3. Plan error handling per layer
4. Create design document

**Kamu perlu:** Review design, approve

---

### Step 1.9: GATE C Phase 3 - Mapping (15 min)
**Tujuan:** Map ke file structure (SPEC, USECASE, PAGE, FACTORY)

📖 **Read:**
- `18-e2e-prd-to-automation.md` → Section "Phase 3: Mapping"

**Apa yang saya lakukan:**
1. Map: SPEC file path, USECASE path, PAGE path, FACTORY path
2. Identify PRE factory location
3. Create mapping document

**Kamu perlu:** Review, approve atau suggest changes

---

### Step 1.10: GATE C Phase 4 - Implement (45 min)
**Tujuan:** Write code per DDD layer, add comments, create AUTOMATION-CHECKLIST

📖 **Read:**
- `18-e2e-prd-to-automation.md` → Section "Phase 4: Implement"
- `16-assertion-design.md` → Section "Implementation Checklist"
- `17-traceability-record.md` → Keseluruhan

**Apa yang saya lakukan:**
1. Code PRE factory (data generation)
2. Code USECASE (business logic)
3. Code PAGE (UI interactions)
4. Code SPEC (test assertions)
5. Add code comments: @covers, // src:, // expect:
6. Create AUTOMATION-CHECKLIST-<TC-ID>.md
7. Run test

**Output:**
- Code files (SPEC, USECASE, PAGE, FACTORY)
- AUTOMATION-CHECKLIST-<TC-ID>.md
- Test result: PASSED

**Kamu perlu:** Informed saja, atau review code jika diminta

---

### Step 1.11: GATE C Phase 5 - Verify (Dev) (15 min)
**Tujuan:** Run test di dev, collect evidence

📖 **Read:**
- `18-e2e-prd-to-automation.md` → Section "Phase 5: Verify"
- `15-test-failure-reporting.md` → Jika test fail

**Apa yang saya lakukan:**
1. Run test di dev
2. Collect: screenshot, video, logs
3. Verify: PRE executed, all assertions pass

**Output:**
- Test status: PASSED ✓
- Evidence files

**Kamu perlu:** Informed saja

---

### Step 1.12: GATE C Phase 5.5 - Environment Confirmation (STG) (30 min)
**⚠️ PENTING:** Automation NOT "done" jika hanya pass di dev!

📖 **Read:**
- `21-environment-confirmation-stg.md` → Keseluruhan

**Apa yang saya lakukan:**
1. Setup precondition di STG
2. Run test di STG (same code, different config)
3. Verify: PRE executable, test pass, cleanup working
4. Document: STG-ENVIRONMENT-SETUP.md, STG-TEST-RUN-RESULT.md
5. Get QA lead approval: "Regression ready?"

**Output:**
- Test status: PASSED in STG ✓
- Documentation: environment setup + test result
- Approval: QA lead sign-off

**Kamu perlu:** Approve atau flag issues di STG

---

### Step 1.13: GATE C Phase 6 - PR Review & Merge (20 min)
**Tujuan:** Create PR, lead review, merge

📖 **Read:**
- `19-pr-review-prerequisites.md` → Jika lead-nya baca ini

**Apa yang saya lakukan:**
1. Self-review checklist
2. Create PR dengan judul, description, evidence
3. Lead reviewer runs skill: automation-pr-review
4. Lead approve: APPROVED
5. Merge PR

**Output:**
- PR merged ✓
- Automation live + regression-ready ✓

**Status: SELESAI! 🎉**

---

---

## 2️⃣ WORKFLOW: Review PR Automation (You as QA/Lead)

**When:** Ada PR automation yang kamu perlu review

### Step 2.1: Find TC di staffinc-testcase (10 min)
**Tujuan:** Locate test case yang di-automate

📖 **Read:**
- `19-pr-review-prerequisites.md` → Section "Step 1: Extract TC ID from PR" ... "Step 2: Locate TC"

**Apa yang kamu lakukan:**
1. Read PR title (ada TC-ID)
2. Search di staffinc-testcase repo: `grep -r "TC-ID" testcase/`
3. Find TC file
4. Note: path + TC ID

---

### Step 2.2: Read & Understand TC (15 min)
**Tujuan:** Understand apa yang TC expect

📖 **Read:**
- `19-pr-review-prerequisites.md` → Section "Step 3: Read TC Completely"

**Apa yang kamu lakukan:**
1. Read TC: Given/When/Then
2. Understand: PRE, actions, expected results
3. Ask: Can this be executed in dev/stg? Data varied?
4. Check: All clauses clear?

**Output:** Clear understanding dari TC

---

### Step 2.3: Review PR Code (Executability) (20 min)
**Tujuan:** Check apakah code bisa dijalankan per layer

📖 **Read:**
- `14-executability-principle.md` → Section "Checklist per layer"
- `19-pr-review-prerequisites.md` → Section "Step 4: Map PR to TC"

**Apa yang kamu check:**
- SPEC: Has @covers TC-ID?
- USECASE: Calls real API (bukan mock)?
- PAGE: Selectors grounded (ada di UI)?
- FACTORY: Data varied (bukan hardcoded)?
- PRE: Precondition called?

---

### Step 2.4: Review PR Code (Red Flags) (15 min)
**Tujuan:** Check apakah ada mistakes

📖 **Read:**
- `16-assertion-design.md` → Section "Red Flags During Code Review"

**Apa yang kamu check:**
- ❌ Tautology? expect(true).toBe(true)
- ❌ Swallowed error? .catch(() => false)
- ❌ Hardcoded value? 'test@test.co'
- ❌ Missing assertion? TC clause tanpa expect()

---

### Step 2.5: Verify AUTOMATION-CHECKLIST (10 min)
**Tujuan:** Confirm traceability

📖 **Read:**
- `17-traceability-record.md` → Section "What to Record"

**Apa yang kamu check:**
- ✅ AUTOMATION-CHECKLIST-<TC-ID>.md exists?
- ✅ All TC clauses listed?
- ✅ Each clause has assertion?
- ✅ Red flags checked?

---

### Step 2.6: Run Skill: automation-pr-review (10 min)
**Tujuan:** Let skill do automated checks

📖 **Read:**
- PR review skill documentation

**Apa yang kamu lakukan:**
```
/automation-pr-review --pr-url <PR_URL> --tc-id <TC-ID>
```

**Output:**
- Layer 1: Static code findings
- Layer 2: Traceability findings
- Layer 3: Executability findings

---

### Step 2.7: Make Decision (5 min)

**If APPROVED:**
```
✓ All checks pass
✓ No blockers
→ Merge PR
→ Automation live
```

**If REQUEST_CHANGES:**
```
✗ Found blocker
→ Comment PR with findings
→ Engineer fixes
→ Repeat from Step 2.3
```

---

---

## 3️⃣ WORKFLOW: Fix PR from Feedback (You as Engineer)

**When:** Lead bilang REQUEST_CHANGES, ada findings yang harus di-fix

### Step 3.1: Read Feedback (10 min)
**Tujuan:** Understand apa yang harus di-fix

📖 **Read:**
- `20-fix-pr-from-feedback.md` → Section "Step 1: Read PR Review Feedback"

**Apa yang kamu lakukan:**
1. Read setiap finding
2. Understand: apa masalahnya, kenapa masalah
3. Categorize: SPEC issue? USECASE issue? PAGE issue? FACTORY issue?

---

### Step 3.2: Fix Issue per Layer (30 min)
**Tujuan:** Fix setiap issue

📖 **Read:**
- `20-fix-pr-from-feedback.md` → Section "Step 2: Categorize Issues" ... "Step 3: Fix Each Issue"
- `16-assertion-design.md` → Reference untuk error handling, assertion design

**Apa yang kamu lakukan:**
1. FACTORY issue: Remove hardcoded, use faker
2. USECASE issue: Propagate error, don't swallow
3. PAGE issue: Ground selector, add // src: comment
4. SPEC issue: Add missing assertion, add // expect: comment

---

### Step 3.3: Run Test (10 min)
**Tujuan:** Verify fixes work

📖 **Read:**
- `18-e2e-prd-to-automation.md` → Section "Phase 5: Verify"

**Apa yang kamu lakukan:**
```bash
npm test -- create-employee.spec.ts
```

**Expected:** Test PASSED ✓

---

### Step 3.4: Update AUTOMATION-CHECKLIST (10 min)
**Tujuan:** Document yang sudah di-fix

📖 **Read:**
- `20-fix-pr-from-feedback.md` → Section "Step 4: Update AUTOMATION-CHECKLIST"

**Apa yang kamu lakukan:**
1. Add section: "Fixes Applied (from PR review)"
2. List semua fixes
3. Update assertions/data/handling sesuai fix
4. Mark: Red flags = 0, All TC clauses = covered

---

### Step 3.5: Push Fix Commit (5 min)
**Tujuan:** Push fixes ke PR

📖 **Read:**
- `20-fix-pr-from-feedback.md` → Section "Step 6: Create Fix Commit"

**Apa yang kamu lakukan:**
```bash
git add [fixed files]
git commit -m "fix: address PR review findings for DF-M1-POS-001

- Fix #1: Add assertion for status = DRAFT
- Fix #2: Replace hardcoded email with faker
- Fix #3: Propagate error in usecase
- Fix #4: Add PRE verification

All PR review findings addressed. Test passing. Ready for re-review."

git push origin feature/create-employee-automation
```

---

### Step 3.6: Request Re-Review (5 min)
**Tujuan:** Ask lead untuk review ulang

📖 **Read:**
- `20-fix-pr-from-feedback.md` → Section "Step 7: Push & Re-request Review"

**Apa yang kamu lakukan:**
1. Comment di PR:
```markdown
@lead-reviewer

All findings from PR review addressed:
✅ Fix #1, #2, #3, #4

Test re-run: PASSED ✓
AUTOMATION-CHECKLIST updated: YES ✓
Ready for re-review.
```

2. Lead re-review → APPROVED → MERGE

**Status: SELESAI! 🎉**

---

---

## 📖 SUMMARY: Gunakan Index Ini Seperti Ini:

```
Kamu sedang fase/scenario apa?

1. Create automation from scratch?
   → Baca Step 1.1 → 1.2 → 1.3 → ... → 1.13
   → Selesai automation live

2. Review PR automation?
   → Baca Step 2.1 → 2.2 → ... → 2.7
   → APPROVED atau REQUEST_CHANGES

3. Fix PR from feedback?
   → Baca Step 3.1 → 3.2 → ... → 3.6
   → Re-review → MERGE
```

---

## 🎯 Setiap Step:

```
Step [number]: [Tujuan]

📖 Read: [File yang dibaca]

Apa yang saya/kamu lakukan:
1. ...
2. ...

Output: ...

Kamu perlu: ...
```

---

**Gini lebih jelas kan? Pakai ini sebagai workflow checklist!** ✅
