# Common Pytest Patterns and Recipes

Collection of practical pytest patterns and solutions for common testing scenarios.

## Test Organization Patterns

### Grouping Related Tests with Classes

Use classes to group related tests without sharing state:

```python
class TestUserAuthentication:
    def test_login_with_valid_credentials(self):
        user = User("alice@example.com", "password123")
        assert user.authenticate("password123") is True

    def test_login_with_invalid_credentials(self):
        user = User("alice@example.com", "password123")
        assert user.authenticate("wrong_password") is False

    def test_account_locked_after_failed_attempts(self):
        user = User("alice@example.com", "password123")
        for _ in range(5):
            user.authenticate("wrong_password")
        assert user.is_locked() is True
```

### Shared Setup with autouse Fixtures

```python
@pytest.fixture(autouse=True)
def setup_test_environment():
    """Automatically run before each test in the module."""
    os.environ["ENV"] = "testing"
    yield
    os.environ.pop("ENV", None)

def test_uses_test_environment():
    assert os.environ["ENV"] == "testing"
```

## Parametrization Patterns

### Parametrizing with pytest.param

Add marks and IDs to individual parameters:

```python
@pytest.mark.parametrize("input,expected", [
    pytest.param(2, 4, id="two"),
    pytest.param(3, 9, id="three"),
    pytest.param(-1, 1, id="negative", marks=pytest.mark.skip),
    pytest.param(0, 0, id="zero"),
])
def test_square(input, expected):
    assert input ** 2 == expected
```

### Combining Multiple parametrize Decorators

```python
@pytest.mark.parametrize("width", [1, 2, 3])
@pytest.mark.parametrize("height", [4, 5, 6])
def test_rectangle_area(width, height):
    # Creates 9 tests (3 × 3 combinations)
    rect = Rectangle(width, height)
    assert rect.area() == width * height
```

### Parametrizing Fixtures

```python
@pytest.fixture(params=["sqlite", "postgres", "mysql"])
def database(request):
    """Parametrized fixture - tests run once per database type."""
    db = create_database(request.param)
    yield db
    db.cleanup()

def test_database_operations(database):
    # This test runs 3 times, once for each database type
    database.insert("test", {"key": "value"})
    result = database.query("test")
    assert result is not None
```

### Indirect Parametrization

Use fixtures with parameters:

```python
@pytest.fixture
def user(request):
    """Create user with parametrized attributes."""
    return User(**request.param)

@pytest.mark.parametrize("user", [
    {"name": "Alice", "age": 30},
    {"name": "Bob", "age": 25},
], indirect=True)
def test_user_creation(user):
    assert user.name in ["Alice", "Bob"]
    assert user.age > 0
```

## Fixture Patterns

### Fixture Chains

Build complex fixtures from simpler ones:

```python
@pytest.fixture
def database():
    db = Database()
    db.connect()
    yield db
    db.disconnect()

@pytest.fixture
def user_repository(database):
    return UserRepository(database)

@pytest.fixture
def admin_user(user_repository):
    user = User(name="Admin", role="admin")
    user_repository.save(user)
    return user

def test_admin_operations(admin_user, user_repository):
    assert user_repository.find_by_role("admin") == [admin_user]
```

### Fixture Factories

Create fixtures that return factory functions:

```python
@pytest.fixture
def user_factory():
    """Factory for creating test users."""
    created_users = []

    def make_user(name="Test", email=None):
        if email is None:
            email = f"{name.lower()}@example.com"
        user = User(name=name, email=email)
        created_users.append(user)
        return user

    yield make_user

    # Cleanup all created users
    for user in created_users:
        user.delete()

def test_multiple_users(user_factory):
    alice = user_factory("Alice")
    bob = user_factory("Bob")
    assert alice.name != bob.name
```

### Yielding Fixtures with Cleanup

```python
@pytest.fixture
def temp_file():
    """Create temporary file and clean up after test."""
    file_path = Path("temp_test.txt")
    file_path.write_text("test data")
    yield file_path
    file_path.unlink()  # Cleanup

def test_file_operations(temp_file):
    assert temp_file.exists()
    content = temp_file.read_text()
    assert content == "test data"
```

### Request Fixture for Metadata

Access test metadata in fixtures:

```python
@pytest.fixture
def logger(request):
    """Create logger with test name."""
    test_name = request.node.name
    logger = logging.getLogger(test_name)
    logger.info(f"Starting test: {test_name}")
    yield logger
    logger.info(f"Finished test: {test_name}")

def test_with_logging(logger):
    logger.info("Test is running")
    assert True
```

