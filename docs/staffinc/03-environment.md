# 03 — Environment, tenant, dan struktur folder (Staffinc)

## Tech stack

| Lapis | Teknologi |
|---|---|
| Agent runtime | Hermes Agent (profil `automation-worker`) |
| Web runner | Playwright + Bun |
| Mobile runner | Appium + WebdriverIO + Bun |
| Emulator | Android SDK + QEMU + Xvfb |
| Code knowledge | `code-knowledge.db` (SQLite + sqlite_vec + fastembed) |
| Business knowledge | `suite.db` (SQLite + sqlite_vec + fastembed) |
| Syntax gate | `bun scripts/ci/syntax-check.ts` |
| Quality gate | `python3 scripts/quality/check.py` |
| Cross-validator | `scripts/cross-validate-automation.py` |
| Target backend | `hcmsvc` (Go), `hcmworker` |
| Target web | `kerjaan-client-portal` (Next.js), `seamless-admin-portal` |
| Target mobile | `kerjaan-android` (Kotlin), `ios-kerjaan` (Swift) |

## Tenant: admin dan worker harus satu `client_id`

Fixture tenant yang dipakai: **`client_id: 2469`**, untuk admin maupun worker. Kalau berbeda,
gejalanya bukan "tenant salah" — tapi 404 di `/v1/agent/submissions/form-versions/*` sementara
form duplikat tetap dibuat.

- Admin/fixture owner: email `+client0808` (kredensial di `.env`, bukan di repo).
- Worker app: login phone + OTP (resep regenerasi ada di skill mobile).
- Object ID membawa prefix tenant: `2469-...` vs tenant lain `2393-...`.
- Sebelum debug 404 di endpoint submission, decode kedua JWT dan bandingkan `client_id`.

**Jangan menaruh password, token, atau OTP di repo.** Yang didokumentasikan hanya nama variabel
dan lokasinya.

| Kredensial | Lokasi |
|---|---|
| Admin email/password | `.env`: `DIGITAL_FORM_FIXTURE_ADMIN_EMAIL` / `_PASSWORD` |
| Token hasil generate | `tokens.json` (kedaluwarsa ~24 jam) |
| Mobile login | phone + OTP, resep di skill mobile |

## Environment variables

Wajib per playbook: `BASE_URL_HCM`, `CLIENT_ID`, `CLIENT_TOKEN`, `APPROVAL_LAYER_1_EMAIL/PASSWORD`
… sampai layer 5, `API_RESPONSE_TIME_LIMIT`, `API_MAX_RETRIES`, `API_RETRY_DELAY`.
Pindah environment: `npm run env:dev` / `env:stg` / `env:show`.

## Emulator

| Config | Nilai |
|---|---|
| Emulator | `StaffincA33` (Android 33) — pakai ini |
| Hindari | `StaffincTest` (Android 34) — QEMU crash di host kernel 6.17 |
| GPU | Xvfb + `-gpu host` |
| Env | `ANDROID_PLATFORM_VERSION=13`, `ANDROID_DEVICE_NAME=StaffincA33` |
| App package | `com.kerjaan.app.dev` |

Kalau `device not found` muncul di tengah run, restart emulator — jangan debug spec-nya.

## Struktur folder repo automation

```
staffinc-automation/
  domain/api/{module}/
    specs/          # Layer 1 SPEC
    usecases/       # Layer 2 USECASE
    repositories/
      https/        # Layer 3 COMPONENT
      test-data/    # FACTORY
  domain/web/module/{feature}/
    tests/          # Layer 1 SPEC
    usecases/       # Layer 2 USECASE
    pages/          # Layer 3 PAGE
    factories/      # FACTORY
  domain/mobile/module/{feature}/
    tests/          # Layer 1 SPEC
    usecases/       # Layer 2 USECASE
    screens/ios|android/  # Layer 3 SCREEN
    data/           # FACTORY
  scripts/ci/syntax-check.ts
  scripts/quality/check.py
  scripts/mobile-runner.ts
```

Catatan: API memakai `specs/`, web dan mobile memakai `tests/`.

Struktur repo TC:

```
staffinc-testcase/
  testcases/{web,mobile}/<module>/<TC-ID>.md
  preconditions/*.md
  flows/ suites/ docs/
  scripts/cross-validate-automation.py
```

## Catatan teknis yang sering menjebak

- `bun run type-check` tidak pernah hijau: ada ~2.591 type error lama di 255 file. Gate yang
  dipakai adalah `syntax-check.ts` (parse-level).
- `check.py` versi lama hanya mencocokkan `test(` sehingga spec mobile (`it(`) dapat Grade A
  padahal 0 test. Cek `grep -c '(?:test|it)' scripts/quality/check.py` sebelum percaya grade.
