# 14 — Pemantau update repo pendukung

`python3 scripts/monitor_submodules.py` membaca **seluruh** submodule di `.gitmodules` pada
`origin/main` Agentic, lalu membandingkan gitlink yang di-pin dengan HEAD **default branch** tiap
repo (`main`, `develop`, atau `master` sesuai GitHub). Pemantauan berlangsung read-only: tidak
checkout, pull, reset, atau mengubah clone/submodule yang dipakai agent lain. Auth memakai `gh`
CLI pada mesin yang punya akses ke repo privat. Jika satu repo gagal dibaca, proses gagal jelas,
bukan menyimpulkan semuanya mutakhir.

## Operasi bot

- Jadwalkan job Hermes cron harian pada **profil bot Telegram khusus** (profil itu punya tokennya
  sendiri dan akses `gh` ke semua repo); deliver ke chat pemilik. Gunakan `monitor` script
  `scripts/monitor_submodules.py` agar LLM hanya bangun jika hasil berubah. `--all` untuk audit.
- Pada tick pertama, hasil adalah baseline. Bila ada drift, bandingkan commit dan **diff relevan**
  (TC, skill, runner, CI, route, selector, aturan bisnis) terhadap dokumentasi Agentic. Jangan
  menyamakan setiap commit produk dengan kebutuhan mengubah workflow. Klasifikasikan perubahan
  relevan, tidak relevan, dan belum bisa diakses. Sertakan SHA asal/tujuan dan bukti file:line.
- Untuk perubahan yang membutuhkan penyesuaian Agentic, buat branch/worktree terpisah dari
  `origin/main`, ubah hanya dokumen/rules yang benar-benar terpengaruh, jalankan pemeriksaan,
  lalu buat **draft PR**; tidak merge, tidak post review, dan tidak memperbarui repo sumber.
  Jika belum ada pembaruan dokumentasi yang dapat dibuktikan, cukup kirim ringkasan tanpa PR.
- Saat sudah ada draft PR monitor terbuka, **jangan** buat PR duplikat untuk SHA yang sama.
  Jelaskan perubahan baru pada PR yang sama bila relevan dan aman; bila PR sedang ditangani
  manusia, jangan memaksakan push ke branch mereka. Dedup dari URL PR + daftar SHA dalam body.
- Jangan otomatis menggeser semua gitlink submodule hanya karena HEAD bergerak. Bump gitlink
  hanya bila diperlukan oleh perubahan yang direview, commit-nya dapat diakses, dan tidak
  bertentangan dengan pekerjaan lain. Sisanya adalah laporan drift untuk keputusan manusia.
- Kirim notifikasi Telegram ringkas: repo, SHA lama→baru, dampak ke Agentic, URL draft PR bila
  dibuat, blocker/yang tidak dicek. Tidak ada klaim `passed` tanpa run nyata.

## Setup dan verifikasi

1. Siapkan bot Telegram baru via BotFather; verifikasi token `getMe` sebelum cloning profil.
   Satu profil = satu token. Jangan menyimpan token di repo, PR, skill, atau cron prompt.
2. Clone profil Hermes yang sudah bekerja, ganti token pada **profil baru**, pastikan allowed user,
   pairing, `gh auth status`, dan akses ke semua repo; install/start gateway dan cek log Telegram.
3. Buat Hermes cron pada profil baru dengan `monitor` mengarah ke script absolut di checkout yang
   memuat file ini, `workdir` ke checkout tersebut, dan deliver `telegram:<chat_id>`. Instruksi
   mandiri job ada di `docs/shared/14-upstream-monitor-cron-prompt.md`. Jangan jadwalkan di profil
   default: platform tujuan tidak menentukan identitas bot pengirim.
4. Jalankan unit test script dan detektor live (`--all`), cek daftar seluruh submodule dan status
   drift. Uji cron satu kali, baca hasil job dan delivery bot. Bila `main` bergerak, cron harus
   memakai checkout/script yang diperbarui; pantau versi script saat update workflow.

Batas: monitor membandingkan HEAD default branch, bukan seluruh branch/PR terbuka. GitHub Actions
repo Agentic tidak otomatis dapat membaca repo privat organisasi memakai `GITHUB_TOKEN` default;
karena itu akses `gh` di mesin bot merupakan prasyarat, bukan secret yang ditaruh di Actions.
