package {
  name        = "nextjs"
  version     = "0.2.1"
  description = "Next.js 16+ App Router expert: Server/Client Components, Server Actions, API routes, middleware, authentication, and data fetching patterns"
  platforms   = ["claude-code", "github-copilot"]
}

dependency "typescript" {
  version = "^0.2.0"
}

claude_skill "nextjs" {
  description = "Expert in Next.js 16+ App Router patterns, Server/Client Components, Server Actions, API routes, middleware, authentication, and data fetching. Use when implementing Next.js features, routing, or server-side logic."
  content     = file("skills/nextjs/SKILL.md")
}

file "tasks" {
  src  = "tasks.yaml"
  dest = ".mcp_tasks/nextjs_tasks.yaml"
}

mcp_server "nextjs-tasks" {
  description = "Next.js development task automation"
  command     = "dev-toolkit-mcp"
  args = [
    "-config",
    ".mcp_tasks/nextjs_tasks.yaml"
  ]
}

claude_settings "mcp-permissions" {
  allow = [
    "mcp__dev-toolkit-mcp"
  ]
}

# GitHub Copilot Resources

copilot_skill "nextjs" {
  description = "Expert in Next.js 16+ App Router patterns, Server/Client Components, Server Actions, API routes, middleware, authentication, and data fetching. Use when implementing Next.js features, routing, or server-side logic."
  content     = file("skills/nextjs/SKILL.md")
}
