package {
  name        = "python-dev"
  version     = "0.2.0"
  description = "Python development toolkit with style guidelines, type hints, testing patterns, and code quality standards"
  platforms   = ["claude-code", "github-copilot"]
}

claude_skill "python-style" {
  description = "Expert guidance for Python code style, PEP 8, type hints, and formatting with Ruff"
  content     = file("skills/python-style/SKILL.md")
}

claude_skill "python-testing" {
  description = "Expert guidance for Python testing with pytest, fixtures, mocking, and test organization"
  content     = file("skills/python-testing/SKILL.md")
}

claude_rules "python" {
  description = "Python development standards: code style, formatting, and testing requirements"

  file {
    src  = "rules/python-style.md"
    dest = "python-style.md"
  }

  file {
    src  = "rules/python-formatting.md"
    dest = "python-formatting.md"
  }

  file {
    src  = "rules/python-testing.md"
    dest = "python-testing.md"
  }
}

claude_subagent "python-tester" {
  description = "Specialized agent for Python testing, debugging, and test automation"
  content     = file("agents/python-tester.md")
}

# GitHub Copilot Resources

copilot_skill "python-style" {
  description = "Expert guidance for Python code style, PEP 8, type hints, and formatting with Ruff"
  content     = file("skills/python-style/SKILL.md")
}

copilot_skill "python-testing" {
  description = "Expert guidance for Python testing with pytest, fixtures, mocking, and test organization"
  content     = file("skills/python-testing/SKILL.md")
}

copilot_instruction "python-style" {
  description = "Python code style standards including PEP 8 compliance and type hints"
  content     = file("rules/python-style.md")
}

copilot_instruction "python-formatting" {
  description = "Python code formatting standards using Ruff"
  content     = file("rules/python-formatting.md")
}

copilot_instruction "python-testing" {
  description = "Python testing standards using pytest"
  content     = file("rules/python-testing.md")
}

copilot_agent "python-tester" {
  description = "Specialized agent for Python testing, debugging, and test automation"
  content     = file("agents/python-tester.md")
}
