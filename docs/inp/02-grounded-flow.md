# 02 — Alur grounded per TC (INP)

Sepuluh langkah, satu TC. Struktur sama dengan track Staffinc; yang berbeda hanya alat grounding
dan perintah run.

## 1. READ — TC + preconditions

```
repos/automation-code/staffinc-testcase/testcases/web/<module>/<TC-ID>.md
repos/automation-code/staffinc-testcase/preconditions/*.md
```

Catat `automationStatus`, `sourceRefs`, dan modul. Pastikan masih `planned`.

## 2. FETCH — peta modul

Sekali per modul: cari entry utama (route/halaman) dan simpan hasilnya untuk semua TC modul itu.

```
search_entries "performance review"          -> entry halaman/route
get_trace_full <entry-id>                    -> urutan langkah bisnis
```

## 3. GROUND — teknis

Untuk tiap langkah TC, ambil bukti dari index lalu konfirmasi di kode:

```
get_request_rules <entry-id>     -> field wajib + aturan (bahan skenario NEG)
get_dto_shape <entry-id>         -> bentuk payload/response
tables_of <entry-id>             -> tabel yang berubah (precondition & verifikasi)
path_from_root / children_of     -> method yang benar-benar dipanggil
```

Catat `// src: utility-portal/path/file.php:line` atau `// src: utilitysvc/path/file.py:line`.
Kalau `provenance` bukan `verified`, buka filenya — jangan mengutip baris dari index.

## 4. GROUND + VALIDATE — expected result

Expected value diambil dari TC. Kalau kode menunjukkan aturan yang berbeda (mis. batas karakter,
urutan status, teks error), itu **temuan**: kumpulkan bukti dan eskalasi sebelum menulis assertion.

Tidak ada padanan `suite.db` yang terverifikasi di track ini — jangan mengarang sumber aturan bisnis.

## 5. PERSIST + PLAN

Tulis `workspace/grounding/<TC-ID>.md` (selector/route, field, tabel, sitasi, gap). Sampaikan
rencana per langkah, lalu **panggil `clarify()`** dan tunggu "Go".

## 6. BUILD — DDD

Mengikuti aturan yang sama: SPEC → USECASE → PAGE/SCREEN (+ FACTORY). Spec tidak menyentuh
selector mentah; semua interaksi lewat PAGE/SCREEN, orkestrasi lewat USECASE.

## 7. RUN

```bash
bun run check-all
bun run test:web:inp -- --grep "<test name>"
```

Selalu `--project=inp`. Tanpa itu project `partner-*` ikut jalan dan hasilnya jadi noise.
Hanya `passed` yang boleh dipetakan.

## 8. QUALITY GATE

```bash
bun run check-all
```

Belum ada cross-validator INP yang setara track Staffinc. Yang tetap wajib: `@covers` lengkap per
test, tidak ada stub, tidak ada `test.only`, tidak ada `console.log`.

## 9. COMMIT + PUSH — dua repo

Branch sendiri (mis. `feat/<module>-<slug>`), commit spec di `internaltools-automation`, set
`automationRef` di `staffinc-testcase` (repo, path, command, branch), buka dua PR.

## 10. REPORT

TC ID · entry/tool yang dipakai · sitasi file:line · status test · gap yang ditemukan
(terutama beda app vs TC).
