# 01 — Arsitektur Automation Worker (INP / internal tools)

Konsepnya sama dengan track Staffinc: TC `planned` → spec yang lulus, DDD-compliant, tiap selector
dan expected value punya sumber. Bedanya di repo codebase, tooling grounding, dan runner.

Platform saat ini: **web** (Playwright, project `inp`). Mobile belum ada track-nya di
`internaltools-automation`.

## Tujuh lapis (versi INP)

| # | Lapis | Isi | Peran |
|---|---|---|---|
| 1 | Source | `staffinc-testcase` (ledger), `utility-portal` (PHP web), `utilitysvc` (Python API), `utilityapp` (PHP app) | ground truth, read-only |
| 2 | Knowledge | `kartographer-mcp` (index route, call chain, request rules, DTO, tabel) + pembacaan kode | navigasi + sitasi |
| 3 | Skill | skill automation INP (`internal-tools` / `automation-worker`) | cara kerja track |
| 4 | Gate | `bun run check-all` + aturan repo | menegakkan kualitas |
| 5 | Build | SPEC → USECASE → PAGE/SCREEN (+ FACTORY) | kode test |
| 6 | Execution | Playwright `--project=inp`, `bun run test:web:inp` | menjalankan |
| 7 | Output | `internaltools-automation` (spec), `staffinc-testcase` (`automationRef`), dual PR | hasil |

## Sumber kebenaran

1. **TC di ledger** — klaim Given/When/Then adalah kontrak.
2. **Kode di `utility-portal` / `utilitysvc`** — route, validasi (`FormRequest`), DTO, tabel.
3. **Aplikasi live** — hanya untuk hal yang tidak terjawab kode (copy tombol, urutan render).

Kalau app berbeda dari TC: berhenti, kumpulkan bukti, tanya user — perbaiki TC atau catat defect.
Jangan melemahkan assertion agar hijau.

## Grounding lewat `kartographer-mcp`

Index dibangun dari codebase, disajikan read-only oleh MCP. Fungsinya menyamai `code_kb` di track
Staffinc, tetapi berbentuk graf (entry → call chain → rules/DTO/tables), bukan vector search.

| Kebutuhan | Tool |
|---|---|
| Cari route/fitur | `search_entries` |
| Metadata satu entry | `get_entry` |
| Urutan alur yang dijalankan route | `get_trace_full` / `summarize_trace` |
| Rantai pemanggilan ke sebuah method | `path_from_root` / `children_of` / `subtree_from` |
| Aturan validasi + nama field | `get_request_rules` / `search_rules` |
| Bentuk payload/response | `get_dto_shape` / `dtos_of` |
| Tabel yang disentuh | `tables_of` / `processes_of` / `list_tables` |
| Bandingkan branch dev vs main | `compare_entries` |
| Peta file/node/impact | `codebase_map` |

Aturan pakai:

- **Index adalah snapshot.** Cek build time dan jumlah entry `stale` saat start. Index basi atau
  entry `stale` tidak boleh dipakai untuk menyimpulkan perilaku — rebuilt dulu.
- **Entry id tidak ditebak.** Selalu `search_entries` dulu.
- **`provenance` bukan `verified`** → buka file di path yang diberikan, jangan mengutip baris.
- MCP menunjukkan **di mana harus melihat**, bukan **apa yang harus di-assert**. Assertion tetap
  dari TC + perilaku app.

Detail tool dan batasan: `docs/inp/kartographer-mcp.md`.

## Gate

Track INP belum punya gate mekanis setara `plan_gate` / `citation_gate`. Yang berlaku sekarang:

- `bun run check-all` (tsc + lint) sebelum commit.
- Aturan DDD dan `@covers` tetap sama — ditegakkan lewat review, bukan hook.
- Kalau nanti gate Staffinc dipasang di INP, aturannya mengikuti: rencana dikonfirmasi dulu,
  sitasi wajib, dan tidak ada jalan memutar untuk melewati gate.

## Yang tidak boleh dilakukan

- Tidak ada selector/endpoint tanpa sumber (`// src:`); untuk INP sitasi menunjuk
  `utility-portal`/`utilitysvc` path + baris.
- Tidak menebak entry id, route, atau nama field.
- Tidak menandai `automated` kalau test belum `passed`.
- Tidak commit ke `develop`; selalu branch sendiri.
- Tidak ada satu PR saja — spec dan `automationRef` harus berpasangan.
- Tidak memakai skill/perintah Staffinc (`code_kb`, `qa_kb`, `--project=chromium`) di track ini.
