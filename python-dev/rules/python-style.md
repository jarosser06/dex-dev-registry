# Python Style Standards

## PEP 8 Compliance

**MUST**: Follow PEP 8 style guide for all Python code

**MUST**: Use 4 spaces for indentation (never tabs)

**MUST**: Limit lines to 88 characters (Ruff default)

## Type Hints

**MUST**: Include type hints for all function signatures

**MUST**: Use modern type hint syntax (Python 3.9+)

**Examples:**
```python
# ✅ CORRECT: Modern type hints
def process_items(items: list[str]) -> dict[str, int]:
    return {item: len(item) for item in items}

def get_user(user_id: int) -> User | None:
    return users.get(user_id)

# ❌ WRONG: Missing type hints
def process_items(items):
    return {item: len(item) for item in items}

# ❌ WRONG: Legacy typing syntax
from typing import List, Dict, Optional

def process_items(items: List[str]) -> Dict[str, int]:
    return {item: len(item) for item in items}
```

## Mutable Default Arguments

**MUST NOT**: Use mutable objects as default arguments

**MUST**: Use `None` as default and create new instance inside function

**Examples:**
```python
# ❌ WRONG: Mutable default
def add_item(item: str, items: list[str] = []) -> list[str]:
    items.append(item)
    return items

# ✅ CORRECT: None default with initialization
def add_item(item: str, items: list[str] | None = None) -> list[str]:
    if items is None:
        items = []
    items.append(item)
    return items
```

## Type Checking

**MUST**: Use `isinstance()` for type checks

**MUST NOT**: Use `type()` for type checking

**Examples:**
```python
# ✅ CORRECT: isinstance works with inheritance
if isinstance(obj, list):
    process_list(obj)

# ❌ WRONG: type() doesn't work with inheritance
if type(obj) == list:
    process_list(obj)
```

## Comparison Operations

**MUST**: Use `is` for `None` comparisons

**MUST**: Simplify boolean comparisons

**Examples:**
```python
# ✅ CORRECT
if value is None:
    pass

if is_valid:
    pass

if not is_complete:
    pass

# ❌ WRONG
if value == None:
    pass

if is_valid == True:
    pass

if is_complete is False:
    pass
```

## Exception Handling

**MUST**: Catch specific exception types

**MUST NOT**: Use bare `except` clauses

**Examples:**
```python
# ✅ CORRECT: Specific exceptions
try:
    value = int(user_input)
except ValueError as e:
    logger.error(f"Invalid input: {e}")

# ❌ WRONG: Bare except catches everything
try:
    value = int(user_input)
except:
    pass
```

## Import Organization

**MUST**: Organize imports in three sections:
1. Standard library imports
2. Third-party imports
3. Local application imports

**MUST**: Use Ruff or isort for automatic import sorting

**Examples:**
```python
# ✅ CORRECT: Properly organized
# Standard library
import os
import sys
from datetime import datetime

# Third-party
import numpy as np
import requests

# Local
from myapp.models import User
from myapp.utils import helper

# ❌ WRONG: Mixed imports
from myapp.models import User
import os
import requests
from datetime import datetime
```

## Naming Conventions

**MUST**: Follow these naming conventions:
- Modules/packages: `lowercase_with_underscores`
- Classes: `CapWords`
- Functions/methods: `lowercase_with_underscores`
- Constants: `UPPERCASE_WITH_UNDERSCORES`
- Private: `_leading_underscore`

**Examples:**
```python
# ✅ CORRECT
class UserAccount:
    MAX_LOGIN_ATTEMPTS = 3

    def __init__(self, name: str):
        self.name = name
        self._password_hash = None

    def calculate_total(self) -> float:
        pass

# ❌ WRONG
class user_account:  # Should be CapWords
    maxLoginAttempts = 3  # Should be UPPERCASE

    def CalculateTotal(self):  # Should be lowercase_with_underscores
        pass
```

## Docstrings

**MUST**: Include docstrings for all public modules, classes, and functions

**MUST**: Use consistent docstring style (Google, NumPy, or Sphinx)

**Examples:**
```python
# ✅ CORRECT
def calculate_distance(point1: tuple[float, float],
                       point2: tuple[float, float]) -> float:
    """Calculate Euclidean distance between two points.

    Args:
        point1: First point as (x, y) coordinates
        point2: Second point as (x, y) coordinates

    Returns:
        The Euclidean distance between the points
    """
    x1, y1 = point1
    x2, y2 = point2
    return ((x2 - x1) ** 2 + (y2 - y1) ** 2) ** 0.5

# ❌ WRONG: Missing docstring
def calculate_distance(point1, point2):
    x1, y1 = point1
    x2, y2 = point2
    return ((x2 - x1) ** 2 + (y2 - y1) ** 2) ** 0.5
```

## Code Organization

**MUST**: Organize module content in this order:
1. Module docstring
2. Imports
3. Constants
4. Classes
5. Functions
6. Main guard (`if __name__ == "__main__"`)

## Context Managers

**MUST**: Use context managers for resource management

**Examples:**
```python
# ✅ CORRECT: Context manager
with open("data.txt") as f:
    data = f.read()

# ❌ WRONG: Manual close
f = open("data.txt")
data = f.read()
f.close()
```

## String Formatting

**MUST**: Use f-strings for string formatting (Python 3.6+)

**Examples:**
```python
# ✅ CORRECT
name = "Alice"
age = 30
message = f"Hello, {name}! You are {age} years old."

# ❌ AVOID in new code
message = "Hello, {}! You are {} years old.".format(name, age)
message = "Hello, %s! You are %d years old." % (name, age)
```
