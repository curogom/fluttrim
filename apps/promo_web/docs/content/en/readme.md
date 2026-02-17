# fluttrim

Fluttrim is a cross-platform tool to inspect and clean Flutter-related caches and build artifacts safely.

## Monorepo Structure

- `packages/core`: pure Dart business logic (scan/plan/apply/safety)
- `apps/cli`: thin CLI frontend for `packages/core`
- `apps/desktop`: Flutter desktop GUI frontend for `packages/core`
- `apps/promo_web`: static marketing/docs website

Scope is intentionally limited to Flutter-related caches/artifacts. It is not a generic system cleaner.

## License

MIT (`LICENSE`)

## Local Development

- Core: `cd packages/core && dart test`
- CLI: `cd apps/cli && dart run bin/fluttrim.dart --help`
- Desktop: `cd apps/desktop && flutter run`
- Promo web: `cd apps/promo_web && python3 -m http.server 8080`

## Developer Docs

- Core API reference: `packages/core/doc/api-reference.md`
- CLI command reference: `apps/cli/doc/commands.md`

## Deployment

- Desktop builds: GitHub Actions `Desktop Release`
- Promo website: Cloudflare Pages dashboard Git integration (no repository token required)

## Publishing

- Public packages:
  - `fluttrim_core`: core logic package
  - `fluttrim_cli`: global `fluttrim` command package
- CLI global install example:
  - `dart pub global activate fluttrim_cli`
  - `fluttrim --help`
- Publishing guide: `docs/pubdev-publishing.md`

## OSS Policy Set

- `CONTRIBUTING.md`
- `CODE_OF_CONDUCT.md`
- `SECURITY.md`
- `SUPPORT.md`
- `GOVERNANCE.md`
- `MAINTAINERS.md`
- `ROADMAP.md`
