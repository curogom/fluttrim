# fluttrim_cli

Thin CLI wrapper around `fluttrim_core`.

Full command reference: `doc/commands.md`

## Usage

Local run:

```bash
dart run bin/fluttrim.dart --help
```

Install from pub.dev (global):

```bash
dart pub global activate fluttrim_cli
fluttrim --help
```

Commands:

- `scan`: discover Flutter projects and estimate reclaimable bytes
- `plan`: generate a cleanup plan (preview only)
- `apply`: execute cleanup with guardrails
- `doctor`: print OS/tool/cache diagnostics

Examples:

```bash
dart run bin/fluttrim.dart scan --root ~/Projects --profile safe
dart run bin/fluttrim.dart plan --root ~/Projects --profile medium
dart run bin/fluttrim.dart apply --root ~/Projects --profile safe --yes
dart run bin/fluttrim.dart doctor
```
