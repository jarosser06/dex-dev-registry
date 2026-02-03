---
name: linting
description: Enforce code quality standards. Linting must pass before commits. Do not ignore linting errors unless explicitly instructed.
---

# Linting Standards

## Core Principle

**All linting errors must be resolved before committing code.**

Do not ignore, suppress, or bypass linting checks unless explicitly instructed by the user.

## Workflow

1. **Run the project's linter** - Use whatever linting tools the project has configured
2. **Fix all reported issues** - Address errors, warnings, and style violations
3. **Verify clean output** - Re-run linter to confirm all issues are resolved
4. **Only then commit** - Linting must pass before creating commits

## When Linting Errors Occur

- **Fix the issue** - Don't add ignore comments or suppress warnings
- **Follow project standards** - Respect the project's linting configuration
- **Ask for clarification** - If an error seems incorrect, ask the user rather than bypassing it

## Acceptable Exceptions

You may ignore linting errors only when:
- The user explicitly instructs you to do so
- The user provides specific ignore directives or suppression comments to add

Otherwise, treat all linting errors as blockers that must be resolved.
