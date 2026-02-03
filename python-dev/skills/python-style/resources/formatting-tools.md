# Python Formatting Tools Guide

Comprehensive comparison of Python formatting and linting tools: Ruff, Black, isort, Flake8, and Pylint.

## Ruff (Recommended)

**Modern, fast, all-in-one linter and formatter written in Rust.**

### Why Ruff?

- **Extremely fast**: 10-100x faster than other tools
- **All-in-one**: Replaces Black, isort, Flake8, and more
- **Compatible**: Drop-in replacement for existing tools
- **Actively maintained**: Modern tool with regular updates

### Installation

```bash
pip install ruff
```

### Basic Usage

```bash
# Format code (like Black)
ruff format .
ruff format myfile.py

# Check for linting issues
ruff check .
ruff check myfile.py

# Auto-fix issues
ruff check --fix .

# Show what would be fixed without changing files
ruff check --fix --diff .
```

### Configuration

Create `pyproject.toml` or `ruff.toml`:

```toml
[tool.ruff]
# Line length (default: 88)
line-length = 88

# Python version
target-version = "py39"

# Exclude directories
exclude = [
    ".git",
    ".venv",
    "__pycache__",
    "build",
    "dist",
]

[tool.ruff.lint]
# Enable specific rule sets
select = [
    "E",   # pycodestyle errors
    "F",   # pyflakes
    "I",   # isort
    "N",   # pep8-naming
    "W",   # pycodestyle warnings
    "UP",  # pyupgrade
    "B",   # flake8-bugbear
    "C4",  # flake8-comprehensions
    "SIM", # flake8-simplify
]

# Ignore specific rules
ignore = [
    "E501",  # line too long (handled by formatter)
]

# Allow fix for all enabled rules
fixable = ["ALL"]
unfixable = []

[tool.ruff.lint.per-file-ignores]
# Ignore specific rules in test files
"tests/**/*.py" = ["S101"]  # Allow assert in tests

[tool.ruff.format]
# Use double quotes for strings
quote-style = "double"

# Indent with spaces
indent-style = "space"
```

### Common Ruff Commands

```bash
# Check and format in one go
ruff check --fix . && ruff format .

# Watch mode (requires ruff 0.1.0+)
ruff check --watch .

# Show all available rules
ruff rule --all

# Explain a specific rule
ruff rule E501

# Generate configuration
ruff check --select ALL --ignore E501,E502 --config pyproject.toml
```

### Integration with Pre-commit

```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: v0.1.6
    hooks:
      - id: ruff
        args: [--fix, --exit-non-zero-on-fix]
      - id: ruff-format
```

## Black

**Opinionated code formatter - "The Uncompromising Code Formatter".**

### When to Use Black

- **Established projects** already using Black
- **Team preference** for Black's specific style
- **Note**: Ruff format is compatible with Black

### Installation

```bash
pip install black
```

### Basic Usage

```bash
# Format files
black .
black myfile.py

# Check without modifying
black --check .

# Show diff of changes
black --diff .
```

### Configuration

```toml
[tool.black]
line-length = 88
target-version = ['py39']
include = '\.pyi?$'
exclude = '''
/(
    \.git
  | \.venv
  | build
  | dist
)/
'''
```

## isort

**Import statement sorter and formatter.**

### When to Use isort

- **Standalone use** when not using Ruff
- **Note**: Ruff includes isort functionality via `I` rules

### Installation

```bash
pip install isort
```

### Basic Usage

```bash
# Sort imports
isort .
isort myfile.py

# Check without modifying
isort --check-only .

# Show diff
isort --diff .
```

### Configuration

```toml
[tool.isort]
profile = "black"  # Compatible with Black
line_length = 88
multi_line_output = 3
include_trailing_comma = true
force_grid_wrap = 0
use_parentheses = true
ensure_newline_before_comments = true
```

### Import Organization

isort organizes imports into sections:

1. Future imports
2. Standard library
3. Third-party libraries
4. First-party (local)
5. Local folder imports

