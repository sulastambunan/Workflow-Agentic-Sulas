# 05 — Failure modes dan eskalasi (Staffinc)

| Gejala | Penyebab | Tindakan |
|---|---|---|
| 404 di `/v1/agent/submissions/form-versions/*`, form duplikat tiap run | admin dan worker beda `client_id` | decode JWT, samakan ke 2469 |
| `device not found` di tengah run | QEMU crash (kernel host 6.17) | restart emulator; pakai `StaffincA33`, bukan `StaffincTest` |
| `qa_kb` mengembalikan 0 tanpa error | nama modul automation dipakai, bukan nama repo-native | ulangi dengan nama repo-native (`submission`) |
| `ModuleNotFoundError: No module named 'sqlite_vec'` | interpreter salah | pakai `/usr/bin/python3` |
| Tool call diblokir | `plan_gate` / `citation_gate` / `skill_diet` belum dipenuhi | baca pesan gate, penuhi kondisinya, jangan ulangi buta |
| `bun run type-check` 2.591 error | error lama di 255 file | pakai `syntax-check.ts` |
| `check.py` Grade A untuk 0 test | versi lama hanya cocokkan `test(` | tarik fix `it(` dari `develop` |
| Sitasi hilang di tengah sesi | context compression | baca `workspace/grounding/<TC-ID>.md` |
| Error per modul terlihat kecil | `--module` dipakai | jalankan tanpa `--module`, bandingkan repo-wide |

## Aturan eskalasi

- **Maksimal 2 percobaan debug.** Kalau test masih gagal, berhenti: laporkan kegagalan, grounding
  yang sudah ada, dan apa yang sudah dicoba. Keputusan berikutnya milik user.
- **Elemen tidak bisa di-ground** (`code_kb` 0 + live inspection habis) → **stop dan laporkan**.
  `// src: none (justified: ...)` hanya dengan alasan eksplisit dan bisa diaudit.
- **App berbeda dari TC** → jangan sesuaikan assertion agar hijau. Kumpulkan bukti (AC, langkah,
  hasil aktual, id record) lalu tanya user: perbaiki TC di `staffinc-testcase` atau catat defect.
- **Gate memblokir** → jangan cari jalan memutar. Penuhi gate atau hentikan pekerjaan.

## Batas keras

Tidak ada selector tanpa `// src:`. Tidak ada `expect()` tanpa `// expect:`. Tidak ada
`automated` tanpa run `passed`. Tidak ada commit di atas gate merah. Tidak ada commit langsung ke
`main`/`develop`. Tidak ada satu PR tanpa pasangannya.
