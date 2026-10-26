# Phase 4 — Verify & evidence

**Goal:** hasil yang bisa dikutip, bukan hasil yang bisa dibayangkan.

## Steps

1. Tentukan run yang tepat: satu file spec utuh untuk alur berantai, `-g` hanya untuk spec
   mandiri. Jangan jalan seluruh suite untuk satu perbaikan.
2. Jalankan. Simpan perintah + output.
3. Kalau butuh bukti visual: jalankan ulang dengan video aktif. Simpan di
   `outputs/evidence/<YYYY-MM-DD>/` (web) atau `domain/mobile/test-results/recordings/` (mobile), lalu
   rename jadi `<TC-ID> - <Judul Skenario>.mp4`. Detail: `docs/shared/12-evidence-video.md`.
4. Bandingkan mtime artifact dengan mtime file yang diedit — pastikan run memakai kode terbaru.
5. Jalankan gate lokal: `python3 scripts/check_agent_rules.py --base <base>` (+ type-check repo).
6. Jalankan pre-push review (`docs/shared/11-pre-push-review.md`): GWT sesuai TC, assertion sesuai
   TC, `@covers` ada dan cocok, DDD, pitfall statis. `REQUEST_CHANGES` = jangan commit/push.

## Output

```text
RAN: <command>
RESULT: <n passed / n failed + durasi>
FAILED STEP: <kalau gagal: nama step + pesan>
EVIDENCE: <path file, nama = TC>
NOT RUN: <yang sengaja tidak dijalankan + alasan>
```

## Exit criteria

- Verdict berasal dari output nyata, bukan ingatan.
- Setiap klaim "sudah jalan" punya command + hasil.
- Kalau ada yang gagal: langkah yang gagal disebut, bukan "ada error".

## Prompt

```text
Lanjut fase 5: jalankan hanya spec yang berubah (<path>) dengan <flag yang benar>.
Sertakan perintah lengkap dan output aslinya. Kalau butuh video, aktifkan dan beri nama per TC.
Jangan menyimpulkan hijau untuk apa pun yang tidak dijalankan.
```
