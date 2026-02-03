# Common Python Issues and Solutions

Guide to common Python pitfalls, anti-patterns, and their solutions.

## Mutable Default Arguments

### The Problem

Default argument values are created once when the function is defined, not each time it's called.

```python
# ❌ DANGEROUS
def append_to_list(item, my_list=[]):
    my_list.append(item)
    return my_list

# Unexpected behavior!
print(append_to_list(1))  # [1]
print(append_to_list(2))  # [1, 2] - same list!
print(append_to_list(3))  # [1, 2, 3] - still same list!
```

### The Solution

Use `None` as default and create new instance inside function:

```python
# ✅ CORRECT
def append_to_list(item, my_list=None):
    if my_list is None:
        my_list = []
    my_list.append(item)
    return my_list

print(append_to_list(1))  # [1]
print(append_to_list(2))  # [2] - new list!
print(append_to_list(3))  # [3] - new list!
```

### Affected Types

This affects all mutable defaults:
- Lists: `[]`
- Dictionaries: `{}`
- Sets: `set()`
- Class instances
- Any mutable object

```python
# ❌ ALL WRONG
def bad_dict(key, value, data={}):
    data[key] = value
    return data

def bad_set(item, items=set()):
    items.add(item)
    return items

def bad_class(name, obj=SomeClass()):
    obj.name = name
    return obj

# ✅ ALL CORRECT
def good_dict(key, value, data=None):
    if data is None:
        data = {}
    data[key] = value
    return data

def good_set(item, items=None):
    if items is None:
        items = set()
    items.add(item)
    return items

def good_class(name, obj=None):
    if obj is None:
        obj = SomeClass()
    obj.name = name
    return obj
```

## Late Binding Closures

### The Problem

Loop variables in closures are evaluated when the closure is called, not when defined.

```python
# ❌ WRONG
functions = []
for i in range(5):
    functions.append(lambda: i)

# All functions return 4!
for func in functions:
    print(func())  # 4, 4, 4, 4, 4
```

### The Solution

Use default argument to capture current value:

```python
# ✅ CORRECT
functions = []
for i in range(5):
    functions.append(lambda x=i: x)

for func in functions:
    print(func())  # 0, 1, 2, 3, 4
```

Or use functools.partial:

```python
from functools import partial

def print_value(x):
    return x

functions = [partial(print_value, i) for i in range(5)]
for func in functions:
    print(func())  # 0, 1, 2, 3, 4
```

## Name Clashing with Built-ins

### The Problem

Shadowing built-in names causes unexpected behavior:

```python
# ❌ WRONG
list = [1, 2, 3]  # Shadows built-in list!
my_list = list(range(10))  # TypeError: 'list' object is not callable
```

### The Solution

Never use built-in names as variables:

```python
# ✅ CORRECT
items = [1, 2, 3]
my_list = list(range(10))
```

### Common Built-ins to Avoid

```python
# Never use these as variable names:
# list, dict, set, tuple, str, int, float, bool
# min, max, sum, len, range, input, open, type
# id, filter, map, zip, all, any, print
# object, property, staticmethod, classmethod
```

## Using type() Instead of isinstance()

### The Problem

`type()` doesn't work with inheritance:

```python
class Animal:
    pass

class Dog(Animal):
    pass

dog = Dog()

# ❌ WRONG
if type(dog) == Animal:  # False! Even though Dog inherits from Animal
    print("Is an animal")
```

### The Solution

Use `isinstance()`:

```python
# ✅ CORRECT
if isinstance(dog, Animal):  # True! Works with inheritance
    print("Is an animal")

# Check multiple types
if isinstance(value, (str, bytes)):
    process_string(value)
```

## Comparing to None, True, or False

### The Problem

Using `==` for singleton comparisons:

```python
# ❌ WRONG
if value == None:
    pass

if flag == True:
    pass

if result == False:
    pass
```

### The Solution

Use `is` for `None`, and direct checks for booleans:

```python
# ✅ CORRECT
if value is None:
    pass

if flag:  # or: if flag is True (rarely needed)
    pass

if not result:  # or: if result is False (rarely needed)
    pass
```

## Inefficient String Concatenation

### The Problem

String concatenation in loops is O(n²):

```python
# ❌ SLOW
result = ""
for item in items:
    result += str(item) + ", "
```

### The Solution

Use `join()`:

