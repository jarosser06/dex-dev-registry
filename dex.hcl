project {
  name            = "dex-dev-registry"
  agentic_platform = "claude-code"
}

plugin "dex-builder" {
  source  = "git+https://github.com/LaunchCG/dex-plugin"
  version = "2.0.0"
}
