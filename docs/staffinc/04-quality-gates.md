# 04 — Quality gate (Staffinc)

Gate dijalankan **sebelum** commit, bukan sesudah CI merah.

| # | Cek | Perintah | Lulus kalau |
|---|---|---|---|
| 1 | Syntax | `bun scripts/ci/syntax-check.ts` | exit 0, tidak ada parse error |
| 2 | Test | `playwright test --grep "..."` / `mobile-runner.ts` | status `passed` |
| 3 | Quality | `python3 scripts/quality/check.py --ci` | grade A/B, **tanpa** `--module` |
| 4 | Cross-validate | `python3 scripts/cross-validate-automation.py` | tidak ada `@covers` / `automationRef` yatim |
| 5 | Sitasi resolve | `$PY $CKB selector <testid>` | tiap `// src:` menunjuk kode nyata |
| 6 | Self-review | checklist `automation-spec-reviewer` | DDD patuh, tidak ada stub, tidak ada raw locator |
| 7 | Mobile grade | `grep -c '(?:test\|it)' scripts/quality/check.py` | hasil non-zero (fix `it(` ada) |

## Aturan status

Hanya **`passed`** yang boleh dipetakan ke `automationStatus: automated`.

`skipped`, `pending`, "pending server", `flaky`, `failed` **bukan** automation. Biarkan TC tetap
`planned`, atau tandai gap dengan alasan. Menandai `automated` tanpa run yang lulus = forgery.

## Kenapa `--module` dilarang untuk penilaian akhir

Dengan `--module`, `check.py` hanya memuat TC modul itu, sehingga baseline error berubah dan
angkanya terlihat jauh lebih kecil (144 / 349 / 374 per modul). Yang dibandingkan adalah hitungan
repo-wide sebelum vs sesudah.

## Dual PR

`cross-validator` gagal kalau hanya satu repo yang di-PR. Spec di repo automation membawa
`// @covers <TC-ID>`; repo TC membawa `automationRef` yang menunjuk balik ke spec itu.
`automationRef` saat `automated` berisi 4 field: `repo`, `path`, `command`, `branch`.
Saat `planned`, nilainya `null`.

## Review

Self-review dulu terhadap checklist sebelum minta review orang. Kalau reviewer minta perubahan,
perbaiki di branch yang sama dan push — jangan buka PR baru. Merge hanya setelah ada approval;
bot/agent tidak merge sendiri.
