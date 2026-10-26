# Workflow

Tujuh fase, satu TC pada satu waktu. Fase 0–6 berlaku untuk dua track; perbedaan alat ada di
`docs/staffinc/` dan `docs/inp/`.

| Fase | Dokumen | Output |
|---|---|---|
| 0 | `00-ledger-intake.md` | TC terbaca, status `planned`, spec lama dicek |
| 1 | `01-grounding.md` | sitasi `file:line`, entry MCP (INP), jawaban per klaim |
| 2 | `02-scenario-design.md` | skenario + traceability TC → checkpoint |
| 3 | `03-layer-mapping.md` | peta SPEC/USECASE/PAGE-SCREEN/FACTORY |
| 4 | `04-implement.md` | kode spec |
| 5 | `05-verify-evidence.md` | run `passed` + video/artefak |
| 6 | `06-dual-pr.md` | dua PR + `automationRef` |

Aturan yang tidak berubah antar-track:

- Jangan mulai menulis sebelum grounding selesai.
- Rencana dikonfirmasi user sebelum implementasi.
- Hanya run `passed` yang boleh menaikkan status TC.
- PR automation dan PR ledger dibuka berpasangan.
