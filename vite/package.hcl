package {
  name        = "vite"
  version     = "0.1.0"
  description = "Vite expert: lightning-fast dev server, HMR, production builds, framework integration, and modern build optimization"
  platforms   = ["claude-code", "github-copilot"]
}

dependency "typescript" {
  version = "^0.2.0"
}

claude_skill "vite" {
  description = "Expert in Vite development: native ES modules, HMR, Rollup-based builds, framework integration (React, Vue, Svelte), environment variables, and build optimization. Use when working with Vite projects or build tooling."
  content     = file("skills/vite/SKILL.md")
}

file "tasks" {
  src  = "tasks.yaml"
  dest = ".mcp_tasks/vite_tasks.yaml"
}

mcp_server "vite-tasks" {
  description = "Vite development task automation"
  command     = "dev-toolkit-mcp"
  args = [
    "-config",
    ".mcp_tasks/vite_tasks.yaml"
  ]
}

claude_settings "mcp-permissions" {
  allow = [
    "mcp__dev-toolkit-mcp"
  ]
}

# GitHub Copilot Resources

copilot_skill "vite" {
  description = "Expert in Vite development: native ES modules, HMR, Rollup-based builds, framework integration (React, Vue, Svelte), environment variables, and build optimization. Use when working with Vite projects or build tooling."
  content     = file("skills/vite/SKILL.md")
}
