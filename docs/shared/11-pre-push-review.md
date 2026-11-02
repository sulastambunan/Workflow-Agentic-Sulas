# 11 — Pre-push review

Gate terakhir sebelum branch keluar dari mesin. Bedanya dengan review PR: ini membaca **diff lokal**
(staged, unstaged, dan commit di branch), bukan PR yang sudah dibuka.

Untuk Staffinc, sumber review semantik: `skills/automation-pr-review/SKILL.md` beserta ketiga
`references/`-nya (salinan utuh skill lead). Skill aslinya untuk **PR orang lain**, bukan self-check;
gunakan pemeriksaan semantiknya untuk diff lokal dengan adaptasi eksplisit di bawah. Skill
`staffinc-automation-pre-push-review` (profil `automation-worker`) boleh jadi pelengkap, bukan
pengganti. Untuk INP, pertahankan gate track INP; jangan mengklaim skill Staffinc berlaku di sana.

## Adaptasi self-review sebelum push (Staffinc)

- Target bukan nomor/head PR: pin `HEAD`, base yang benar (termasuk stacked branch), dan diff
  `base...HEAD` **ditambah staged, unstaged, untracked**. Jangan checkout/reset shared tree.
- Jalankan intake/assumption ledger, inventaris spec/usecase/page/fixture, per-`@covers` clause
  table, scan red flags/vacuous pass/env/time/data, gates, verifikasi temuan, dan laporan sesuai
  `SKILL.md` langkah 0–8. `references/intake-and-assumptions.md`, `review-checks.md`, dan
  `report-and-posting.md` wajib dibaca ketika langkahnya tiba. Tandai klaim PR, paired PR, dan
  CI PR sebagai belum ada, bukan sebagai sudah diperiksa. Langkah 9 (posting) tidak berlaku.
- Gunakan TC `staffinc-testcase` main yang bersih dan mutakhir (atau head paired testcase PR
  untuk TC baru). Bila TC tidak tersedia, jangan klaim coverage terverifikasi; berhenti dan
  minta keputusan bila review semantik terblokir. Pastikan tiap Given/When sesuai dan tiap Then/And
  outcome punya assertion yang benar-benar bisa gagal saat fitur rusak.
- `scripts/pre-push-review.sh <base>` memeriksa diff lokal secara deterministik; jalankan juga
  `python3 scripts/check_agent_rules.py --base <base>` dan type-check repo. Jangan substitusi
  `pr_guard.py` PR pada head lokal yang belum mencakup file staged/unstaged.
- Verdict adaptasi: `PASS` = tak ada blocker dan semua klausul ter-assert; `CONDITIONAL` = tidak
  ada blocker tetapi ada prasyarat yang diputus manusia; `REQUEST_CHANGES` = ada blocker, **jangan
  push**. Major tetap harus dibereskan atau diputus manusia, bukan disembunyikan di PASS.
- Lampirkan SHA/base, sumber TC, basis run (run fase 5 vs review code-only), findings `file:line`,
  coverage, gate, asumsi, dan yang belum diverifikasi. Setelah perbaikan, ulang review atas diff
  terbaru. Channel percakapan ini untuk review PR; jangan post GitHub tanpa permintaan eksplisit.

## Urutan wewenang

```
TSD → testcase/GWT (staffinc-testcase) → kode produk → diff → bukti run
```

`suite.db` hanya alat bantu pencarian, bukan sumber requirement. Kalau kode bertentangan dengan TC,
itu **drift** yang dilaporkan — bukan alasan melemahkan assertion.

## Tiga aturan yang wajib lolos

1. **GWT sesuai `staffinc-testcase`.** Tiap `Then`/`And` punya minimal satu assertion yang bisa
   gagal. Klausa yang hanya ada di komentar, `console.log`, atau catch yang ditelan = BLOCKER.
2. **Assertion sesuai TC.** Teks, status, jumlah, dan nilai field diambil dari TC dan
   preconditions-nya — bukan dari apa yang kebetulan dikembalikan kode.
3. **`@covers` ada dan sesuai.** Tiap deklarasi test punya `@covers <TC-ID>`; ID-nya ada di ledger;
   test benar-benar mengeksekusi skenario TC itu, bukan ID tetangga.

## Langkah

1. **Scope** — `git status`, `git diff --stat origin/develop...HEAD`, cek conflict marker.
2. **Coverage map** — spec → judul test → `@covers` → file TC.
3. **Resolve TC** — id ada, status bukan `deprecated`, `automationRef.path` + `command` menunjuk
   spec dan judul test yang benar; tidak ada status `automated` yang tertinggal dari test yang
   di-rename/dihapus.
4. **GWT traceability** — tabel: klausa TC → jenis (Given/When/Then) → tempat implementasi →
   assertion yang bisa gagal.
5. **Audit assertion** — tolak tautologi, `||` fallback, array status permisif, cek panjang objek
   statis, `createSuccessResult({ skipped: true })`.
6. **DDD** — spec tanpa `page.`/`$(`/`driver.`; usecase tanpa `expect()`; page/screen tanpa logika
   bisnis; factory tanpa API/alur.
7. **Pitfall statis** — lihat `references/pitfalls.md` di skill: TS2729, `ChainablePromiseArray.length`,
   throwing stub, `recordResult`, path mesin hardcoded, `process.env` di top-level, SQL mentah.
8. **Cek murah** — `syntax-check.ts` / `bun run check-all` / `check.py --ci` (repo-wide), checker
   repo. Run E2E hanya spec yang berubah dan hanya kalau user mengizinkan.

## Verdict dan keputusan push

| Verdict | Arti | Push? |
|---|---|---|
| `PASS` | 0 blocker | ya |
| `CONDITIONAL` | 0 blocker, ada prasyarat (mis. commit TC belum di-push) | ya, setelah user setuju |
| `REQUEST_CHANGES` | ≥ 1 blocker | **tidak** |

Blocker: requirement hilang/terbalik, assertion tautologis atau error ditelan, `@covers`
salah/hilang, selector/endpoint fiktif, crash saat discovery, secret bocor, aksi destruktif.

## Output

- Chat: Bahasa Indonesia.
- **Gaya jawaban:** singkat dan langsung ke poin; detail tetap ada tapi padat. Tanpa mengulang isi
  file/diff, cukup `file:line` yang relevan. Satu putaran review = satu verdict.
- Artefak review dan komentar GitHub: English.
- Format temuan: Location / Issue / Impact / Fix / Verification.
- Akhiri dengan verdict, jumlah blocker, perintah yang benar-benar dijalankan, dan hal yang **belum**
  diverifikasi (mis. belum ada run live).

## Menjalankan gate

```bash
bash scripts/pre-push-review.sh origin/develop     # deterministik: conflict, .only, console.log,
                                                   # secret, @covers vs ledger, tautologi
bash scripts/install-pre-push-hook.sh /path/to/staffinc-automation   # pasang sebagai hook git
```

Script ini lantai, bukan pengganti: kecocokan GWT dan isi assertion tetap diperiksa manual
(skill `staffinc-automation-pre-push-review`). `REQUEST_CHANGES` = jangan push.
