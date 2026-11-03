# Updates to Existing Files (Manual Review Needed)

This file lists changes needed in existing documentation files. Due to complexity of merging into existing content, these should be reviewed and merged manually.

---

## 1. workflow/00-ledger-intake.md

**Add:** Step 6 — Environment & Data Setup questionnaire

**Location:** After current Step 5, before "Output" section

**Content:** Ask user about:
- Target environment (dev/stg/both)
- Test account (role, email, credential source)
- Test data availability
- Environment-specific config (endpoint URL, feature flag, auth)
- Data cleanup policy

**Reference:** See `docs/shared/14-executability-principle.md` for environment parity requirements

**Benefit:** Prevent environment surprises in Phase 5 (Verify)

---

## 2. workflow/04-implement.md

**Add:** Implementation Output section (after current "Code style" or at end)

**Content:**
```markdown
## Implementation Output: Traceability Record

Setelah code selesai, create:

1. **AUTOMATION-CHECKLIST-<TC-ID>.md**
   - Location: domain/[module]/AUTOMATION-CHECKLIST-<TC-ID>.md
   - Content: TC clause → assertion mapping
   - Self-review: engineer verify matching
   - Reference: docs/shared/17-traceability-record.md

2. **Code comments**
   - // @covers <TC-ID>
   - // src: filepath:line (selector, endpoint)
   - // expect: <TC-ID> Then#n (assertion)

3. **Run test + evidence**
   - Test PASSED (not skipped, not failed)
   - PRE executed successfully
   - Video evidence collected

## Checklist before push (SPEC layer)
- [ ] No tautology
- [ ] No swallowed errors
- [ ] No hardcoded values
- [ ] All TC clauses covered
- [ ] Assertions from TC, not memory
```

**References:** 
- `docs/shared/14-executability-principle.md`
- `docs/shared/16-assertion-design.md`
- `docs/shared/17-traceability-record.md`

**Benefit:** Ensure upstream prevention, not downstream detection

---

## 3. workflow/05-verify-evidence.md

**Add:** Failure Diagnosis section (after "Reporting a result")

**Content:**
```markdown
## Failure Diagnosis

If test FAILED, use structured diagnosis:

Reference: `docs/shared/15-test-failure-reporting.md`

1. **Identify layer:** PRE, FACTORY, USECASE, Layer3, or SPEC?
2. **Root cause:** Why did it fail?
3. **Evidence:** Screenshot, video, logs, stack trace
4. **Decision:** Fix code, re-ground, or escalate?

Example:
- SPEC assertion fail: "expect(status).toBe('DRAFT') actual='PENDING'"
  Decision: Update TC or report defect?
- Layer3 selector fail: "element not found '[data-testid="..."]'"
  Decision: Re-ground selector or verify app UI
- PRE endpoint fail: "HTTP 500"
  Decision: Environment issue, automation blocked until fixed
```

**Benefit:** Clear failure diagnosis, not vague error messages

---

## 4. docs/shared/11-pre-push-review.md

**Add:** Traceability Verification checklist (in "Aturan status" or "Langkah" section)

**Content:**
```markdown
## Traceability Verification

Sebelum push, verify:

- [ ] AUTOMATION-CHECKLIST-<TC-ID>.md exist?
- [ ] All TC clauses covered? (Given/When/Then/And)
- [ ] Clause table complete? (no missing assertions)
- [ ] Red flags scanned? (tautology, swallowed error, hardcoded)
- [ ] Code comments present? (@covers, // expect:, // src:)
- [ ] Test result: PASSED (not skipped, not failed)?

Reference: `docs/shared/17-traceability-record.md`

Blocker: Any of above unchecked = REQUEST_CHANGES
```

**Benefit:** Ensure traceability before PR

---

## 5. skills/automation-pr-review/SKILL.md

**Add:** Two sections to the SKILL

### **Section 5.1 (after "5. Code checks")**

