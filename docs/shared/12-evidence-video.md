# 12 — Evidence video

Tujuan: video yang bisa ditemukan orang lain tanpa bertanya. Nama file = skenario, bukan hash folder.

## Lokasi simpan

| Track | Folder | Contoh |
|---|---|---|
| Web (Staffinc / INP) | `outputs/evidence/<YYYY-MM-DD>/` | `PM-C01-POS-006 - Create Review with valid data.mp4` |
| Mobile | `domain/mobile/test-results/recordings/` | `VIS-001 - Check in at location.mp4` |

Jangan simpan di `/tmp`. `outputs/` dan `test-results/` sudah gitignored — video tidak ikut commit.

## Aturan nama

1. `<TC-ID> - <Judul Skenario>.<ext>` — judul diambil dari judul test/TC, bukan nama folder artifact.
2. Karakter `/ : * ? " < > |` diganti `-`.
3. Run gagal → prefix `FAILED - ` dan taruh di `failures/`.
4. Dua test berjudul sama → suffix ` (2)`.
5. Satu file = satu skenario.

## Daftar isi

Setiap folder tanggal punya `index.md`:

| File | TC | Judul | Status | Durasi | Spec |
|---|---|---|---|---|---|
| `PM-C01-POS-006 - Create Review with valid data.mp4` | PM-C01-POS-006 | Create Review with valid data | passed | 42s | `domain/web/module/.../tests/...spec.ts` |

Tanpa index, folder tanggal hanya berguna bagi orang yang membuatnya.

## Prompt (copy-paste)

```text
Rekam evidence video untuk TC <TC-ID> saja.

1. Jalankan dengan HEADLESS=true dan video aktif, hanya spec/TC ini (bukan seluruh suite).
2. Simpan di outputs/evidence/<YYYY-MM-DD>/ (web) atau domain/mobile/test-results/recordings/ (mobile).
   Jangan simpan di /tmp.
3. Rename video jadi "<TC-ID> - <Judul Skenario>.mp4" — judul dari judul test/TC, bukan folder hash.
4. Kalau gagal: prefix "FAILED - " dan taruh di failures/.
5. Tulis index.md (file | TC | judul | status | durasi | spec).
6. Kirim semua path sebagai MEDIA: di akhir run; jangan commit artefak.
7. Sebutkan TC yang tidak direkam beserta alasannya.
```

## Verifikasi sebelum dikirim

- [ ] Video benar-benar ada di path yang disebut (cek `ls -la`).
- [ ] Nama file cocok dengan judul skenario, bukan hash.
- [ ] `index.md` ada dan jumlah barisnya = jumlah video.
- [ ] Status di index sesuai hasil run nyata (bukan asumsi).
- [ ] Ukuran wajar; kalau >45 MB, kompres atau pecah sebelum dikirim.
