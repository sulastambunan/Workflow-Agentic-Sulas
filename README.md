# Workflow Agentic — Automation Staffinc

Panduan kerja agent untuk automation: **TC → grounding → spec DDD → run → review → push**.
Bukan kumpulan aturan umum — ini alur yang benar-benar dipakai di repo automation kita.

## Dua track

| Track | Codebase (dibaca) | Automation repo |
|---|---|---|
| **Staffinc** | `hcmsvc` · `hcmworker` · `kerjaan-client-portal` · `kerjaan-android` · `ios-kerjaan` · `seamless-admin-portal` | `staffinc-automation` |
| **INP / internal tools** | `utilitysvc` · `utility-portal` · `utilityapp` | `internaltools-automation` |

Ledger TC-nya satu untuk dua track: `staffinc-testcase`.

## Cara mulai

```bash
git clone --recurse-submodules https://github.com/sulastambunan/Workflow-Agentic-Sulas.git
cd Workflow-Agentic-Sulas
```

Repo ini sudah membawa semua repo pendukung sebagai submodule:

```
repos/automation-code/   staffinc-testcase · staffinc-automation · internaltools-automation
repos/staffinc/          codebase Staffinc · skills
repos/inp/               codebase INP
repos/tooling/           kartographer-mcp
```

## Alur satu TC

```
0 intake      arahkan ke TC di staffinc-testcase (link / path / ID)
1 grounding   baca codebase + app → tulis sitasi file:line; cek reuse dulu
2 desain      skenario + traceability TC → checkpoint; konfirmasi user
3 mapping     tentukan SPEC / USECASE / PAGE-SCREEN / FACTORY
4 implement   tulis kode sesuai layer
5 verify      run spesifik → passed + video
6 review      pre-push review (GWT, assertion, @covers, DDD)
7 push        dua PR: spec + automationRef
```

Detail per fase: `workflow/00`–`06`.

## Aturan yang tidak boleh dilanggar

1. **Reuse dulu.** Cari page/screen → method → usecase → factory sebelum bikin baru.
2. **GWT sesuai TC.** Tiap `Then`/`And` punya assertion yang bisa gagal.
3. **Assertion sesuai TC.** Nilai expected dari TC, bukan dari kode.
4. **`@covers` ada dan cocok.** Satu test = satu TC yang benar-benar dieksekusi.
5. **Tidak ada `page.` di spec.** Spec memanggil usecase; layer 3 hanya lewat usecase.
6. **Hanya `passed` yang jadi `automated`.** Tanpa run lulus, TC tetap `planned`.
7. **Review sebelum push.** `REQUEST_CHANGES` = jangan push.

## Dokumen

| Folder | Isi |
|---|---|
| `docs/shared/` | aturan lintas track: ledger, grounding, DDD, desain test, bukti, PR, CI, worktree, workspace, pre-push, evidence video |
| `docs/staffinc/` | arsitektur 7 lapis, alur 10 langkah, tenant/emulator, quality gate, failure modes |
| `docs/inp/` | versi INP + `kartographer-mcp` |
| `workflow/` | tujuh fase kerja |
| `checklists/` | pre-PR dan paket bukti |
| `scripts/` | checker, pre-push gate, bootstrap workspace |

Index lengkap: `docs/README.md`.

## Perintah penting

```bash
bash scripts/pre-push-review.sh origin/develop
python3 scripts/check_agent_rules.py --base origin/develop
bash scripts/bootstrap-workspace.sh check
```

## Batas

- Agent tidak merge PR dan tidak menyentuh `main`/`develop` langsung.
- Perbedaan app vs TC = keputusan manusia: perbaiki TC atau catat defect.
- Tanpa run, tanpa klaim.
