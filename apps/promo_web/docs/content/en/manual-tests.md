# Manual Test Guide

Smoke/manual validation scenarios by platform.

## Common

1. Prepare two Flutter projects in test workspace
2. Place non-empty files in `build/` and `.dart_tool/`
3. Run SAFE scan and verify discovery rules
4. Verify plan path/size output before apply
5. Verify trash-first behavior where supported
6. Verify JSON logs are generated

## Desktop UI

1. Run `Scan Now`
2. Verify project list/search/detail view
3. Verify `Preview Plan` -> `Apply` flow
4. Verify result and log refresh

## macOS

- Validate Xcode DerivedData attribution and unknown-block defaults

## Windows

- Validate recycle bin behavior

## Ubuntu

- Validate freedesktop trash behavior or explicit fallback policy
