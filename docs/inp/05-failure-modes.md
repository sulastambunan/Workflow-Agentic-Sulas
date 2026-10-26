# 05 — Failure modes dan eskalasi (INP)

| Gejala | Penyebab | Tindakan |
|---|---|---|
| Tool MCP menolak / entry tidak ketemu | entry id ditebak | `search_entries` dulu, jangan mengarang id |
| Kesimpulan bertentangan dengan app | index basi / entry `stale` | rebuild index, lalu ulangi |
| Baris sitasi tidak cocok | `provenance` bukan `verified` | buka file di path yang diberikan |
| Banyak test partner ikut jalan | `--project=inp` tidak dipakai | tambahkan `--project=inp` |
| Spec lulus tapi tidak menguji apa pun | stub / assertion lemah | perbaiki assertion dari TC, bukan dari kode |
| `check-all` gagal di file yang tidak disentuh | error lama | catat sebagai pre-existing, jangan sembunyikan |

## Aturan eskalasi

- **Maksimal 2 percobaan debug**, lalu laporkan kegagalan + grounding + yang sudah dicoba.
- **Tidak bisa di-ground** → stop dan laporkan. Jangan menebak selector, route, atau field.
- **App berbeda dari TC** → jangan sesuaikan assertion agar hijau. Kumpulkan bukti (langkah,
  hasil aktual, id record) lalu tanya user: perbaiki TC atau catat defect.
- **Index tidak tersedia** → grounding lewat kode langsung, dan sebutkan di laporan bahwa MCP
  tidak dipakai.

## Batas keras

Tidak ada selector tanpa sumber. Tidak ada `automated` tanpa run `passed`. Tidak ada commit ke
`develop`. Tidak ada satu PR tanpa pasangannya.