## Mocking Patterns

### Mocking with Side Effects

```python
def test_retry_on_failure(mocker):
    mock_api = mocker.patch("myapp.api.call")
    # First two calls fail, third succeeds
    mock_api.side_effect = [
        ConnectionError("Failed"),
        ConnectionError("Failed"),
        {"status": "success"},
    ]

    result = retry_api_call()
    assert result["status"] == "success"
    assert mock_api.call_count == 3
```

### Mocking with Context Managers

```python
def test_file_operations(mocker):
    mock_open = mocker.patch("builtins.open", mocker.mock_open(read_data="test"))

    content = read_file("test.txt")

    assert content == "test"
    mock_open.assert_called_once_with("test.txt")
```

### Spying on Real Objects

```python
def test_spy_on_method(mocker):
    calculator = Calculator()
    spy = mocker.spy(calculator, "add")

    # Real method is called
    result = calculator.add(2, 3)

    assert result == 5
    spy.assert_called_once_with(2, 3)
```

### Partial Mocking

Mock some methods while keeping others real:

```python
def test_partial_mock(mocker):
    service = DataService()
    # Mock only the fetch method
    mocker.patch.object(service, "fetch", return_value={"data": "test"})

    # process method uses real implementation
    result = service.process()

    assert "data" in result
```

## Exception Testing Patterns

### Testing Exception Messages

```python
def test_exception_message():
    with pytest.raises(ValueError) as exc_info:
        validate_age(-1)

    assert "must be positive" in str(exc_info.value)
```

### Testing Multiple Exceptions

```python
@pytest.mark.parametrize("invalid_input,exception", [
    ("", ValueError),
    (None, TypeError),
    (-1, ValueError),
])
def test_invalid_inputs(invalid_input, exception):
    with pytest.raises(exception):
        process_input(invalid_input)
```

### Asserting No Exception

```python
def test_no_exception_raised():
    # Should complete without exception
    try:
        result = safe_operation()
        assert result is not None
    except Exception as e:
        pytest.fail(f"Unexpected exception: {e}")
```

## Async Testing Patterns

### Testing Async Functions

```python
import pytest

@pytest.mark.asyncio
async def test_async_fetch():
    result = await fetch_data_async("https://api.example.com")
    assert result["status"] == "success"
```

### Async Fixtures

```python
@pytest.fixture
async def async_client():
    client = AsyncClient()
    await client.connect()
    yield client
    await client.disconnect()

@pytest.mark.asyncio
async def test_async_client(async_client):
    response = await async_client.get("/endpoint")
    assert response.status == 200
```

### Mocking Async Functions

```python
@pytest.mark.asyncio
async def test_mock_async(mocker):
    mock_fetch = mocker.patch("myapp.fetch_async")
    mock_fetch.return_value = {"data": "test"}

    result = await process_async()
    assert result == {"data": "test"}
```

## Test Data Patterns

### Using Factories

```python
from dataclasses import dataclass

@dataclass
class UserFactory:
    _counter: int = 0

    def create(self, name=None, email=None):
        self._counter += 1
        name = name or f"User{self._counter}"
        email = email or f"user{self._counter}@example.com"
        return User(name=name, email=email)

@pytest.fixture
def user_factory():
    return UserFactory()

def test_with_factory(user_factory):
    user1 = user_factory.create()
    user2 = user_factory.create(name="Alice")
    assert user1.name != user2.name
```

### Loading Test Data from Files

```python
import json
from pathlib import Path

@pytest.fixture
def test_data():
    """Load test data from JSON file."""
    data_path = Path(__file__).parent / "fixtures" / "test_data.json"
    with data_path.open() as f:
        return json.load(f)

def test_with_file_data(test_data):
    assert "users" in test_data
    assert len(test_data["users"]) > 0
```

## Conditional Test Patterns

### Skip Based on Condition

```python
import sys

@pytest.mark.skipif(sys.platform == "win32", reason="Unix-only test")
def test_unix_feature():
    pass

@pytest.mark.skipif(
    sys.version_info < (3, 9),
    reason="Requires Python 3.9+"
)
def test_new_syntax():
    pass
```

### Expected Failures

