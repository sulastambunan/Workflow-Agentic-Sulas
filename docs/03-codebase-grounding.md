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

Navigasi cepat: kalau index Kartographer tersedia, pakai MCP-nya dulu (`docs/09-kartographer-mcp.md`) —
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

## Reuse-first

Sebelum membuat step/locator/usecase/component baru:

```bash
grep -rn "createEmployee" domain/ | head
find domain -name '*<entity>*'
```

Kalau sudah ada, pakai yang ada. Duplikasi membuat suite punya dua definisi untuk satu perilaku,
dan yang lama akan basi tanpa ada yang sadar.

## Aturan bukti

- Selector harus bisa ditunjuk sumbernya (kode/komponen/atribut/UI live), bukan "kelihatannya benar".
- Jangan memakai teks yang ditulis oleh test sendiri sebagai bukti (mis. assert substring
  `'EDITED'` untuk data yang test itu yang menambahkan).
- Jangan menghapus assertion lama saat menyelaraskan; tambahkan yang baru.
