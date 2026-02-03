---
name: python-testing
description: Expert in Python testing with pytest, fixtures, mocking, test organization, and testing best practices
---

# Python Testing Expert

Expert in Python testing practices using pytest. Specializes in test organization, fixtures, parametrization, mocking, and comprehensive test strategies.

## Required Rules

**MUST** follow these absolute requirements defined in project rules:
- `.claude/rules/python/python-testing.md` - Testing standards, pytest usage, test organization
- `.claude/rules/python/python-style.md` - Code style in test files
- `.claude/rules/python/python-formatting.md` - Formatting test files

## When to Use This Skill

Use this skill for:
- Writing unit tests with pytest
- Creating and using fixtures
- Mocking dependencies
- Parametrizing tests
- Organizing test suites
- Debugging test failures
- Improving test coverage

## Pytest Fundamentals

### Why Pytest?

**MUST**: Use pytest as the primary testing framework

**Advantages over unittest:**
- Simpler syntax with plain `assert` statements
- Powerful fixtures system
- Better test discovery
- Rich plugin ecosystem
- Detailed assertion introspection
- Parametrization support

### Basic Test Structure

```python
# test_calculator.py
def test_addition():
    assert 2 + 2 == 4

def test_subtraction():
    assert 5 - 3 == 2

def test_multiplication():
    assert 3 * 4 == 12
```

### Running Tests

```bash
# Run all tests
pytest

# Run specific file
pytest test_calculator.py

# Run specific test
pytest test_calculator.py::test_addition

# Run with verbose output
pytest -v

# Run with coverage
pytest --cov=myapp

# Run and stop on first failure
pytest -x
```

## Test Organization

### Directory Structure

**MUST**: Organize tests to mirror source structure

```
myproject/
├── myapp/
│   ├── __init__.py
│   ├── calculator.py
│   ├── database.py
│   └── api.py
└── tests/
    ├── __init__.py
    ├── conftest.py           # Shared fixtures
    ├── test_calculator.py
    ├── test_database.py
    └── test_api.py
```

### Test Naming Conventions

**MUST**: Follow pytest naming conventions:
- Test files: `test_*.py` or `*_test.py`
- Test functions: `test_*`
- Test classes: `Test*`

```python
# ✅ CORRECT
def test_user_creation():
    pass

def test_user_deletion():
    pass

class TestUserAuthentication:
    def test_login_success(self):
        pass

    def test_login_failure(self):
        pass

# ❌ WRONG
def check_user_creation():  # Missing 'test_' prefix
    pass

class UserTests:  # Missing 'Test' prefix
    pass
```

## Fixtures

### Basic Fixtures

Fixtures provide reusable test setup and teardown:

```python
import pytest

@pytest.fixture
def sample_user():
    """Create a sample user for testing."""
    return User(name="Alice", email="alice@example.com")

def test_user_name(sample_user):
    assert sample_user.name == "Alice"

def test_user_email(sample_user):
    assert sample_user.email == "alice@example.com"
```

### Fixture Scopes

Control fixture lifecycle with scope:

```python
# Function scope (default) - created for each test
@pytest.fixture(scope="function")
def temp_data():
    return {"key": "value"}

# Class scope - created once per test class
@pytest.fixture(scope="class")
def database_connection():
    conn = create_connection()
    yield conn
    conn.close()

# Module scope - created once per module
@pytest.fixture(scope="module")
def app():
    app = create_app()
    yield app
    app.cleanup()

# Session scope - created once per test session
@pytest.fixture(scope="session")
def test_config():
    return load_test_config()
```

### Fixture Factories

Create fixtures that return factory functions:

```python
@pytest.fixture
def user_factory():
    """Factory fixture for creating users with custom attributes."""
    def create_user(name="Test User", email=None):
        if email is None:
            email = f"{name.lower().replace(' ', '')}@example.com"
        return User(name=name, email=email)
    return create_user

def test_multiple_users(user_factory):
    user1 = user_factory(name="Alice")
    user2 = user_factory(name="Bob")
    assert user1.name != user2.name
```

### Fixture Dependencies

