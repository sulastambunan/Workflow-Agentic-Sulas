# 11 — Pre-push review

Gate terakhir sebelum branch keluar dari mesin. Bedanya dengan review PR: ini membaca **diff lokal**
(staged, unstaged, dan commit di branch), bukan PR yang sudah dibuka.

Skill agent-nya: `staffinc-automation-pre-push-review` (profil `automation-worker`).

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
- Artefak review dan komentar GitHub: English.
- Format temuan: Location / Issue / Impact / Fix / Verification.
- Akhiri dengan verdict, jumlah blocker, perintah yang benar-benar dijalankan, dan hal yang **belum**
  diverifikasi (mis. belum ada run live).
