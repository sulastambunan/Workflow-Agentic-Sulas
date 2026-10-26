# 02 — Ledger contract (staffinc-testcase)

Ledger adalah sumber kebenaran TC. Agent membacanya, bukan mengarangnya.

## Bentuk file

Satu TC = satu file markdown:

```
testcases/<product>/<module>/<ID>-<slug>.md
```

Frontmatter yang dipakai:

```yaml
---
id: PIN-M5-POS-002
title: "..." 
automationStatus: manual      # manual | planned | partial | automated | blocked | "can't automate"
automationRef: null           # atau { repo, path, command, branch }
sourceRefs:                   # tsd, tsdSection, tsdScenario, prd, jira
preconditionRefs: []
---
```

Body selalu memakai heading yang sama: `## Objective`, `## Preconditions`, `## Steps`,
`## Expected Results`, `## Source Traceability`, `## Notes / Gaps`.
Penanda `**Given**` / `**When**` / `**Then**` ada **di dalam** paragraf, bukan heading.

## Status — arti yang sebenarnya

| Status | Arti | `automationRef` |
|---|---|---|
| `manual` | belum/tidak diautomate | **wajib `null`** |
| `planned` | direncanakan | `null` |
| `partial` | sebagian terpicu, sisanya manual | wajib ada (path yang benar) |
| `automated` | skenario benar-benar dieksekusi dan hijau | wajib ada |
| `blocked` | terhalang sesuatu | `null` |
| `can't automate` | harness tidak bisa memicu (push FCM, job server-side) | `null` |

Aturan keras:

- `manual` / `planned` / `blocked` **harus** `automationRef: null` — validator gagal kalau tidak.
- `automated` hanya sah kalau: spec ada, test-nya benar-benar jalan, dan `automationRef.command`
  memang memilih test itu.
- `partial` tetap menyimpan ref; bagian manualnya ditulis di `## Notes / Gaps`.
- Turun status = hapus `automationRef` (bukan menambah field baru), dan hapus test dari spec —
  **bukan** `it.skip` (skip terbaca sebagai klaim setengah jalan).

## Kapan status di-flip

Setelah PR automation **merged** ke default branch. Sebelum itu:

- PR ledger hanya membawa perubahan yang tidak mengklaim automation (`manual` + `null`), atau
- tulis di `## Notes / Gaps` bahwa PR automation `<org>/<repo>#<n>` masih menunggu merge.

## Validasi (jangan lapor hijau tanpa env)

```bash
export STAFFINC_PLATFORM_ROOT="$HOME/Documents/AUTOMATION-WORKER"
export STAFFINC_AUTOMATION_ROOT="$HOME/Documents/AUTOMATION-WORKER/staffinc-automation"
export TESTCASE_ROOT="$HOME/Documents/AUTOMATION-WORKER/staffinc-testcase"

cd "$TESTCASE_ROOT"
npm run testcase:validate
npm run testcase:build                     # validate + index + report
python3 scripts/cross-validate-automation.py --module <slug>
```

Tanpa env di atas, cek keberadaan `automationRef.path` **di-skip** sementara output tetap
bilang sukses — itu hijau palsu.

## Path, bukan tebakan

- Pindah/rename spec = update `automationRef.path` di wave yang sama. Path drift = blocker review.
- `indexes/*.json` dan `reports/features/**` adalah artefak generated — jangan di-commit.
- ID yang dipakai di `@covers` harus ada di ledger. ID "kelihatan masuk akal" = temuan review.
