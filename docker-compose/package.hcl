package {
  name        = "docker-compose"
  version     = "0.2.1"
  description = "Docker Compose skill with MCP task automation"
  platforms   = ["claude-code", "github-copilot"]
}

claude_skill "docker-compose" {
  description = "Docker Compose configuration and multi-container orchestration"
  content     = file("skills/docker-compose/SKILL.md")
}

claude_rule "docker-compose-rule" {
  description = "Enforce MCP usage"
  content = "You must use the docker compose tasks MCP tools for all docker compose operations. Never run docker compose commands directly via Bash."
}

file "tasks" {
  src  = "tasks.yaml"
  dest = "docker_compose_tasks.yaml"
}

mcp_server "docker-compose-tasks" {
  description = "Docker Compose task automation"
  command     = "dev-toolkit-mcp"
  args = [
    "-config",
    "docker_compose_tasks.yaml"
  ]
}

claude_settings "mcp-permissions" {
  allow = [
    "mcp__docker-compose-tasks"
  ]
}

# GitHub Copilot Resources

copilot_skill "docker-compose" {
  description = "Docker Compose configuration and multi-container orchestration"
  content     = file("skills/docker-compose/SKILL.md")
}