Fixtures can use other fixtures:

```python
@pytest.fixture
def database():
    db = Database()
    yield db
    db.cleanup()

@pytest.fixture
def user_repository(database):
    return UserRepository(database)

@pytest.fixture
def sample_user(user_repository):
    user = User(name="Alice")
    user_repository.save(user)
    return user

def test_user_exists(sample_user, user_repository):
    found = user_repository.find_by_name("Alice")
    assert found == sample_user
```

### conftest.py

**MUST**: Place shared fixtures in `conftest.py`

```python
# tests/conftest.py
import pytest

@pytest.fixture
def app():
    """Application instance for testing."""
    app = create_app(config="testing")
    yield app
    app.cleanup()

@pytest.fixture
def client(app):
    """Test client for making requests."""
    return app.test_client()

@pytest.fixture
def database(app):
    """Database instance with test data."""
    db = app.database
    db.create_all()
    yield db
    db.drop_all()
```

## Parametrization

### Basic Parametrization

Run same test with different inputs:

```python
@pytest.mark.parametrize("input,expected", [
    (2, 4),
    (3, 9),
    (4, 16),
    (5, 25),
])
def test_square(input, expected):
    assert input ** 2 == expected
```

### Multiple Parameters

```python
@pytest.mark.parametrize("width,height,expected_area", [
    (2, 3, 6),
    (4, 5, 20),
    (10, 10, 100),
])
def test_rectangle_area(width, height, expected_area):
    rect = Rectangle(width, height)
    assert rect.area() == expected_area
```

### Parametrize with IDs

Add descriptive test IDs:

```python
@pytest.mark.parametrize("input,expected", [
    (2, 4),
    (3, 9),
    (0, 0),
], ids=["two_squared", "three_squared", "zero_squared"])
def test_square(input, expected):
    assert input ** 2 == expected
```

### Complex Parametrization

```python
@pytest.mark.parametrize("user_data,is_valid", [
    ({"name": "Alice", "email": "alice@example.com"}, True),
    ({"name": "", "email": "alice@example.com"}, False),
    ({"name": "Bob", "email": "invalid"}, False),
    ({"name": "Charlie", "email": "charlie@example.com"}, True),
], ids=["valid_user", "empty_name", "invalid_email", "another_valid_user"])
def test_user_validation(user_data, is_valid):
    user = User(**user_data)
    assert user.is_valid() == is_valid
```

## Mocking and Patching

### Using unittest.mock

```python
from unittest.mock import Mock, patch, MagicMock

def test_api_call():
    # Create a mock
    mock_response = Mock()
    mock_response.status_code = 200
    mock_response.json.return_value = {"data": "value"}

    # Use mock in test
    with patch("requests.get", return_value=mock_response):
        result = fetch_data("https://api.example.com")
        assert result == {"data": "value"}
```

### Mocking Methods

```python
def test_send_email():
    # Mock a method
    with patch.object(EmailService, "send", return_value=True) as mock_send:
        service = EmailService()
        result = service.send_welcome_email("user@example.com")

        assert result is True
        mock_send.assert_called_once_with(
            to="user@example.com",
            subject="Welcome",
            body="Welcome to our service!"
        )
```

### pytest-mock Plugin

**Recommended**: Use pytest-mock for cleaner syntax

```python
# Install: pip install pytest-mock

def test_with_pytest_mock(mocker):
    # mocker fixture provided by pytest-mock
    mock_get = mocker.patch("requests.get")
    mock_get.return_value.json.return_value = {"key": "value"}

    result = fetch_data()
    assert result["key"] == "value"
    mock_get.assert_called_once()
```

### Mocking Fixtures

```python
@pytest.fixture
def mock_database(mocker):
    """Mock database for testing."""
    mock_db = mocker.Mock(spec=Database)
    mock_db.query.return_value = [{"id": 1, "name": "Test"}]
    return mock_db

def test_user_service(mock_database):
    service = UserService(mock_database)
    users = service.get_all_users()
    assert len(users) == 1
    mock_database.query.assert_called_once()
```

## Assertions

