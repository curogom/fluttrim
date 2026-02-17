# JSON Schemas

Fluttrim emits machine-readable JSON for scan and cleanup runs.

## ScanResult

Key fields:

- `profile`: `safe | medium | aggressive`
- `projects[]`: project root and per-target sizing
- `xcodeTargets[]`: DerivedData entries with attribution fields
- `globalTargets[]`: global cache entries
- `totalsByCategory`, `totalBytes`

## CleanupPlan

Key fields:

- explicit `items[]` with `targetId`, `path`, `sizeBytes`, `risk`, `category`
- `deleteMode`
- generated timestamp and profile

## CleanupResult

Key fields:

- per-item status (`success`, `failed`, `skipped`)
- reclaimed bytes
- failure reasons/errors

For authoritative structure, refer to models in `packages/core` and sample logs under user log directory.
