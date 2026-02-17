# GUI User Guide

This guide helps users quickly move from scan to safe cleanup in the Fluttrim desktop app.

## 1. Onboarding

On first launch, users configure:

- Language (English/Korean)
- Default scan roots
- Quick home-folder shortcut

## 2. Dashboard

System overview for current scan status.

- `Total reclaimable`
- `Projects found`
- Active `Profile`

Recommended flow:

1. Click `Scan Now`
2. Resolve any permission/path error banners first

## 3. Projects

Main workspace for project-level cleanup.

- Search and filter projects
- Multi-select for batch cleanup
- Per-project target checklist
- `Preview Plan` before any deletion
- `Apply` only after confirmation

Notes:

- 0B entries are excluded from cleanup counts/selections.
- Projects under `packages` directories are excluded from discovery.

## 4. Xcode (macOS)

DerivedData cleanup and attribution.

- Attribution states: `Attributed` / `Unknown`
- Unknown targets are blocked by default
- Danger Zone confirmation is required before apply

## 5. Flutter SDK (FVM)

FVM visibility and SDK usage.

- Installed SDKs sorted by newest first
- `Used by projects` is counted only from explicit FVM configs
- Ambiguous inference is intentionally excluded

## 6. Global Caches

Global cache cleanup with safety rails.

- Read/preview first
- Apply gated by Danger Zone confirmation
- Out-of-allowlist paths are blocked in planning

## 7. History

Track scan/cleanup runs.

- Timestamps and profiles
- Reclaimed bytes
- Open JSON logs directly

## 8. Settings

Manage default behavior.

- Scan roots
- Profile (SAFE/MEDIUM/AGGRESSIVE)
- Delete mode (Trash/Permanent)
- Unknown attribution policy
- Language

## Recommended User Journey

1. Configure roots/profile in `Settings`
2. Run `Scan Now`
3. Batch-select projects in `Projects`
4. Review `Preview Plan`
5. Execute `Apply`
6. Confirm results in `History`
