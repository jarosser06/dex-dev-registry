# Python Formatting Standards

## Code Formatter

**MUST**: Use Ruff for code formatting and linting

**MUST**: Format code before committing

**Examples:**
```bash
# Format code
ruff format .

# Check linting
ruff check .

# Fix auto-fixable issues
ruff check --fix .
```

## Line Length

**MUST**: Keep lines under 88 characters (Ruff default)

**MUST**: Use implicit line continuation for long lines

**Examples:**
```python
# ✅ CORRECT: Implicit continuation
result = some_function(
    argument1,
    argument2,
    argument3,
    argument4,
)

# ✅ CORRECT: Long strings
message = (
    "This is a very long message that needs to be "
    "split across multiple lines for readability."
)

# ❌ WRONG: Line too long
result = some_function(argument1, argument2, argument3, argument4, argument5, argument6)

# ❌ WRONG: Backslash continuation
result = some_function(argument1, argument2, \
                       argument3, argument4)
```

## Indentation

**MUST**: Use 4 spaces for indentation

**MUST NOT**: Use tabs for indentation

**MUST NOT**: Mix spaces and tabs

## Import Formatting

**MUST**: Use Ruff to sort imports automatically

**MUST**: Group imports into three sections:
1. Standard library
2. Third-party
3. Local application

**MUST**: Separate import groups with blank lines

**Examples:**
```python
# ✅ CORRECT: Properly formatted imports
import os
import sys
from datetime import datetime

import numpy as np
import requests

from myapp.models import User
from myapp.utils import helper

# ❌ WRONG: Not grouped or sorted
from myapp.models import User
import requests
import os
from datetime import datetime
```

## Blank Lines

**MUST**: Use two blank lines between top-level functions and classes

**MUST**: Use one blank line between methods within a class

**Examples:**
```python
# ✅ CORRECT
def function_one():
    pass


def function_two():
    pass


class MyClass:
    def method_one(self):
        pass

    def method_two(self):
        pass


# ❌ WRONG
def function_one():
    pass
def function_two():
    pass

class MyClass:
    def method_one(self):
        pass
    def method_two(self):
        pass
```

## Quotes

**MUST**: Use double quotes for strings (Ruff default)

**MUST**: Be consistent with quote style throughout the project

**Examples:**
```python
# ✅ CORRECT: Double quotes
message = "Hello, world!"
name = "Alice"

# ❌ INCONSISTENT: Mixing styles without reason
message = 'Hello, world!'
name = "Alice"
```

## Trailing Commas

**MUST**: Use trailing commas in multi-line structures

**Reason**: Makes diffs cleaner and prevents syntax errors

**Examples:**
```python
# ✅ CORRECT: Trailing comma
items = [
    "first",
    "second",
    "third",
]

config = {
    "host": "localhost",
    "port": 8000,
    "debug": True,
}

# ❌ WRONG: Missing trailing comma
items = [
    "first",
    "second",
    "third"
]
```

## Whitespace

**MUST**: Follow PEP 8 whitespace rules

**MUST**: Use spaces around operators

**MUST NOT**: Use spaces inside brackets, parentheses, or braces

**Examples:**
```python
# ✅ CORRECT
x = 1 + 2
result = function(arg1, arg2)
my_list = [1, 2, 3]
my_dict = {"key": "value"}

# ❌ WRONG
x=1+2
result = function( arg1 , arg2 )
my_list = [ 1, 2, 3 ]
my_dict = { "key": "value" }
```

## Function and Method Calls

**MUST**: Use consistent formatting for function calls

**MUST**: Break long argument lists across multiple lines

**Examples:**
```python
# ✅ CORRECT: Short call on one line
result = function(arg1, arg2, arg3)

# ✅ CORRECT: Long call broken across lines
result = function_with_long_name(
    argument1,
    argument2,
    argument3,
    keyword_arg=value,
)

# ❌ WRONG: Inconsistent formatting
result = function(arg1, arg2,
    arg3, arg4)
```

## List and Dictionary Formatting

**MUST**: Use consistent formatting for collections

**Examples:**
```python
# ✅ CORRECT: Short collections inline
numbers = [1, 2, 3, 4, 5]
config = {"debug": True, "port": 8000}

# ✅ CORRECT: Long collections multi-line
numbers = [
    1, 2, 3, 4, 5,
    6, 7, 8, 9, 10,
]

config = {
    "database_url": "postgresql://localhost/mydb",
    "cache_timeout": 300,
    "debug": True,
    "port": 8000,
}

# ❌ WRONG: Inconsistent formatting
numbers = [1, 2, 3, 4, 5,
    6, 7, 8]
```

## Ruff Configuration

**MUST**: Configure Ruff in `pyproject.toml`

**Example configuration:**
```toml
[tool.ruff]
line-length = 88
target-version = "py39"

[tool.ruff.lint]
select = [
    "E",   # pycodestyle errors
    "F",   # pyflakes
    "I",   # isort
    "N",   # pep8-naming
    "W",   # pycodestyle warnings
]

ignore = [
    "E501",  # line-too-long (handled by formatter)
]

[tool.ruff.format]
quote-style = "double"
indent-style = "space"
```

## Pre-commit Hook

**MUST**: Run Ruff before committing code

**Recommended**: Set up pre-commit hook

**Example `.pre-commit-config.yaml`:**
```yaml
repos:
  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: v0.1.6
    hooks:
      - id: ruff
        args: [--fix, --exit-non-zero-on-fix]
      - id: ruff-format
```

## CI/CD Integration

**MUST**: Run Ruff checks in CI/CD pipeline

**Example GitHub Actions:**
```yaml
- name: Check formatting
  run: ruff format --check .

- name: Lint
  run: ruff check .
```
