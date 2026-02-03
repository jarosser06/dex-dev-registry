---
name: linting
description: Expert in maintaining code quality using ESLint and TypeScript
---

# Linting Skill

Expert in code quality enforcement for TypeScript projects.

## Linting Tools

- **ESLint**: JavaScript/TypeScript linting with framework presets
- **TypeScript Compiler**: Type checking and static analysis
- **Framework-specific linting**: Framework rules and optimizations (Next.js, React, etc.)

## Configuration

Example config files (adjust for your project):
- `eslint.config.mjs` or `.eslintrc` - ESLint configuration with framework presets
- `tsconfig.json` - TypeScript compiler configuration with strict mode

## Running Linters

```bash
npm run lint              # Run ESLint on the project
npx tsc --noEmit          # Run TypeScript type checking
```

## Auto-Fix Commands

```bash
npm run lint -- --fix     # Auto-fix ESLint issues where possible
```

## Standards

### TypeScript
- **Strict mode**: Enabled (`strict: true`)
- **Type checking**: Required for all code
- **Target**: ES2017+ (or as configured for your project)
- **Module system**: ESNext with bundler resolution
- **Path aliases**: Configure in `tsconfig.json` (e.g., `@/*` for `./src/*`)

### ESLint
- **Configuration**: Framework presets + TypeScript (e.g., Next.js, React, Node.js)
- **Ignored paths**: Build directories, generated files
- **Framework rules**: Follow your framework's recommended rules

### Code Organization
- Use path aliases for imports (e.g., `@/components/...`, configured in tsconfig.json)
- Follow your framework's conventions for file structure and naming
- Maintain isolated modules (`isolatedModules: true`)

## Zero-Error Policy

**All linting and type checking must pass before committing.**

- ESLint errors must be resolved
- TypeScript type errors must be fixed
- No bypassing with `@ts-ignore` or `eslint-disable` without justification
- Warnings should be addressed when reasonable

## Common Auto-Fix Scenarios

Most auto-fixable issues:
- Import ordering
- Spacing and formatting
- Missing semicolons (if configured)
- Simple framework best practices

Must be fixed manually:
- Type errors
- Missing dependencies in React hooks
- Complex logic issues
- Accessibility violations

## Integration

This linting skill applies to TypeScript projects using:
- TypeScript 5.x or higher
- ESLint 8.x or 9.x
- Framework-specific plugins (Next.js, React, Node.js, etc.)

Configure your `eslint.config.mjs` or `.eslintrc` and `tsconfig.json` according to your project's needs.

Run linting before building or committing code to catch issues early.
