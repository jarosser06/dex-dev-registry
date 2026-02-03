# Test Organization and Structure

Guide to organizing Python tests for maintainability, discoverability, and scalability.

## Directory Structure

### Basic Test Layout

```
myproject/
├── myapp/                      # Application code
│   ├── __init__.py
│   ├── models.py
│   ├── services.py
│   └── utils.py
└── tests/                      # Test code
    ├── __init__.py
    ├── conftest.py             # Shared fixtures
    ├── test_models.py
    ├── test_services.py
    └── test_utils.py
```

### Hierarchical Test Organization

```
myproject/
├── myapp/
│   ├── __init__.py
│   ├── api/
│   │   ├── __init__.py
│   │   ├── routes.py
│   │   └── handlers.py
│   ├── database/
│   │   ├── __init__.py
│   │   ├── models.py
│   │   └── repositories.py
│   └── services/
│       ├── __init__.py
│       └── user_service.py
└── tests/
    ├── __init__.py
    ├── conftest.py             # Root fixtures
    ├── unit/                   # Unit tests
    │   ├── conftest.py         # Unit test fixtures
    │   ├── test_models.py
    │   └── test_services.py
    ├── integration/            # Integration tests
    │   ├── conftest.py         # Integration fixtures
    │   ├── test_api.py
    │   └── test_database.py
    └── e2e/                    # End-to-end tests
        ├── conftest.py
        └── test_workflows.py
```

## Test Naming Conventions

### File Names

**Pattern:** `test_*.py` or `*_test.py`

```
✅ GOOD:
- test_user.py
- test_authentication.py
- user_test.py

❌ BAD:
- user.py
- test.py
- tests_user.py
```

### Function Names

**Pattern:** `test_<what>_<condition>_<expected_result>`

```python
# ✅ GOOD: Descriptive names
def test_user_login_with_valid_credentials_succeeds():
    pass

def test_user_login_with_invalid_password_fails():
    pass

def test_order_calculation_with_discount_applies_correctly():
    pass

# ❌ BAD: Unclear names
def test_login():
    pass

def test_user1():
    pass

def test_edge_case():
    pass
```

### Class Names

**Pattern:** `Test<Feature>` or `Test<ClassName>`

```python
# ✅ GOOD
class TestUserAuthentication:
    pass

class TestShoppingCart:
    pass

class TestPaymentProcessing:
    pass

# ❌ BAD
class UserTests:  # Missing 'Test' prefix
    pass

class TestCases:  # Too generic
    pass
```

## Test Organization Patterns

### Organize by Feature

```python
# test_shopping_cart.py

class TestShoppingCartCreation:
    def test_create_empty_cart(self):
        pass

    def test_create_cart_with_items(self):
        pass

class TestShoppingCartOperations:
    def test_add_item(self):
        pass

    def test_remove_item(self):
        pass

    def test_update_quantity(self):
        pass

class TestShoppingCartCalculations:
    def test_calculate_subtotal(self):
        pass

    def test_calculate_tax(self):
        pass

    def test_calculate_total(self):
        pass
```

### Organize by Test Type

```
tests/
├── unit/                       # Fast, isolated tests
│   ├── test_models.py
│   └── test_utils.py
├── integration/                # Tests with real dependencies
│   ├── test_database.py
│   └── test_api.py
├── functional/                 # End-to-end workflows
│   └── test_user_flows.py
└── performance/                # Load and stress tests
    └── test_api_performance.py
```

### Organize by Component

```
tests/
├── models/
│   ├── test_user.py
│   ├── test_product.py
│   └── test_order.py
├── services/
│   ├── test_user_service.py
│   ├── test_payment_service.py
│   └── test_notification_service.py
└── api/
    ├── test_auth_routes.py
    └── test_user_routes.py
```

## conftest.py Organization

### Root conftest.py

Session and shared fixtures:

```python
# tests/conftest.py
import pytest

@pytest.fixture(scope="session")
def app_config():
    """Application configuration for tests."""
    return {
        "debug": True,
        "testing": True,
        "database_url": "sqlite:///:memory:"
    }

@pytest.fixture(scope="session")
def app(app_config):
    """Application instance."""
    app = create_app(app_config)
    yield app
    app.cleanup()

@pytest.fixture
def client(app):
    """Test client for making requests."""
    return app.test_client()
```

### Test-type Specific conftest.py

