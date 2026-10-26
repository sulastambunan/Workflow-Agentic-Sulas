# 04 — Quality gate (INP)

| # | Cek | Perintah | Lulus kalau |
|---|---|---|---|
| 1 | Type + lint | `bun run check-all` | exit 0 |
| 2 | Test | `bun run test:web:inp -- --grep "..."` | status `passed` |
| 3 | `@covers` | inspeksi spec | tiap deklarasi test punya `@covers <TC-ID>` |
| 4 | DDD | inspeksi spec/page | tidak ada raw locator / `page.click()` di spec |
| 5 | Stub | inspeksi | tidak ada `expect(true)`, `toBeDefined()` tanpa nilai, `test.only` |
| 6 | Artefak | jalankan dengan video | video tersimpan di `test-results/recordings/` |

Yang belum ada di track ini: `syntax-check.ts`, `check.py --ci`, `cross-validate-automation.py`,
dan gate mekanis `plan_gate` / `citation_gate`. Jangan mengklaim gate itu hijau — sebutkan apa yang
benar-benar dijalankan.

## Aturan status

Sama seperti track Staffinc: hanya `passed` yang boleh dipetakan ke `automated`. `skipped`,
`pending`, `flaky`, `failed` bukan automation.

## Run dan bukti

- `HEADLESS=true` untuk semua run.
- Video wajib; nama file mengikuti judul skenario.
- Verifikasi terarah: pakai `-g` untuk perbaikan; jangan menjalankan seluruh suite untuk satu TC.

## Review

Self-review isi branch sebelum meminta review. Perubahan dari reviewer dikerjakan di branch yang
sama; merge hanya setelah approval — agent tidak merge sendiri.
