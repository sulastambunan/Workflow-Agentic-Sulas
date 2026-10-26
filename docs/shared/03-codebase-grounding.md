# 03 — Codebase grounding

TC bilang **apa** yang harus terjadi. Codebase bilang **bagaimana** app melakukannya.
Spec yang ditulis tanpa keduanya adalah tebakan.

## Urutan sumber kebenaran

1. **TC di ledger** — Given/When/Then, termasuk precondition dan teks yang diharapkan.
2. **Codebase produk** — route, komponen, nama field, aturan validasi, permission, API contract.
3. **App live (dev/stg)** — hanya untuk hal yang tidak bisa dibaca dari kode atau untuk
   memastikan build yang dipakai memang berperilaku seperti itu.

Kalau ketiganya bertentangan, **jangan pilih sendiri**: angkat ke manusia dengan bukti.
App benar → koreksi TC/ledger. TC benar → itu bug produk (test.fail + KNOWN BUG, ledger `manual`).

## Alat baca per track

| Track | Alat | Catatan |
|---|---|---|
| Staffinc | `code_kb.py` (code-knowledge.db), `qa_kb.py` (suite.db) | butuh `/usr/bin/python3` (sqlite_vec + fastembed); detail di `docs/staffinc/01-architecture.md` |
| INP | `kartographer-mcp` | index read-only; detail di `docs/inp/kartographer-mcp.md` |

Index/KB adalah **peta**, bukan kebenaran final: kalau entry basi, `provenance` bukan `verified`,
atau KB mengembalikan 0, buka kode atau probe app — jangan menyimpulkan dari index saja.

## Repo produk yang biasa dipakai

| Repo | Dipakai untuk |
|---|---|
| `hcmsvc` | API/backend contract (endpoint, payload, status, validasi server) |
| `hcmworker` | worker/agent side behavior |
| `kerjaan-client-portal` | web admin/CP: halaman, tab, tombol, form, permission |
| `kerjaan-android` | mobile Android: screen, widget, accessibility id |
| `ios-kerjaan` | mobile iOS: native field, accessibility identifier |

### Track INP / internal tools

| Repo | Dipakai untuk |
|---|---|
| `utilitysvc` | API Python: endpoint, payload, aturan validasi, status |
| `utility-portal` | web PHP (Laravel/Blade): halaman, tab, form, permission, copy tombol/error |
| `utilityapp` | sisi app: layar/field yang dipakai skenario mobile — baca struktur repo sebelum menyimpulkan |

Modul automation INP ada di `internaltools-automation/domain/web/module/<module>/`
(mis. `performance-review`). Project Playwright-nya `inp`, jadi run selalu memakai `--project=inp`.

Navigasi cepat: kalau index Kartographer tersedia, pakai MCP-nya dulu (`docs/inp/kartographer-mcp.md`) —
`search_entries` untuk menemukan route, `get_request_rules` untuk aturan validasi, `tables_of` untuk
tabel yang harus disiapkan. Baru buka file untuk hal yang tidak dijawab index.

## Yang dicari di codebase

- **Route/halaman** — path yang harus dibuka, guard permission.
- **Label & copy** — teks tombol/error yang akan di-assert (jangan menebak dari screenshot).
- **Validasi** — `required`, `maxlength`, aturan lintas-field, pesan error server.
- **Struktur data** — nama field payload/response yang dipakai usecase.
- **Widget khusus** — dropdown custom, date picker readonly, modal/popup, tab yang re-render.

## Grounding ke app live

Probe sebelum menulis locator, bukan sesudah test merah:

- Login → buka halaman → dump input/select/tabel + semua request XHR.
- Submit form kosong dan baca body 422: itu daftar field wajib yang otoritatif.
- Kalau tidak bisa membuka halaman (5xx, permission), **berhenti menulis assertion** untuk
  halaman itu — laporkan blocker, jangan mengarang selector.

## Reuse-first (wajib)

Sebelum membuat file/method baru, cari dengan urutan ini:

1. **PAGE / SCREEN / COMPONENT** untuk modul itu — halaman ini sudah punya page object?
2. **Method** yang menyentuh elemen yang sama — cari `testid`, label, atau route.
3. **USECASE** yang sudah menjalankan langkah/alur ini.
4. **FACTORY** untuk entity/data yang sama.
5. **Helper murni** (format tanggal, parse) di `helpers/` atau `core/utils/`.

```bash
find domain -path '*module/<module>*' \( -name '*.page.ts' -o -name '*.screen.ts' -o -name '*.component.ts' \)
grep -rn "<testid|label|route>" domain/web/module/<module>
grep -rn "<action>" domain/web/module/<module>/usecases
find domain/web/module/<module>/factories -name '*<entity>*'
```

| Temuan | Tindakan |
|---|---|
| method persis ada | pakai apa adanya |
| file ada, method belum | extend file itu |
| tidak ada sama sekali | buat baru, tulis alasannya |

Termasuk duplikasi (dilarang): dua page object untuk halaman yang sama, dua usecase untuk alur yang
sama, dua factory untuk entity yang sama, selector yang sama ditulis ulang di dua tempat.

## Aturan bukti

- Selector harus bisa ditunjuk sumbernya (kode/komponen/atribut/UI live), bukan "kelihatannya benar".
- Jangan memakai teks yang ditulis oleh test sendiri sebagai bukti (mis. assert substring
  `'EDITED'` untuk data yang test itu yang menambahkan).
- Jangan menghapus assertion lama saat menyelaraskan; tambahkan yang baru.
