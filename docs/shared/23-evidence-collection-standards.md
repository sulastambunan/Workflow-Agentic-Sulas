# 23 — Evidence Collection Standards: Video & Screenshots

**Goal:** Ensure video evidence captures COMPLETE flow without missing context or results.

---

## 🎥 Critical: Video Evidence Must Be COMPLETE

```
❌ WRONG (Incomplete):
  Video starts at: "Click submit"
  Video ends at: "Loading..."
  Missing: PRE setup, initial state, final result
  → Context lost, cannot verify actual outcome

✅ RIGHT (Complete):
  Video starts at: PRE execution (precondition setup)
  Video includes: All test steps in sequence
  Video ends at: Final verification (result assertion)
  → Full context preserved, complete verification
```

---

## 📹 Video Evidence Requirements

### **1. COMPLETE SEQUENCE: PRE → Steps → Result**

**Video MUST include:**

```
[SEGMENT 1: Precondition (PRE) Execution]
├─ PRE setup start
├─ API call / DB operation
├─ PRE completion + verification
└─ System ready state

[SEGMENT 2: Test Steps (When)]
├─ Navigate / Form interaction
├─ Fill data / Input actions
├─ User actions sequence
└─ Submission / Trigger

[SEGMENT 3: Result Verification (Then/And)]
├─ API response received
├─ Database state change
├─ UI state change
├─ Assertion verification
└─ Final outcome visible
```

**Example: Create Employee Test**
```
[PRE]: Manager user creation (HTTP 201) → User exists in DB ✓
[Steps]: Navigate → Fill name → Fill email → Click submit
[Result]: Status = DRAFT ✓, ID created ✓, Email sent ✓
```

---

### **2. BEFORE SENDING: Verify Video Content**

**DO NOT just check:**
```
❌ File exists? ✓
❌ File size > 0? ✓
❌ Video format correct? ✓
```

**DO check:**
```
✅ PRE execution visible? (start of video)
✅ All steps captured? (no jump cuts)
✅ Result visible? (end of video)
✅ Timestamps clear? (can trace timeline)
✅ Error/success state clear? (PASS or FAIL?)
✅ No missing segments? (complete flow)
```

**Verification Checklist:**
```
[ ] Video starts with PRE? (not mid-test)
[ ] PRE execution success visible? (status code, DB confirm)
[ ] First action visible? (navigate, fill, etc)
[ ] All actions in order? (no jump cuts)
[ ] Final assertion visible? (expect(...) result)
[ ] Status clear: PASSED or FAILED?
[ ] Duration reasonable? (not fast-forwarded/skipped)
[ ] Audio/clarity OK? (if needed to hear)
```

---

### **3. COMPLETE vs SUMMARY VIDEO**

**If creating summary/condensed version:**

```
✅ DO: Create summary IF wanted
   ├─ Short version: 2-3 minutes (key moments)
   └─ Label: "Summary video"

❌ BUT: Always include COMPLETE version
   ├─ Full version: entire flow
   ├─ Label: "Complete video"
   └─ This is mandatory
```

**Example Structure:**
```
outputs/evidence/2026-01-20/
├─ DF-M1-POS-001-complete.webm  ← MANDATORY (full flow)
├─ DF-M1-POS-001-summary.webm   ← OPTIONAL (condensed)
├─ DF-M1-POS-001-screenshot.png
└─ DF-M1-POS-001-logs.txt
```

---

## 📸 Screenshot Requirements

**Screenshot MUST show:**

```
✅ PRE execution result (if visible)
✅ UI state after all actions
✅ Success/failure indicator clear
✅ Relevant data visible (created record, status, etc)
✅ Timestamp (when screenshot taken)
✅ Error message (if test failed)
```

---

## 📋 Evidence Checklist per Phase

### **Phase 5: Verify (Dev)**

```
Test PASSED:
  [ ] Complete video: PRE → Steps → Result ✓
  [ ] Screenshot: Final UI state ✓
  [ ] Logs: Test output ✓
  [ ] Duration: Reasonable (not skipped) ✓

Test FAILED:
  [ ] Complete video: PRE → Steps → Failure ✓
  [ ] Screenshot: Error state (exact moment of failure) ✓
  [ ] Logs: Full error stack trace ✓
  [ ] Evidence: Proof of failure (not assumptions) ✓
```

