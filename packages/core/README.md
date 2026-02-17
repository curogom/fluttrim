# fluttrim_core

Pure Dart core library for Fluttrim.

`fluttrim_core` contains all shared business logic used by the Fluttrim CLI and desktop GUI:
scan Flutter projects, build safe cleanup plans, and execute cleanup with guardrails.

## API docs

- API reference: `doc/api-reference.md`

## What this package does

- Discover Flutter projects from scan roots.
- Calculate cache/artifact sizes by cleanup profile.
- Build a cleanup plan with allowlist + containment checks.
- Execute cleanup in `trash` or `permanent` mode with per-item results.
- Run doctor checks (OS/tools/cache path diagnostics).
- Write machine-readable JSON logs for scan/cleanup runs.

## Core API

- `ScanService.scan(ScanRequest) -> Stream<ScanEvent>`
- `CleanupPlanner.createPlan(...) -> CleanupPlan`
- `CleanupExecutor.execute(...) -> Stream<CleanupEvent>`
- `DoctorService.run() -> Future<DoctorResult>`
- `RunLogWriter.writeScanResult(...)`
- `RunLogWriter.writeCleanupResult(...)`

## Quick example

```dart
import 'package:fluttrim_core/fluttrim_core.dart';

Future<void> main() async {
  const request = ScanRequest(
    roots: ['/Users/you/dev'],
    profile: Profile.safe,
    includeGlobal: false,
  );

  final scanService = ScanService();
  await for (final event in scanService.scan(request)) {
    if (event.isDone) {
      final result = event.result!;
      print('projects: ${result.projects.length}');
      print('reclaimable: ${result.totalBytes} bytes');
    }
  }
}
```

## Validation before publishing

```bash
dart format --output=none --set-exit-if-changed .
dart analyze
dart test
dart pub publish --dry-run
```
