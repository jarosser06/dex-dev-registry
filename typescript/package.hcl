package {
  name        = "typescript"
  version     = "0.2.0"
  description = "TypeScript development toolkit with linting, testing, and E2E validation using Chrome DevTools MCP"
  platforms   = ["claude-code", "github-copilot"]
}

claude_skill "linting" {
  description = "Expert in maintaining code quality using ESLint and TypeScript. Enforces zero-error policy for linting and type checking."
  content     = file("skills/linting/SKILL.md")
}

claude_skill "testing" {
  description = "Expert in testing TypeScript applications with unit tests and E2E validation using Chrome DevTools MCP"
  content     = file("skills/testing/SKILL.md")
}

file "tasks" {
  src  = "tasks.yaml"
  dest = "typescript_tasks.yaml"
}

mcp_server "typescript-tasks" {
  description = "TypeScript development task automation"
  command     = "dev-toolkit-mcp"
  args = [
    "-config",
    "typescript_tasks.yaml"
  ]
}

mcp_server "chrome-devtools" {
  description = "Chrome DevTools MCP for browser automation, E2E testing, and UI validation"
  command     = "npx"
  args = [
    "-y",
    "chrome-devtools-mcp@latest"
  ]
}

claude_settings "mcp-permissions" {
  allow = [
    "mcp__chrome-devtools",
    "mcp__dev-toolkit-mcp"
  ]
}

# GitHub Copilot Resources

copilot_skill "linting" {
  description = "Expert in maintaining code quality using ESLint and TypeScript. Enforces zero-error policy for linting and type checking."
  content     = file("skills/linting/SKILL.md")
}

copilot_skill "testing" {
  description = "Expert in testing TypeScript applications with unit tests and E2E validation using Chrome DevTools MCP"
  content     = file("skills/testing/SKILL.md")
}
