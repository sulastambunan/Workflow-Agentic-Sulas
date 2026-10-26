# 01 — Three-layer architecture

## Why layers at all

A test fails for exactly one of three reasons: the product is wrong, the flow is wrong, or the
selector/timing is wrong. Layers exist so the failure report points at one of them instead of
"the test is red". It is also what makes a suite maintainable when the UI changes weekly.

## The shape

```
SPEC          what must be true        (assertions live only here)
  ↓
USECASE       how it is achieved       (order of business steps)
  ↓
COMPONENT/PAGE/SCREEN   how to touch   (HTTP, DOM, device)
```

Factory sits beside the chain: it manufactures data, nothing else.

## Layer 1 — SPEC

Owns: test orchestration, the scenario narrative, every `expect()`.

```ts
// @covers PM-C01-POS-006
test('Create Review with valid data → saved as Draft', async () => {
  const input = createReviewDraftInput('auto');
  const result = await manageReview.saveDraftForm(input);

  expect(result.success).toBe(true);
  expect(result.data?.status).toBe('DRAFT');
});
```

Rules:

- Calls usecases only. A `page.`/`screen.` reference in a spec is a violation, even `import type`.
- No business branching (`if (data.x > 5)`) — that belongs to the usecase.
- Long journeys: wrap each surface in `test.step('<stage>', ...)` and use `expect.soft` so all
  checkpoints report together.

## Layer 2 — USECASE

Owns: the order of operations, business rules, error mapping.

```ts
export class SaveDraftFormUsecase {
  constructor(private deps: { page: ReviewPage }) {}

  async execute(input: ReviewDraftInput): Promise<UsecaseResult<DraftState>> {
    try {
      await this.deps.page.openCreate();
      await this.deps.page.chooseProgram(input.programId);
      await this.deps.page.fillReviewInfo(input.title, input.description);
      await this.deps.page.save();
      return createSuccessResult(await this.deps.page.readState());
    } catch (error) {
      return createErrorResult(error);
    }
  }
}
```

Rules:

- Always returns `UsecaseResult<T>`; wrap the body in `try/catch` → `createErrorResult`.
- Validate HTTP responses through `HttpResult` (`isSuccess`, `isClientError`, `getErrorMessage`).
- No `expect()`. No hardcoded test data — accept it as a parameter.
- Atomic (one operation) vs composite (calls other usecases). Prefer composite when the flow
  is a named business journey; keep the public method count honest (one submit method, not two
  that differ only by what they return).

## Layer 3 — COMPONENT / PAGE / SCREEN

Owns: locators and interactions. Returns values, never judgements.

```ts
export class ReviewPage {
  async fillReviewInfo(title: string, description: string) {
    await this.titleInput.fill(title);
    await this.descriptionInput.fill(description);
  }

  async readState(): Promise<DraftState> {
    return { status: await this.statusBadge.innerText() };
  }
}
```

Rules:

- Web: locators in `defineElements()` or `*.selectors.ts`, prefer `data-testid`.
- API: `extends BaseComponent`, methods return the raw axios promise.
- Mobile: locators live inside `screens/**` (XPath / accessibility id).
- Readers take the entity id as an argument; never re-derive it from `page.url()`.
- Handle UI quirks here (custom dropdowns, date pickers, popups) — not in the usecase.

## FACTORY

```ts
export function createReviewDraftInput(suffix: string): ReviewDraftInput { /* valid data */ }

export function withInvalidReviewInformation(base: ReviewDraftInput): ReviewDraftInput {
  return { ...base, title: 'X'.repeat(51) };
}
```

Rules:

- Data only. No HTTP, no flow, no assertions.
- Called from SPEC (fixtures) and from USECASE (in-flow generation) — both allowed.
- Different DATA = factory variant. Different FLOW = new usecase method. This is the rule that
  prevents 16 near-identical tests.

## Naming

| Kind | File | Class |
|---|---|---|
| Spec | `{feature}.spec.ts` | — |
| Usecase | `{action}-{entity}.usecase.ts` | `{Action}{Entity}Usecase` |
| Component | `{entity}.component.ts` | `{Entity}Component` |
| Page | `{feature}.page.ts` | `{Feature}Page` |
| Screen | `{feature}.screen.ts` | `{Feature}{Platform}Screen` |
| Factory | `{entity}-data.factory.ts` | `{Entity}DataFactory` |

Variables `camelCase`, classes/types `PascalCase`, constants `UPPER_SNAKE_CASE`,
booleans `is`/`has`.

## Folder layout

```
domain/api/{module}/        specs/ · usecases/ · repositories/https/... · repositories/test-data/
domain/web/module/{m}/      tests/ · usecases/ · pages/ · factories/
domain/mobile/module/{m}/   tests/ · usecases/ · screens/{android,ios}/ · data/
```

API uses `specs/`; web and mobile use `tests/`. Keep helpers (pure functions) in `helpers/`,
manual CLI tooling in `scripts/` — the test runner must never discover a script.

## Anti-patterns

1. Spec calling an API/component directly → layer skipped
2. Business logic in a factory → factory became a usecase
3. Assertions in a usecase → the cook grading their own dish
4. Logic (not `expect`) in a spec → spec became a usecase
5. Hardcoded env/token → use `process.env` and the token helper
6. `console.log` → repo logger
7. Emoji / non-English identifiers in source
