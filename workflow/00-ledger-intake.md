# Phase 0 — Ledger intake

**Goal:** memastikan TC yang akan dikerjakan benar-benar ada dan dipahami apa adanya.

## Inputs

- **Pointer ke TC** di `staffinc-testcase`: link file, path relatif, atau TC ID (+ module)
- Lokasi ledger (`staffinc-testcase`, branch)
- Repo automation tujuan + branch
- Environment (dev/stg) dan akun yang tersedia

## Steps

0. **Resolve pointer jadi file TC.** Yang penting adalah arahannya menunjuk ke `staffinc-testcase`,
   bukan formatnya:
   - link: `https://github.com/sampingantech/staffinc-testcase/blob/<branch>/testcases/...`
   - path relatif: `testcases/<product>/<module>/<ID>-*.md`
   - TC ID saja: cari `testcases/**/<ID>-*.md`
   - branch ≠ checkout lokal → baca lewat
     `git -C repos/automation-code/staffinc-testcase show <branch>:<path>`.
   - Cocokkan `id` di frontmatter dengan ID yang diminta. Kalau beda atau ada lebih dari satu
     kandidat, berhenti dan tanya.
   - Jangan menyimpulkan isi TC dari judul atau dari ingatan.
1. Baca **seluruh** body — Objective, Preconditions, Steps, Expected Results, Notes/Gaps.
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
Arahkan ke TC-nya di staffinc-testcase: <link | path | TC-ID>.
Resolve ke file TC (branch + path), cocokkan id di frontmatter, lalu jalankan
workflow/00-ledger-intake.md.
Cek juga apakah sudah ada spec yang @covers id itu.
Jangan menulis kode. Keluarkan output fase 0 saja.
```
