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

Track INP memakai repo automation yang berbeda, jadi root-nya menunjuk
`internaltools-automation`. Repo automation yang belum dikenal ledger harus didaftarkan lebih dulu di
`scripts/lib/agentic-utils.ts` (`automationRepoRoot()`) dan `scripts/cross-validate-automation.py`
(dict `REPOS`) — tanpa itu validasi hard-fail `unknown automation repo`.

## Path, bukan tebakan

- Pindah/rename spec = update `automationRef.path` di wave yang sama. Path drift = blocker review.
- `indexes/*.json` dan `reports/features/**` adalah artefak generated — jangan di-commit.
- ID yang dipakai di `@covers` harus ada di ledger. ID "kelihatan masuk akal" = temuan review.

## GWT fidelity (wajib)

Test yang mengautomate sebuah TC harus mengikuti **Given / When / Then** dari file TC itu,
bukan versi yang lebih mudah di-assert.

1. **Given** — precondition di spec harus sama dengan `## Preconditions` (role, state record,
   data yang harus ada). Kalau test membangun state lain, itu skenario lain.
2. **When** — langkah di usecase/spec mengikuti `## Steps` sejauh harness bisa memicunya.
3. **Then** — setiap klaim di `## Expected Results` harus punya assertion. Yang tidak bisa
   di-assert tidak boleh dihilangkan diam-diam: turunkan status ke `partial` dan tulis di
   `## Notes / Gaps` bagian mana yang tidak terbukti.
4. **Copy** — teks tombol/pesan error yang di-assert diambil dari TC atau dari app, bukan dikarang.
5. **ID** — `@covers` harus lengkap: semua TC yang benar-benar dieksekusi test itu ditulis.
   Satu test boleh membawa lebih dari satu `@covers`; test tanpa `@covers` tidak boleh masuk PR.

## Kalau implementasi dev berbeda dari TC

Jangan putuskan sendiri dan jangan menulis assertion yang "menyesuaikan app". Urutannya:

1. Kumpulkan bukti: AC yang dikutip, langkah, hasil aktual (status HTTP / teks / screenshot),
   dan record id kalau ada.
2. Laporkan ke manusia dengan dua pilihan eksplisit:
   - **TC yang salah** → usulkan wording `## Expected Results` pengganti; setelah disetujui,
     ubah TC di `staffinc-testcase` (satu wave dengan spec).
   - **App yang salah (defect)** → laporkan sebagai bug; spec memakai `test.fail()` + komentar
     `KNOWN BUG`, ledger tetap `manual` + `automationRef: null`.
3. Tunggu keputusan. Selama belum ada keputusan, jangan ubah TC dan jangan ubah assertion
   supaya hijau.
