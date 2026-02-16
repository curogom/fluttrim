# fluttrim

Cross-platform (macOS/Windows/Linux) Flutter-focused cache inspector and space trimmer with:

- `packages/core`: pure Dart business logic (scan/plan/apply + safety rules)
- `apps/cli`: thin Dart CLI wrapper around `packages/core`
- `apps/desktop`: thin Flutter desktop GUI wrapper around `packages/core`
- `apps/promo_web`: static promotional landing website (EN default + KO toggle)

Scope: only Flutter-related caches/artifacts. No "general system cleaner" features.

## License

MIT (`LICENSE`)

## Dev

- Core: `cd packages/core && dart test`
- CLI: `cd apps/cli && dart run bin/fluttrim.dart --help`
- Desktop: `cd apps/desktop && flutter run`
- Promo web: `cd apps/promo_web && python3 -m http.server 8080`

## Deployment

- Desktop build artifacts (macOS/Windows/Linux): GitHub Actions `Desktop Release` workflow (`.github/workflows/desktop-release.yml`).
- Promo landing page: Cloudflare Pages via `Promo Web Cloudflare Pages` workflow (`.github/workflows/promo-web-pages.yml`).
- Promo web backend is optional. For pure landing pages, static hosting is enough. Add Firebase only if you need dynamic features (auth, database, server logic).

### Cloudflare Pages Setup

Set these repository settings before running the workflow:

- Secrets:
  - `CLOUDFLARE_API_TOKEN` (Pages deploy permission)
  - `CLOUDFLARE_ACCOUNT_ID`
- Variable:
  - `CLOUDFLARE_PAGES_PROJECT` (Cloudflare Pages project name)

Detailed guide: `docs/cloudflare-pages-setup.md`

Design/spec docs live in `fluttrim_planning_md_set/`.
