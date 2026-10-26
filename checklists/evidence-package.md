# Checklist — paket bukti (video / artifact)

## Sebelum run
- [ ] Video/trace diaktifkan (`ENABLE_VIDEOS=true` atau setara)
- [ ] Hanya spec yang relevan yang dijalankan (bukan seluruh suite)
- [ ] Artifact lama sudah tidak dipakai sebagai bukti — folder dibersihkan tiap run

## Saat run
- [ ] Perintah lengkap dicatat (termasuk flag dan env)
- [ ] `--workers=1` kalau butuh urutan yang deterministik untuk pemetaan evidence
- [ ] Jangan pakai `--reporter` CLI yang menimpa reporter config — hasil JSON/HTML hilang

## Setelah run
- [ ] mtime artifact ≥ mtime file yang diedit (run memakai kode terbaru)
- [ ] Nama file = TC: `<TC-ID>__<spec>__<judul>.webm`
- [ ] Test tanpa TC (setup) memakai prefix `SETUP__`, bukan ID pinjaman
- [ ] Pemetaan 1:1: jumlah artifact = jumlah test yang dijalankan, tanpa duplikat
- [ ] `MANIFEST.txt` berisi file → test → covers
- [ ] Zip dikirim bersama laporan, bukan disimpan sendiri

## Jangan
- [ ] Jangan kirim video tanpa nama TC
- [ ] Jangan klaim "sudah pakai bukti" kalau video berasal dari run sebelum patch
- [ ] Jangan unggah artifact yang berisi cookie, token, atau data pribadi
