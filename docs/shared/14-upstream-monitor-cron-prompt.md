# Prompt job monitor (profil bot khusus)

Gunakan teks berikut sebagai prompt Hermes cron **pada profil bot monitor**, setelah token dan akses repo disiapkan. Jangan simpan token dalam job.

```text
Pantau seluruh repo/submodule Workflow-Agentic-Sulas. Baca docs/shared/14-upstream-monitor.md dan jalankan `python3 scripts/monitor_submodules.py --all` dari workdir repo. Jangan menebak status dari cache; bila fetch/GitHub API gagal, laporkan blocker dan jangan buat PR. Parse JSON, hitung repo berubah secara programatik. Bandingkan setiap pinned SHA ke latest SHA default branch; lakukan analisis diff commit lewat API/clone read-only hanya untuk repo yang berubah dan pilih yang benar-benar mengubah aturan Agentic (TC/skills/CI/runner/selector/kontrak produk). Gunakan file:line, jangan menganggap setiap commit perlu update dokumen. Cek draft PR monitor terbuka agar tidak duplikat. Bila ada update Agentic yang terbukti diperlukan, buat worktree branch sendiri dari origin/main, edit dokumen terkait, jalankan pemeriksaan lokal, buat draft PR di sulastambunan/Workflow-Agentic-Sulas; jangan merge atau post review. Jangan mengubah checkout/submodule shared ataupun repo sumber. Jika tidak ada update Agentic yang valid, jangan buat PR. Balas ringkas dalam Bahasa Indonesia: jumlah repo diperiksa dan drift, mana yang relevan, bukti SHA, link draft PR atau alasan tidak membuatnya, serta langkah yang terblokir. Output ini otomatis dikirim oleh cron; jangan kirim pesan manual dari dalam job.
```

**Catatan dedup:** `monitor` script sebagai change detector membuat agent tidak jalan jika output sama; tetapi saat hasil `--all` berbeda karena perubahan parent gitlink, job tetap harus cek PR yang sudah ada. Pada tick pertama tetap ada satu run baseline.
