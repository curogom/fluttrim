# Manual Tests

These are smoke/manual scripts to validate behavior per OS.

## Common (all OS)

1. Create a test workspace with 2 Flutter projects.
2. Add dummy files into `build/` and `.dart_tool/` so sizes are non-zero.
3. Run scan (CLI/GUI) with `SAFE` and confirm:
   - projects discovered via `pubspec.yaml` + (.metadata OR ios/ OR android/)
   - only allowlisted targets are listed
   - no symlinks are followed by default
4. Generate a plan and verify it lists explicit paths and sizes.
5. Apply with trash mode and confirm items are moved to Trash/Recycle Bin (not permanently deleted).
6. CLI smoke:
   - `dart run bin/fluttrim.dart scan --root <path>`
   - `dart run bin/fluttrim.dart plan --root <path>`
   - `dart run bin/fluttrim.dart apply --root <path> --yes`
   - `dart run bin/fluttrim.dart doctor`
7. Confirm JSON logs are written under user log directory (`~/.fluttrim/logs` on macOS/Linux).

## Desktop UI (Milestone 3)

1. Open `Projects` and click `Scan Now`.
2. Verify project list is populated and sortable/searchable.
3. Open one project, toggle targets, click `Preview Plan`, then `Apply`.
4. Confirm apply requires confirmation and updates summary/log path.

## Xcode DerivedData (macOS milestone)

1. Open `Xcode` tab and click `Refresh`.
2. Verify each DerivedData folder shows:
   - attribution state (`Attributed` or `Unknown`)
   - confidence/evidence when available
3. Confirm unknown-attribution rows are disabled when `Allow unknown attribution cleanup` is off.
4. Enable Danger Zone gate, click `Preview Plan`, then `Apply`.
5. Confirm only selected/allowed entries are deleted and cleanup log is written.

## Flutter SDK (FVM status)

1. Open `Flutter SDK` tab and click `Refresh`.
2. Verify availability (`available/unavailable`) and executable path are shown.
3. Verify installed SDK versions are listed.
4. After a scan, verify project pinned-version mapping appears.
5. In `Unused SDK cleanup`, remove one unused SDK and verify:
   - confirmation modal appears
   - result banner shows success/failure
   - SDK list refreshes automatically

## History (v1)

1. Run at least one scan and one cleanup.
2. Open `History` tab and verify run list is populated with latest-first order.
3. Verify metrics show:
   - total run count
   - cumulative reclaimed bytes
   - latest scan delta
4. Click open action on a history row and verify the underlying JSON log opens.
5. Verify filters work:
   - type chips (`Scan` / `Cleanup`)
   - profile selector (`safe/medium/aggressive/all`)
   - period selector (`7/30/90 days/all`)

## macOS

- Validate Trash behavior.
- Validate Xcode DerivedData attribution and that Unknown is blocked by default.

## Windows 10/11

- Validate Recycle Bin behavior.

## Ubuntu (Linux)

- Validate freedesktop.org trash behavior (or fallback rules if unavailable).
