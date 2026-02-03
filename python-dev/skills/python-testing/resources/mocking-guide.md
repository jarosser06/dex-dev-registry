# Python Mocking and Patching Guide

Comprehensive guide to mocking and patching in Python tests using unittest.mock and pytest-mock.

## Why Mock?

Mocking replaces real objects with test doubles to:
- Isolate code under test
- Avoid expensive operations (API calls, database queries)
- Control test behavior and simulate edge cases
- Speed up tests
- Test error conditions

## unittest.mock Basics

### Mock Objects

```python
from unittest.mock import Mock

# Create a mock object
mock = Mock()

# Mock can be called
mock()
mock("arg1", "arg2")
mock(key="value")

# Mock returns another mock by default
result = mock.method()
assert isinstance(result, Mock)

# Set return value
mock.method.return_value = 42
assert mock.method() == 42
```

### Mock Attributes

```python
mock = Mock()

# Access any attribute (returns new Mock)
value = mock.some_attribute
assert isinstance(value, Mock)

# Set attribute value
mock.name = "Test"
assert mock.name == "Test"

# Configure mock
mock.value = 100
mock.get_value.return_value = 100
```

### Spec Objects

Use `spec` to restrict mock to match real object interface:

```python
class User:
    def __init__(self, name):
        self.name = name

    def greet(self):
        return f"Hello, {self.name}"

# Mock with spec
mock_user = Mock(spec=User)
mock_user.name = "Alice"
mock_user.greet.return_value = "Hello, Alice"

# Raises AttributeError for non-existent attributes
# mock_user.invalid_method()  # AttributeError!
```

## Patching

### patch Decorator

```python
from unittest.mock import patch

# Patch a function
@patch("mymodule.expensive_api_call")
def test_function(mock_api):
    mock_api.return_value = {"data": "test"}

    result = function_that_calls_api()

    assert result == {"data": "test"}
    mock_api.assert_called_once()
```

### patch Context Manager

```python
def test_with_context_manager():
    with patch("mymodule.send_email") as mock_send:
        mock_send.return_value = True

        result = process_user_registration()

        assert result is True
        mock_send.assert_called()
```

### patch.object

Patch methods or attributes of objects:

```python
from myapp import EmailService

@patch.object(EmailService, "send")
def test_email_service(mock_send):
    mock_send.return_value = True

    service = EmailService()
    result = service.send_welcome_email("user@example.com")

    assert result is True
    mock_send.assert_called_once()
```

### patch.multiple

Patch multiple targets at once:

```python
@patch.multiple(
    "mymodule",
    function_a=Mock(return_value=1),
    function_b=Mock(return_value=2),
)
def test_multiple_patches(function_a, function_b):
    result_a = function_a()
    result_b = function_b()

    assert result_a == 1
    assert result_b == 2
```

## Return Values and Side Effects

### Setting Return Values

```python
mock = Mock()

# Simple return value
mock.method.return_value = 42
assert mock.method() == 42

# Different return values for different calls
mock.get.side_effect = [1, 2, 3]
assert mock.get() == 1
assert mock.get() == 2
assert mock.get() == 3
```

### Side Effects with Functions

```python
def side_effect_function(arg):
    if arg == "valid":
        return "success"
    raise ValueError("Invalid argument")

mock = Mock()
mock.process.side_effect = side_effect_function

assert mock.process("valid") == "success"

with pytest.raises(ValueError):
    mock.process("invalid")
```

### Side Effects with Exceptions

```python
mock = Mock()

# Raise exception
mock.fetch.side_effect = ConnectionError("Network failure")

with pytest.raises(ConnectionError):
    mock.fetch()

# Mix success and failure
mock.api_call.side_effect = [
    ConnectionError("First call fails"),
    {"status": "success"},  # Second call succeeds
]
```

## Assertions on Mocks

### Call Assertions

```python
mock = Mock()
mock.method("arg1", "arg2", key="value")

# Assert called
mock.method.assert_called()

# Assert called once
mock.method.assert_called_once()

# Assert called with specific arguments
mock.method.assert_called_with("arg1", "arg2", key="value")

# Assert called once with specific arguments
mock.method.assert_called_once_with("arg1", "arg2", key="value")

# Assert any call with arguments
mock.method("different", "args")
mock.method.assert_any_call("arg1", "arg2", key="value")

# Assert not called
mock.other_method.assert_not_called()
```

### Call Count

```python
mock = Mock()

# Call multiple times
mock.method()
mock.method()
mock.method()

assert mock.method.call_count == 3
```

### Call Arguments