```python
# After isort
from __future__ import annotations

import os
import sys
from datetime import datetime

import numpy as np
import requests

from myapp.models import User
from myapp.utils import helper

from .local_module import function
```

## Flake8

**Style guide enforcement tool (linter).**

### When to Use Flake8

- **Established projects** already using Flake8
- **Note**: Ruff replaces Flake8 functionality

### Installation

```bash
pip install flake8
```

### Basic Usage

```bash
# Check code
flake8 .
flake8 myfile.py

# With specific rules
flake8 --select=E,W,F .

# Ignore specific rules
flake8 --ignore=E501,W503 .
```

### Configuration

```ini
# .flake8 or setup.cfg
[flake8]
max-line-length = 88
extend-ignore = E203, W503
exclude =
    .git,
    __pycache__,
    .venv,
    build,
    dist
```

### Popular Flake8 Plugins

```bash
# Install useful plugins
pip install flake8-bugbear      # Additional bug checks
pip install flake8-comprehensions  # Comprehension improvements
pip install flake8-docstrings   # Docstring checks
pip install flake8-simplify     # Code simplification suggestions
```

## Pylint

**Comprehensive static analysis tool.**

### When to Use Pylint

- **Deep analysis** needed beyond formatting
- **Code quality metrics** required
- **Note**: More opinionated and slower than Ruff

### Installation

```bash
pip install pylint
```

### Basic Usage

```bash
# Analyze code
pylint mymodule
pylint myfile.py

# Generate config file
pylint --generate-rcfile > .pylintrc

# Disable specific checks
pylint --disable=C0111,R0903 myfile.py
```

### Configuration

```ini
# .pylintrc
[MASTER]
ignore=CVS,.git,__pycache__,.venv

[MESSAGES CONTROL]
disable=
    C0111,  # missing-docstring
    R0903,  # too-few-public-methods

[FORMAT]
max-line-length=88

[BASIC]
good-names=i,j,k,x,y,_
```

## Tool Comparison Matrix

| Feature | Ruff | Black | isort | Flake8 | Pylint |
|---------|------|-------|-------|--------|--------|
| **Formatting** | ✅ | ✅ | ❌ | ❌ | ❌ |
| **Import Sorting** | ✅ | ❌ | ✅ | ❌ | ❌ |
| **Linting** | ✅ | ❌ | ❌ | ✅ | ✅ |
| **Speed** | ⚡ Very Fast | 🚀 Fast | 🚀 Fast | 🐢 Medium | 🐌 Slow |
| **Auto-fix** | ✅ | ✅ | ✅ | ❌ | Limited |
| **Type Checking** | ❌ | ❌ | ❌ | ❌ | ❌ |
| **Configuration** | Simple | Simple | Medium | Medium | Complex |

## Recommended Tool Combinations

### Modern Stack (Recommended)

```bash
# Install Ruff only
pip install ruff

# Format and lint
ruff check --fix . && ruff format .
```

**Advantages:**
- Single tool to maintain
- Extremely fast
- Comprehensive rule coverage
- Active development

### Traditional Stack

```bash
# Install multiple tools
pip install black isort flake8

# Run all tools
isort .
black .
flake8 .
```

**Advantages:**
- Mature, stable tools
- Large community
- Extensive plugin ecosystem

### Comprehensive Stack

```bash
pip install ruff mypy

# Linting and formatting
ruff check --fix . && ruff format .

# Type checking
mypy .
```

**Advantages:**
- Fast linting/formatting with Ruff
- Static type checking with MyPy
- Best of both worlds

## Editor Integration

### VS Code

```json
{
  "python.formatting.provider": "none",
  "[python]": {
    "editor.formatOnSave": true,
    "editor.codeActionsOnSave": {
      "source.fixAll": true,
      "source.organizeImports": true
    },
    "editor.defaultFormatter": "charliermarsh.ruff"
  },
  "ruff.lint.run": "onSave"
}
```

### PyCharm

1. Install Ruff plugin from marketplace
2. Settings → Tools → Ruff
3. Enable "Run ruff on save"

