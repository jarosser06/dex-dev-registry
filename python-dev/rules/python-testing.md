# Python Testing Standards

## Test Framework

**MUST**: Use pytest as the primary testing framework

**MUST**: Follow pytest naming conventions for test discovery

**Examples:**
```python
# ✅ CORRECT: Pytest conventions
# File: test_user.py
def test_user_creation():
    pass

class TestUserAuthentication:
    def test_login_success(self):
        pass

# ❌ WRONG: Missing 'test_' prefix
# File: user_tests.py
def check_user_creation():
    pass
```

## Test Organization

**MUST**: Mirror source code structure in test directory

**MUST**: Use descriptive test names that explain what is being tested

**Examples:**
```
# ✅ CORRECT: Clear structure
myproject/
├── myapp/
│   ├── models.py
│   └── services.py
└── tests/
    ├── test_models.py
    └── test_services.py

# ❌ WRONG: Unclear structure
myproject/
├── myapp/
│   ├── models.py
│   └── services.py
└── tests/
    └── test.py
```

## Test Naming

**MUST**: Use pattern `test_<what>_<condition>_<expected_result>`

**Examples:**
```python
# ✅ CORRECT: Descriptive names
def test_user_login_with_valid_credentials_succeeds():
    pass

def test_user_login_with_invalid_password_fails():
    pass

def test_order_calculation_with_discount_applies_correctly():
    pass

# ❌ WRONG: Unclear names
def test_login():
    pass

def test_user1():
    pass

def test_case_1():
    pass
```

## Test Independence

**MUST**: Write tests that are independent of execution order

**MUST NOT**: Share mutable state between tests

**Examples:**
```python
# ✅ CORRECT: Independent tests
def test_user_creation():
    user = User("Alice")
    assert user.name == "Alice"

def test_user_deletion():
    user = User("Bob")
    user.delete()
    assert user.is_deleted

# ❌ WRONG: Tests share state
_test_user = None

def test_create():
    global _test_user
    _test_user = User("Alice")

def test_delete():
    # Fails if test_create doesn't run first!
    _test_user.delete()
```

## Fixtures

**MUST**: Use fixtures for test setup and teardown

**MUST**: Place shared fixtures in `conftest.py`

**Examples:**
```python
# ✅ CORRECT: Using fixtures
@pytest.fixture
def sample_user():
    return User(name="Alice", email="alice@example.com")

def test_user_name(sample_user):
    assert sample_user.name == "Alice"

# ❌ WRONG: Repeated setup
def test_user_name():
    user = User(name="Alice", email="alice@example.com")
    assert user.name == "Alice"

def test_user_email():
    user = User(name="Alice", email="alice@example.com")
    assert user.email == "alice@example.com"
```

## AAA Pattern

**MUST**: Follow Arrange-Act-Assert pattern in tests

**Examples:**
```python
# ✅ CORRECT: Clear AAA structure
def test_user_creation():
    # Arrange
    name = "Alice"
    email = "alice@example.com"

    # Act
    user = User(name=name, email=email)

    # Assert
    assert user.name == name
    assert user.email == email

# ❌ WRONG: Mixed arrangement
def test_user_creation():
    user = User(name="Alice", email="alice@example.com")
    assert user.name == "Alice"
    user.activate()
    assert user.is_active
```

## Assertions

**MUST**: Use clear, specific assertions

**MUST**: Include helpful assertion messages when needed

**Examples:**
```python
# ✅ CORRECT: Specific assertions
def test_user_age():
    user = User(name="Alice", age=30)
    assert user.age == 30, f"Expected age 30, got {user.age}"

# ✅ CORRECT: Using pytest helpers
def test_exception_raised():
    with pytest.raises(ValueError, match="invalid email"):
        User(name="Alice", email="invalid")

# ❌ WRONG: Generic assertions
def test_user():
    user = User(name="Alice")
    assert user
```

## Mocking

**MUST**: Mock external dependencies (APIs, databases, file systems)

**MUST**: Use appropriate mock scope (patch at usage point)

**Examples:**
```python
# ✅ CORRECT: Mock external API
@patch("myapp.api.requests.get")
def test_fetch_user_data(mock_get):
    mock_get.return_value.json.return_value = {"name": "Alice"}
    result = fetch_user_data(user_id=1)
    assert result["name"] == "Alice"

# ❌ WRONG: Real API call in test
def test_fetch_user_data():
    result = fetch_user_data(user_id=1)  # Makes real API call!
    assert result["name"] == "Alice"
```

