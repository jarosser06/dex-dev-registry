# Python Code Style Guide

Comprehensive guide to writing clean, idiomatic Python code following PEP 8 and modern best practices.

## PEP 8 Fundamentals

### Indentation and Whitespace

**4 spaces per indentation level** - Never use tabs.

```python
# ✅ CORRECT
def calculate_sum(numbers):
    total = 0
    for num in numbers:
        total += num
    return total

# ❌ WRONG: Using 2 spaces or tabs
def calculate_sum(numbers):
  total = 0
  for num in numbers:
    total += num
  return total
```

### Line Length

**88 characters maximum** (Ruff/Black default)
**79 characters for comments and docstrings** (PEP 8 recommendation)

Break long lines using implicit continuation inside parentheses, brackets, or braces.

```python
# ✅ CORRECT: Implicit line continuation
result = some_function(
    argument1,
    argument2,
    argument3,
    argument4,
)

# ✅ CORRECT: Long string
message = (
    "This is a very long message that needs to be "
    "split across multiple lines for readability."
)

# ❌ WRONG: Backslash continuation
result = some_function(argument1, argument2, \
                       argument3, argument4)
```

### Blank Lines

- **Two blank lines** between top-level functions and classes
- **One blank line** between methods within a class
- **One blank line** to separate logical sections within functions (sparingly)

```python
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

## Naming Conventions

### General Rules

| Type | Convention | Example |
|------|------------|---------|
| Module/Package | lowercase_with_underscores | `my_module.py` |
| Class | CapWords | `UserAccount` |
| Function/Method | lowercase_with_underscores | `calculate_total()` |
| Variable | lowercase_with_underscores | `user_count` |
| Constant | UPPERCASE_WITH_UNDERSCORES | `MAX_RETRIES` |
| Private | _leading_underscore | `_internal_method()` |
| Magic | __double_leading_trailing__ | `__init__()` |

### Specific Guidelines

**Module names:**
```python
# ✅ CORRECT
import user_manager
from data_processor import process_records

# ❌ WRONG
import UserManager
from DataProcessor import processRecords
```

**Class names:**
```python
# ✅ CORRECT
class UserAccount:
    pass

class HTTPServer:
    pass

# ❌ WRONG
class user_account:
    pass

class Http_Server:
    pass
```

**Function and method names:**
```python
# ✅ CORRECT
def calculate_total():
    pass

def get_user_by_id():
    pass

# ❌ WRONG
def calculateTotal():
    pass

def GetUserByID():
    pass
```

**Constants:**
```python
# ✅ CORRECT
MAX_CONNECTIONS = 100
DEFAULT_TIMEOUT = 30
API_KEY = "secret"

# ❌ WRONG
maxConnections = 100
default_timeout = 30
```

**Private attributes and methods:**
```python
class User:
    def __init__(self):
        self._internal_state = {}  # Single underscore: internal use
        self.__private_data = []   # Double underscore: name mangling

    def _internal_helper(self):
        pass

    def public_method(self):
        pass
```

## Imports

### Import Order

Group imports in three sections separated by blank lines:
1. Standard library imports
2. Third-party library imports
3. Local application imports

Within each section, imports should be alphabetically sorted.

```python
# Standard library
import os
import sys
from datetime import datetime
from pathlib import Path

# Third-party
import numpy as np
import pandas as pd
import requests
from flask import Flask, jsonify

# Local
from myapp.config import settings
from myapp.models import User, Post
from myapp.utils import validate_email
```

### Import Styles

**Prefer specific imports:**
```python
# ✅ CORRECT
from os.path import join, exists
from typing import Optional, List

# ❌ AVOID (unless standard convention)
import os.path
import typing
```

**Never use wildcard imports:**
```python
# ❌ WRONG
from module import *

# ✅ CORRECT
from module import function1, function2, Class1
```

**Use aliases sparingly and conventionally:**
```python
# ✅ CORRECT: Standard conventions
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

