# Contributing Guide

Thank you for contributing to Fluttrim.

## Before You Start

- Open an issue first for bugs, regressions, or feature proposals.
- Keep scope focused on Flutter cache/artifact workflows.
- Discuss large architecture changes before implementation.

## PR Rules

- One focused change per PR.
- Include tests/docs updates with code changes.
- Keep CLI/GUI thin and put logic in `packages/core`.
- Preserve safety rules: allowlist, containment, preview-before-apply.

## Review Checklist

- [ ] Analyze passes
- [ ] Tests pass
- [ ] No scope creep beyond Flutter caches/artifacts
- [ ] EN/KO UI text updates are synchronized where applicable
- [ ] Internal-only assets are not included in PR
