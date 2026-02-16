# Contributing

Thanks for contributing to Fluttrim.

## Before You Start

- Open an issue for bugs, regressions, or feature proposals.
- Keep scope focused on Flutter-related caches/artifacts.
- Discuss large changes before implementation.

## Development Setup

- Core: `cd packages/core && dart test`
- CLI: `cd apps/cli && dart run bin/fluttrim.dart --help`
- Desktop: `cd apps/desktop && flutter run`
- Promo web: `cd apps/promo_web && python3 -m http.server 8080`

## Pull Request Rules

- One feature/fix per PR.
- Include tests/docs updates with code changes.
- Keep CLI/GUI thin: business logic belongs in `packages/core`.
- Preserve safety rules: allowlist + containment + preview-before-apply.
- For destructive actions, maintain explicit confirmation flow.

## Commit Style

- Use concise commit messages, e.g.:
  - `feat(core): add scan filter`
  - `fix(desktop): guard unknown attribution cleanup`
  - `docs: update manual tests`

## Review Checklist

- [ ] `dart analyze` / `flutter analyze` passed
- [ ] Tests passed for changed modules
- [ ] No scope creep beyond Flutter caches
- [ ] i18n strings added for EN/KO when UI text changes