# ❌ WRONG: Non-standard aliases
import requests as r
import json as j
```

## Expressions and Statements

### Comparisons

**Use `is` for None comparisons:**
```python
# ✅ CORRECT
if value is None:
    pass

if value is not None:
    pass

# ❌ WRONG
if value == None:
    pass
```

**Use `isinstance()` for type checks:**
```python
# ✅ CORRECT
if isinstance(obj, str):
    pass

# ❌ WRONG
if type(obj) == str:
    pass
```

**Simplify boolean comparisons:**
```python
# ✅ CORRECT
if is_valid:
    pass

if not is_complete:
    pass

# ❌ WRONG
if is_valid == True:
    pass

if is_complete is False:
    pass
```

### Sequence Checks

**Check emptiness directly:**
```python
# ✅ CORRECT
if items:
    process(items)

if not items:
    return

# ❌ WRONG
if len(items) > 0:
    process(items)

if len(items) == 0:
    return
```

### Exception Handling

**Be specific with exceptions:**
```python
# ✅ CORRECT
try:
    value = int(user_input)
except ValueError as e:
    logger.error(f"Invalid input: {e}")

# ❌ WRONG
try:
    value = int(user_input)
except:
    pass
```

**Use multiple except clauses when needed:**
```python
try:
    response = requests.get(url)
    data = response.json()
except requests.RequestException as e:
    logger.error(f"Request failed: {e}")
except ValueError as e:
    logger.error(f"Invalid JSON: {e}")
```

## Idiomatic Python

### List Comprehensions

Use comprehensions for simple transformations:

```python
# ✅ CORRECT
squares = [x**2 for x in range(10)]
even_nums = [x for x in numbers if x % 2 == 0]
upper_names = [name.upper() for name in names]

# ❌ WRONG: Too complex for comprehension
result = [
    transform_a(x) if condition_a(x) else
    transform_b(x) if condition_b(x) else
    default
    for x in items
    if validate(x) and check(x) and verify(x)
]
```

### Dictionary Comprehensions

```python
# ✅ CORRECT
word_lengths = {word: len(word) for word in words}
inverted = {v: k for k, v in original.items()}
filtered = {k: v for k, v in data.items() if v > 0}
```

### Enumerate for Indexing

```python
# ✅ CORRECT
for i, item in enumerate(items):
    print(f"{i}: {item}")

# ❌ WRONG
for i in range(len(items)):
    print(f"{i}: {items[i]}")
```

### Zip for Parallel Iteration

```python
# ✅ CORRECT
for name, age in zip(names, ages):
    print(f"{name} is {age} years old")

# ❌ WRONG
for i in range(len(names)):
    print(f"{names[i]} is {ages[i]} years old")
```

### Context Managers

Always use context managers for resource management:

```python
# ✅ CORRECT
with open("file.txt") as f:
    data = f.read()

# ❌ WRONG
f = open("file.txt")
data = f.read()
f.close()
```

### String Formatting

Use f-strings for formatting (Python 3.6+):

```python
# ✅ CORRECT
message = f"Hello, {name}! You are {age} years old."
debug = f"Value: {value!r}"  # Use repr()
formatted = f"Price: ${price:.2f}"  # Format specifier

# ❌ AVOID in new code
message = "Hello, {}! You are {} years old.".format(name, age)
message = "Hello, %s! You are %d years old." % (name, age)
```

## Function Design

### Function Length

Keep functions focused and concise. If a function exceeds 20-30 lines, consider breaking it down.

### Default Arguments

**Never use mutable defaults:**

```python
# ❌ WRONG
def add_item(item, items=[]):
    items.append(item)
    return items

# ✅ CORRECT
def add_item(item, items=None):
    if items is None:
        items = []
    items.append(item)
    return items
```

### Keyword Arguments

Use keyword-only arguments for clarity:

```python
# ✅ CORRECT
def create_user(name, email, *, is_admin=False, is_active=True):
    pass

# Forces keyword usage
create_user("Alice", "alice@example.com", is_admin=True)

