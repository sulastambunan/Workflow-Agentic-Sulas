# 14 — Executability principle: No assumptions

**Goal:** EVERYTHING must be EXECUTABLE in dev and stg. No aspirational behavior. Every layer verified in real environment before claiming automation.

---

## Core Rule

```
NOT: "Assume the code will work, test later"
BUT: "Verify everything works in REAL environment, then write code"
```

---

## What Must Be Executable

| Layer | Must Be Executable | Verify By |
|-------|-------------------|-----------|
| **SPEC** | test.step, expect() runs in real env | Run test in dev/stg |
| **USECASE** | Endpoint call works, response valid | Grounding: endpoint exists, responds |
| **Layer 3** | Selector found, element exists | Grounding: live inspection of app |
| **FACTORY** | Generated data insertable | Test: data passes validation, inserts |
| **PRE** | Setup endpoint works, DB mutates | Grounding: endpoint exists, verify response |
| **Environment** | Dev and stg have SAME structure | Verify: endpoint URL, schema, data |

---

## Per-Layer Executability Rules

### **Layer 1: SPEC**

✅ **Executable:**
```typescript
test('@covers DF-M1-POS-001', async () => {
  const data = factory.generateEmployee()
  const result = await usecase.execute(data)
  expect(result.status).toBe('DRAFT')  // Actual value, not assumption
})
```

❌ **NOT executable (assumption):**
```typescript
test('Create employee', async () => {
  // Assume usecase.execute works
  const result = await usecase.execute({ name: 'John' })
  expect(result).toBeDefined()  // Assume something will be defined
})
```

**Checklist:**
- [ ] Usecase call = real function (not mock)
- [ ] Expected value = from TC (not from code)
- [ ] Assertion = meaningful, can fail
- [ ] No assumption of success

---

### **Layer 2: USECASE**

✅ **Executable:**
```typescript
export class CreateEmployeeUsecase {
  async execute(data: EmployeeInput): Promise<UsecaseResult> {
    // Call REAL endpoint
    const res = await http.post('/v1/employees', data)
    
    // Validate response (not assume success)
    if (!res.ok()) {
      throw new Error(`API error: ${res.status()}`)
    }
    
    return { success: true, data: res.json() }
  }
}
```

❌ **NOT executable (assumption):**
```typescript
export class CreateEmployeeUsecase {
  async execute(data) {
    // Assume endpoint exists (not verified)
    // Assume response has data field
    const res = await http.post('/v1/employees', data)
    return res  // Assume caller will handle error
  }
}
```

**Checklist:**
- [ ] HTTP call = to real endpoint (not mock)
- [ ] Response validated = check status, structure
- [ ] Error handling = explicit throw (not silent)
- [ ] No assumption of success

---

### **Layer 3: PAGE/SCREEN/COMPONENT**

✅ **Executable:**
```typescript
// src: kerjaan-client-portal/src/pages/CreateEmployee.tsx:42
async fillName(name: string) {
  // Selector verified in grounding (live inspection)
  await this.page.fill('[data-testid="employee-name"]', name)
  
  // Wait for actual network (not fixed sleep)
  await this.page.waitForLoadState('networkidle')
}
```

❌ **NOT executable (assumption):**
```typescript
async fillName(name: string) {
  // Assume selector exists (not verified)
  await this.page.fill('[data-testid="employee-name"]', name)
  
  // Assume 2 seconds is enough (hardcoded wait)
  await this.page.waitForTimeout(2000)
}
```

**Checklist:**
- [ ] Selector = grounded (live inspected app)
- [ ] Selector = commented with // src:
- [ ] Wait = dynamic (waitForLoadState, not waitForTimeout)
- [ ] No assumption of element existence

---

### **FACTORY**

✅ **Executable:**
```typescript
export function generateEmployee(overrides = {}) {
  // Generate varied, valid data
  return {
    name: faker.person.fullName(),        // Unique per run
    email: faker.internet.email(),        // Valid format
    salary: faker.number.int({ min: 3000000, max: 10000000 }),
    ...overrides
  }
}
```

❌ **NOT executable (assumption):**
```typescript
export function generateEmployee() {
  // Hardcoded same data every run
  return {
    name: 'John Doe',
    email: 'john@test.co',
    salary: 5000000  // Assume this is valid
  }
}
```

**Checklist:**
- [ ] Data = varied (not hardcoded)
- [ ] Data = schema-valid (email format, constraints)
- [ ] No API call in FACTORY
- [ ] No assumption of data uniqueness