```python
from unittest.mock import call

mock = Mock()
mock.method(1, 2)
mock.method(3, 4, key="value")

# Check all calls
assert mock.method.call_args_list == [
    call(1, 2),
    call(3, 4, key="value"),
]

# Check last call
assert mock.method.call_args == call(3, 4, key="value")
```

## pytest-mock

### Installation

```bash
pip install pytest-mock
```

### Using mocker Fixture

```python
def test_with_mocker(mocker):
    # mocker provides convenient interface
    mock_send = mocker.patch("myapp.send_email")
    mock_send.return_value = True

    result = notify_user()

    assert result is True
    mock_send.assert_called_once()
```

### mocker.patch vs unittest.mock.patch

```python
# With mocker (cleaner in pytest)
def test_mocker_style(mocker):
    mock_api = mocker.patch("myapp.api.call")
    mock_api.return_value = {"data": "test"}

# With unittest.mock
from unittest.mock import patch

@patch("myapp.api.call")
def test_unittest_style(mock_api):
    mock_api.return_value = {"data": "test"}
```

### mocker.Mock and mocker.MagicMock

```python
def test_mocker_mock(mocker):
    # Create regular mock
    mock_obj = mocker.Mock()

    # Create MagicMock (supports magic methods)
    magic_mock = mocker.MagicMock()
    magic_mock.__len__.return_value = 5
    assert len(magic_mock) == 5
```

### Spy on Real Objects

```python
def test_spy(mocker):
    calculator = Calculator()

    # Spy allows real method to run while tracking calls
    spy = mocker.spy(calculator, "add")

    result = calculator.add(2, 3)

    assert result == 5  # Real method was called
    spy.assert_called_once_with(2, 3)
```

### Stub Functions

```python
def test_stub(mocker):
    # Replace function but keep signature
    stub = mocker.stub(name="my_stub")
    stub.return_value = "stubbed"

    result = stub("arg")
    assert result == "stubbed"
```

## Common Mocking Patterns

### Mocking API Calls

```python
@patch("requests.get")
def test_fetch_data(mock_get):
    # Mock successful response
    mock_response = Mock()
    mock_response.status_code = 200
    mock_response.json.return_value = {"data": "value"}
    mock_get.return_value = mock_response

    result = fetch_user_data(user_id=123)

    assert result == {"data": "value"}
    mock_get.assert_called_once_with(
        "https://api.example.com/users/123"
    )
```

### Mocking Database Queries

```python
def test_user_service(mocker):
    # Mock database
    mock_db = mocker.Mock(spec=Database)
    mock_db.query.return_value = [
        {"id": 1, "name": "Alice"},
        {"id": 2, "name": "Bob"},
    ]

    service = UserService(mock_db)
    users = service.get_all_users()

    assert len(users) == 2
    assert users[0]["name"] == "Alice"
    mock_db.query.assert_called_once()
```

### Mocking File Operations

```python
@patch("builtins.open", create=True)
def test_read_file(mock_open):
    # Mock file content
    mock_open.return_value.__enter__.return_value.read.return_value = "file content"

    content = read_config_file("config.txt")

    assert content == "file content"
    mock_open.assert_called_once_with("config.txt")
```

### Mocking with mock_open

```python
from unittest.mock import mock_open

@patch("builtins.open", mock_open(read_data="test data"))
def test_read_file():
    with open("file.txt") as f:
        content = f.read()

    assert content == "test data"
```

### Mocking datetime

```python
from datetime import datetime

@patch("myapp.datetime")
def test_time_sensitive(mock_datetime):
    # Mock current time
    mock_datetime.now.return_value = datetime(2024, 1, 1, 12, 0, 0)

    timestamp = get_current_timestamp()

    assert timestamp == "2024-01-01 12:00:00"
```

### Mocking Environment Variables

```python
@patch.dict(os.environ, {"API_KEY": "test_key"})
def test_environment_variable():
    api_key = get_api_key()
    assert api_key == "test_key"
```

## MagicMock

### Magic Methods Support

```python
from unittest.mock import MagicMock

magic_mock = MagicMock()

# Supports magic methods
magic_mock.__len__.return_value = 10
assert len(magic_mock) == 10

magic_mock.__getitem__.return_value = "value"
assert magic_mock["key"] == "value"

magic_mock.__iter__.return_value = iter([1, 2, 3])
assert list(magic_mock) == [1, 2, 3]
```

### Context Manager Mocking

```python
magic_mock = MagicMock()
magic_mock.__enter__.return_value = "resource"

with magic_mock as resource:
    assert resource == "resource"

magic_mock.__enter__.assert_called_once()
magic_mock.__exit__.assert_called_once()
```

## PropertyMock

