package {
  name        = "tailwind-css"
  version     = "0.2.0"
  description = "Comprehensive Tailwind CSS toolkit with Material Design 3 patterns, design tokens, dark mode support, and testing standards"
  platforms   = ["claude-code", "github-copilot"]
}

claude_skill "tailwind-css" {
  description = "Expert guidance for Tailwind CSS v4 with Material Design 3, design tokens, dark mode, and responsive patterns"
  content     = file("skills/tailwind-css/SKILL.md")
}

claude_rules "tailwind" {
  description = "Tailwind CSS standards: design tokens, component patterns, and testing requirements"

  file {
    src  = "rules/tailwind-classes.md"
    dest = "tailwind-classes.md"
  }

  file {
    src  = "rules/tailwind-components.md"
    dest = "tailwind-components.md"
  }

  file {
    src  = "rules/tailwind-testing.md"
    dest = "tailwind-testing.md"
  }
}

# GitHub Copilot Resources

copilot_skill "tailwind-css" {
  description = "Expert guidance for Tailwind CSS v4 with Material Design 3, design tokens, dark mode, and responsive patterns"
  content     = file("skills/tailwind-css/SKILL.md")
}

copilot_instruction "tailwind-classes" {
  description = "Tailwind CSS class usage and design token standards"
  content     = file("rules/tailwind-classes.md")
}

copilot_instruction "tailwind-components" {
  description = "Tailwind CSS component patterns and organization"
  content     = file("rules/tailwind-components.md")
}

copilot_instruction "tailwind-testing" {
  description = "Tailwind CSS testing requirements"
  content     = file("rules/tailwind-testing.md")
}