```python
@pytest.mark.xfail(reason="Known bug in external library")
def test_known_issue():
    result = buggy_function()
    assert result == expected

@pytest.mark.xfail(raises=NotImplementedError)
def test_not_implemented():
    future_feature()
```

### Custom Skip Logic

```python
def test_requires_service():
    if not service_available():
        pytest.skip("Service not available")

    result = call_service()
    assert result is not None
```

## Temporary Resource Patterns

### Temporary Directories

```python
def test_file_operations(tmp_path):
    # tmp_path is a pathlib.Path to temporary directory
    test_file = tmp_path / "test.txt"
    test_file.write_text("content")

    assert test_file.exists()
    assert test_file.read_text() == "content"
    # Automatically cleaned up after test
```

### Temporary Files

```python
def test_config_file(tmp_path):
    config_file = tmp_path / "config.json"
    config_data = {"key": "value"}

    with config_file.open("w") as f:
        json.dump(config_data, f)

    loaded = load_config(config_file)
    assert loaded == config_data
```

## Monkey Patching Patterns

### Patching Environment Variables

```python
def test_environment_variable(monkeypatch):
    monkeypatch.setenv("API_KEY", "test_key")

    api_key = get_api_key()
    assert api_key == "test_key"
```

### Patching Attributes

```python
def test_patched_attribute(monkeypatch):
    monkeypatch.setattr("myapp.config.DEBUG", True)

    assert is_debug_mode() is True
```

### Patching Dictionary Items

```python
def test_patched_dict(monkeypatch):
    monkeypatch.setitem(os.environ, "TEST_VAR", "value")

    assert os.environ["TEST_VAR"] == "value"
```

## Subtest Patterns

### Using pytest-subtests

```python
def test_multiple_cases(subtests):
    test_cases = [
        (2, 4),
        (3, 9),
        (4, 16),
    ]

    for input_val, expected in test_cases:
        with subtests.test(input=input_val):
            assert input_val ** 2 == expected
```

## Logging and Debugging Patterns

### Capturing Logs

```python
def test_logging(caplog):
    with caplog.at_level(logging.INFO):
        function_that_logs()

    assert "Expected message" in caplog.text
    assert len(caplog.records) == 1
```

### Capturing stdout/stderr

```python
def test_print_output(capsys):
    print("Hello")
    print("Error", file=sys.stderr)

    captured = capsys.readouterr()
    assert captured.out == "Hello\n"
    assert captured.err == "Error\n"
```

### Capturing Warnings

```python
def test_warning():
    with pytest.warns(UserWarning, match="deprecated"):
        deprecated_function()
```

## Performance Testing Patterns

### Timing Tests

```python
import time

def test_performance():
    start = time.time()

    perform_operation()

    duration = time.time() - start
    assert duration < 1.0, "Operation took too long"
```

### Using pytest-benchmark

```python
def test_benchmark(benchmark):
    result = benchmark(expensive_function, arg1, arg2)
    assert result is not None
```

## Database Testing Patterns

### Transaction Rollback

```python
@pytest.fixture
def database_session():
    session = create_session()
    session.begin()
    yield session
    session.rollback()
    session.close()

def test_database_operation(database_session):
    user = User(name="Test")
    database_session.add(user)
    database_session.flush()

    assert user.id is not None
    # Changes rolled back after test
```

### In-Memory Database

```python
@pytest.fixture(scope="session")
def in_memory_db():
    db = create_engine("sqlite:///:memory:")
    Base.metadata.create_all(db)
    return db

def test_with_memory_db(in_memory_db):
    session = Session(in_memory_db)
    # Fast tests with in-memory database
```

## Custom Assertions

### Creating Custom Assertion Helpers

```python
def assert_valid_email(email):
    __tracebackhide__ = True  # Hide helper from traceback
    assert "@" in email, f"{email} is not a valid email"
    assert "." in email.split("@")[1], f"{email} missing domain extension"

def test_email_validation():
    assert_valid_email("user@example.com")
```

## Flaky Test Patterns

### Retrying Flaky Tests

```python
@pytest.mark.flaky(reruns=3, reruns_delay=1)
def test_flaky_operation():
    # Test that occasionally fails due to timing
    result = sometimes_fails()
    assert result is not None
```

## Resources

- [Pytest Documentation](https://docs.pytest.org/)
- [Pytest Examples and Tutorials](https://docs.pytest.org/en/stable/example/index.html)
- [Effective Python Testing](https://realpython.com/pytest-python-testing/)
