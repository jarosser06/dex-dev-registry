dex-dev-registry
================

My personal S3 hosted package registry for reusable AI context management.

Requirements:
- [Dev Toolkit MCP installed](https://github.com/jarosser06/dev-toolkit-mcp)
- [Dex Installed](https://github.com/LaunchCG/dex)

## Usage

### Add Registry

```bash
dex registry add dex-dev-registry http://dex-dev-registry-production-471112549359.s3-website-us-west-2.amazonaws.com
```

### Install Packages

Create a `dex.hcl` in your project:

**For Claude Code:**

```hcl
project {
  name             = "my-project"
  agentic_platform = "claude-code"
}

registry "dex-dev" {
  url = "http://dex-dev-registry-production-471112549359.s3-website-us-west-2.amazonaws.com"
}

plugin "base-dev" {
  registry = "dex-dev"
  version  = "0.2.0"
}

plugin "typescript" {
  registry = "dex-dev"
  version  = "0.2.0"
}

plugin "nextjs" {
  registry = "dex-dev"
  version  = "0.2.0"
}
```

**For GitHub Copilot:**

```hcl
project {
  name             = "my-project"
  agentic_platform = "github-copilot"
}

registry "dex-dev" {
  url = "http://dex-dev-registry-production-471112549359.s3-website-us-west-2.amazonaws.com"
}

plugin "base-dev" {
  registry = "dex-dev"
  version  = "0.2.0"
}

plugin "python-dev" {
  registry = "dex-dev"
  version  = "0.2.0"
}

plugin "tailwind-css" {
  registry = "dex-dev"
  version  = "0.2.0"
}
```

Then install:

```bash
dex install
```

## Available Packages

All packages support both `claude-code` and `github-copilot` platforms.

- **base-dev** (0.2.0) - Commit standards, linting rules, CI/CD automation, MCP servers (serena, context7, dev-toolkit-mcp)
- **python-dev** (0.2.0) - Python style guidelines, type hints, testing patterns, pytest standards
- **typescript** (0.2.0) - TypeScript linting, testing, E2E validation with Chrome DevTools MCP
- **nextjs** (0.2.0) - Next.js 16+ App Router patterns, Server/Client Components, Server Actions
- **tailwind-css** (0.2.0) - Tailwind CSS v4 with Material Design 3, design tokens, dark mode
- **docker-compose** (0.2.0) - Docker Compose configuration and orchestration

## Publishing

Update version in `package.hcl`, then:
```bash
./deploy.sh
```

## Setup (First Time)

```bash
./deploy.sh --infra
```
