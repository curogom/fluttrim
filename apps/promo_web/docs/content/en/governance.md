# Governance

Decision model and approval criteria for the Fluttrim project.

## Maintainer Model

- Project owner/maintainer makes final decisions.
- External contributions are reviewed and merged via PR workflow.

## Decision Principles

- Safety first: do not weaken allowlist/containment guarantees
- Scope discipline: avoid non-Flutter cleaner features
- Reproducibility: behavior changes must include tests and docs

## Release Principles

- `packages/core` follows semver
- `dart pub publish --dry-run` is required before public release