```markdown
### 5.1 Executability validation (code-only check)

Even without running tests, code review can check executability signals:

- **SPEC layer:** 
  - ✅ Every `expect()` has source? (TC clause)
  - ❌ Tautology? (expect(true))

- **USECASE layer:**
  - ✅ Calls real endpoint (not mocked)?
  - ❌ Exception swallowed? (try/catch hidden)

- **Layer 3 (PAGE/COMPONENT):**
  - ✅ Selector has `// src:` comment?
  - ✅ Grounded (not memory)?

- **FACTORY:**
  - ✅ Data varied (not hardcoded)?
  - ❌ API call? (red flag)

- **PRE:**
  - ✅ Setup endpoint verified?
  - ❌ PRE skipped? (red flag)

Reference: `docs/shared/14-executability-principle.md`
```

### **Section 6.1 (after "6. Gates")**

```markdown
### 6.1 When tests have been executed (optional in intake)

If intake said review basis is "executed" (tests actually ran):

1. **Executability checkpoint:** Did execution match code expectations?
   - PRE: endpoint respond? DB mutation happen?
   - USECASE: called real endpoint?
   - Layer3: selectors found?
   - FACTORY: generated data valid?

2. **Failure diagnosis:** If test failed
   - Which layer failed?
   - Root cause clear?
   - Evidence collected? (screenshot, video, logs)

Reference: `docs/shared/14-executability-principle.md`
              `docs/shared/15-test-failure-reporting.md`
```

### **Update Section 8 (Report)**

Add to report template:

```markdown
## Executability findings (if tests executed)

Per `docs/shared/14-executability-principle.md`:

- PRE execution: [blocked | passed | skipped]
- FACTORY validation: [blocked | passed]
- USECASE execution: [blocked | passed | error]
- Layer3 grounding: [verified | outdated | fabricated]
- SPEC assertions: [all asserted | weaker | missing | extra]

## Failure diagnosis (if test failed)

Per `docs/shared/15-test-failure-reporting.md`:

- Failed test: [@covers TC-ID]
- Layer: [SPEC | USECASE | Layer3 | FACTORY | PRE]
- Error: [message + evidence]
- Root cause: [diagnosis]
- Action: [fix code | re-ground | escalate | known issue]
```

**References:** 
- `docs/shared/14-executability-principle.md`
- `docs/shared/15-test-failure-reporting.md`

**Benefit:** Skill aligned with new executability principle & failure diagnosis

---

## Cross-Reference: New Docs Reference Each Other

All new docs link to each other:
- 14-executability-principle.md → 15, 16, 17, 04-three-layer-architecture
- 15-test-failure-reporting.md → 14, 16, 05-test-design-rules
- 16-assertion-design.md → 14, 15, 04-three-layer-architecture
- 17-traceability-record.md → 14, 16, 11-pre-push-review
- INTEGRATION-MAP.md → all new docs + skill + workflow

---

## Summary

**Files with new content:**
- ✅ 14-executability-principle.md (CREATED)
- ✅ 15-test-failure-reporting.md (CREATED)
- ✅ 16-assertion-design.md (CREATED)
- ✅ 17-traceability-record.md (CREATED)
- ✅ INTEGRATION-MAP.md (CREATED, in docs/shared/)
- ✅ README-NEW-DOCUMENTATION.md (CREATED, in root)

**Files that need updates (manual merge):**
- ⚠️ workflow/00-ledger-intake.md (add Step 6)
- ⚠️ workflow/04-implement.md (add Output section)
- ⚠️ workflow/05-verify-evidence.md (add Failure Diagnosis)
- ⚠️ docs/shared/11-pre-push-review.md (add Traceability Check)
- ⚠️ skills/automation-pr-review/SKILL.md (add Executability + Failure)

---

## How to Merge

1. Review each update above
2. Apply manually to avoid merge conflicts
3. Test cross-references work
4. Commit when all updates done

**Or:** Automation engineer can apply these updates and push a follow-up commit after PR merge.
