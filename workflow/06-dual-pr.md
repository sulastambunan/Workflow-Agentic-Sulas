# Phase 6 — Dual PR + status flip

**Goal:** perubahan masuk lewat dua PR yang saling menunjuk, lalu ledger di-flip setelah merge.

## Dua PR, satu pekerjaan

| PR | Repo | Isi |
|---|---|---|
| Automation | `staffinc-automation` | spec/usecase/page + `@covers` + `test-specs.json` |
| Ledger | `staffinc-testcase` | `automationStatus` + `automationRef` untuk TC yang sama |

Body PR ledger wajib menyebut PR automation-nya:

```text
Automation-PR: <org>/<repo>#<n>
```

## Urutan yang benar

```
1. push branch automation → buka PR
2. review + merge PR automation ke default branch
3. baru buka/merge PR ledger yang menaikkan status
4. CI ledger regenerate report web
```

Kalau status dinaikkan sebelum PR automation merged, check `automation-merged` gagal
(`<path> does not exist on the default branch; no pull request covers it either`).

## Isi PR automation

```text
## What
<TC/spec yang ditambah atau diubah>

## Evidence
<perintah + hasil, path video/zip>

## Not verified
<bagian yang belum dijalankan + alasan>

## Traceability
| TC | Spec | Status |
|---|---|---|
```

## Isi PR ledger

- Hanya file TC yang diubah (`git add testcases/<product>/<module>/`).
- Sebut mapping path lama → baru kalau ada rename.
- Sertakan hasil `testcase:validate` + `testcase:build` yang dijalankan **dengan env root**.
- Jangan commit `indexes/` atau `reports/**` (generated).

## Review loop

1. Baca review TERBARU; catat `commit_id` yang dinilai.
2. Verifikasi setiap temuan terhadap kode saat ini, satu perintah per temuan.
3. Perbaiki per wave; commit message memetakan temuan → fix.
4. Komentar PR: mapping + bukti, pisahkan VERIFIED vs PENDING.
5. Jangan merge PR orang lain; tunggu approving review.

Detail: `docs/07-pr-and-review.md`.

## Exit criteria

- PR automation dan PR ledger saling menunjuk.
- Status di ledger belum diklaim naik sebelum PR automation merged.
- Setiap klaim punya perintah + hasil nyata.