### Mocking Properties

```python
from unittest.mock import PropertyMock

@patch.object(User, "is_active", new_callable=PropertyMock)
def test_property(mock_is_active):
    mock_is_active.return_value = True

    user = User("alice")
    assert user.is_active is True

    mock_is_active.assert_called_once()
```

## AsyncMock (Python 3.8+)

### Mocking Async Functions

```python
from unittest.mock import AsyncMock
import pytest

@pytest.mark.asyncio
async def test_async_function():
    mock_fetch = AsyncMock(return_value={"data": "value"})

    result = await mock_fetch()

    assert result == {"data": "value"}
    mock_fetch.assert_called_once()
```

### Patching Async Functions

```python
@pytest.mark.asyncio
@patch("myapp.fetch_data_async", new_callable=AsyncMock)
async def test_async_patch(mock_fetch):
    mock_fetch.return_value = {"status": "success"}

    result = await process_data_async()

    assert result["status"] == "success"
```

## Best Practices

### Mock at the Right Level

```python
# ❌ BAD: Mocking too deep
@patch("requests.adapters.HTTPAdapter.send")
def test_bad_level(mock_send):
    pass

# ✅ GOOD: Mock at usage point
@patch("myapp.api.requests.get")
def test_good_level(mock_get):
    pass
```

### Use spec for Safety

```python
# ❌ BAD: No spec, can call anything
mock = Mock()
mock.nonexistent_method()  # No error!

# ✅ GOOD: With spec, catches typos
from myapp import RealClass

mock = Mock(spec=RealClass)
# mock.nonexistent_method()  # AttributeError!
```

### Clear Return Values

```python
# ❌ BAD: Unclear what mock returns
mock = Mock()
mock.return_value = Mock()

# ✅ GOOD: Explicit return values
mock = Mock()
mock.get_user.return_value = {
    "id": 1,
    "name": "Alice",
    "email": "alice@example.com"
}
```

### Test Mock Configuration

```python
def test_mock_setup():
    # Test that mock is configured correctly
    mock_api = Mock()
    mock_api.get.return_value = {"data": "test"}

    # Verify mock works as expected before using in real test
    assert mock_api.get() == {"data": "test"}
```

### Don't Over-Mock

```python
# ❌ BAD: Mocking simple logic
@patch("myapp.add")
def test_over_mocked(mock_add):
    mock_add.return_value = 5
    # Testing nothing useful

# ✅ GOOD: Mock only external dependencies
@patch("myapp.database.query")
def test_appropriate_mock(mock_query):
    mock_query.return_value = [{"id": 1}]
    # Testing actual logic with mocked dependency
```

## Debugging Mocks

### Inspecting Mock Calls

```python
mock = Mock()
mock.method("arg1", key="value")
mock.method("arg2", key="other")

# Print all calls
print(mock.method.call_args_list)

# Print mock details
print(mock.method_calls)
print(mock.call_args)
print(mock.call_args_list)
```

### Using mock.call_args

```python
mock = Mock()
mock.method(1, 2, key="value")

# Unpack call arguments
args, kwargs = mock.method.call_args
assert args == (1, 2)
assert kwargs == {"key": "value"}
```

### Reset Mocks

```python
mock = Mock()
mock.method()

# Reset mock
mock.reset_mock()

# Now shows as not called
mock.method.assert_not_called()
```

## Common Pitfalls

### Patching Wrong Target

```python
# File: myapp/service.py
from external_lib import function

def my_function():
    return function()

# ❌ WRONG: Patching where defined
@patch("external_lib.function")
def test_wrong():
    pass

# ✅ CORRECT: Patch where used
@patch("myapp.service.function")
def test_correct():
    pass
```

### Side Effects Exhaustion

```python
mock = Mock()
mock.method.side_effect = [1, 2]

mock.method()  # Returns 1
mock.method()  # Returns 2
# mock.method()  # Raises StopIteration!

# ✅ BETTER: Handle exhaustion
mock.method.side_effect = [1, 2, 3, 3, 3]  # Repeat last value
```

### Forgotten spec

```python
# ❌ Typo goes unnoticed
mock_user = Mock()
mock_user.naem = "Alice"  # Typo!

# ✅ Catches typos
mock_user = Mock(spec=User)
# mock_user.naem = "Alice"  # AttributeError!
mock_user.name = "Alice"  # Correct
```

## Resources

- [unittest.mock Documentation](https://docs.python.org/3/library/unittest.mock.html)
- [pytest-mock Documentation](https://pytest-mock.readthedocs.io/)
- [Python Mocking Guide](https://realpython.com/python-mock-library/)