## Parametrization

**MUST**: Use parametrization for testing multiple scenarios

**Examples:**
```python
# ✅ CORRECT: Parametrized test
@pytest.mark.parametrize("input,expected", [
    (2, 4),
    (3, 9),
    (4, 16),
])
def test_square(input, expected):
    assert input ** 2 == expected

# ❌ WRONG: Repeated tests
def test_square_2():
    assert 2 ** 2 == 4

def test_square_3():
    assert 3 ** 2 == 9

def test_square_4():
    assert 4 ** 2 == 16
```

## Test Coverage

**MUST**: Write tests for new features and bug fixes

**MUST**: Aim for meaningful test coverage

**MUST NOT**: Focus on coverage percentage as the primary goal

**Note**: Coverage is a guide, not a target. Well-designed tests are more valuable than high coverage numbers.

## Exception Testing

**MUST**: Test both success and failure cases

**MUST**: Verify exception types and messages

**Examples:**
```python
# ✅ CORRECT: Testing exceptions
def test_invalid_age_raises_error():
    with pytest.raises(ValueError, match="Age must be positive"):
        User(name="Alice", age=-1)

def test_valid_age_succeeds():
    user = User(name="Alice", age=30)
    assert user.age == 30

# ❌ WRONG: Only testing success case
def test_user_age():
    user = User(name="Alice", age=30)
    assert user.age == 30
```

## Test Markers

**MUST**: Use markers to categorize tests

**MUST**: Define markers in `pytest.ini` or `pyproject.toml`

**Examples:**
```python
# Configuration
[tool.pytest.ini_options]
markers = [
    "slow: marks tests as slow",
    "integration: integration tests",
    "unit: unit tests",
]

# Usage
@pytest.mark.unit
def test_fast_unit_test():
    pass

@pytest.mark.integration
def test_database_integration():
    pass

@pytest.mark.slow
def test_expensive_operation():
    pass

# Run specific markers:
# pytest -m unit
# pytest -m "not slow"
```

## Test Data

**MUST**: Use fixtures or factories for test data

**MUST NOT**: Use production data in tests

**Examples:**
```python
# ✅ CORRECT: Test data factory
@pytest.fixture
def user_factory():
    def create_user(name="Test", email=None):
        if email is None:
            email = f"{name.lower()}@example.com"
        return User(name=name, email=email)
    return create_user

def test_multiple_users(user_factory):
    alice = user_factory("Alice")
    bob = user_factory("Bob")
    assert alice.name != bob.name

# ❌ WRONG: Hardcoded production data
def test_user():
    user = User(name="John Smith", email="john.smith@realcompany.com")
    # Using real user data!
```

## Test Speed

**MUST**: Keep unit tests fast (under 100ms each)

**MUST**: Use markers for slow tests

**MUST**: Mock expensive operations in unit tests

**Examples:**
```python
# ✅ CORRECT: Fast unit test with mocking
@patch("myapp.expensive_api_call")
def test_process_data(mock_api):
    mock_api.return_value = {"data": "test"}
    result = process_data()
    assert result is not None

# ❌ WRONG: Slow test in unit suite
def test_process_data():
    # Makes real API call - slow!
    result = expensive_api_call()
    processed = process_data(result)
    assert processed is not None
```

## Async Testing

**MUST**: Use `@pytest.mark.asyncio` for async tests

**MUST**: Use `AsyncMock` for mocking async functions

**Examples:**
```python
# ✅ CORRECT: Async test
@pytest.mark.asyncio
async def test_async_function():
    result = await fetch_data_async()
    assert result is not None

@pytest.mark.asyncio
@patch("myapp.fetch_async", new_callable=AsyncMock)
async def test_with_async_mock(mock_fetch):
    mock_fetch.return_value = {"data": "test"}
    result = await process_async()
    assert result["data"] == "test"
```

## Continuous Integration

**MUST**: Run all tests in CI/CD pipeline

**MUST**: Fail builds on test failures

**Example GitHub Actions:**
```yaml
- name: Run tests
  run: pytest tests/

- name: Run tests with coverage
  run: pytest --cov=myapp --cov-report=term-missing
```
