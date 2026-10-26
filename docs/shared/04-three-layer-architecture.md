# 04 — DDD Test Architecture: 3 layer + factory

Berlaku untuk dua track. Yang berbeda hanya nama workspace (API/web/mobile) dan isi Layer 3.

```
SPEC  →  USECASE  →  PAGE / SCREEN / COMPONENT
                        ↑
                   [FACTORY]  (utilitas data, bukan layer)
```

Satu tanggung jawab per lapis. Ini evolusi dari POM dan Serenity: SPEC menyatakan apa yang harus
dibuktikan, USECASE tahu urutan bisnisnya, Layer 3 yang menyentuh UI/HTTP.

## Ringkasan layer

| Layer | API | Web | Mobile | Tanggung jawab |
|---|---|---|---|---|
| 1 | SPEC | SPEC | SPEC | orkestrasi test + assertion |
| 2 | USECASE | USECASE | USECASE | logika bisnis + orkestrasi Layer 3 |
| 3 | COMPONENT | PAGE | SCREEN | interaksi HTTP/UI |
| — | FACTORY | FACTORY | FACTORY | generate data uji (bukan layer) |

## Layer 1 — SPEC

Lokasi: API `domain/api/{module}/specs/*.spec.ts` · Web `domain/web/module/{feature}/tests/*.spec.ts`
· Mobile `domain/mobile/module/{feature}/tests/*.spec.ts`.

Boleh: memanggil USECASE, mengimpor FACTORY untuk setup data, `expect()`.
Tidak boleh: memanggil Layer 3 langsung, logika bisnis kompleks, raw locator.

```ts
// @covers PM-C01-POS-006
test('Create employee with valid data -> created', async () => {
  const data = factory.generateEmployee();
  const result = await createEmployeeUsecase.execute(data);
  expect(result.success).toBe(true);
  expect(result.data?.id).toBeTruthy();
});
```

## Layer 2 — USECASE

Lokasi: `domain/{api,web,mobile}/.../usecases/*.usecase.ts`.

Boleh: logika bisnis, memanggil Layer 3, memanggil usecase lain (composite).
Tidak boleh: `expect()`, HTTP/UI langsung (harus lewat Layer 3).

Selalu mengembalikan `UsecaseResult<T>`; bungkus body dengan try/catch → `createErrorResult`.
Validasi response lewat `HttpResult` (`isSuccess`, `isClientError`, `getErrorMessage`), bukan
`if (status === 200)` manual.

```ts
export interface UsecaseResult<T = any> {
  success: boolean;
  data?: T;
  error?: string;
  metadata?: Record<string, any>;
}
```

Jenis: **atomic** (satu operasi, mis. `CheckInUsecase`) dan **composite** (memanggil beberapa
usecase, mis. `CompleteCicoFlowUsecase`).

## Layer 3 — COMPONENT / PAGE / SCREEN

Lokasi: API `repositories/https/**/{entity}.component.ts` · Web `module/{feature}/pages/*.page.ts`
· Mobile `module/{feature}/screens/{ios,android}/*.screen.ts`.

Boleh: HTTP call, interaksi Playwright/Appium.
Tidak boleh: assertion, logika bisnis.

Web memakai `data-testid`; mobile memakai `R.id.` / `accessibilityIdentifier`; API memakai
`BaseComponent` (`validateResponse`, `requestWithRetry`, `postFormData`).

## FACTORY (bukan layer)

Lokasi: Web `module/{feature}/factories/` · API `repositories/test-data/` · Mobile
`module/{feature}/data/`.

Boleh: generate data, termasuk override (`generateAllowanceComponent({ name: 'X' })`).
Tidak boleh: logika bisnis, API call, assertion. `createWithSetup()` yang ikut assign jadwal
adalah contoh salah — factory berubah jadi usecase.

Dipanggil dari SPEC (setup/fixture) dan USECASE (data generation).

## Naming