### Basic Assertions

```python
def test_assertions():
    # Equality
    assert result == expected
    assert value != other_value

    # Comparisons
    assert count > 0
    assert age >= 18
    assert score < 100

    # Membership
    assert item in collection
    assert key not in dictionary

    # Type checks
    assert isinstance(obj, MyClass)

    # Truthiness
    assert condition
    assert not empty_list
```

### Assertion Messages

Add helpful messages:

```python
def test_with_messages():
    result = calculate_total([1, 2, 3])
    assert result == 6, f"Expected 6, got {result}"

    user = User.find_by_id(123)
    assert user is not None, "User 123 should exist in database"
```

### pytest Helpers

```python
def test_pytest_helpers():
    # Test for exceptions
    with pytest.raises(ValueError):
        int("not a number")

    # Test for specific exception message
    with pytest.raises(ValueError, match="invalid literal"):
        int("not a number")

    # Test for warnings
    with pytest.warns(UserWarning):
        warnings.warn("deprecated", UserWarning)

    # Approximate comparison for floats
    assert 0.1 + 0.2 == pytest.approx(0.3)
```

## Test Markers

### Built-in Markers

```python
@pytest.mark.skip(reason="Not implemented yet")
def test_future_feature():
    pass

@pytest.mark.skipif(sys.version_info < (3, 9), reason="Requires Python 3.9+")
def test_new_syntax():
    pass

@pytest.mark.xfail(reason="Known bug")
def test_buggy_feature():
    pass

@pytest.mark.slow
def test_slow_operation():
    pass
```

### Custom Markers

```python
# pytest.ini or pyproject.toml
[tool.pytest.ini_options]
markers = [
    "slow: marks tests as slow",
    "integration: marks tests as integration tests",
    "unit: marks tests as unit tests",
]

# In tests
@pytest.mark.unit
def test_calculator_add():
    pass

@pytest.mark.integration
def test_database_connection():
    pass

# Run specific markers
# pytest -m unit
# pytest -m "not slow"
```

## Test Coverage

### Measuring Coverage

```bash
# Install coverage tools
pip install pytest-cov

# Run tests with coverage
pytest --cov=myapp

# Generate HTML report
pytest --cov=myapp --cov-report=html

# Show missing lines
pytest --cov=myapp --cov-report=term-missing

# Fail if coverage below threshold
pytest --cov=myapp --cov-fail-under=80
```

### Coverage Configuration

```toml
# pyproject.toml
[tool.coverage.run]
source = ["myapp"]
omit = [
    "*/tests/*",
    "*/test_*.py",
    "*/__init__.py",
]

[tool.coverage.report]
exclude_lines = [
    "pragma: no cover",
    "def __repr__",
    "raise AssertionError",
    "raise NotImplementedError",
    "if __name__ == .__main__.:",
    "if TYPE_CHECKING:",
]
```

**IMPORTANT**: Do not mandate specific coverage percentages as project requirements.

## Test Best Practices

### AAA Pattern

**MUST**: Follow Arrange-Act-Assert pattern:

```python
def test_user_creation():
    # Arrange - Set up test data
    name = "Alice"
    email = "alice@example.com"

    # Act - Perform the action
    user = User(name=name, email=email)

    # Assert - Verify the result
    assert user.name == name
    assert user.email == email
```

### One Assertion Per Test

**Prefer**: One logical assertion per test:

```python
# ✅ GOOD: Focused tests
def test_user_has_correct_name():
    user = User(name="Alice", email="alice@example.com")
    assert user.name == "Alice"

def test_user_has_correct_email():
    user = User(name="Alice", email="alice@example.com")
    assert user.email == "alice@example.com"

# ⚠️ ACCEPTABLE: Related assertions
def test_user_attributes():
    user = User(name="Alice", email="alice@example.com")
    assert user.name == "Alice"
    assert user.email == "alice@example.com"
    assert user.is_active is True
```

### Test Independence

**MUST**: Tests must not depend on execution order:

