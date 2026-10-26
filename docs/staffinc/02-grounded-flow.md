# 02 — Alur grounded per TC (Staffinc)

Sepuluh langkah, satu TC. Semua langkah menghasilkan bukti yang bisa dibaca ulang setelah
context compression.

## 1. READ — TC + preconditions

Baca file TC: id, module, `sourceRefs.tsd`, `preconditionRefs`, `automationStatus`. Pastikan
statusnya `planned`. Baca semua precondition yang dirujuk — di situ biasanya ada endpoint, tabel,
dan jalur navigasi.

```
repos/automation-code/staffinc-testcase/testcases/{web,mobile}/<module>/<TC-ID>.md
repos/automation-code/staffinc-testcase/preconditions/*.md
```

## 2. FETCH — module code map (sekali per modul)

Ambil peta modul sekali, pakai untuk semua TC di modul itu. Ini pengungkit biaya utama.

```bash
$PY $CKB module <module>
```

## 3. GROUND — teknis

Cari selector, endpoint, dan async queue; catat `// src: repo/path:line` untuk tiap elemen yang
dipakai. Kalau hasil 0 → live inspection, jangan menebak.

```bash
$PY $CKB search "<objective>" --kind endpoint -k 5
$PY $CKB search "<objective>" --kind selector -k 5
$PY $CKB search "<objective>" --kind async -k 3
```

## 4. GROUND + VALIDATE — expected result

Tiap `expect()` butuh provenance: `suite.db` (terkuat) → TC → code. Kalau `suite.db` bertentangan,
selidiki dulu; kalau diam, sitasi TC.

```bash
$PY $QKB search "<PK behavior>" --mode e2e -k 5
```

## 5. PERSIST + PLAN

Tulis hasil grounding ke `workspace/grounding/<TC-ID>.md` — satu baris per elemen yang dipakai,
plus daftar gap. File ini yang dibaca ulang kalau sesi ter-compress.

Lalu sampaikan rencana per langkah (langkah → aksi → selector/endpoint → sitasi) dan **panggil
`clarify()`**. Menulis "menunggu approval" di chat bukan jeda.

## 6. BUILD — DDD

SPEC → USECASE → PAGE/SCREEN (+ FACTORY), di `domain/{web,mobile}/module/<module>/`.
Tiap selector `// src:`, tiap `expect()` `// expect:`, tiap test `// @covers <TC-ID>`.

## 7. RUN — hijau

Syntax check dulu (detik, menangkap parse error), baru run penuh.

```bash
bun scripts/ci/syntax-check.ts
HEADLESS=true QASE_MODE=off playwright test --project=chromium --grep "<test name>"
bun scripts/mobile-runner.ts module/<module>/tests/<spec>.spec.ts -- --grep "<test name>"
```

Hanya status `passed` yang boleh dipetakan. `skipped`, `pending`, `flaky`, `failed` = belum
automation.

## 8. QUALITY GATE

```bash
python3 scripts/quality/check.py --ci          # tanpa --module
python3 scripts/cross-validate-automation.py
$PY $CKB selector <testid>                     # pastikan sitasi benar-benar resolve
```

`--module` membuat hitungan error tidak sebanding (hanya TC modul itu yang dimuat) — jangan dipakai
untuk menilai hasil akhir.

## 9. COMMIT + PUSH — dua repo

Branch `automation-worker/<module>-<slug>`, commit di repo automation, set `automationRef` di repo
testcase (4 field: `repo`, `path`, `command`, `branch`), push keduanya, buka **dua** PR.

## 10. REPORT

Sertakan: TC ID · apa yang di-ground dan di mana (`file:line`) · status test · asumsi dan flag
(doc drift, elemen hasil DOM inspection, gate yang kena). Deliverable berupa artefak yang benar-benar
jalan, bukan deskripsi.

## Bentuk `workspace/grounding/<TC-ID>.md`

```
## Selectors
login-button      -> // src: kerjaan-client-portal/src/.../Login.tsx:42

## Endpoints
POST /v1/auth/login -> // src: hcmsvc/internal/auth/handler.go:67

## Async
submission.created -> // src: hcmworker/internal/queue/submission.go:23

## Expected
expect(submitted)  -> // expect: suite.db PK12 "form submitted successfully"
expect(status=200) -> // expect: TC DF-M1-POS-001 Then "returns 200"

## Gaps
none
```
