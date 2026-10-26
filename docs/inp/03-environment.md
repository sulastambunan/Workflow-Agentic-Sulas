# 03 — Environment dan struktur folder (INP)

## Repo

| Repo | Peran | Branch default |
|---|---|---|
| `internaltools-automation` | spec Playwright (project `inp`) | `develop` |
| `staffinc-testcase` | ledger TC (dipakai dua track) | `main` |
| `utility-portal` | web portal PHP — halaman, tab, form, permission, copy | `develop` |
| `utilitysvc` | API Python — endpoint, payload, validasi | `develop` |
| `utilityapp` | app PHP — layar, field | `develop` |
| `kartographer-mcp` | index codebase (tooling) | `main` |

Lokasi di workspace ini: `repos/automation-code/*` (ledger + dua repo automation),
codebase INP di `repos/inp/*`, MCP di `repos/tooling/kartographer-mcp`.

## Perintah

```bash
bun run check-all                  # tsc + lint
bun run test:web:inp               # seluruh suite INP
bun run test:web:inp -- --grep "<test name>"
bun run test:web                   # JANGAN: ikut menjalankan partner-*
```

Project Playwright `inp` memisahkan suite internal tools dari suite partner. Semua run track ini
memakai `--project=inp`.

## Struktur folder

```
internaltools-automation/
  domain/web/module/<module>/
    tests/        # Layer 1 SPEC
    usecases/     # Layer 2 USECASE
    pages/        # Layer 3 PAGE
    factories/    # FACTORY
  scripts/
```

Contoh modul: `performance-review`.

## Kartographer MCP

Dijalankan dengan satu atau lebih index:

```bash
kartographer-mcp --db=utility-portal=/path/utility-portal.sqlite \
                 --codebase-root=utility-portal=/path/to/utility-portal
```

Kalau ada beberapa index, sebut `db=<alias>` di setiap panggilan tool.

Yang harus dicek saat start (tertulis di output startup):

- build time index,
- jumlah entry yang berhasil di-trace,
- jumlah entry `stale`.

Index `stale` atau lebih tua dari HEAD → rebuild sebelum menyimpulkan perilaku.

## Kredensial dan tenant

Belum terdokumentasi untuk track ini. Jangan menebak kredensial, tenant id, atau akun fixture —
tanyakan ke user / baca `.env` repo automation yang berlaku, dan jangan pernah commit nilainya.

## Yang belum diverifikasi

- Padanan `suite.db` (aturan bisnis) untuk INP.
- Gate mekanis setara `plan_gate` / `citation_gate`.
- Cross-validator `@covers` ↔ `automationRef` untuk INP.

Kalau salah satu di atas ternyata ada, perbarui dokumen ini dengan path/command yang nyata —
jangan menyalin asumsi dari track Staffinc.
