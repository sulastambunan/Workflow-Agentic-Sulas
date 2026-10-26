# Phase 5 — Commit, PR, review loop

**Goal:** pekerjaan sampai ke reviewer dengan jejak yang bisa diperiksa, tanpa merge.

## Commit

1. Stage selektif — jangan `git add .`. Buang probe, worklog, hasil generate.
2. Satu commit per wave perubahan; pesan memetakan temuan/perubahan → alasan.
3. Jalankan hook/gate repo lebih dulu kalau hook sering gagal di lingkungan ini.
4. Push hanya setelah manusia meminta.

## PR body

```text
## What
<ringkas: TC/spec yang ditambah atau diubah>

## Evidence
<perintah + hasil, path video/zip>

## Not verified
<bagian yang belum dijalankan + alasan>

## Traceability
| TC | Spec | Status |
|---|---|---|
```

## Review loop

1. Baca review TERBARU, catat hash yang di-review.
2. Verifikasi setiap temuan terhadap kode saat ini dengan satu perintah per temuan.
3. Perbaiki per wave; commit message memetakan temuan → fix.
4. Post komentar PR dengan mapping + bukti.
5. Pisahkan VERIFIED vs PENDING. Jangan merge — tunggu approving review.

Detail lengkap: `docs/04-pr-review-loop.md`.

## Exit criteria

- Reviewer bisa menjawab "apakah ini sesuai review?" hanya dari komentar PR.
- Tidak ada klaim hijau untuk run yang tidak dijalankan.
- PR tidak di-merge oleh agent.
