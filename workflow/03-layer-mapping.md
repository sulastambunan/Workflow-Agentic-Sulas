# Phase 2 — Layer mapping

**Goal:** tahu file mana yang dibuat/diubah, dan isi tiap file, sebelum coding.

## Decision map

| Pertanyaan | Jawab |
|---|---|
| Klik / ketik / isi form? | PAGE (web) / SCREEN (mobile) |
| Panggil API atau DB? | COMPONENT / repositories |
| Menentukan urutan langkah atau aturan? | USECASE |
| Menyatakan "hasilnya harus begini"? | SPEC |
| Membuat / memvariasikan data? | FACTORY |
| Fungsi murni (parse, format tanggal)? | helpers/ |
| Tool yang dijalankan manual? | scripts/ (bukan test) |

## Steps

1. Petakan setiap langkah skenario ke layer.
2. Tentukan: method baru vs method lama; factory variant baru vs data yang sudah ada.
3. Baca kode yang sudah ada untuk pola yang sama — ikuti pola repo, jangan bikin format baru.
4. Tulis daftar file + tanda tangan method (tanpa implementasi).
5. Cek risiko: id yang harus mengalir dari satu stage ke stage lain (jangan hardcode),
   locator yang perlu probe dulu, dropdown/popup khusus.

## Output

```text
CREATE: <file> — <tanggung jawab>
CHANGE: <file> — <method yang berubah>
FLOW: spec -> usecase -> page/component
DATA: <factory variant>
PROBE NEEDED: <halaman/kontrol yang belum dikenal>
RISK: <state yang mengunci konfigurasi, dsb>
```

## Exit criteria

- Tidak ada logika bisnis di layer 3, tidak ada `expect()` di usecase.
- Tidak ada id hardcoded — id mengalir dari hasil stage sebelumnya.
- Rencana file disetujui manusia (khususnya kalau ada file yang harus dibuat baru).

## Prompt

```text
Lanjut fase 3: petakan skenario yang disetujui ke layer.
Tunjukkan daftar file (create/change), tanda tangan method, dan alur id antar stage.
Jangan menulis implementasi dulu.
```
