package {
  name        = "docker-compose"
  version     = "0.2.0"
  description = "Docker Compose skill with MCP task automation"
  platforms   = ["claude-code", "github-copilot"]
}

claude_skill "docker-compose" {
  description = "Docker Compose configuration and multi-container orchestration"
  content     = file("skills/docker-compose/SKILL.md")
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
    "mcp__dev-toolkit-mcp"
  ]
}

# GitHub Copilot Resources

copilot_skill "docker-compose" {
  description = "Docker Compose configuration and multi-container orchestration"
  content     = file("skills/docker-compose/SKILL.md")
}
