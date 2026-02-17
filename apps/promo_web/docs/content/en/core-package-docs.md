# pub.dev Publishing Strategy

This document defines the publish scope and release procedure for the Fluttrim monorepo.

## Public Packages

- `packages/core` (`fluttrim_core`)
- `apps/cli` (`fluttrim_cli`)

## Principles

- Keep business logic in `fluttrim_core`
- Keep desktop app and internal operational assets out of pub.dev scope
- Keep credentials local (never commit tokens)

## `fluttrim_core` Release Checklist

1. Update version and changelog
   - `packages/core/pubspec.yaml`
   - `packages/core/CHANGELOG.md`
   - Verify metadata: `homepage=https://fluttrim.curogom.dev`
   - Verify API docs: `packages/core/doc/api-reference.md` and public API dartdoc
2. Run quality checks
   - `cd packages/core`
   - `dart format --output=none --set-exit-if-changed .`
   - `dart analyze`
   - `dart test`
3. Run publish validation
   - `dart pub publish --dry-run`
4. Publish from local environment
   - `dart pub publish`

## `fluttrim_cli` Release Checklist

1. Update version and changelog
   - `apps/cli/pubspec.yaml`
   - `apps/cli/CHANGELOG.md`
   - Verify `executables.fluttrim` is defined
   - Verify command docs: `apps/cli/doc/commands.md`
2. Verify dependency source
   - Use hosted dependency for `fluttrim_core`
3. Run quality checks
   - `cd apps/cli`
   - `dart format --output=none --set-exit-if-changed .`
   - `dart analyze`
4. Run publish validation
   - `dart pub publish --dry-run`
5. Publish from local environment
   - `dart pub publish`

## CI Guard

- `.github/workflows/ci.yml` runs `core-pub-dry-run` and `cli-pub-dry-run` for publish validation
- CI should fail on missing metadata/license before merge

## Recommended Release Order

1. Publish `fluttrim_core` first
2. Publish `fluttrim_cli` and include install instructions (`dart pub global activate fluttrim_cli`) in release notes
