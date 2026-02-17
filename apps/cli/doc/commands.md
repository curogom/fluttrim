# fluttrim CLI Command Reference

This document describes command usage for `fluttrim_cli`.

## Run Modes

- Local (inside repository): `dart run bin/fluttrim.dart <command> [options]`
- Global (after pub.dev activation): `fluttrim <command> [options]`

## Global Options

- `-h, --help`: show help
- `--version`: print CLI version

## `scan`

Discover Flutter projects and estimate cache/artifact sizes.

```bash
fluttrim scan [options]
```

Options:

- `-r, --root <path>`: scan root (repeatable)
- `--profile <safe|medium|aggressive>`: cleanup profile (default: `safe`)
- `--exclude <pattern>`: exclusion pattern (repeatable)
- `--max-depth <n>`: discovery depth from each root (default: `5`)
- `--include-global`: include global caches (default: `false`)
- `--json`: output JSON

Examples:

```bash
fluttrim scan --root ~/dev --profile safe
fluttrim scan --root ~/dev --include-global --json
```

## `plan`

Generate cleanup plan only (no deletion).

```bash
fluttrim plan [options]
```

`scan` options plus:

- `--trash`: set delete mode to trash (default)
- `--permanent`: set delete mode to permanent
- `--allow-unknown`: include unknown-attribution targets
- `--json`: output JSON

Examples:

```bash
fluttrim plan --root ~/dev --profile medium
fluttrim plan --root ~/dev --profile safe --json
```

## `apply`

Execute cleanup plan.

```bash
fluttrim apply [options]
```

Options:

- `-r, --root <path>`: scan root (repeatable)
- `--profile <safe|medium|aggressive>`: profile (default: `safe`)
- `--exclude <pattern>`: exclusion pattern (repeatable)
- `--max-depth <n>`: discovery depth (default: `5`)
- `--include-global`: include global caches
- `-y, --yes`: skip confirmation prompt
- `--trash`: trash mode (default)
- `--permanent`: permanent mode (`--yes` required)
- `--allow-unknown`: allow unknown-attribution targets
- `--json`: output JSON

Notes:

- `--permanent` cannot be used without `--yes`.
- Safe defaults are `--trash` and unknown-attribution blocking.

Examples:

```bash
fluttrim apply --root ~/dev --profile safe --yes
fluttrim apply --root ~/dev --profile aggressive --permanent --yes
fluttrim apply --root ~/dev --profile safe --json --yes
```

## `doctor`

Print OS, tool availability, and cache path diagnostics.

```bash
fluttrim doctor [options]
```

Options:

- `--json`: output JSON

Examples:

```bash
fluttrim doctor
fluttrim doctor --json
```

## Exit Codes

- `0`: success
- `1`: runtime exception/failure
- `64`: invalid arguments/format error
- `130`: user cancellation (e.g. SIGINT)