```python
# ✅ FAST
result = ", ".join(str(item) for item in items)

# For many concatenations
parts = []
for item in items:
    parts.append(str(item))
result = ", ".join(parts)
```

## Bare except Clauses

### The Problem

Catching all exceptions including system exits:

```python
# ❌ DANGEROUS
try:
    risky_operation()
except:  # Catches EVERYTHING including KeyboardInterrupt, SystemExit
    pass
```

### The Solution

Catch specific exceptions:

```python
# ✅ CORRECT
try:
    risky_operation()
except (ValueError, KeyError) as e:
    logger.error(f"Operation failed: {e}")

# If you really need to catch all normal exceptions
try:
    risky_operation()
except Exception as e:  # Doesn't catch KeyboardInterrupt, SystemExit
    logger.error(f"Unexpected error: {e}")
    raise  # Re-raise to not hide the error
```

## Modifying List While Iterating

### The Problem

Modifying a list while iterating over it causes skipped items:

```python
# ❌ WRONG
numbers = [1, 2, 3, 4, 5, 6]
for num in numbers:
    if num % 2 == 0:
        numbers.remove(num)  # Skips items!

print(numbers)  # [1, 3, 4, 5] - missed one!
```

### The Solution

Iterate over a copy or use list comprehension:

```python
# ✅ CORRECT: Iterate over copy
numbers = [1, 2, 3, 4, 5, 6]
for num in numbers[:]:  # Create a copy with [:]
    if num % 2 == 0:
        numbers.remove(num)

# ✅ BETTER: List comprehension
numbers = [1, 2, 3, 4, 5, 6]
numbers = [num for num in numbers if num % 2 != 0]

# ✅ BEST: filter()
numbers = [1, 2, 3, 4, 5, 6]
numbers = list(filter(lambda x: x % 2 != 0, numbers))
```

## Import Pitfalls

### Circular Imports

**Problem:**
```python
# module_a.py
from module_b import function_b

def function_a():
    return function_b()

# module_b.py
from module_a import function_a  # Circular import!

def function_b():
    return function_a()
```

**Solution:**
```python
# Option 1: Import at function level
def function_b():
    from module_a import function_a  # Import inside function
    return function_a()

# Option 2: Restructure to remove circular dependency
# Extract shared functionality to separate module
```

### Wildcard Imports

**Problem:**
```python
# ❌ WRONG
from module import *  # What did we import?

# Name conflicts
from math import *
from numpy import *
```

**Solution:**
```python
# ✅ CORRECT
from module import function_a, function_b, ClassA

# Or import module
import module
result = module.function_a()
```

## Class Design Issues

### Missing `__repr__`

**Problem:**
```python
class User:
    def __init__(self, name, age):
        self.name = name
        self.age = age

user = User("Alice", 30)
print(user)  # <__main__.User object at 0x...> - not helpful!
```

**Solution:**
```python
class User:
    def __init__(self, name, age):
        self.name = name
        self.age = age

    def __repr__(self):
        return f"User(name={self.name!r}, age={self.age})"

    def __str__(self):
        return f"{self.name} ({self.age})"

user = User("Alice", 30)
print(repr(user))  # User(name='Alice', age=30)
print(str(user))   # Alice (30)
```

### Not Using Dataclasses

**Problem:**
```python
# ❌ VERBOSE
class Point:
    def __init__(self, x, y):
        self.x = x
        self.y = y

    def __repr__(self):
        return f"Point(x={self.x}, y={self.y})"

    def __eq__(self, other):
        if not isinstance(other, Point):
            return NotImplemented
        return self.x == other.x and self.y == other.y
```

**Solution:**
```python
# ✅ CONCISE
from dataclasses import dataclass

@dataclass
class Point:
    x: float
    y: float
```

## Dictionary Issues

### Using get() Wrong

**Problem:**
```python
# ❌ VERBOSE
if key in my_dict:
    value = my_dict[key]
else:
    value = default_value
```

**Solution:**
```python
# ✅ CORRECT
value = my_dict.get(key, default_value)

# For complex defaults that are expensive to compute
value = my_dict.get(key)
if value is None:
    value = expensive_computation()
```

### Not Using setdefault()

**Problem:**
```python
# ❌ VERBOSE
if key not in my_dict:
    my_dict[key] = []
my_dict[key].append(value)
```