```python
# tests/unit/conftest.py
import pytest

@pytest.fixture
def mock_database(mocker):
    """Mock database for unit tests."""
    return mocker.Mock(spec=Database)

# tests/integration/conftest.py
import pytest

@pytest.fixture(scope="module")
def real_database():
    """Real database for integration tests."""
    db = Database(url="postgresql://test")
    db.create_all()
    yield db
    db.drop_all()
    db.close()
```

### Feature-specific conftest.py

```python
# tests/user/conftest.py
import pytest

@pytest.fixture
def sample_user():
    """Sample user for user-related tests."""
    return User(name="Test User", email="test@example.com")

@pytest.fixture
def authenticated_user(sample_user):
    """Authenticated user with token."""
    sample_user.authenticate()
    return sample_user
```

## Test Grouping Strategies

### By Test Class

```python
class TestUserRegistration:
    """Test user registration flow."""

    @pytest.fixture(autouse=True)
    def setup(self):
        """Setup for all tests in this class."""
        self.email_service = EmailService()

    def test_registration_with_valid_data(self):
        pass

    def test_registration_with_duplicate_email(self):
        pass

    def test_registration_sends_confirmation_email(self):
        pass
```

### By Markers

```python
# Define markers in pytest.ini or pyproject.toml
# [tool.pytest.ini_options]
# markers = [
#     "slow: marks tests as slow",
#     "integration: integration tests",
#     "unit: unit tests",
# ]

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
# pytest -m "integration and not slow"
```

### By Parametrization

```python
@pytest.mark.parametrize("role,expected_access", [
    ("admin", ["read", "write", "delete"]),
    ("user", ["read", "write"]),
    ("guest", ["read"]),
])
def test_role_permissions(role, expected_access):
    user = User(role=role)
    assert user.permissions == expected_access
```

## Test Data Management

### Test Data in Same File

For simple, focused tests:

```python
def test_user_creation():
    # Test data inline
    user_data = {
        "name": "Alice",
        "email": "alice@example.com",
        "age": 30
    }
    user = User(**user_data)
    assert user.name == "Alice"
```

### Test Data in Fixtures

For reusable test data:

```python
# conftest.py
@pytest.fixture
def sample_user_data():
    return {
        "name": "Alice",
        "email": "alice@example.com",
        "age": 30
    }

# test_user.py
def test_user_creation(sample_user_data):
    user = User(**sample_user_data)
    assert user.name == "Alice"
```

### Test Data in Files

For complex or large datasets:

```
tests/
├── fixtures/
│   ├── users.json
│   ├── products.json
│   └── orders.json
└── test_data_processing.py
```

```python
import json
from pathlib import Path

@pytest.fixture
def user_data():
    """Load user test data from JSON file."""
    data_path = Path(__file__).parent / "fixtures" / "users.json"
    with data_path.open() as f:
        return json.load(f)

def test_user_import(user_data):
    users = import_users(user_data)
    assert len(users) == len(user_data)
```

### Test Factories

For dynamic test data:

```python
# conftest.py
@pytest.fixture
def user_factory():
    """Factory for creating test users."""
    counter = 0

    def make_user(name=None, email=None):
        nonlocal counter
        counter += 1
        return User(
            name=name or f"User{counter}",
            email=email or f"user{counter}@example.com"
        )

    return make_user

# test_user.py
def test_multiple_users(user_factory):
    alice = user_factory("Alice", "alice@example.com")
    bob = user_factory("Bob")  # Email auto-generated
    assert alice.name != bob.name
```

## Test Documentation

### Module Docstrings

```python
"""
Tests for user authentication and authorization.

These tests cover:
- User login with valid/invalid credentials
- Session management
- Permission checks
- Password reset flow
"""

def test_login_with_valid_credentials():
    pass
```

### Class Docstrings

```python
class TestPaymentProcessing:
    """Test payment processing functionality.

    Tests various payment scenarios including:
    - Successful payments
    - Failed transactions
    - Refunds
    - Partial payments
    """

    def test_successful_payment(self):
        pass
```

### Function Docstrings

```python
def test_user_registration_with_invalid_email():
    """Test that user registration fails with invalid email format.

    Given: An invalid email address
    When: User attempts to register
    Then: Registration fails with appropriate error
    """
    pass
```

## Running Tests

### Run All Tests

```bash
pytest
```

### Run Specific Test File

```bash
pytest tests/test_user.py
```

### Run Specific Test Function

```bash
pytest tests/test_user.py::test_user_creation
```

### Run Tests by Pattern

```bash
pytest -k "user and not delete"
pytest -k "test_login"
```

