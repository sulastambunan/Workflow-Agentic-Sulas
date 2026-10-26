# Docs

Dokumen dibagi tiga: aturan yang berlaku di dua track, dan spesifikasi per track.

## shared/ — berlaku untuk Staffinc dan INP

| Dokumen | Isi |
|---|---|
| `00-working-agreement.md` | kontrak kerja agent: peran, batas, definition of done |
| `01-pipeline-overview.md` | tiga repo (ledger → codebase → automation) dan dua track |
| `02-ledger-contract.md` | bentuk TC, `automationStatus`, `automationRef`, aturan fidelity |
| `03-codebase-grounding.md` | ground don't guess; urutan sumber; repo per track |
| `04-three-layer-architecture.md` | DDD: SPEC → USECASE → PAGE/SCREEN/COMPONENT + FACTORY |
| `05-test-design-rules.md` | POS/NEG, larangan mengarang skenario, assertion fidelity |
| `06-verification-and-evidence.md` | klaim harus punya run nyata + artefak |
| `07-pr-and-review.md` | review loop, konflik, quote commit SHA |
| `08-ci-gates.md` | gate PR dan perintah per track |
| `09-worktree.md` | kerja paralel per branch tanpa mengganggu clone utama |
| `10-workspace-layout.md` | semua repo, submodule, dan layout folder |

## staffinc/ — khusus track Staffinc

| Dokumen | Isi |
|---|---|
| `01-architecture.md` | 7 lapis, sumber kebenaran, tiga gate mekanis |
| `02-grounded-flow.md` | 10 langkah per TC + perintah |
| `03-environment.md` | tenant, kredensial, emulator, tech stack, struktur folder |
| `04-quality-gates.md` | checklist pra-commit, `--module`, dual PR |
| `05-failure-modes.md` | tabel gejala → tindakan, aturan eskalasi |

## inp/ — khusus track INP / internal tools

| Dokumen | Isi |
|---|---|
| `01-architecture.md` | 7 lapis versi INP, grounding lewat `kartographer-mcp` |
| `02-grounded-flow.md` | 10 langkah per TC dengan tool MCP |
| `03-environment.md` | repo, perintah `--project=inp`, struktur folder, yang belum terverifikasi |
| `04-quality-gates.md` | `check-all`, `@covers`, artefak |
| `05-failure-modes.md` | gejala → tindakan, eskalasi |
| `kartographer-mcp.md` | katalog tool, aturan freshness, provenance |

## Urutan baca

1. Baru di repo ini: `shared/00` → `shared/01` → track yang dipakai.
2. Akan menulis spec: `shared/04` → `shared/05` → `shared/06`.
3. Akan buka PR: `shared/07` → `shared/08` → checklist di `checklists/`.
