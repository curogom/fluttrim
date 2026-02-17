# Cloudflare Pages Setup (Token-Free Default)

This project uses Cloudflare Pages dashboard Git integration for `apps/promo_web`.

## Why

- No Cloudflare API token stored in repository
- Simpler operations for static web deployment

## Setup Summary

1. Connect `curogom/fluttrim` in Cloudflare Pages
2. Production branch: `main`
3. Framework preset: none
4. Build output directory: `apps/promo_web`
5. Save and deploy

## Notes

- Deploy is triggered automatically by pushes to `main`.
- If deployment looks stale, verify branch/output directory settings first.