### Run Tests by Marker

```bash
pytest -m unit
pytest -m "not slow"
pytest -m "integration and not flaky"
```

### Run Tests in Parallel

```bash
pip install pytest-xdist
pytest -n auto  # Use all CPU cores
pytest -n 4     # Use 4 workers
```

## Test Configuration

### pytest.ini

```ini
[pytest]
# Test discovery patterns
python_files = test_*.py *_test.py
python_classes = Test*
python_functions = test_*

# Options
addopts =
    --strict-markers
    --verbose
    --cov=myapp
    --cov-report=html
    --cov-report=term-missing

# Test paths
testpaths = tests

# Markers
markers =
    slow: marks tests as slow
    integration: integration tests
    unit: unit tests
    smoke: smoke tests
    wip: work in progress tests
```

### pyproject.toml

```toml
[tool.pytest.ini_options]
minversion = "7.0"
testpaths = ["tests"]
python_files = ["test_*.py", "*_test.py"]
python_classes = ["Test*"]
python_functions = ["test_*"]

addopts = [
    "--strict-markers",
    "--strict-config",
    "--verbose",
]

markers = [
    "slow: marks tests as slow",
    "integration: integration tests",
    "unit: unit tests",
]
```

## Best Practices

### Keep Tests Independent

```python
# ✅ GOOD: Each test is independent
def test_user_creation():
    user = User("Alice")
    assert user.name == "Alice"

def test_user_deletion():
    user = User("Bob")
    user.delete()
    assert user.is_deleted

# ❌ BAD: Tests depend on order
_test_user = None

def test_create():
    global _test_user
    _test_user = User("Alice")

def test_delete():
    # Fails if test_create doesn't run first!
    _test_user.delete()
```

### One Assertion Per Test (Guideline)

```python
# ✅ PREFERRED: Focused tests
def test_user_name():
    user = User("Alice", "alice@example.com")
    assert user.name == "Alice"

def test_user_email():
    user = User("Alice", "alice@example.com")
    assert user.email == "alice@example.com"

# ⚠️ ACCEPTABLE: Related assertions
def test_user_attributes():
    user = User("Alice", "alice@example.com")
    assert user.name == "Alice"
    assert user.email == "alice@example.com"
    assert user.is_active is True
```

### Fast Tests

```python
# ✅ GOOD: Mock expensive operations
@patch("myapp.api.expensive_api_call")
def test_fast(mock_api):
    mock_api.return_value = {"data": "test"}
    result = process_data()
    assert result is not None

# ❌ BAD: Real API calls in unit tests
def test_slow():
    result = expensive_api_call()  # Slow!
    assert result is not None
```

### Clear Test Names

```python
# ✅ GOOD
def test_user_login_with_valid_credentials_returns_token():
    pass

def test_user_login_with_invalid_password_raises_authentication_error():
    pass

# ❌ BAD
def test_login1():
    pass

def test_login2():
    pass
```

## Anti-patterns to Avoid

### Don't Test Implementation Details

```python
# ❌ BAD: Testing implementation
def test_internal_method():
    service = UserService()
    assert service._internal_helper() == "value"

# ✅ GOOD: Test public interface
def test_user_creation():
    service = UserService()
    user = service.create_user("Alice")
    assert user.name == "Alice"
```

### Don't Share State Between Tests

```python
# ❌ BAD: Shared mutable state
shared_list = []

def test_append():
    shared_list.append(1)
    assert len(shared_list) == 1

def test_another():
    # Fails if test_append runs first!
    assert len(shared_list) == 0

# ✅ GOOD: Fresh state per test
@pytest.fixture
def fresh_list():
    return []

def test_append(fresh_list):
    fresh_list.append(1)
    assert len(fresh_list) == 1
```

### Don't Use Too Many Fixtures

```python
# ❌ BAD: Too many dependencies
def test_complex(
    fixture1, fixture2, fixture3, fixture4,
    fixture5, fixture6, fixture7, fixture8
):
    pass

# ✅ GOOD: Combine related fixtures
@pytest.fixture
def test_environment(database, cache, config, logger):
    return TestEnvironment(database, cache, config, logger)

def test_simple(test_environment):
    pass
```

## Resources

- [Pytest Documentation](https://docs.pytest.org/)
- [Test Organization Best Practices](https://docs.pytest.org/en/stable/explanation/goodpractices.html)
- [Effective Python Testing](https://realpython.com/pytest-python-testing/)
