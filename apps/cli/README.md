# fluttrim_cli

Thin CLI wrapper around `fluttrim_core`.

## Usage

```bash
dart run bin/fluttrim.dart --help
```

Commands:

- `scan` : discover Flutter projects and compute cache sizes
- `plan` : create cleanup plan (preview only)
- `apply` : execute cleanup plan
- `doctor` : print OS/tool/cache-path diagnostics

Examples:

```bash
dart run bin/fluttrim.dart scan --root ~/Projects --profile safe
dart run bin/fluttrim.dart plan --root ~/Projects --profile medium
dart run bin/fluttrim.dart apply --root ~/Projects --profile safe --yes
dart run bin/fluttrim.dart doctor
```
