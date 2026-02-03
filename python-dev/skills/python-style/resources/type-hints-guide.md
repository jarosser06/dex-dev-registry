# Python Type Hints Guide

Comprehensive guide to Python type hints, covering modern syntax, common patterns, and best practices.

## Modern Type Hint Syntax (Python 3.9+)

### Built-in Generic Types

Python 3.9+ allows using built-in types directly as generics without importing from `typing`.

**Use built-in types:**
- `list[T]` instead of `List[T]`
- `dict[K, V]` instead of `Dict[K, V]`
- `set[T]` instead of `Set[T]`
- `tuple[T, ...]` instead of `Tuple[T, ...]`

**Examples:**
```python
# Modern syntax (Python 3.9+)
def process_names(names: list[str]) -> dict[str, int]:
    return {name: len(name) for name in names}

# Legacy syntax (avoid in new code)
from typing import List, Dict

def process_names(names: List[str]) -> Dict[str, int]:
    return {name: len(name) for name in names}
```

### Union Types (Python 3.10+)

Python 3.10 introduced the pipe operator `|` for union types.

```python
# Modern syntax (Python 3.10+)
def process_value(value: str | int | None) -> str:
    if value is None:
        return "empty"
    return str(value)

# Legacy syntax
from typing import Union, Optional

def process_value(value: Union[str, int, None]) -> str:
    if value is None:
        return "empty"
    return str(value)
```

## Common Type Patterns

### Optional Types

Use `Optional[T]` or `T | None` for values that can be None.

```python
from typing import Optional

# Using Optional
def find_user(user_id: int) -> Optional[User]:
    return users.get(user_id)

# Using union (Python 3.10+)
def find_user(user_id: int) -> User | None:
    return users.get(user_id)
```

### Callable Types

Type hints for functions and callbacks.

```python
from typing import Callable

# Simple callable
Handler = Callable[[str], int]

def register(handler: Handler) -> None:
    pass

# Multiple arguments
Parser = Callable[[str, int, bool], dict[str, Any]]

# No return value
Validator = Callable[[str], None]
```

### Type Aliases

Create readable names for complex types.

```python
# Simple alias
UserID = int
Username = str

# Complex alias
JSONValue = str | int | float | bool | None | dict[str, "JSONValue"] | list["JSONValue"]
Headers = dict[str, str]
QueryParams = dict[str, str | list[str]]

def fetch_data(
    url: str,
    headers: Headers,
    params: QueryParams
) -> JSONValue:
    pass
```

### Generic Types

Create reusable generic functions and classes.

```python
from typing import TypeVar, Generic

T = TypeVar('T')

def first(items: list[T]) -> T | None:
    return items[0] if items else None

# Generic class
class Stack(Generic[T]):
    def __init__(self) -> None:
        self._items: list[T] = []

    def push(self, item: T) -> None:
        self._items.append(item)

    def pop(self) -> T | None:
        return self._items.pop() if self._items else None
```

### Protocol Types

Structural subtyping (duck typing) with type safety.

```python
from typing import Protocol

class Drawable(Protocol):
    def draw(self) -> None: ...

class Closeable(Protocol):
    def close(self) -> None: ...

def render_shape(shape: Drawable) -> None:
    shape.draw()

# Any object with draw() method can be passed
class Circle:
    def draw(self) -> None:
        print("Drawing circle")

render_shape(Circle())  # ✅ Type checks
```

### Literal Types

Restrict values to specific literals.

```python
from typing import Literal

Mode = Literal["read", "write", "append"]

def open_file(path: str, mode: Mode) -> None:
    pass

open_file("data.txt", "read")  # ✅ OK
open_file("data.txt", "delete")  # ❌ Type error
```

## Advanced Type Hints

### TypedDict

Type-safe dictionaries with specific keys.

```python
from typing import TypedDict

class UserDict(TypedDict):
    name: str
    age: int
    email: str

def create_user(data: UserDict) -> User:
    return User(**data)

# Required and optional keys
class ConfigDict(TypedDict, total=False):
    host: str  # Required
    port: int  # Required
    timeout: int  # Optional
```

### Sequence and Iterable

Use abstract types for flexibility.

```python
from collections.abc import Sequence, Iterable, Mapping

# Accepts list, tuple, etc.
def sum_values(values: Sequence[int]) -> int:
    return sum(values)

# Accepts any iterable
def process_items(items: Iterable[str]) -> list[str]:
    return [item.upper() for item in items]

# Accepts dict-like objects
def print_config(config: Mapping[str, str]) -> None:
    for key, value in config.items():
        print(f"{key}: {value}")
```

### ParamSpec and Concatenate

Advanced function signature typing.

