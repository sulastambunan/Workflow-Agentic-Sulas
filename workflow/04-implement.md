# Phase 3 — Implement

**Goal:** kode yang mengikuti kontrak layer, bukan kode yang kebetulan hijau.

## Order of work

1. **Factory** — data valid + varian invalid (override), tanpa API dan tanpa alur.
2. **Layer 3** — locator dan aksi, mengembalikan nilai mentah. Probe dulu kalau kontrol belum dikenal.
3. **Usecase** — urutan langkah, `UsecaseResult`, `try/catch`, validasi lewat `HttpResult`.
4. **Spec** — panggil usecase, `@covers`, assertion yang bisa gagal.

## Rules while coding

- Jangan menyentuh file di luar scope mapping tanpa memberi tahu.
- Jangan menghapus assertion lama saat menyelaraskan; tambahkan assertion baru.
- Jangan menulis komentar `//` naratif di spec — cukup header satu baris + `@covers`.
- Jangan menaruh kredensial, id environment, atau token di kode.
- Ikuti pola repo untuk fixture/hook; jangan mengubah pola hanya karena "lebih bersih".

## Handling a failing assertion

Kalau app tidak berperilaku seperti TC:

1. Buktikan constraint-nya ada (atribut `maxlength`/`required`, response body, status).
2. Kalau aturannya memang tidak diimplementasikan → itu temuan produk, bukan izin mengubah
   assertion. Laporkan: env, langkah, expected (kutip AC), actual (status + id record), bukti.
3. Keputusan cara test berdiri (merah, `test.fail()` + catatan KNOWN BUG, atau diturunkan ke
   manual) milik manusia.

## Output

```text
CREATE/CHANGE: <file + ringkas isi>
FOLLOWED PATTERN: <file referensi di repo>
DEVIATION: <kalau ada + alasan>
```

## Exit criteria

- Setiap test punya `@covers` dan assertion yang gagal kalau perilaku berubah.
- Tidak ada `console.log`, emoji, atau assertion di layer 2.
- `scripts/check_agent_rules.py` lulus untuk file yang berubah.
