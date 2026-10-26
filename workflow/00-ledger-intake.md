# Phase 0 — Ledger intake

**Goal:** memastikan TC yang akan dikerjakan benar-benar ada dan dipahami apa adanya.

## Inputs

- TC ID (atau daftar)
- Lokasi ledger (`staffinc-testcase`, branch)
- Repo automation tujuan + branch
- Environment (dev/stg) dan akun yang tersedia

## Steps

1. Cari file TC: `testcases/<product>/<module>/<ID>-*.md`. Baca **seluruh** body — Objective,
   Preconditions, Steps, Expected Results, Notes/Gaps.
2. Catat frontmatter: `id`, `automationStatus`, `automationRef` (kalau sudah ada).
3. Cek apakah TC sudah punya spec: grep `@covers <ID>` di repo automation.
   - sudah ada → jangan bikin duplikat; tentukan apakah ini perbaikan atau TC baru
   - belum ada → lanjut
4. Catat precondition yang dibutuhkan: akun/role, data master, state yang harus dibuat.
5. Tandai bagian yang tidak bisa dipicu harness (third-party signing, inbox-only, job server-side).
6. Berhenti dan laporkan. Jangan menulis kode di fase ini.

## Output

```text
TC: <ID> — <judul>
LEDGER: <path file> · status sekarang: <manual|...> · ref: <none|path>
EXISTING SPEC: <path atau "belum ada">
NEED: <akun, role, data, state>
CANNOT AUTOMATE: <bagian + alasan> (atau "none")
OPEN QUESTION: <kalau TC ambigu atau app berbeda>
```

## Exit criteria

- ID benar-benar ada di ledger (bukan hasil karangan).
- Precondition dan kebutuhan data diketahui; blocker disebut, bukan disembunyikan.
- Manusia setuju dengan scope sebelum fase grounding.

## Prompt

```text
Baca docs/shared/00-working-agreement.md, docs/shared/01-pipeline-overview.md, docs/shared/02-ledger-contract.md,
lalu jalankan workflow/00-ledger-intake.md untuk TC <ID>.
Ledger: <path repo/branch>. Automation repo: <path/branch>.
Jangan menulis kode. Keluarkan output fase 0 saja.
```
