# 10 — Git worktree untuk kerja paralel

Satu repo, banyak folder kerja. Tiap folder punya branch sendiri, tapi object database dan
remote-nya sama — tidak ada clone kedua yang harus di-fetch berulang.

```
repo/                     ← checkout utama, biasanya tetap di main
repo-wt-pk143/            ← worktree branch feat/PK143-...
repo-wt-review/           ← worktree detached untuk review PR orang
repo-wt-fix/              ← worktree untuk perbaikan review
```

## Kenapa dipakai di workflow kita

1. **Satu task = satu worktree.** Checkout utama tidak pernah kotor, jadi tidak perlu `git stash`
   dan tidak ada risiko kerja orang lain tertimpa.
2. **Dua PK jalan bersamaan.** PK143 dan PK148 punya worktree masing-masing; pindah konteks cuma
   pindah folder, bukan checkout ulang (yang bisa gagal karena ada perubahan belum commit).
3. **Review PR tanpa mengganggu kerja aktif.** Baca branch orang di worktree terpisah, jalankan
   test di sana, lalu hapus.
4. **Resolusi konflik di worktree throwaway.** Merge base ke branch dilakukan di folder sementara;
   shared tree dan file yang sedang diedit manusia tidak tersentuh.

## Perintah dasar

```bash
# worktree baru + branch baru
git worktree add ../<repo>-wt-<slug> -b feat/<PK>-<slug>

# daftar worktree (path, HEAD, branch)
git worktree list

# review branch orang tanpa checkout
git worktree add --detach ../<repo>-wt-review origin/feat/<branch>

# selesai → hapus
git worktree remove ../<repo>-wt-<slug>
git worktree prune          # bersihkan metadata worktree yang foldernya sudah hilang
```

## Konvensi di tim kita

| Hal | Aturan |
|---|---|
| Path | `../<repo>-wt-<ticket>` (di samping clone utama, bukan di dalamnya) |
| Branch | `feat/<PK>-<slug>` atau `automation-worker/<mod>-<slug>` |
| Satu branch | hanya boleh ke-checkout di **satu** worktree |
| Dependency | `node_modules` tidak ikut — symlink ke clone utama atau install sendiri |
| Env | `.env` tidak ikut — copy dari clone utama, tetap gitignored |
| Hapus | `git worktree remove`, bukan `rm -rf` |

## Aturan keselamatan

- **Jangan `rm -rf` folder worktree.** Pakai `git worktree remove`; kalau folder sudah terhapus
  manual, jalankan `git worktree prune` — bukan menghapus `.git/worktrees` dengan tangan.
- **Jangan hapus worktree yang commit-nya belum di-push.** Cek `git log origin/<branch>..HEAD`.
- **Jangan `git checkout` / `reset --hard` untuk "membatalkan"** di shared tree; orang lain bisa
  sedang mengedit file yang sama. Perbaiki ke depan, bukan revert.
- **Branch terkunci?** `fatal: '<branch>' is already used by worktree at ...` berarti ada worktree
  lama (sering di `/private/tmp`). Lihat `git worktree list`; kalau worktree itu bersih dan branch
  sudah ada di origin, `git worktree remove <path> --force` lalu `git worktree prune` — baru checkout.
- **Worktree tidak mewarisi `node_modules` dan `.env`.** Untuk repo automation, symlink
  `node_modules` dan copy `.env*` sebelum menjalankan apa pun, atau install ulang.

## Dipakai di fase mana

- **Fase 3–5 (implement + verify):** satu worktree per task supaya run dan edit tidak bercampur
  dengan branch lain.
- **Fase 6 (dual PR):** PR automation dan PR ledger masing-masing punya worktree sendiri — dua repo,
  dua branch, tidak saling menimpa.
- **Review:** `--detach` di `origin/<branch>`; tidak perlu mengubah branch kerja sendiri.
