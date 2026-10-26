# Checklist — sebelum PR

## Traceability
- [ ] Setiap test baru punya `// @covers <TC-ID>` (atau `// @no-covers <alasan>`)
- [ ] ID benar-benar ada di ledger — bukan ID yang "kelihatan masuk akal"
- [ ] Satu TC = satu spec pemilik; tidak ada dua spec mengklaim ID yang sama
- [ ] Spec baru terdaftar di runner/catalog repo (kalau repo memakainya)

## Layer
- [ ] Spec tidak meng-import page/screen/component (termasuk `import type`)
- [ ] Usecase tidak punya `expect()`
- [ ] Layer 3 tidak memutuskan urutan bisnis
- [ ] Data uji berasal dari factory; tidak ada `' EDITED'` / `'X'.repeat(51)` di usecase
- [ ] Id mengalir dari hasil stage, tidak hardcode

## Assertion
- [ ] Bisa gagal kalau perilaku berubah (bukan `toBeDefined()` saja)
- [ ] Tidak ada fallback `||` yang selalu true
- [ ] Tidak ada status set yang ditoleransi (`[200,401,404].toContain(...)`)
- [ ] Assertion lama tidak dihapus saat menyelaraskan — yang baru ditambahkan

## Hygiene
- [ ] Tidak ada `test.only` / `describe.only`
- [ ] Tidak ada `console.log`, emoji, atau komentar naratif `//` di spec
- [ ] Tidak ada token/JWT/URL environment hardcoded
- [ ] Tidak ada probe atau file sementara ikut ter-stage

## Gate
- [ ] `python3 scripts/check_agent_rules.py --base origin/develop` → clean
- [ ] Type-check repo dijalankan (`npm run check-all` / `bun run type-check`)
- [ ] Spec yang berubah benar-benar dijalankan; hasilnya dikutip di PR
- [ ] Bagian yang belum dijalankan disebut di PR ("not verified")
