# Workflow Agentic — Automation Staffinc

Cara kerja agent (AI) untuk automation kita yang sebenarnya: **tiga repo + satu ledger**,
bukan sekadar aturan menulis test.

```
(1) staffinc-testcase                (2) codebase produk               (3) staffinc-automation
    ledger TC, 1 file per TC             hcmsvc · hcmworker ·              spec · usecase · page/screen
    frontmatter id, status, ref          kerjaan-client-portal ·           factory · @covers
    testcases/<product>/<module>/        kerjaan-android · ios-kerjaan
         │                                    │                                │
         │ "apa yang harus dibuktikan"        │ "bagaimana app melakukannya"   │ "bagaimana kita membuktikan"
         └──────────────────┬─────────────────┴────────────────────────────────┘
                            ▼
                   agent: intake → grounding → desain → implement → run → dual PR
```

## Dua track yang didukung

| Track | Codebase (sumber perilaku) | Automation repo | Ciri perintah |
|---|---|---|---|
| **Staffinc** (PK / mobile / CP) | `hcmsvc` · `hcmworker` · `kerjaan-client-portal` · `kerjaan-android` · `ios-kerjaan` | `staffinc-automation` | `bun run test:web` / `test:api`, `bun mobile run` |
| **INP / internal tools** | `utilitysvc` (Python API) · `utility-portal` (PHP web) · `utilityapp` (PHP app) | `internaltools-automation` | `bun run test:web:inp` (`--project=inp`), gate `bun run check-all` |

Ledger-nya sama (`staffinc-testcase`), jadi aturan `@covers`, GWT, dan status TC berlaku untuk keduanya.

## Kenapa repo ini ada

Kegagalan yang paling mahal di automation kita bukan test merah, tapi **klaim yang tidak sinkron**:

- ledger bilang `automated`, tapi spec-nya tidak ada atau sudah dihapus;
- spec ada, tapi `@covers` menunjuk ID yang tidak ada di ledger;
- TC bilang A, app berperilaku B, dan test ditulis supaya hijau untuk B tanpa keputusan siapa pun;
- "sudah dites" tanpa run, tanpa video, tanpa artifact.

Repo ini mengunci urutan kerja dan bukti yang membuat klaim itu tidak mungkin lolos.

## Isi

| Path | Isi |
|---|---|
| `docs/00-working-agreement.md` | Kontrak kerja: layer, definition of done, aturan operasi agent |
| `docs/01-pipeline-overview.md` | **Tiga repo, siapa memiliki apa, urutan merge** |
| `docs/02-ledger-contract.md` | Bentuk file TC, arti tiap `automationStatus`, kapan di-flip |
| `docs/03-codebase-grounding.md` | Cara membaca codebase & app supaya selector tidak dikarang |
| `docs/04-three-layer-architecture.md` | Batas SPEC / USECASE / PAGE-SCREEN / FACTORY + naming |
| `docs/05-test-design-rules.md` | Menurunkan skenario: POS/NEG, journey, precondition per state |
| `docs/06-verification-and-evidence.md` | Run nyata, artifact, format laporan bukti |
| `docs/07-pr-and-review.md` | Dual PR, loop review, verifikasi temuan |
| `docs/08-ci-gates.md` | Gate yang memblokir PR dan cara menjalankannya lokal |
| `docs/09-kartographer-mcp.md` | MCP index codebase INP: route, call chain, validation rules, DTO, tabel |
| `workflow/00-ledger-intake.md` | Fase 0 — baca TC dari ledger, cek spec yang sudah ada |
| `workflow/01-grounding.md` | Fase 1 — telusuri codebase + app, cocokkan dengan TC |
| `workflow/02-scenario-design.md` | Fase 2 — desain skenario, tunggu approval |
| `workflow/03-layer-mapping.md` | Fase 3 — petakan ke file & layer |
| `workflow/04-implement.md` | Fase 4 — tulis factory → layer 3 → usecase → spec |
| `workflow/05-verify-evidence.md` | Fase 5 — run, bukti, gate lokal |
| `workflow/06-dual-pr.md` | Fase 6 — PR automation + PR ledger + status flip |
| `checklists/` | Pre-PR dan paket bukti |
| `scripts/check_agent_rules.py` | Checker deterministik: `@covers`, `test.only`, stub, secret, non-ASCII |
| `.github/workflows/quality-gate.yml` | CI: checker + type-check di setiap PR |

## Cara pakai

1. Taruh repo ini di sebelah repo kerja kamu (atau baca langsung dari GitHub).
2. Mulai task dengan prompt:

```text
Baca docs/00-working-agreement.md, docs/01-pipeline-overview.md, docs/02-ledger-contract.md.
Jalankan workflow/00-ledger-intake.md untuk TC <ID>.
Ledger: <path staffinc-testcase>, automation repo: <path staffinc-automation>.
Berhenti setelah fase 0 dan tunjukkan outputnya.
```

3. Lanjutkan fase demi fase: `01-grounding` → `02-scenario-design` → `03-layer-mapping` →
   `04-implement` → `05-verify-evidence` → `06-dual-pr`.
4. Copy `scripts/check_agent_rules.py` + workflow CI ke repo automation yang dipakai.

## Prinsip yang tidak boleh dilanggar

1. **Ledger dulu.** TC harus ada di `staffinc-testcase` sebelum spec ditulis. Tidak ada TC karangan.
2. **Ground, don't guess.** Selector, copy, dan assertion berasal dari TC + codebase + UI nyata.
3. **Reuse-first.** Cari step/usecase/page yang sudah ada sebelum membuat yang baru.
4. **Satu tanggung jawab per layer.** Spec menyatakan kebenaran, usecase mengatur urutan, layer 3 menyentuh UI/HTTP, factory membuat data.
5. **Status mengikuti bukti.** `automated` hanya setelah spec benar-benar jalan dan PR-nya merged.
6. **Dual PR.** Automation + ledger, saling menunjuk; flip status baru setelah automation merged.
7. **Tidak ada klaim tanpa run.** Bukti menyertai klaim, dan yang belum dijalankan disebut.
8. **GWT adalah kontrak.** Precondition, langkah, dan assertion mengikuti Given/When/Then di ledger — tiap klaim Then punya checkpoint yang bisa gagal sendiri.
9. **`@covers` lengkap.** Semua TC yang benar-benar dieksekusi test ditulis; tidak ada ID karangan atau ID hilang.
10. **Beda app vs TC = keputusan manusia.** Berhenti, bawa bukti, tanya: perbaiki TC di `staffinc-testcase` atau catat sebagai defect. Jangan menyesuaikan assertion supaya hijau.

## Sudah diuji

`scripts/check_agent_rules.py` dites dengan tiga fixture: spec bersih → PASS; spec bermasalah →
FAIL dengan 6 temuan (`@covers` hilang, `test.only`, `console.log`, JWT hardcoded, assertion lemah,
karakter non-ASCII); spec dengan 2 test yang hanya satu ber-`@covers` → FAIL di test kedua
(tag dicek per deklarasi test, bukan per file).
