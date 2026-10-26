# 01 — Pipeline overview (tiga repo)

Automation kita bukan satu repo. Ada tiga sumber yang harus konsisten, plus satu skill yang
mengatur cara kerjanya:

```
(1) staffinc-testcase          (2) codebase produk              (3) staffinc-automation
    ledger / sumber TC             hcmsvc · hcmworker ·               repo test
    testcases/<product>/<mod>/     kerjaan-client-portal ·         domain/{api,web,mobile}
    <ID>-<slug>.md                 kerjaan-android · ios-kerjaan   specs · usecases · pages
        │                              │                                │
        │  "apa yang harus dibuktikan" │ "bagaimana app melakukannya"   │ "bagaimana kita membuktikan"
        └──────────────┬───────────────┴────────────────────────────────┘
                       ▼
              automation worker (agent): baca → grounding → desain → tulis → run → PR
```

## Dua track yang berbeda

| Track | Ledger | Codebase (sumber perilaku) | Automation repo |
|---|---|---|---|
| **Staffinc** (PK / mobile / CP) | `sampingantech/staffinc-testcase` | `hcmsvc` (API) · `hcmworker` · `kerjaan-client-portal` (web) · `kerjaan-android` · `ios-kerjaan` | `staffinc-automation` |
| **INP / internal tools** | `sampingantech/staffinc-testcase` (modul `performance-review`, dll) | `utilitysvc` (Python API) · `utility-portal` (PHP web) · `utilityapp` (PHP app) | `internaltools-automation` |

Perbedaan yang mempengaruhi perintah:

- `staffinc-automation`: `bun run test:web` / `test:api`, mobile lewat `bun mobile run --platform=android`.
- `internaltools-automation`: `bun run test:web:inp` (Playwright project `inp`), gate `bun run check-all`,
  env `bun run env:dev|stg`, modul di `domain/web/module/<module>/` (mis. `performance-review`).
  Project lain (`partner-*`) jangan ikut jalan — selalu pilih `--project`.

Keduanya memakai ledger yang sama, jadi aturan `@covers` dan status TC di `docs/02` berlaku identik.

## Siapa memiliki apa

| Repo | Isi | Yang berubah saat kita automate |
|---|---|---|
| `staffinc-testcase` | 1 file markdown per TC, frontmatter `id`, `automationStatus`, `automationRef` | `automationStatus` + `automationRef` (path/nama spec) |
| codebase produk | route, form, label, validasi, API contract | **tidak diubah** — hanya dibaca sebagai sumber kebenaran |
| `staffinc-automation` | spec + usecase + page/screen + factory | file spec baru/perubahan, `@covers`, `test-specs.json` |

Kalau salah satu dari ketiganya tidak sinkron, hasilnya klaim palsu: TC berstatus `automated`
tapi spec tidak ada, atau spec ada tapi menunjuk ID yang tidak ada di ledger.

## Alur kerja (yang harus dilalui agent)

1. **Ledger** — buka file TC, baca `id`, `title`, Preconditions, Steps, Expected Results.
   TC harus sudah ada di ledger. Kalau belum ada, berhenti: TC baru dibuat manusia lebih dulu.
2. **Codebase** — telusuri halaman/endpoint yang dimaksud: route, komponen, validasi, label,
   permission. Ini yang membuat selector dan assertion tidak dikarang.
3. **Grounding** — cocokkan TC ↔ kode ↔ app live. Kalau app berbeda dari TC, angkat sebagai
   keputusan manusia (app benar → koreksi TC; TC benar → temuan bug).
4. **Design** — pecah AC menjadi skenario POS/NEG, kelompokkan per state (lihat `docs/05`).
5. **Implement** — taruh kode di layer yang benar (lihat `docs/04`), `// @covers <TC-ID>`.
6. **Verify** — run nyata + bukti (lihat `docs/06`).
7. **Dual PR** — satu PR ke repo automation, satu PR ke ledger (lihat `docs/07`).
8. **Status flip** — `automationStatus` baru dinaikkan setelah PR automation **merged**.

## Urutan merge yang benar

```
PR automation  →  review + merge  →  PR ledger (flip status)  →  CI ledger regenerate web
```

Kebalikannya (flip status lebih dulu) memblokir PR ledger: CI `automation-merged` membaca
DEFAULT BRANCH repo automation + PR yang sudah merge, bukan branch kerja. Selama PR automation
masih OPEN, path-nya dianggap tidak ada.

## Prinsip yang mengikat ketiganya

- **Ground, don't guess** — selector/assertion berasal dari TC, codebase, atau UI nyata.
- **Reuse-first** — sebelum membuat step/locator/usecase baru, cari dulu di repo automation.
- **Satu TC = satu spec pemilik** (kecuali pola dua-cover yang memang lazim di repo).
- **Status mengikuti bukti**, bukan niat.