**Solution:**
```python
# ✅ CORRECT
my_dict.setdefault(key, []).append(value)

# Or use defaultdict
from collections import defaultdict

my_dict = defaultdict(list)
my_dict[key].append(value)
```

## File Handling Issues

### Not Using Context Managers

**Problem:**
```python
# ❌ WRONG - file might not close on exception
file = open("data.txt")
data = file.read()
file.close()
```

**Solution:**
```python
# ✅ CORRECT - always closes
with open("data.txt") as file:
    data = file.read()

# Multiple files
with open("input.txt") as infile, open("output.txt", "w") as outfile:
    outfile.write(infile.read())
```

## Generator and Iterator Issues

### Loading Large Files Into Memory

**Problem:**
```python
# ❌ MEMORY INTENSIVE
with open("large_file.txt") as f:
    lines = f.readlines()  # Loads entire file!
    for line in lines:
        process(line)
```

**Solution:**
```python
# ✅ MEMORY EFFICIENT
with open("large_file.txt") as f:
    for line in f:  # Iterates line by line
        process(line)

# Or use generator
def read_large_file(file_path):
    with open(file_path) as f:
        for line in f:
            yield line.strip()

for line in read_large_file("large_file.txt"):
    process(line)
```

## Exception Handling Issues

### Swallowing Exceptions

**Problem:**
```python
# ❌ WRONG - hides errors
try:
    critical_operation()
except Exception:
    pass  # Error disappears!
```

**Solution:**
```python
# ✅ CORRECT - log and/or re-raise
import logging

logger = logging.getLogger(__name__)

try:
    critical_operation()
except Exception as e:
    logger.error(f"Critical operation failed: {e}")
    raise  # Re-raise to propagate
```

### Raising Wrong Exception Types

**Problem:**
```python
# ❌ WRONG - generic exception
def withdraw(amount):
    if amount > balance:
        raise Exception("Insufficient funds")
```

**Solution:**
```python
# ✅ CORRECT - specific exception
class InsufficientFundsError(ValueError):
    """Raised when withdrawal exceeds balance."""
    pass

def withdraw(amount):
    if amount > balance:
        raise InsufficientFundsError(
            f"Cannot withdraw {amount}, balance is {balance}"
        )
```

## Performance Anti-patterns

### Using + to Build Lists

**Problem:**
```python
# ❌ SLOW - creates new list each time
result = []
for i in range(1000):
    result = result + [i]  # O(n²)
```

**Solution:**
```python
# ✅ FAST - in-place append
result = []
for i in range(1000):
    result.append(i)  # O(n)

# Or list comprehension
result = [i for i in range(1000)]

# Or just use range
result = list(range(1000))
```

### Not Using Built-in Functions

**Problem:**
```python
# ❌ SLOW
total = 0
for num in numbers:
    total += num

maximum = numbers[0]
for num in numbers[1:]:
    if num > maximum:
        maximum = num
```

**Solution:**
```python
# ✅ FAST
total = sum(numbers)
maximum = max(numbers)
```

## Testing Issues

### Global State

**Problem:**
```python
# ❌ WRONG - global state
counter = 0

def increment():
    global counter
    counter += 1
    return counter

# Tests can interfere with each other
```

**Solution:**
```python
# ✅ CORRECT - no global state
class Counter:
    def __init__(self):
        self.count = 0

    def increment(self):
        self.count += 1
        return self.count

# Each test gets fresh instance
def test_increment():
    counter = Counter()
    assert counter.increment() == 1
    assert counter.increment() == 2
```

## Quick Reference Checklist

- [ ] No mutable default arguments
- [ ] Use `isinstance()` instead of `type()`
- [ ] Use `is` for `None` comparisons
- [ ] Use `join()` for string concatenation
- [ ] Catch specific exceptions
- [ ] Don't modify list while iterating
- [ ] Avoid wildcard imports
- [ ] Implement `__repr__` for classes
- [ ] Use context managers for files
- [ ] Use generators for large data
- [ ] Log exceptions before swallowing
- [ ] Use built-in functions
- [ ] Avoid global state
- [ ] Use dataclasses for simple data containers

## Resources

- [Common Python Gotchas](https://docs.python-guide.org/writing/gotchas/)
- [Python Anti-patterns](https://docs.quantifiedcode.com/python-anti-patterns/)
- [Effective Python](https://effectivepython.com/)
- [PEP 8 Style Guide](https://peps.python.org/pep-0008/)