---

### **Phase 5.5: Environment Confirmation (STG)**

```
Test PASSED in STG:
  [ ] Complete video: STG environment confirmed ✓
  [ ] PRE in STG executed? (visible in video) ✓
  [ ] Same flow as dev? (comparable) ✓
  [ ] Final result visible? ✓

Test FAILED in STG:
  [ ] Complete video: PRE → Failure ✓
  [ ] Error visible? (what exactly happened) ✓
  [ ] Local vs STG diff identified? ✓
  [ ] Follow doc 22: Automation Fixing (trace root cause) ✓
```

---

### **Doc 22: Automation Fixing**

```
Test Failure Analysis:
  [ ] Complete video of failure? ✓
  [ ] PRE executed successfully? (shown in video) ✓
  [ ] Where did it fail? (exact step visible) ✓
  [ ] Error message captured? (screenshot + video) ✓
  [ ] Can trace root cause from evidence? ✓
```

---

## 🎬 Video Format & Storage

**Recommended:**
```
Format: WebM, MP4, or MOV
Quality: 1080p minimum
FPS: 30 FPS
Codec: VP9 or H.264
Size: Reasonable (not > 500MB)
Duration: Complete flow (no cuts)
```

**Storage Location:**
```
outputs/evidence/[YYYY-MM-DD]/
├─ [TC-ID]-complete.webm      ← MANDATORY
├─ [TC-ID]-summary.webm       ← OPTIONAL
├─ [TC-ID]-screenshot.png
├─ [TC-ID]-screenshot-error.png (if failed)
└─ [TC-ID]-logs.txt
```

---

## 📝 Evidence Report Template

**When submitting evidence:**

```markdown
# Evidence Report: DF-M1-POS-001

## Test Execution
- Date: 2026-01-20 10:45 UTC
- Environment: STG
- Status: PASSED ✓

## Video Evidence
- Complete video: DF-M1-POS-001-complete.webm (4:32)
  - [00:00-00:15] PRE: Manager user creation
  - [00:15-02:30] Test: Navigate → Fill → Submit
  - [02:30-04:32] Result: Status DRAFT ✓, ID created ✓
- Summary video: DF-M1-POS-001-summary.webm (1:45) [optional]

## Screenshot Evidence
- Final state: DF-M1-POS-001-screenshot.png
  - Shows: Form submitted, success message visible

## Logs
- Test output: DF-M1-POS-001-logs.txt
  - All assertions passed
  - No errors

## Verification
✅ PRE executed (visible in video)
✅ All steps visible (no cuts)
✅ Result visible (PASSED)
✅ Evidence complete and verifiable
```

---

## 🚨 Common Mistakes to AVOID

```
❌ Video starts mid-test
   → Cannot verify PRE executed

❌ Video ends before result
   → Cannot verify outcome

❌ Jump cuts in video
   → Cannot verify all steps happened

❌ Only summary video provided
   → Complete flow lost

❌ Screenshot only (no video)
   → Cannot verify sequence of events

❌ Video not checked before sending
   → May discover it's incomplete/wrong only during review

❌ Blurry/dark video
   → Cannot read actual values/errors
```

---

## ✅ Best Practice

```
1. Record COMPLETE flow (PRE → Steps → Result)
   └─ Not just "test steps", but full context

2. BEFORE sending:
   └─ Play entire video from start to end
   └─ Verify PRE, steps, result all visible
   └─ Check timestamps/clarity

3. Include BOTH:
   └─ Complete video (mandatory)
   └─ Summary video (optional, if helpful)

4. Label clearly:
   └─ "complete" vs "summary"
   └─ Which TC it covers
   └─ Pass/Fail status

5. With screenshot + logs:
   └─ Video shows flow
   └─ Screenshot shows final state
   └─ Logs show details/errors
```

---

## References

- **18-e2e-prd-to-automation.md** → Phase 5 (collect evidence)
- **21-environment-confirmation-stg.md** → STG evidence
- **22-automation-fixing-best-practices.md** → Failure evidence
