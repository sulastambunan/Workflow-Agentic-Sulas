# AI Automation Workflow

Agentic workflow untuk membangun test automation (API / Web / Mobile) dengan pola **DDD 3-Layer**:
`SPEC → USECASE → COMPONENT/PAGE/SCREEN`, plus factory sebagai pembuat data (bukan layer).

Repo ini adalah **instruksi kerja untuk AI agent** (Claude Code, Codex, Cursor, Hermes, dll)
yang dipakai berulang: dari membaca test case di ledger, mendesain skenario, menaruh kode di layer
yang benar, menjalankan verifikasi nyata, sampai merapikan PR setelah review.

## Kenapa repo ini ada

Agent sering gagal bukan karena tidak bisa menulis kode, tapi karena:

- menaruh logika di layer yang salah (assertion di usecase, HTTP call di spec),
- mengarang hasil run ("sudah dites" padahal belum),
- menutup PR tanpa bukti (video/artifact) dan tanpa memetakan temuan review,
- mengulang precondition yang sama di setiap test sampai suite lambat dan rapuh.

Repo ini mengunci kebiasaan yang benar supaya hasilnya konsisten, bisa direview, dan bisa diaudit.

## Isi

| Path | Isi |
|---|---|
| `docs/00-working-agreement.md` | Aturan inti yang dibaca agent lebih dulu (layer, gate, definition of done) |
| `docs/01-three-layer-architecture.md` | Batas tiap layer, naming, layout folder, anti-pattern |
| `docs/02-test-design-rules.md` | Cara menurunkan skenario dari TC: POS/NEG, journey, precondition |
| `docs/03-verification-and-evidence.md` | Run nyata, artifact, format laporan bukti |
| `docs/04-pr-review-loop.md` | Loop setelah review: verifikasi temuan, commit per wave, mapping |
| `docs/05-ci-gates.md` | Gate yang memblokir PR dan cara menjalankannya lokal |
| `workflow/` | 6 fase kerja agent, masing-masing punya input, langkah, output, exit criteria |
| `checklists/` | Checklist cetak untuk pre-implementasi, pre-PR, dan paket bukti |
| `scripts/check_agent_rules.py` | Checker deterministik: `@covers`, `test.only`, stub assertion, secret |
| `.github/workflows/quality-gate.yml` | CI yang menjalankan checker + type-check di setiap PR |

## Cara pakai (5 menit)

1. Copy `docs/00-working-agreement.md` ke repo automation kamu dan rujuk dari `AGENTS.md` repo tersebut.
2. Copy folder `docs/`, `workflow/`, `checklists/`, dan `scripts/check_agent_rules.py`.
3. Copy `.github/workflows/quality-gate.yml` ke `.github/workflows/`.
4. Sesuaikan perintah di workflow (`bun run test:api`, `npm run check-all`, dst) dengan repo kamu.
5. Mulai task dengan prompt:

```text
Baca AGENTS.md, lalu jalankan workflow/00-intake.md untuk TC <ID>.
Berhenti setelah fase 2 dan tunjukkan rencana skenario sebelum menulis kode.
```

## Prinsip yang tidak boleh dilanggar

1. **Satu tanggung jawab per layer.** Spec menyatakan kebenaran, usecase mengatur urutan, layer 3 menyentuh UI/HTTP.
2. **Data bukan alur.** Beda data → varian factory. Beda langkah → method usecase.
3. **Tidak ada klaim tanpa run.** "Sudah dites" hanya boleh diucapkan setelah perintah benar-benar dijalankan.
4. **Bukti menyertai klaim.** Video/artifact dengan nama yang menyebut TC-nya.
5. **Review itu loop, bukan sekali lihat.** Temuan diverifikasi ulang terhadap kode saat ini, bukan diingat.

## Lisensi

Internal use. Bebas diadaptasi untuk repo automation masing-masing.
