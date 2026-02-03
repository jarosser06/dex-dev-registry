---
name: python-style
description: Expert in Python code style, PEP 8 standards, type hints, formatting with Ruff, and code quality best practices
---

# Python Style Expert

Expert in Python code style and formatting best practices. Specializes in PEP 8 compliance, type hints, Ruff formatting, import organization, and idiomatic Python patterns.

## Required Rules

**MUST** follow these absolute requirements defined in project rules:
- `.claude/rules/python/python-style.md` - PEP 8, type hints, naming conventions
- `.claude/rules/python/python-formatting.md` - Ruff formatting, import ordering
- `.claude/rules/python/python-testing.md` - Testing requirements and patterns

## When to Use This Skill

Use this skill for:
- Writing clean, idiomatic Python code
- Implementing type hints and annotations
- Formatting code with Ruff
- Organizing imports and module structure
- Following PEP 8 style guidelines
- Avoiding common Python anti-patterns

## Core Python Style Concepts

### PEP 8 Fundamentals

**MUST**: Follow PEP 8 style guide for all Python code
**MUST**: Use 4 spaces for indentation (never tabs)
**MUST**: Limit lines to 88 characters (Ruff default)

### Naming Conventions

```python
# Modules and packages
import my_module
from my_package.sub_module import MyClass

# Classes
class UserAccount:
    pass

# Functions and methods
def calculate_total():
    pass

# Constants
MAX_RETRIES = 3
DEFAULT_TIMEOUT = 30

# Variables
user_count = 0
is_active = True
```

## Type Hints - Critical Rules

**MUST**: Use type hints for all function signatures
**MUST**: Use modern type hint syntax (Python 3.9+)
**MUST NOT**: Use legacy typing module types when built-ins are available

### Modern Type Hints (Python 3.9+)

```python
# Built-in generics (preferred)
def process_items(items: list[str]) -> dict[str, int]:
    return {item: len(item) for item in items}

# Optional types
from typing import Optional

def get_user(user_id: int) -> Optional[User]:
    return users.get(user_id)

# Union types (Python 3.10+)
def parse_value(value: str | int | float) -> float:
    return float(value)

# Type aliases for complex types
UserID = int
UserData = dict[str, str | int]

def fetch_user(user_id: UserID) -> UserData:
    return {"name": "Alice", "age": 30}
```

### Common Type Patterns

```python
from typing import Any, Callable, TypeVar, Protocol
from collections.abc import Iterable, Sequence

# Generic type variables
T = TypeVar('T')

def first(items: Sequence[T]) -> T | None:
    return items[0] if items else None

# Callable types
HandlerFunc = Callable[[str], int]

def register_handler(handler: HandlerFunc) -> None:
    pass

# Protocol for structural typing
class Drawable(Protocol):
    def draw(self) -> None: ...

def render(obj: Drawable) -> None:
    obj.draw()
```

## Code Formatting with Ruff

**MUST**: Use Ruff for code formatting and linting
**MUST**: Format code before committing

Ruff combines formatting (like Black) with linting (like Flake8, isort) in a single fast tool.

### Basic Ruff Usage

Format code: `ruff format .`
Check linting: `ruff check .`
Fix auto-fixable issues: `ruff check --fix .`

### Configuration Example

Create `pyproject.toml`:

```toml
[tool.ruff]
line-length = 88
target-version = "py39"

[tool.ruff.lint]
select = ["E", "F", "I", "N", "W"]
ignore = []
```

## Import Organization

**MUST**: Organize imports in three groups:
1. Standard library imports
2. Third-party imports
3. Local application imports

**MUST**: Use Ruff to automatically sort imports

```python
# Standard library
import os
import sys
from datetime import datetime
from pathlib import Path

# Third-party
import numpy as np
import requests
from flask import Flask, jsonify

# Local
from myapp.models import User
from myapp.utils import calculate_total
```

## Docstring Standards

**MUST**: Include docstrings for all public modules, classes, and functions
**MUST**: Use consistent docstring style (Google, NumPy, or Sphinx)