# ❌ WRONG (positional)
create_user("Alice", "alice@example.com", True, True)
```

### Return Values

Be consistent with return types:

```python
# ✅ CORRECT
def find_user(user_id: int) -> User | None:
    user = database.get(user_id)
    return user  # Returns User or None consistently

# ❌ WRONG: Inconsistent return types
def find_user(user_id):
    user = database.get(user_id)
    if user:
        return user
    return False  # Mixing None and False
```

## Class Design

### Use Dataclasses

For simple data containers:

```python
from dataclasses import dataclass

@dataclass
class Point:
    x: float
    y: float

    def distance_from_origin(self) -> float:
        return (self.x**2 + self.y**2) ** 0.5
```

### Implement Magic Methods

```python
class User:
    def __init__(self, name: str, age: int):
        self.name = name
        self.age = age

    def __repr__(self) -> str:
        return f"User(name={self.name!r}, age={self.age})"

    def __str__(self) -> str:
        return f"{self.name} ({self.age})"

    def __eq__(self, other) -> bool:
        if not isinstance(other, User):
            return NotImplemented
        return self.name == other.name and self.age == other.age
```

### Properties

Use properties for computed attributes:

```python
class Circle:
    def __init__(self, radius: float):
        self._radius = radius

    @property
    def radius(self) -> float:
        return self._radius

    @radius.setter
    def radius(self, value: float) -> None:
        if value < 0:
            raise ValueError("Radius cannot be negative")
        self._radius = value

    @property
    def area(self) -> float:
        return 3.14159 * self._radius ** 2
```

## Documentation

### Docstring Format

Use Google-style docstrings:

```python
def calculate_distance(point1: tuple[float, float],
                       point2: tuple[float, float]) -> float:
    """Calculate Euclidean distance between two points.

    Args:
        point1: First point as (x, y) coordinates
        point2: Second point as (x, y) coordinates

    Returns:
        The Euclidean distance between the points

    Raises:
        ValueError: If coordinates are invalid

    Examples:
        >>> calculate_distance((0, 0), (3, 4))
        5.0
    """
    x1, y1 = point1
    x2, y2 = point2
    return ((x2 - x1) ** 2 + (y2 - y1) ** 2) ** 0.5
```

### Comments

Write comments that explain *why*, not *what*:

```python
# ✅ CORRECT: Explains reasoning
# Use binary search because the list is sorted and contains millions of items
result = binary_search(sorted_list, target)

# ❌ WRONG: States the obvious
# Call binary_search with sorted_list and target
result = binary_search(sorted_list, target)
```

## Anti-patterns to Avoid

### String Building in Loops

```python
# ❌ WRONG
result = ""
for item in items:
    result += str(item) + ", "

# ✅ CORRECT
result = ", ".join(str(item) for item in items)
```

### Checking Types with type()

```python
# ❌ WRONG
if type(obj) == list:
    process_list(obj)

# ✅ CORRECT
if isinstance(obj, list):
    process_list(obj)
```

### Using Flags for Multiple Return Values

```python
# ❌ WRONG
success = process_data()
if success:
    print("Success")

# ✅ CORRECT
result = process_data()  # Returns Result object or raises exception
print(f"Processed {result.count} items")
```

## Code Organization Checklist

- [ ] Use 4 spaces for indentation
- [ ] Keep lines under 88 characters
- [ ] Follow proper import ordering
- [ ] Use descriptive variable names
- [ ] Write docstrings for public functions
- [ ] Use type hints for function signatures
- [ ] Avoid mutable default arguments
- [ ] Use context managers for resources
- [ ] Prefer comprehensions for simple transformations
- [ ] Use f-strings for string formatting
- [ ] Implement `__repr__` for custom classes
- [ ] Handle exceptions specifically
- [ ] Write idiomatic Python code

## Resources

- [PEP 8 - Style Guide for Python Code](https://peps.python.org/pep-0008/)
- [PEP 20 - The Zen of Python](https://peps.python.org/pep-0020/)
- [Google Python Style Guide](https://google.github.io/styleguide/pyguide.html)
- [Effective Python](https://effectivepython.com/)