```python
# ❌ WRONG: Tests depend on order
test_counter = 0

def test_increment():
    global test_counter
    test_counter += 1
    assert test_counter == 1  # Fails if run after other tests!

# ✅ CORRECT: Independent tests
def test_increment():
    counter = Counter()
    counter.increment()
    assert counter.value == 1
```

### Descriptive Test Names

**MUST**: Use descriptive test names:

```python
# ❌ WRONG: Unclear names
def test_1():
    pass

def test_user():
    pass

# ✅ CORRECT: Clear, descriptive names
def test_user_creation_with_valid_data():
    pass

def test_user_creation_fails_with_invalid_email():
    pass

def test_user_deletion_removes_from_database():
    pass
```

## Testing Patterns

### Testing Exceptions

```python
def test_exception_raised():
    with pytest.raises(ValueError) as exc_info:
        parse_age("not a number")

    assert "invalid" in str(exc_info.value).lower()

def test_exception_not_raised():
    # Should not raise
    result = parse_age("25")
    assert result == 25
```

### Testing Async Code

```python
import pytest

@pytest.mark.asyncio
async def test_async_function():
    result = await fetch_data_async()
    assert result is not None

@pytest.fixture
async def async_client():
    client = AsyncClient()
    await client.connect()
    yield client
    await client.disconnect()

@pytest.mark.asyncio
async def test_with_async_fixture(async_client):
    response = await async_client.get("/users")
    assert response.status == 200
```

### Testing Classes

```python
class TestUserService:
    @pytest.fixture(autouse=True)
    def setup(self):
        """Setup run before each test method."""
        self.service = UserService()
        yield
        # Teardown after each test
        self.service.cleanup()

    def test_create_user(self):
        user = self.service.create("Alice", "alice@example.com")
        assert user.name == "Alice"

    def test_delete_user(self):
        user = self.service.create("Bob", "bob@example.com")
        self.service.delete(user.id)
        assert self.service.find(user.id) is None
```

## Debugging Tests

### Using pytest Options

```bash
# Show print statements
pytest -s

# Show local variables on failure
pytest -l

# Drop into debugger on failure
pytest --pdb

# Start debugger at test start
pytest --trace

# Show full diff
pytest -vv

# Run last failed tests only
pytest --lf

# Run failed tests first
pytest --ff
```

### Using breakpoint()

```python
def test_complex_logic():
    data = prepare_data()
    breakpoint()  # Debugger starts here
    result = process(data)
    assert result == expected
```

## Implementation Checklist

- [ ] Use pytest as testing framework
- [ ] Follow AAA pattern (Arrange-Act-Assert)
- [ ] Use descriptive test names
- [ ] Create fixtures for reusable setup
- [ ] Use parametrization for multiple scenarios
- [ ] Mock external dependencies
- [ ] One logical assertion per test
- [ ] Tests are independent of execution order
- [ ] Use appropriate test markers
- [ ] Measure test coverage
- [ ] Handle exceptions properly
- [ ] Test edge cases and error conditions
- [ ] Keep tests fast and focused

## Resources

### In-Depth Guides

- **`resources/pytest-patterns.md`** - Common pytest patterns and recipes
- **`resources/fixtures-guide.md`** - Comprehensive fixture usage guide
- **`resources/mocking-guide.md`** - Mocking and patching strategies
- **`resources/test-organization.md`** - Test structure and organization

### Official Documentation

- [Pytest Documentation](https://docs.pytest.org/)
- [pytest-cov Documentation](https://pytest-cov.readthedocs.io/)
- [pytest-mock Documentation](https://pytest-mock.readthedocs.io/)
- [unittest.mock Documentation](https://docs.python.org/3/library/unittest.mock.html)
- [Testing Best Practices](https://docs.python-guide.org/writing/tests/)

## Remember

- **pytest framework** mandatory | **AAA pattern** for clarity | **Independent tests** required
- **Fixtures** for setup | **Parametrize** for multiple cases | **Mock** external dependencies
- **Descriptive names** for tests | **One assertion** per test (guideline) | Test **edge cases**
- **Fast tests** preferred | **Coverage** as guide (not goal) | **Refactor tests** like production code
