# fluttrim_core

Pure Dart core for Fluttrim.

## Responsibilities

- Discover Flutter projects from scan roots
- Compute allowlisted cache target sizes by profile
- Build cleanup plans with allowlist + containment guards
- Execute cleanup with trash/permanent modes and per-item results
- Provide doctor diagnostics (OS/tools/cache paths)
- Write machine-readable JSON run logs

## Public API (current)

- `ScanService.scan(ScanRequest) -> Stream<ScanEvent>`
- `CleanupPlanner.createPlan(...) -> CleanupPlan`
- `CleanupExecutor.execute(...) -> Stream<CleanupEvent>`
- `DoctorService.run() -> Future<DoctorResult>`
- `RunLogWriter.writeScanResult(...)`
- `RunLogWriter.writeCleanupResult(...)`

## Test

```bash
dart test
```

