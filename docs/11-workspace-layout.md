# 11 — Workspace: semua repo yang terlibat

Satu pekerjaan automation menyentuh beberapa repo sekaligus. Dokumen ini mencatat repo mana saja,
di mana salinannya, dan bagaimana worktree dipakai per task.

## Peta repo

| Repo | Peran | Track | Branch default |
|---|---|---|---|
| `sampingantech/staffinc-testcase` | ledger TC (sumber kebenaran TC) | Staffinc + INP | `main` |
| `sampingantech/staffinc-automation` | repo test Staffinc | Staffinc | `develop` |
| `sampingantech/internaltools-automation` | repo test INP / internal tools | INP | `develop` |
| `sampingantech/hcmsvc` | API Go | Staffinc | `develop` |
| `sampingantech/hcmworker` | worker Go | Staffinc | `develop` |
| `sampingantech/kerjaan-client-portal` | web portal (TypeScript) | Staffinc | `develop` |
| `sampingantech/seamless-admin-portal` | admin portal Next.js | Staffinc | `develop` |
| `sampingantech/kerjaan-sdd` | dokumen SDD produk (grounding alur) | Staffinc | `main` |
| `sampingantech/kerjaan-android` | app Android (Kotlin) | Staffinc | `master` |
| `sampingantech/ios-kerjaan` | app iOS (Swift) | Staffinc | `main` |
| `sampingantech/utilitysvc` | API Python | INP | `develop` |
| `sampingantech/utility-portal` | web portal PHP | INP | `develop` |
| `sampingantech/utilityapp` | app PHP | INP | `develop` |
| `rotaigalp/kartographer-mcp` | MCP index codebase INP | tooling | `main` |
| `sampingantech/skills` | skill agent (termasuk `automation-worker`) | tooling | `main` |

Semua private. Akses lewat `gh` (akun yang sudah login), bukan token di URL.

### Menemukan repo baru

Daftar di atas bukan tebakan — ambil dari org langsung:

```bash
gh repo list sampingantech --limit 200 \
  --json name,description,primaryLanguage,updatedAt \
  --jq '.[] | "\(.name)\t\(.primaryLanguage.name // "-")\t\(.description // "")"'
```

Repo yang relevan untuk automation biasanya jatuh ke salah satu peran di tabel: ledger, automation,
codebase track Staffinc, codebase track INP, atau tooling. Kalau ragu apakah sebuah repo dipakai,
cek dulu apakah `automationRef` di ledger menunjuk ke sana sebelum menambahkannya ke workspace.

## Repo ini membawa submodule

Semua repo di tabel di atas terpasang sebagai submodule di `repos/`, jadi satu clone repo ini
= satu workspace lengkap:

```
repos/
  staffinc/   staffinc-automation · hcmsvc · hcmworker · kerjaan-client-portal
              kerjaan-android · ios-kerjaan · seamless-admin-portal · kerjaan-sdd
  inp/        internaltools-automation · utilitysvc · utility-portal · utilityapp
  shared/     staffinc-testcase      (ledger dipakai dua track)
  tooling/    kartographer-mcp · skills
```

Pemisahan ini mengikuti track: repo yang hanya dipakai track Staffinc di `staffinc/`, yang hanya
dipakai INP di `inp/`. `staffinc-testcase` sengaja di `shared/` karena ledger-nya satu untuk dua
track — kalau butuh checkout terpisah per track, pakai worktree dari submodule itu, bukan clone kedua.

```bash
git clone --recurse-submodules https://github.com/sulastambunan/Workflow-Agentic-Sulas.git
# atau kalau sudah clone:
git submodule update --init --recursive
git submodule status                    # commit yang di-pin per repo
```

Catatan:

- Submodule **dipin ke satu commit**, bukan mengikuti branch. Untuk menyegarkan:
  `git submodule update --remote --merge`.
- Worktree dari repo ini **tidak otomatis** mengisi submodule — jalankan
  `git submodule update --init --recursive` di worktree tersebut.
- Codebase hanya dibaca untuk grounding; perubahan kode produk tidak dilakukan dari submodule ini.
  Kalau perlu branch kerja, buat worktree dari repo aslinya (lihat bagian di atas).

## Layout yang dipakai

```
~/Documents/
  AUTOMATION-WORKER <...>/     staffinc-automation · staffinc-testcase · hcmsvc · hcmworker
                               kerjaan-client-portal · kerjaan-android · ios-kerjaan
                               seamless-admin-portal · kerjaan-sdd · skills
  AUTOMATION-INP - commercial/ internaltools-automation · staffinc-testcase · utilitysvc
                               utility-portal · utilityapp
  DATA TESTING/INP - MCP/      kartographer-mcp
  Workflow-Agentic-Sulas/      repo panduan ini
```

Nama folder workspace boleh berbeda per orang — yang penting **satu repo = satu clone utama**,
dan worktree dibuat di sampingnya.

## Worktree per task

Satu task biasanya butuh tiga repo sekaligus. Pola yang dipakai:

```
<clone utama>/                    branch default, tidak disentuh
<clone utama>-wt-<PK>/            worktree task (branch feat/<PK>-<slug>)
```

Contoh untuk satu TC mobile PK157:

```bash
git -C staffinc-automation worktree add ../staffinc-automation-wt-PK157 -b feat/PK157-pin-login
git -C staffinc-testcase   worktree add ../staffinc-testcase-wt-PK157   -b automation/PK157-status
git -C kerjaan-android     worktree add ../kerjaan-android-wt-PK157     -b explore/PK157
```

Repo yang dibutuhkan per jenis task:

| Task | Repo wajib | Repo pendukung |
|---|---|---|
| API | automation + ledger + `hcmsvc` | – |
| Web portal | automation + ledger + `kerjaan-client-portal` | `hcmsvc` |
| Mobile Android | automation + ledger + `kerjaan-android` | `hcmworker` |
| Mobile iOS | automation + ledger + `ios-kerjaan` | – |
| INP web | `internaltools-automation` + ledger + `utility-portal` | `utilitysvc` + `kartographer-mcp` |
| INP API | `internaltools-automation` + ledger + `utilitysvc` | `kartographer-mcp` |

Codebase **tidak diubah** — worktree-nya dibuat hanya agar agent bisa membaca kode di branch yang
sama dengan yang sedang diuji, tanpa mengganggu checkout orang lain.

## Bootstrap

`scripts/bootstrap-workspace.sh` mengecek repo mana yang sudah ada, mana yang belum:

```bash
bash scripts/bootstrap-workspace.sh check          # tabel FOUND/MISSING + branch
bash scripts/bootstrap-workspace.sh clone --dest ~/Documents/"AUTOMATION-INP - commercial"
```

`clone` memakai `--filter=blob:none` supaya clone codebase besar tetap ringan (blob diambil saat
dibutuhkan). Script tidak pernah menghapus atau memindahkan clone yang sudah ada.

## Aturan

- Satu repo = satu clone utama; jangan clone berkali-kali untuk tiap task — pakai worktree.
- Satu branch hanya di satu worktree.
- Hapus worktree dengan `git worktree remove`, bukan `rm -rf` (detail: `docs/10-worktree.md`).
- `node_modules` dan `.env` tidak ikut ke worktree — symlink/copy sebelum run.
- Jangan commit `node_modules`, `test-results`, `outputs/`, `.env*`.