### Google Style (Recommended)

```python
def calculate_distance(point1: tuple[float, float], point2: tuple[float, float]) -> float:
    """Calculate Euclidean distance between two points.

    Args:
        point1: First point as (x, y) coordinates
        point2: Second point as (x, y) coordinates

    Returns:
        The Euclidean distance between the points

    Raises:
        ValueError: If coordinates are invalid
    """
    x1, y1 = point1
    x2, y2 = point2
    return ((x2 - x1) ** 2 + (y2 - y1) ** 2) ** 0.5
```

## Common Anti-patterns to Avoid

### MUST NEVER

**Mutable default arguments:**
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

**Bare except clauses:**
```python
# ❌ WRONG: Catches everything including KeyboardInterrupt
try:
    risky_operation()
except:
    pass

# ✅ CORRECT: Catch specific exceptions
try:
    risky_operation()
except (ValueError, KeyError) as e:
    logger.error(f"Operation failed: {e}")
```

**Using type() for type checking:**
```python
# ❌ WRONG: Doesn't work with inheritance
if type(obj) == list:
    process_list(obj)

# ✅ CORRECT: Use isinstance
if isinstance(obj, list):
    process_list(obj)
```

**String concatenation in loops:**
```python
# ❌ WRONG: Inefficient
result = ""
for item in items:
    result += str(item) + ", "

# ✅ CORRECT: Use join
result = ", ".join(str(item) for item in items)
```

## Idiomatic Python Patterns

### Context Managers

**MUST**: Use context managers for resource management

```python
# File handling
with open("data.txt") as f:
    data = f.read()

# Custom context manager
from contextlib import contextmanager

@contextmanager
def timer(name: str):
    start = time.time()
    yield
    print(f"{name} took {time.time() - start:.2f}s")

with timer("operation"):
    perform_operation()
```

### List Comprehensions

**MUST**: Use comprehensions for simple transformations
**MUST NOT**: Use comprehensions for complex logic

```python
# ✅ CORRECT: Simple transformation
squares = [x**2 for x in range(10)]
even_nums = [x for x in numbers if x % 2 == 0]

# ❌ WRONG: Too complex
result = [
    complex_transform(x) if condition(x) else
    other_transform(x) if other_condition(x) else
    default_value
    for x in items
    if validate(x) and check(x)
]

# ✅ CORRECT: Use explicit loop for complex logic
result = []
for x in items:
    if not validate(x) or not check(x):
        continue
    if condition(x):
        result.append(complex_transform(x))
    elif other_condition(x):
        result.append(other_transform(x))
    else:
        result.append(default_value)
```

### Dictionary Operations

```python
# Get with default
value = my_dict.get(key, default_value)

# Dictionary comprehension
word_lengths = {word: len(word) for word in words}

# Merge dictionaries (Python 3.9+)
combined = dict1 | dict2

# Update with unpacking
new_dict = {**defaults, **overrides}
```

### Iteration Patterns

```python
# Enumerate for index and value
for i, item in enumerate(items):
    print(f"{i}: {item}")

# Zip for parallel iteration
for name, score in zip(names, scores):
    print(f"{name}: {score}")

# Reversed iteration
for item in reversed(items):
    process(item)
```

## Code Organization

### Module Structure

**MUST**: Organize modules in this order:
1. Module docstring
2. Imports
3. Constants
4. Classes
5. Functions
6. Main guard

```python
"""Module for user management operations."""

import logging
from typing import Optional

from myapp.models import User

logger = logging.getLogger(__name__)

MAX_LOGIN_ATTEMPTS = 3

class UserManager:
    """Manages user authentication and authorization."""
    pass

def validate_email(email: str) -> bool:
    """Validate email format."""
    pass

if __name__ == "__main__":
    # Module testing code
    pass
```

### Class Design

**MUST**: Use dataclasses for simple data containers
**MUST**: Implement `__repr__` for debugging
**MUST**: Use properties for computed attributes

