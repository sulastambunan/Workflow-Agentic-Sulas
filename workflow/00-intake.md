# Phase 0 — Intake

**Goal:** paham apa yang harus dibuktikan sebelum menyentuh kode.

## Inputs

- TC ID (atau daftar), link/isi ledger, AC dari PRD/ticket
- Repo + branch tujuan, environment (dev/stg/prod), akun yang tersedia
- Batas waktu / target batch (kalau ada)

## Steps

1. Baca TC dan AC apa adanya. Catat precondition, steps, expected result — jangan diringkas.
2. Cari spec yang sudah ada untuk modul itu. Satu TC = satu spec pemilik; jangan bikin duplikat.
3. Cek data & permission yang dibutuhkan: akun, role, master data, seed time-based state.
4. Tandai yang tidak bisa diautomate (third-party signing, inbox-only verification, fault injection).
5. Tulis pemahaman dalam 5 baris dan hentikan langkah di sini.

## Output

```text
TASK: <TC ids> · repo/branch · env
READ: <file spec yang ada / "belum ada">
NEED: <akun, data, permission>
CANNOT AUTOMATE: <bagian + alasan> (atau "none")
RISK: <hal yang bisa mengubah rencana>
```

## Exit criteria

- Semua TC bisa dilacak ke sumber (ledger/PRD), tidak ada skenario karangan.
- Kebutuhan data/akun diketahui; kalau ada yang belum ada, sebut sebagai blocker.
- Manusia setuju dengan scope sebelum fase 1.

## Prompt

```text
Baca docs/00-working-agreement.md dan workflow/00-intake.md.
Untuk TC: <ID>. Sumber: <ledger/PRD path atau isi>.
Repo: <path>, branch: <name>, env: <dev|stg>.
Jangan menulis kode. Keluarkan output fase 0 saja.
```
