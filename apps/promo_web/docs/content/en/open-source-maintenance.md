# Open Source Maintenance Scope

This policy defines what should and should not be public in the repository.

## Include

- product code under `packages/` and `apps/`
- public docs and OSS policy files
- operational docs required by contributors/users

## Exclude

- internal planning drafts and prompt files
- private operational notes
- sensitive personal/infrastructure details

## Pre-PR Check

1. inspect changed files
2. verify internal-only assets are excluded
3. complete PR template checks
4. ensure CI/public-scope checks pass
