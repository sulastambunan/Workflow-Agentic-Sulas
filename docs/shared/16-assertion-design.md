# 16 — Assertion design & error handling

**Goal:** Design assertion and error handling from TC BEFORE writing code. Prevent tautology and swallowed errors upstream.

---

## Rule 1: Every Assertion Must Be Able to FAIL

```
❌ TAUTOLOGY (always pass):
  expect(true).toBe(true)
  expect(result).toBeDefined()
  expect(count).toBeGreaterThanOrEqual(0)

✅ MEANINGFUL (can fail):
  expect(result.status).toBe('DRAFT')
  expect(employees).toHaveLength(3)
  expect(form).toBeVisible()
```

---

## Rule 2: Every Error Must PROPAGATE

```
❌ SWALLOWED (error hidden):
  .catch(() => false)
  .catch(() => {})
  try { } catch(e) { console.log(e) }
  result.success || true

✅ PROPAGATE (error clear):
  // Let error throw naturally
  throw new Error(`Failed: ${message}`)
  if (!response.ok()) throw new Error(...)
```

---

## Rule 3: Every Value from TC (not code)

```
❌ HARDCODED (from memory):
  expect(result.status).toBe('ACTIVE')  // code assumes
  const name = 'John'  // hardcoded

✅ FROM TC (traceable):
  expect(result.status).toBe('DRAFT')  // from TC Then#1
  const data = factory.generateEmployee()  // varied, from FACTORY
```

---

## Assertion Design Template (Grounding Phase)

For each TC Then/And clause:

| TC Clause | Observable | Expected | Assertion | Can Fail? |
|-----------|-----------|----------|-----------|-----------|
| "Status DRAFT" | result.status field | "DRAFT" | expect(...).toBe('DRAFT') | ✅ Yes |
| "Row exists" | row in table | row.id === X | expect(rows).toContainEqual({id: X}) | ✅ Yes |
| "Form visible" | form element | visible | expect(form).toBeVisible() | ✅ Yes |

---

## Error Handling Pattern (per Layer)

### **SPEC Layer**

```typescript
test('@covers DF-M1-POS-001', async () => {
  // Let error propagate (not swallow)
  const result = await usecase.execute(data)
  
  // Assertion: can fail if feature broken
  expect(result.status).toBe('DRAFT')
})
```

### **USECASE Layer**

```typescript
export class CreateEmployeeUsecase {
  async execute(data: EmployeeInput): Promise<UsecaseResult> {
    try {
      const res = await http.post('/v1/employees', data)
      if (!res.ok()) {
        throw new Error(`API error: ${res.status()}`)
      }
      return { success: true, data: res.json() }
    } catch (e) {
      // Re-throw with context (not swallow)
      throw new Error(`Create failed: ${e.message}`)
    }
  }
}
```

### **Layer 3 (PAGE)**

```typescript
async fillName(name: string) {
  // Let error propagate (not .catch)
  await this.page.fill('[data-testid="name"]', name)
  
  // Positive anchor (not negative read)
  await expect(this.page.locator('[data-testid="name"]')).toHaveValue(name)
}
```

### **FACTORY**

```typescript
export function generateEmployee(overrides = {}) {
  // Validate data (not assume valid)
  const data = {
    name: faker.person.fullName(),
    email: faker.internet.email(),
    ...overrides
  }
  
  // Optional: validate schema
  if (!data.email.includes('@')) {
    throw new Error('Invalid email generated')
  }
  
  return data
}
```

### **PRE (Precondition)**

```typescript
export async function preconditionManagerUser() {
  const response = await request.post('/v1/admin/seed/user', {
    role: 'manager',
    email: `mgr-${Date.now()}@test.co`
  })
  
  // Assert PRE executed (not assume)
  expect(response.status()).toBe(201)
  expect(response.json().id).toBeTruthy()
  
  return response.json()
}
```

---

## Checklist: Before Implementing

```
Assertion Design:
  [ ] No tautology (not expect(true).toBe(true))
  [ ] Can fail (jika feature broken)
  [ ] From TC expected, not code
  [ ] // expect: <TC-ID> Then#n comment added
  [ ] One assertion per TC clause

Error Handling:
  [ ] No .catch(() => false)
  [ ] No try/catch hiding error
  [ ] Errors propagate with message
  [ ] PRE assertion explicit
  [ ] USECASE error handling clear

Data & Values:
  [ ] No hardcoded data (use FACTORY)
  [ ] Dynamic email/id per run
  [ ] Expected value from TC, not memory
  [ ] Selector from grounding (// src:)

DDD:
  [ ] SPEC calls usecase only
  [ ] USECASE no expect()
  [ ] Layer 3 no business logic
  [ ] FACTORY no API calls
```

---

## Red Flags During Code Review

```
BLOCKER:
  ❌ Tautology: expect(true), toBeDefined(), toBeGreaterThanOrEqual(0)
  ❌ Swallowed error: .catch(() => false)
  ❌ Hardcoded value: 'John Doe', 'john@test.co'
  ❌ Missing assertion: TC clause with no expect()
  ❌ DDD broken: SPEC touch page, USECASE with expect()
  ❌ No error handling: try/catch with console.log
```

---

## Reference

- Executability: `docs/shared/14-executability-principle.md`
- Test design: `docs/shared/05-test-design-rules.md`
- Layer architecture: `docs/shared/04-three-layer-architecture.md`
- Failure reporting: `docs/shared/15-test-failure-reporting.md`