```python
from typing import ParamSpec, Concatenate, Callable

P = ParamSpec('P')
R = TypeVar('R')

def log_calls(func: Callable[P, R]) -> Callable[P, R]:
    def wrapper(*args: P.args, **kwargs: P.kwargs) -> R:
        print(f"Calling {func.__name__}")
        return func(*args, **kwargs)
    return wrapper

@log_calls
def add(a: int, b: int) -> int:
    return a + b
```

### Self Type (Python 3.11+)

Type hint for methods returning instance of own class.

```python
from typing import Self

class Builder:
    def set_name(self, name: str) -> Self:
        self.name = name
        return self

    def set_age(self, age: int) -> Self:
        self.age = age
        return self

    def build(self) -> dict[str, Any]:
        return {"name": self.name, "age": self.age}

# Enables chaining with proper types
builder = Builder().set_name("Alice").set_age(30)
```

## Type Checking Tools

### MyPy

Industry-standard static type checker.

**Installation:**
```bash
pip install mypy
```

**Usage:**
```bash
mypy myapp/
mypy --strict myfile.py
```

**Configuration (mypy.ini or pyproject.toml):**
```ini
[mypy]
python_version = 3.9
warn_return_any = True
warn_unused_configs = True
disallow_untyped_defs = True
```

### Pyright

Fast type checker from Microsoft.

**Installation:**
```bash
npm install -g pyright
```

**Usage:**
```bash
pyright
pyright --strict
```

### Ruff

Modern linter with type checking support.

```bash
ruff check --select=ANN  # Check missing type annotations
```

## Best Practices

### When to Use Type Hints

**Always use type hints for:**
- Public API functions and methods
- Function parameters and return values
- Class attributes
- Complex data structures

**Optional for:**
- Simple local variables with obvious types
- Private implementation details
- Scripts and prototypes

### Type Hint Style

**DO:**
```python
# Clear, explicit types
def calculate_total(prices: list[float], tax_rate: float) -> float:
    subtotal = sum(prices)
    return subtotal * (1 + tax_rate)

# Type aliases for readability
Price = float
TaxRate = float

def calculate_total(prices: list[Price], tax_rate: TaxRate) -> Price:
    subtotal = sum(prices)
    return subtotal * (1 + tax_rate)
```

**DON'T:**
```python
# Overly complex inline types
def process(data: dict[str, list[tuple[int, str, dict[str, Any]]]]) -> None:
    pass

# Better: use type alias
DataItem = tuple[int, str, dict[str, Any]]
DataDict = dict[str, list[DataItem]]

def process(data: DataDict) -> None:
    pass
```

### Gradual Typing

Start adding types gradually to existing codebases.

**Priority order:**
1. Public API functions
2. Functions with complex signatures
3. Data processing pipelines
4. Internal utilities
5. Simple getters/setters

### Type Stubs

Use stub files (.pyi) for third-party libraries without types.

```python
# mylib.pyi (stub file)
def process_data(data: list[str]) -> dict[str, int]: ...

class DataProcessor:
    def __init__(self, config: dict[str, Any]) -> None: ...
    def process(self, data: bytes) -> str: ...
```

## Common Pitfalls

### Circular Imports

Use string annotations for forward references.

```python
from __future__ import annotations
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from myapp.models import User

class UserManager:
    def get_user(self, user_id: int) -> User:  # ✅ Works due to annotations
        pass
```

### Mutable Default Arguments

Never use mutable defaults, always use None.

```python
# ❌ WRONG
def append_item(item: str, items: list[str] = []) -> list[str]:
    items.append(item)
    return items

# ✅ CORRECT
def append_item(item: str, items: list[str] | None = None) -> list[str]:
    if items is None:
        items = []
    items.append(item)
    return items
```

### Any Type

Avoid `Any` when possible - it defeats the purpose of type hints.

```python
from typing import Any

# ❌ WRONG: Too permissive
def process(data: Any) -> Any:
    return data

# ✅ CORRECT: Be specific
def process(data: dict[str, str]) -> list[str]:
    return list(data.values())

# ✅ ACCEPTABLE: When truly dynamic
def dynamic_handler(data: Any) -> None:
    # Handling truly dynamic external data
    pass
```

## Type Narrowing

Python type checkers understand type narrowing through conditionals.

```python
def process_value(value: str | int | None) -> str:
    if value is None:
        return "empty"  # Type narrowed to None

    if isinstance(value, str):
        return value.upper()  # Type narrowed to str

    return str(value)  # Type narrowed to int
```

## Resources

- [PEP 484 - Type Hints](https://peps.python.org/pep-0484/)
- [PEP 585 - Type Hinting Generics](https://peps.python.org/pep-0585/)
- [PEP 604 - Union Types](https://peps.python.org/pep-0604/)
- [MyPy Documentation](https://mypy.readthedocs.io/)
- [Typing Module Reference](https://docs.python.org/3/library/typing.html)