```python
from dataclasses import dataclass

@dataclass
class Point:
    """Represents a 2D point."""
    x: float
    y: float

    @property
    def magnitude(self) -> float:
        """Calculate distance from origin."""
        return (self.x**2 + self.y**2) ** 0.5

# Traditional class with __init__
class User:
    def __init__(self, name: str, email: str):
        self.name = name
        self.email = email

    def __repr__(self) -> str:
        return f"User(name={self.name!r}, email={self.email!r})"
```

## Error Handling

**MUST**: Raise appropriate exception types
**MUST**: Include helpful error messages
**MUST NOT**: Use exceptions for control flow

```python
# ✅ CORRECT: Specific exceptions with context
def divide(a: float, b: float) -> float:
    if b == 0:
        raise ValueError(f"Cannot divide {a} by zero")
    return a / b

# Custom exceptions
class ValidationError(Exception):
    """Raised when data validation fails."""
    pass

def validate_age(age: int) -> None:
    if age < 0:
        raise ValidationError(f"Age cannot be negative: {age}")
```

## Performance Considerations

### When to Use Generators

**MUST**: Use generators for large datasets
**MUST**: Use generators when full list isn't needed

```python
# Generator expression (memory efficient)
total = sum(x**2 for x in range(1000000))

# Generator function
def read_large_file(filepath: str):
    with open(filepath) as f:
        for line in f:
            yield line.strip()
```

### Built-in Functions

**MUST**: Prefer built-in functions over manual loops

```python
# ✅ CORRECT: Use built-ins
total = sum(numbers)
maximum = max(values)
all_positive = all(x > 0 for x in numbers)

# ❌ WRONG: Manual loop when built-in exists
total = 0
for num in numbers:
    total += num
```

## Testing Considerations

**MUST**: Write testable code
**MUST**: Avoid global state
**MUST**: Use dependency injection

```python
# ✅ CORRECT: Testable with dependency injection
def process_data(data: list[str], validator: Callable[[str], bool]) -> list[str]:
    return [item for item in data if validator(item)]

# Can easily test with different validators
def test_process_data():
    data = ["a", "ab", "abc"]
    result = process_data(data, lambda x: len(x) > 1)
    assert result == ["ab", "abc"]
```

## Implementation Checklist

- [ ] Follow PEP 8 style guidelines
- [ ] Add type hints to all function signatures
- [ ] Use Ruff for formatting and linting
- [ ] Organize imports correctly (stdlib, third-party, local)
- [ ] Add docstrings to public functions/classes
- [ ] Avoid mutable default arguments
- [ ] Use context managers for resources
- [ ] Prefer comprehensions for simple transformations
- [ ] Use isinstance() instead of type()
- [ ] Implement `__repr__` for custom classes
- [ ] Raise specific exception types with helpful messages
- [ ] Use generators for large datasets
- [ ] Write testable code with dependency injection

## Resources

### In-Depth Guides

- **`resources/type-hints-guide.md`** - Comprehensive type hints reference
- **`resources/code-style-guide.md`** - PEP 8 and idiomatic Python patterns
- **`resources/formatting-tools.md`** - Ruff, Black, and isort comparison
- **`resources/common-issues.md`** - Common Python pitfalls and solutions

### Official Documentation

- [PEP 8 - Style Guide](https://peps.python.org/pep-0008/)
- [PEP 484 - Type Hints](https://peps.python.org/pep-0484/)
- [PEP 585 - Type Hinting Generics](https://peps.python.org/pep-0585/)
- [Python Data Model](https://docs.python.org/3/reference/datamodel.html)
- [Ruff Documentation](https://docs.astral.sh/ruff/)

## Remember

- **PEP 8 compliance** mandatory | **Type hints** for all functions | **Ruff formatting** before commits
- **4 spaces** for indentation | **88 characters** line length | No **mutable defaults**
- **Docstrings** for public APIs | **Context managers** for resources | Use **isinstance()** not type()
- **Idiomatic Python** over clever code | **Readability** counts | Simple is **better than complex**