### Vim/Neovim

```vim
" Using ALE
let g:ale_linters = {'python': ['ruff']}
let g:ale_fixers = {'python': ['ruff']}
let g:ale_fix_on_save = 1

" Using null-ls (Neovim)
local null_ls = require("null-ls")
null_ls.setup({
  sources = {
    null_ls.builtins.formatting.ruff,
    null_ls.builtins.diagnostics.ruff,
  },
})
```

## CI/CD Integration

### GitHub Actions

```yaml
name: Lint and Format

on: [push, pull_request]

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-python@v4
        with:
          python-version: "3.9"
      - name: Install Ruff
        run: pip install ruff
      - name: Check formatting
        run: ruff format --check .
      - name: Lint
        run: ruff check .
```

### Pre-commit Hook

```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: v0.1.6
    hooks:
      - id: ruff
        args: [--fix, --exit-non-zero-on-fix]
      - id: ruff-format
```

Install and run:
```bash
pip install pre-commit
pre-commit install
pre-commit run --all-files
```

## Migration Guide

### From Black + isort + Flake8 to Ruff

**1. Install Ruff:**
```bash
pip install ruff
pip uninstall black isort flake8  # Optional
```

**2. Create configuration:**
```toml
[tool.ruff]
line-length = 88
target-version = "py39"

[tool.ruff.lint]
select = ["E", "F", "I", "N", "W"]
```

**3. Update pre-commit:**
```yaml
- repo: https://github.com/astral-sh/ruff-pre-commit
  rev: v0.1.6
  hooks:
    - id: ruff
      args: [--fix]
    - id: ruff-format
```

**4. Update CI/CD:**
Replace Black/isort/Flake8 commands with:
```bash
ruff check --fix . && ruff format .
```

### From Pylint to Ruff

Ruff doesn't replace all Pylint functionality, but covers most common cases:

```toml
[tool.ruff.lint]
select = [
    "E",   # pycodestyle errors
    "F",   # pyflakes
    "C90", # mccabe complexity
    "N",   # pep8-naming
    "B",   # flake8-bugbear
    "PL",  # pylint
]
```

## Best Practices

### Format Before Committing

Always format code before committing:

```bash
# Manual
ruff check --fix . && ruff format .
git add .
git commit -m "Your message"

# Automated with pre-commit hook
git commit -m "Your message"  # Runs formatting automatically
```

### Consistent Configuration

Keep configuration in `pyproject.toml` for consistency:

```toml
[tool.ruff]
line-length = 88
target-version = "py39"

[tool.ruff.lint]
select = ["E", "F", "I"]

[tool.mypy]
python_version = "3.9"
strict = true
```

### Team Agreement

Establish team conventions:
- Which tool to use (Ruff recommended)
- Line length (88 is standard)
- Which rules to enable/disable
- Pre-commit hook requirements

## Troubleshooting

### Ruff vs Black Formatting Differences

Ruff format aims for Black compatibility but may have minor differences:

```bash
# Compare outputs
black --diff . > black.diff
ruff format --diff . > ruff.diff
diff black.diff ruff.diff
```

### Conflicting Rules

Some linting rules may conflict with formatters:

```toml
[tool.ruff.lint]
# Ignore rules that conflict with formatter
ignore = [
    "E501",  # line-too-long (formatter handles this)
    "W191",  # tab-indentation (formatter handles this)
]
```

### Performance Issues

For large codebases:

```bash
# Process files in parallel (default)
ruff check .

# Cache results for faster subsequent runs
ruff check --cache-dir .ruff_cache .
```

## Resources

- [Ruff Documentation](https://docs.astral.sh/ruff/)
- [Black Documentation](https://black.readthedocs.io/)
- [isort Documentation](https://pycqa.github.io/isort/)
- [Flake8 Documentation](https://flake8.pycqa.org/)
- [Pylint Documentation](https://pylint.readthedocs.io/)
- [PEP 8 Style Guide](https://peps.python.org/pep-0008/)