---

### **PRE (Precondition)**

✅ **Executable:**
```typescript
export async function preconditionManagerUser() {
  // PRE endpoint verified in grounding
  const response = await request.post('/v1/admin/seed/user', {
    role: 'manager',
    email: `mgr-${Date.now()}@test.co`  // Unique per run
  })
  
  // Assert PRE actually worked
  expect(response.status()).toBe(201)
  expect(response.json().id).toBeTruthy()
  
  return response.json()
}
```

❌ **NOT executable (assumption):**
```typescript
export async function preconditionManagerUser() {
  // Assume endpoint exists (not verified)
  // Assume it always succeeds
  const response = await request.post('/v1/admin/seed/user', {...})
  return response  // No assertion, assume success
}
```

**Checklist:**
- [ ] PRE endpoint = verified in grounding
- [ ] PRE response = validated (status, data)
- [ ] PRE data = unique (not reused)
- [ ] PRE assertion = explicit (expect status, data)

---

## Environment Parity

**Rule:** All layers tested in SAME environment (dev/dev or stg/stg).

```
❌ WRONG:
- PRE tested in dev ✓
- Scenario tested in stg ✗
- Endpoint different: dev localhost, stg api.staging.co
- Test fail, unclear why

✅ RIGHT:
- PRE tested in dev
- Scenario tested in dev
- OR both in stg
- Same endpoint, same schema, same behavior
```

**Verify:**
```bash
# Check endpoint URL
echo $API_ENDPOINT  # Should be dev or stg, not mixed

# Check environment config
grep -r "localhost\|staging" code/  # Should use ENV, not hardcoded

# Test in target env only
ENVIRONMENT=dev npm test
ENVIRONMENT=stg npm test
# Not mixed!
```

---

## Checklist: Executability per Phase

### **Phase 1: Grounding**

```
[ ] Selector: Live inspection of app, element FOUND
[ ] Endpoint: Search codebase, URL EXISTS
[ ] Expected value: From TC or app response, not memory
[ ] Error scenario: Can this be triggered in real env?
[ ] PRE: Endpoint reachable, response structure known
```

### **Phase 2: Design**

```
[ ] Assertion: Can fail? Meaningful? From TC?
[ ] Error handling: How to detect failure per step?
[ ] PRE sequence: Setup will work in target env?
[ ] Data flow: Data from PRE → scenario → assertion clear?
```

### **Phase 4: Implement**

```
[ ] SPEC: Calls usecase only (not page/API direct)
[ ] USECASE: Calls real endpoint, validates response
[ ] Layer 3: Selector grounded (// src:), no hardcoded
[ ] FACTORY: Data varied, valid schema, not API call
[ ] PRE: Endpoint real, response validated, unique data
```

### **Phase 5: Verify**

```
[ ] PRE: Does setup endpoint respond? DB mutates?
[ ] Test: Does run in target environment? PASSED?
[ ] Selector: Does live inspection confirm element found?
[ ] Response: Does actual response match expected?
[ ] Error: If fail, is error clear (not assumption)?
```

---

## Anti-Patterns: What NOT to Do

```
❌ "The endpoint probably works, let's write test"
✅ "Verified endpoint works, now write test"

❌ "Selector should be there, let me hardcode"
✅ "Grounded selector with live inspection, now hardcode"

❌ "Expected value looks right from code"
✅ "Expected value from TC Then clause"

❌ "Test passed locally, must be correct"
✅ "Test passed locally AND in stg, then claim automation"

❌ "PRE setup probably works"
✅ "PRE endpoint responds + DB mutation verified"

❌ "Generate data same every run"
✅ "Generate data varied, unique per run"
```

---

## Summary: The Principle

```
EXECUTABILITY PRINCIPLE:

Every assertion, endpoint, selector, value, and precondition
must be VERIFIED IN REAL ENVIRONMENT,
not assumed or hoped.

Code is EXECUTED, not THEORETICAL.

If something cannot be executed in real environment,
it's not part of the automation — it's blocked.
```

---

## Reference

- Grounding: `docs/shared/03-codebase-grounding.md`
- Layer architecture: `docs/shared/04-three-layer-architecture.md`
- Test design: `docs/shared/05-test-design-rules.md`
- Assertion design: `docs/shared/16-assertion-design.md`
- Failure reporting: `docs/shared/15-test-failure-reporting.md`
