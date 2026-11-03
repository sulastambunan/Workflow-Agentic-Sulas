# QA authoring — PRD → TSD → canonical testcase → automation

## Authority dan lokasi

Gunakan skill perusahaan dari submodule `repos/staffinc/skills`, bukan salinan
aturan yang dapat tertinggal. Integrasi awal berasal dari
[sampingantech/skills PR #11](https://github.com/sampingantech/skills/pull/11)
(`feat/qa-tsd-testcase-skills`), commit
`d26ba77`. Gitlink repository ini mematok versi yang direview.

```bash
git submodule update --init repos/staffinc/skills
```

Baca `SKILL.md` beserta reference yang diarahkan untuk tugas tersebut:

| Input / tugas | Skill wajib | Handoff |
|---|---|---|
| PRD → TSD, review/update TSD, test plan | `repos/staffinc/skills/tsd-writer/SKILL.md` | TSD dengan versi, readiness, traceability, hasil self-check |
| TSD / skenario disetujui → canonical TC | `repos/staffinc/skills/testcase-writer/SKILL.md` | File TC + PRE, reconciliation dan hasil validator |
| TC yang sudah ada → automation | `workflow/00-ledger-intake.md` | Grounding → scenario approval → mapping → implement → evidence → review |

Jangan mewajibkan pembuatan TSD baru untuk memperbaiki automation TC yang sudah ada.
TSD dan TC ditulis dalam English; percakapan mengikuti bahasa user. Skill perusahaan
ini ditulis untuk Staffinc; pada track INP gunakan hanya kontrak yang berlaku menurut
aturan/schema ledger, bukan asumsi perilaku Staffinc.

## Gate A — TSD

1. Baca skill `tsd-writer` dan reference sesuai deliverable. Bind PRD dengan path
   dan SHA-256; inventaris AC, scope, dependency, serta konflik sumber.
2. Expected behavior berasal dari PRD / keputusan Product yang tercatat. Codebase
   adalah bukti implementasi, bukan alasan mengganti requirement diam-diam.
3. Reuse/extend coverage; pertahankan ID. Undefined behavior masuk open decision,
   bukan expected result karangan atau skenario executable.
4. Jalankan `tsd-writer/references/self-check.md` pada file final: inventory,
   format 12 section, GWT, Ref, ID, count dan judul. Checklist ini **manual**;
   tidak ada script linter yang dibundel. Laporkan hasil nyata, bukan "CI passed".
5. Status DRAFT / VALIDATED mengikuti Definition of Done skill. Jika knowledge
   atau ledger tidak tersedia, tetap DRAFT dengan Coverage `Not checked`.

## Gate B — canonical testcase

1. Baca aturan repository `staffinc-testcase` terlebih dahulu; schema dan validator
   ledger menang atas contoh di skill. Gunakan clone yang sudah diketahui, jangan
   menanyakan ulang path yang dapat ditemukan. Branch dari baseline ledger terbaru.
2. Bind path, versi dan SHA-256 **file TSD**, bukan hash PRD. DRAFT hanya boleh
   dikonversi setelah user menerima risikonya, dan tulis status tersebut di handoff.
3. Rekonsiliasi tiap skenario menjadi REUSE / EXTEND / NEW dengan bukti; reuse PRE
   berdasarkan state, jangan mengarang endpoint atau menduplikasi behavior.
4. TSD boleh mempunyai kategori EDGE. Ledger **tidak** mempunyai tipe `edge`:
   boundary yang ditolak → `negative`; boundary diterima → `functional`.
   Jangan mengubah semua boundary menjadi NEG hanya karena label EDGE.
5. Jalankan dari clone ledger:
   ```bash
   npm run testcase:build
   python3 scripts/validate-tsd-sync.py --source <SOURCE_ID>
   ```
   Perintah kedua hanya untuk governed source. Set `STAFFINC_AUTOMATION_ROOT`
   dan `INTERNALTOOLS_AUTOMATION_ROOT` ke clone aktual bila validator memerlukannya.
   Audit zero unresolved dispositions, satu active TC per source scenario,
   PRE refs valid, dan tidak ada duplicate behavior.
6. Pisahkan error baseline dari regresi perubahan. Hasil baseline-aware bukan
   klaim CI green. Stage path spesifik; jangan commit hasil index/report generated.

## Gate C — kembali ke workflow automation

Setelah canonical TC tersedia, mulai `workflow/00-ledger-intake.md`, bukan langsung
menulis spec. Pertahankan grounding dengan sitasi, reuse audit, approval scope,
layer mapping, runtime evidence, dan pre-push review. Perbedaan app vs TC tetap
keputusan manusia: perubahan TC atau defect, bukan assertion disesuaikan diam-diam.

Readiness TSD, validator ledger, dan automation execution adalah tiga status berbeda.
TC baru memakai `automationRef: null` kecuali sudah benar-benar automated.
`automationStatus: automated` hanya setelah PR automation merged dan green dengan
`@covers` yang tepat; run lokal passed saja belum cukup untuk promosi status ledger.
Tidak membuat PR, push, atau merge tanpa izin publikasi user.

## Handoff minimum

- Source path/version/hash, scope, readiness dan keputusan terbuka.
- Reconciliation REUSE / EXTEND / NEW beserta bukti dan count dari data aktual.
- Path TC/PRE dan traceability skenario → TC → checkpoint automation.
- Hasil self-check, validator dan runtime dicatat terpisah; blocker tetap blocker.
- File yang berubah dan baseline commit; izin sebelum publikasi.