| Tipe | Pola | Contoh |
|---|---|---|
| SPEC | `{feature}.spec.ts` | `create-employee.spec.ts` |
| USECASE | `{action}-{entity}.usecase.ts` | `assign-schedule.usecase.ts` |
| COMPONENT | `{entity}.component.ts` | `master-schedules.component.ts` |
| PAGE | `{feature}.page.ts` | `create-client.page.ts` |
| SCREEN | `{feature}.screen.ts` | `checkin.screen.ts` |
| FACTORY | `{entity}-data.factory.ts` | `employee-data.factory.ts` |

Class: `{Action}{Entity}Usecase`, `{Entity}Component`, `{Feature}Page`, `{Feature}{Platform}Screen`,
`{Entity}DataFactory`.
Variabel/fungsi camelCase, class/type PascalCase, konstanta UPPER_SNAKE_CASE, boolean `is`/`has`.

## Peta keputusan: kode ini taruh di mana?

| Pertanyaan | Jawaban |
|---|---|
| Klik / ketik / isi form? | PAGE (web) / SCREEN (mobile) |
| Panggil API atau DB? | COMPONENT / `repositories/https` |
| Menentukan urutan langkah atau aturan bisnis? | USECASE |
| Menyatakan "hasilnya harus begini"? | SPEC |
| Membuat/memvariasikan data uji? | FACTORY |
| Fungsi murni (parse, format tanggal)? | `helpers/` / `core/utils/` |
| Tool yang dijalankan manual (probe/CLI)? | `scripts/` |

- Beda **data** (valid vs invalid) → varian di FACTORY.
- Beda **alur** → method USECASE baru.
- `usecase` tidak boleh punya `expect()`; `spec` tidak boleh mengimpor page/screen/component.

## Anti-pattern

1. SPEC memanggil API/component langsung — skip layer.
2. Logika bisnis di FACTORY — factory jadi usecase.
3. Assertion di USECASE — koki menilai masakannya sendiri.
4. Hardcode env/token — pakai `process.env` dan `token.get()`.
5. `console.log` — pakai `log.info/debug/warn/error`, `log.step`, `log.logApiCall`.
6. Emoji di kode/komentar/log — dilarang; kode dan komentar English.
7. Stub test (`expect(true)`, `toBeDefined()` tanpa nilai) — bukan test.

## Code style

- English untuk kode, komentar, dan nama.
- Strict TypeScript; hindari `any`.
- Tanpa emoji di source, komentar, atau log.

## Layout folder

```
domain/api/{module}/
  specs/            # Layer 1
  usecases/         # Layer 2
  repositories/
    https/          # Layer 3 COMPONENT
    test-data/      # FACTORY
domain/web/module/{feature}/
  tests/            # Layer 1
  usecases/         # Layer 2
  pages/            # Layer 3
  factories/        # FACTORY
domain/mobile/module/{feature}/
  tests/            # Layer 1
  usecases/         # Layer 2
  screens/ios|android/  # Layer 3
  data/             # FACTORY
```

Root: `core/` (http, usecase, utils, runners) + `domain/{api,web,mobile}` + `environments/` +
`tokens.json`.

## Checklist sebelum push

- [ ] Data uji di FACTORY; tidak ada angka/teks uji hardcoded di usecase/spec.
- [ ] Factory tidak memanggil API dan tidak punya alur.
- [ ] Usecase tanpa `expect()`; urutan langkah ada di usecase.
- [ ] Usecase mengembalikan `UsecaseResult` (try/catch → `createErrorResult`).
- [ ] Spec memakai usecase, bukan page/component; assertion di spec.
- [ ] `// @covers <TC-ID>` di atas tiap test.
- [ ] Nama file/class ikut pola.
- [ ] Tanpa emoji, tanpa `console.log`.
- [ ] Gate lokal hijau.
- [ ] Verifikasi cukup pada test yang diperbaiki.
