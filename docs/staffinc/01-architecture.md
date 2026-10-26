# 01 — Arsitektur Automation Worker (Staffinc)

Tujuan: mengubah TC `planned` di ledger menjadi spec yang **lulus**, DDD-compliant, dan setiap
selector / endpoint / expected value punya sitasi ke sumber nyata. Bukan menebak.

Platform: **web** (Playwright) dan **mobile** (Appium + WebdriverIO).

## Tujuh lapis

| # | Lapis | Isi | Peran |
|---|---|---|---|
| 1 | Source | `staffinc-testcase`, codebase (`hcmsvc`, `hcmworker`, `kerjaan-client-portal`, `kerjaan-android`, `ios-kerjaan`), `suite.db` | ground truth, read-only |
| 2 | Knowledge | `code_kb.py` (code-knowledge.db), `qa_kb.py` (suite.db), `workspace/grounding/<TC-ID>.md` | index + cache hasil grounding |
| 3 | Skill | `staffinc-automation-dev`, `staffinc-mobile-automation`, `automation-spec-reviewer` | cara kerja per platform |
| 4 | Gate | `plan_gate`, `citation_gate`, `skill_diet` | menegakkan aturan secara mekanis |
| 5 | Build | SPEC → USECASE → PAGE/SCREEN (+ FACTORY) | kode test |
| 6 | Execution | Playwright, Appium + WDIO, `syntax-check.ts` | menjalankan |
| 7 | Output | `staffinc-automation` (spec), `staffinc-testcase` (`automationRef`), dual PR | hasil |

Urutannya satu arah: lapis di atas memberi input ke lapis di bawah. Source tidak pernah ditulis
oleh agent; output selalu berupa PR di dua repo.

## Sumber kebenaran dan kekuatan sitasi

Dari terkuat ke terlemah:

1. **`suite.db`** — aturan bisnis (`// expect: suite.db PK<n> "rule"`).
2. **TC** — klaim Then/And (`// expect: TC <ID> Then "..."`).
3. **Codebase** — default/contract (`// src: repo/path:line`).
4. **Live UI** — DOM dump / `uiautomator dump`, hanya kalau codebase tidak menjawab
   (`// src: none (justified: <alasan>)`).

Kalau codebase bertentangan dengan dokumen, **kode menang**; drift-nya dilaporkan, bukan
disembunyikan. Kalau `code_kb` mengembalikan 0 hasil untuk sebuah elemen, lanjut ke live
inspection — jangan menebak selector.

### Jebakan yang sudah terbukti

- **Nama modul `suite.db`** memakai nama repo-native (`submission`), bukan nama modul automation
  (`digital-form`). Query dengan nama automation menghasilkan 0 hit tanpa error — terlihat sama
  seperti "tidak ada aturan". Ulangi dengan nama repo-native.
- **Interpreter**: `code_kb`/`qa_kb` butuh `sqlite_vec` + `fastembed`; hanya `/usr/bin/python3`
  yang punya. `ModuleNotFoundError: No module named 'sqlite_vec'` = interpreter salah, bukan KB rusak.
- **Batas DOM inspection**: maksimal 1–2 TC per sesi. Selebihnya hentikan dan laporkan gap.

## Tiga gate mekanis

| Gate | Memblokir | Cara memenuhi |
|---|---|---|
| `plan_gate` | tulis ke repo spec/TC, run, commit/push, `gh pr create` | sampaikan rencana grounded, lalu `clarify()` dan tunggu "Go"; konfirmasi berlaku 2 jam |
| `citation_gate` | tulis ke `domain/**` (tests, usecases, pages, screens, factories) | `// src:` di atas tiap selector/endpoint baru, `// expect:` di atas tiap `expect()` |
| `skill_diet` | `skill_view` penuh kedua kali untuk skill besar yang sama | baca `references/...` untuk detail; muat skill sekali per sesi |

Gate yang memblokir bukan bug. Jangan mengulang panggilan yang sama dan jangan mematikan gate —
penuhi dulu kondisinya. Satu-satunya escape hatch adalah `// src: none (justified: ...)`, dan itu
hanya untuk elemen yang benar-benar tidak bisa di-ground.

## Yang tidak boleh dilakukan

- Tidak ada selector/endpoint tanpa `// src:`, tidak ada `expect()` tanpa `// expect:`.
- Tidak menebak selector; inspect atau berhenti.
- Tidak menandai `automated` kalau test belum benar-benar `passed` (anti-forgery).
- Tidak commit saat test atau quality gate merah.
- Tidak commit ke `main`/`develop`; selalu branch `automation-worker/...`.
- Tidak ada raw locator / `page.fill()` / `page.click()` / `page.goto()` di SPEC.
- Tidak ada stub test: `expect(true)`, `toBeDefined()` tanpa nilai.
- Tidak ada satu PR saja — automation dan testcase harus berpasangan (cross-validator).
- Tidak ada `delegate_task`; worker jalan inline.
