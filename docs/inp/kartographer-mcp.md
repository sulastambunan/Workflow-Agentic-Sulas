# 09 — kartographer-mcp (navigasi codebase INP)

`kartographer-mcp` adalah MCP server read-only yang menyajikan index codebase PHP/Laravel
(`utility-portal`, `utilitysvc`, `utilityapp`) sebagai graph: entry point (route/command/job),
call chain, FormRequest rules, DTO shape, dan tabel DB yang disentuh.

Tujuannya di workflow kita: **berhenti membaca repo dari nol**. Sebelum probe UI, tanya index dulu —
"route ini masuk ke method apa, validasinya apa, payload-nya apa".

Repo: `rotaigalp/kartographer-mcp` (private, PHP 8.3+).

## Menjalankan

```bash
php bin/kartographer-mcp --db=utility-portal=/path/output/utility-portal-dev/utility-portal-dev.sqlite
```

- `--db=ALIAS=PATH` — satu flag per index; alias dipakai sebagai argumen `db` saat lebih dari satu index.
- `--codebase-root=ALIAS=/path/checkout` — mengaktifkan tool `codebase_map` (file, node, dampak
  perubahan) dan baris source **hanya** kalau hash span masih cocok (`provenance: verified`).
- `--http` / `--port=N` — streamable HTTP (default `127.0.0.1:9000`); stdio adalah default.
- Tanpa autentikasi: jangan bind ke `0.0.0.0`.

Index dibuat oleh `kartographer db {project}` di repo Kartographer, bukan oleh server ini.

## Tool → kebutuhan test

| Kebutuhan | Tool |
|---|---|
| Cari fitur/route dari nama | `search_entries` → `get_entry` |
| Alur yang dijalankan satu route (urutan bisnis) | `get_trace_full` / `summarize_trace` |
| Rantai pemanggilan ke satu method | `path_from_root`, `children_of`, `subtree_from` |
| **Aturan validasi + nama field** | `get_request_rules` (per route/FQCN), `search_rules` (per field/rule) |
| Bentuk payload/response | `get_dto_shape`, `dtos_of` |
| Tabel DB yang dibaca/ditulis (untuk precondition & verifikasi) | `tables_of`, `processes_of`, `list_tables` |
| Bandingkan implementasi dev vs main | `compare_entries` |
| File/node yang terdampak satu perubahan | `codebase_map` (`files`, `nodes`, `node`, `impact`) |

Yang paling sering dipakai saat menulis TC: `get_request_rules` (sumber aturan NEG: `required`,
`max`, `in:...`, pesan validasi) dan `tables_of` (state yang harus disiapkan).

## Aturan pakai (jangan salah percaya)

1. **Ini snapshot, bukan app.** Index bisa lebih tua dari HEAD. Cek baris startup
   (`built …`, jumlah `stale`) dan bandingkan dengan commit repo. Index basi → rebuild dulu,
   jangan simpulkan perilaku dari index lama.
2. **`stale` = jangan dipercaya.** Entry yang stale bisa menunjuk method yang sudah berubah.
3. **Entry id jangan ditebak.** Cari dengan `search_entries`; kalau alias salah, baca daftar alias
   dari pesan error, bukan mengarang.
4. **Baris source hanya kalau `provenance: verified`.** Selain itu buka file di path yang dikembalikan;
   `changed` / `missing` / `unresolved` berarti index tidak sinkron dengan checkout.
5. **MCP menunjukkan di mana harus melihat, bukan apa yang harus di-assert.** Assertion tetap dari
   TC + perilaku app nyata.
6. **Read-only.** Jangan menjadikannya tempat menulis atau memperbaiki data.

## Kapan dipakai di workflow

- **Fase 1 (grounding, track INP):** cari entry → baca trace → ambil validation rules + DTO + tabel
  → baru probe UI kalau masih ada yang tidak terjawab.
- **Fase 2 (desain):** rules dari `get_request_rules` jadi kandidat skenario NEG per aturan.
- **Fase 6 (review):** `compare_entries` untuk memastikan perilaku yang diuji memang ada di branch
  yang dipakai, `codebase_map impact` untuk melihat file yang terdampak perubahan.
