# Phase 1 — Grounding (codebase + app)

**Goal:** tahu bagaimana app benar-benar berperilaku sebelum mendesain skenario.

## Steps

1. Petakan TC ke permukaan app: halaman/route, endpoint, atau screen.
2. Telusuri codebase produk (lihat `docs/03-codebase-grounding.md`):
   - route + guard permission
   - label/copy yang akan di-assert
   - validasi (`required`, `maxlength`, aturan lintas-field, pesan server)
   - struktur payload/response
3. Kalau perlu, probe app live: login → buka halaman → dump elemen + XHR.
   Submit form kosong untuk membaca daftar field wajib dari body 422.
4. Cocokkan hasilnya dengan TC, klaim per klaim (Given/When/Then):
   - sama → lanjut
   - **berbeda → berhenti.** Jangan menyesuaikan assertion, jangan mengubah TC sendiri.
     Kumpulkan bukti (AC yang dikutip, langkah, hasil aktual, status HTTP/teks/screenshot,
     record id) lalu tanya manusia dengan dua pilihan:
     (a) TC diperbaiki di `staffinc-testcase`, atau (b) dikategorikan defect produk.
5. Cek reuse: sudah ada step/usecase/page untuk perilaku ini?

## Output

```text
SURFACE: <route/screen/endpoint>
SOURCE: <file:baris di codebase> (untuk tiap klaim penting)
COPY TO ASSERT: <teks tombol/error yang dipakai>
VALIDATION: <field + aturan + trigger: inline | on-submit>
REUSE: <helper/usecase yang sudah ada atau "none">
MISMATCH: <TC vs app, klaim mana yang beda, bukti> — atau "none"
DECISION NEEDED: <perbaiki TC di staffinc-testcase | defect produk> (kalau ada mismatch)
PROBE: <perintah/script yang dipakai> atau "tidak perlu"
```

## Exit criteria

- Setiap selector/assertion punya sumber (kode, atribut, atau UI live) — bukan tebakan.
- Perbedaan TC vs app sudah diangkat **dengan bukti**, tidak diputuskan sendiri.
- Tidak ada halaman yang di-assert padahal tidak bisa dibuka (5xx/permission).

## Prompt

```text
Lanjut fase 1 (grounding) untuk TC <ID> yang sudah lolos fase 0.
Track: <staffinc | inp>.
Codebase: <path kerjaan-client-portal|hcmsvc|kerjaan-android | utility-portal|utilitysvc|utilityapp>.
Telusuri route, copy, validasi, dan struktur data yang relevan; probe app kalau perlu.
Keluarkan output fase 1 saja — jangan menulis spec dulu.
```
