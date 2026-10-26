# Phase 1 — Scenario design

**Goal:** daftar skenario yang bisa dieksekusi dan dipertanggungjawabkan, sebelum satu baris kode.

## Steps

1. Pecah AC menjadi skenario POS / NEG. Tidak ada tipe EDGE — boundary ditulis NEG.
2. Satu aturan = satu test. Jangan gabungkan beberapa validasi dalam satu blok assertion.
3. Kelompokkan precondition berdasarkan STATE, bukan data:
   `login` → `record exists` → `record + participant` → `record started`.
4. Urutkan alur: negative/guard dulu (form masih editable), lalu happy path, lalu transisi,
   lalu assertion pasca-transisi.
5. Tandai mana yang perlu record terpisah (toggle yang terkunci setelah start, guard dengan
   precondition bertentangan, langkah yang login sebagai role lain).
6. Tentukan assertion per permukaan: apa yang dibaca, nilai yang diharapkan, dari mana asalnya.
7. Ajukan daftar ini dan tunggu persetujuan.

## Output

```text
SPEC FILE: <path>
1. <judul> [POS] — precondition: <state> — assert: <checkpoint>
2. <judul> [NEG] — precondition: <state> — assert: <error copy / status>
JOURNEY: <test yang menggabungkan beberapa TC + test.step per TC>
DATA: <varian factory yang dibutuhkan>
NOT MERGED: <pasangan yang sengaja dipisah + alasannya>
```

## Exit criteria

- Setiap baris bisa dipetakan ke TC/AC — tidak ada skenario tanpa sumber.
- Jumlah test wajar: precondition tidak diulang hanya karena datanya beda.
- Manusia menyetujui daftar sebelum implementasi.

## Prompt

```text
Lanjut fase 2: desain skenario untuk <TC ids> berdasarkan AC berikut: <paste AC>.
Patuhi docs/05-test-design-rules.md. Jangan menulis kode; tunjukkan daftar skenario,
precondition per state, dan assertion per permukaan. Tunggu approval.
```
