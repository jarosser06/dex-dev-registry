# Pytest Fixtures Comprehensive Guide

Deep dive into pytest fixtures: scopes, factories, dependencies, and advanced patterns.

## Fixture Basics

### What Are Fixtures?

Fixtures are reusable pieces of code that set up test preconditions and cleanup. They provide:
- Test data preparation
- Resource initialization
- Setup and teardown logic
- Dependency injection for tests

### Simple Fixture

```python
import pytest

@pytest.fixture
def sample_data():
    """Provide sample data for tests."""
    return {"name": "Alice", "age": 30}

def test_name(sample_data):
    assert sample_data["name"] == "Alice"

def test_age(sample_data):
    assert sample_data["age"] == 30
```

## Fixture Scopes

### Available Scopes

- **function** (default): Run once per test function
- **class**: Run once per test class
- **module**: Run once per module
- **package**: Run once per package
- **session**: Run once per test session

### Function Scope

```python
@pytest.fixture(scope="function")
def fresh_data():
    """New data for each test."""
    data = create_data()
    yield data
    cleanup_data(data)

def test_one(fresh_data):
    # Gets new data
    pass

def test_two(fresh_data):
    # Gets different new data
    pass
```

### Class Scope

```python
@pytest.fixture(scope="class")
def database_connection():
    """Shared connection for all tests in class."""
    conn = Database.connect()
    yield conn
    conn.close()

class TestDatabaseOperations:
    def test_insert(self, database_connection):
        # Uses same connection
        pass

    def test_query(self, database_connection):
        # Uses same connection
        pass
```

### Module Scope

```python
@pytest.fixture(scope="module")
def app():
    """Application instance for entire test module."""
    app = create_app()
    yield app
    app.shutdown()

def test_route_one(app):
    # Uses same app instance
    pass

def test_route_two(app):
    # Uses same app instance
    pass
```

### Session Scope

```python
@pytest.fixture(scope="session")
def test_config():
    """Configuration loaded once for entire test session."""
    config = load_test_config()
    return config

def test_setting_one(test_config):
    assert test_config["debug"] is True

def test_setting_two(test_config):
    assert test_config["database"] == "test.db"
```

## Fixture Teardown

### Using yield for Cleanup

```python
@pytest.fixture
def temp_file():
    """Create file and clean up after test."""
    file_path = Path("temp.txt")
    file_path.write_text("test")
    yield file_path
    # Cleanup runs after test
    if file_path.exists():
        file_path.unlink()

def test_file_exists(temp_file):
    assert temp_file.exists()
```

### Multiple Cleanup Steps

```python
@pytest.fixture
def complex_resource():
    """Resource with multiple cleanup steps."""
    resource = Resource()
    resource.initialize()
    resource.connect()

    yield resource

    # Cleanup in reverse order
    resource.disconnect()
    resource.cleanup()
    resource.destroy()
```

### Cleanup on Fixture Failure

```python
@pytest.fixture
def safe_cleanup():
    """Ensure cleanup even if fixture setup fails."""
    resource = None
    try:
        resource = acquire_resource()
        yield resource
    finally:
        if resource is not None:
            release_resource(resource)
```

## Fixture Dependencies

### Fixtures Using Other Fixtures

```python
@pytest.fixture
def database():
    """Database connection."""
    db = Database.connect()
    yield db
    db.close()

@pytest.fixture
def user_repository(database):
    """User repository depends on database fixture."""
    return UserRepository(database)

@pytest.fixture
def sample_user(user_repository):
    """Sample user depends on repository."""
    user = User(name="Alice")
    user_repository.save(user)
    return user

def test_user_retrieval(sample_user, user_repository):
    found = user_repository.find_by_name("Alice")
    assert found == sample_user
```

### Fixture Dependency Chain

```python
@pytest.fixture
def config():
    return {"db_url": "sqlite:///:memory:"}

@pytest.fixture
def engine(config):
    return create_engine(config["db_url"])

@pytest.fixture
def session(engine):
    Base.metadata.create_all(engine)
    session = Session(engine)
    yield session
    session.close()

@pytest.fixture
def populated_db(session):
    # Add test data
    session.add(User(name="Alice"))
    session.commit()
    return session

def test_with_data(populated_db):
    users = populated_db.query(User).all()
    assert len(users) == 1
```

## Fixture Factories

### Basic Factory Pattern

```python
@pytest.fixture
def user_factory():
    """Factory for creating users."""
    def create_user(name="Default", email=None):
        if email is None:
            email = f"{name.lower()}@example.com"
        return User(name=name, email=email)
    return create_user

def test_multiple_users(user_factory):
    alice = user_factory("Alice")
    bob = user_factory("Bob", "bob@custom.com")
    assert alice.name == "Alice"
    assert bob.email == "bob@custom.com"
```

### Factory with Cleanup Tracking

```python
@pytest.fixture
def user_factory(database):
    """Factory that tracks created users for cleanup."""
    created_users = []

    def create_user(**kwargs):
        user = User(**kwargs)
        database.save(user)
        created_users.append(user)
        return user

    yield create_user

    # Cleanup all created users
    for user in created_users:
        database.delete(user)

def test_user_interactions(user_factory):
    alice = user_factory(name="Alice")
    bob = user_factory(name="Bob")
    # Both users automatically cleaned up
```

### Advanced Factory with Builder Pattern

```python
@pytest.fixture
def user_builder():
    """Builder pattern factory for complex objects."""
    class UserBuilder:
        def __init__(self):
            self.name = "Default"
            self.email = "default@example.com"
            self.age = 25
            self.is_admin = False

        def with_name(self, name):
            self.name = name
            return self

        def with_email(self, email):
            self.email = email
            return self

        def with_age(self, age):
            self.age = age
            return self

        def as_admin(self):
            self.is_admin = True
            return self

        def build(self):
            return User(
                name=self.name,
                email=self.email,
                age=self.age,
                is_admin=self.is_admin
            )

    return UserBuilder

def test_admin_user(user_builder):
    admin = user_builder().with_name("Admin").as_admin().build()
    assert admin.is_admin is True
```

## Parametrized Fixtures

### Basic Parametrization

```python
@pytest.fixture(params=["sqlite", "postgres", "mysql"])
def database_type(request):
    """Test runs once for each database type."""
    return request.param

def test_database_operations(database_type):
    db = create_database(database_type)
    # Test runs 3 times
```

### Parametrized with Setup/Teardown

```python
@pytest.fixture(params=["dev", "staging", "production"])
def environment(request):
    """Setup environment, run test, teardown."""
    env_name = request.param
    env = setup_environment(env_name)
    yield env
    teardown_environment(env)

def test_environment_config(environment):
    assert environment.is_configured()
```

### IDs for Parametrized Fixtures

```python
@pytest.fixture(
    params=[
        {"type": "admin", "permissions": ["read", "write", "delete"]},
        {"type": "user", "permissions": ["read"]},
        {"type": "guest", "permissions": []},
    ],
    ids=["admin", "user", "guest"]
)
def user_role(request):
    return request.param

def test_permissions(user_role):
    user = User(role=user_role["type"])
    assert user.permissions == user_role["permissions"]
```

## Auto-use Fixtures

### Module-level Auto-use

```python
@pytest.fixture(autouse=True)
def setup_test_environment():
    """Automatically run before each test in module."""
    os.environ["TEST_MODE"] = "true"
    yield
    os.environ.pop("TEST_MODE", None)

def test_environment():
    # Fixture runs automatically
    assert os.environ["TEST_MODE"] == "true"
```

### Class-level Auto-use

```python
class TestWithAutoFixture:
    @pytest.fixture(autouse=True)
    def setup_method(self):
        """Run before each test method."""
        self.data = {"key": "value"}
        yield
        self.data = None

    def test_one(self):
        assert self.data["key"] == "value"

    def test_two(self):
        assert "key" in self.data
```

### Session-level Auto-use

```python
@pytest.fixture(scope="session", autouse=True)
def setup_test_session():
    """Run once at start of test session."""
    initialize_test_database()
    yield
    cleanup_test_database()
```

## Fixture Introspection

### Using request Fixture

```python
@pytest.fixture
def logger(request):
    """Logger with test name."""
    test_name = request.node.name
    module = request.module.__name__
    logger = logging.getLogger(f"{module}.{test_name}")
    return logger

def test_with_logging(logger):
    logger.info("Test is running")
```

### Accessing Test Markers

```python
@pytest.fixture
def test_timeout(request):
    """Get timeout from test marker."""
    marker = request.node.get_closest_marker("timeout")
    if marker:
        return marker.args[0]
    return 30  # default

@pytest.mark.timeout(60)
def test_slow_operation(test_timeout):
    assert test_timeout == 60
```

### Conditional Fixture Behavior

```python
@pytest.fixture
def database(request):
    """Use in-memory DB for unit tests, real DB for integration."""
    if "integration" in request.node.keywords:
        db = create_real_database()
    else:
        db = create_memory_database()
    yield db
    db.close()

@pytest.mark.unit
def test_unit(database):
    # Uses in-memory database
    pass

@pytest.mark.integration
def test_integration(database):
    # Uses real database
    pass
```

## Fixture Best Practices

### Keep Fixtures Focused

```python
# ✅ GOOD: Single responsibility
@pytest.fixture
def database():
    db = Database.connect()
    yield db
    db.close()

@pytest.fixture
def test_data():
    return [1, 2, 3, 4, 5]

# ❌ BAD: Doing too much
@pytest.fixture
def everything():
    db = Database.connect()
    data = load_data()
    user = create_user()
    # Too many responsibilities
    yield db, data, user
    cleanup_user(user)
    cleanup_data(data)
    db.close()
```

### Name Fixtures Clearly

```python
# ✅ GOOD: Clear names
@pytest.fixture
def authenticated_user():
    pass

@pytest.fixture
def empty_shopping_cart():
    pass

# ❌ BAD: Unclear names
@pytest.fixture
def user():  # Which user? Any user?
    pass

@pytest.fixture
def data():  # What kind of data?
    pass
```

### Avoid Side Effects

```python
# ✅ GOOD: No side effects
@pytest.fixture
def user_data():
    return {"name": "Alice", "age": 30}

# ❌ BAD: Modifies global state
counter = 0

@pytest.fixture
def incremented_counter():
    global counter
    counter += 1
    return counter
```

## Common Fixture Patterns

### Database Fixture with Transaction Rollback

```python
@pytest.fixture
def db_session():
    """Provide database session with automatic rollback."""
    session = Session(engine)
    session.begin()
    yield session
    session.rollback()
    session.close()

def test_database_changes(db_session):
    user = User(name="Test")
    db_session.add(user)
    db_session.flush()
    # Changes rolled back after test
```

### Temporary Directory Fixture

```python
@pytest.fixture
def temp_workspace(tmp_path):
    """Create temporary workspace with structure."""
    workspace = tmp_path / "workspace"
    workspace.mkdir()
    (workspace / "data").mkdir()
    (workspace / "output").mkdir()
    return workspace

def test_file_operations(temp_workspace):
    data_file = temp_workspace / "data" / "test.txt"
    data_file.write_text("content")
    assert data_file.exists()
```

### API Client Fixture

```python
@pytest.fixture
def api_client():
    """API client with authentication."""
    client = APIClient(base_url="http://test.api")
    client.authenticate(api_key="test_key")
    yield client
    client.close()

def test_api_endpoint(api_client):
    response = api_client.get("/users")
    assert response.status_code == 200
```

### Mock Service Fixture

```python
@pytest.fixture
def mock_email_service(mocker):
    """Mock email service for testing."""
    mock = mocker.Mock(spec=EmailService)
    mock.send.return_value = True
    return mock

def test_notification(mock_email_service):
    send_notification(mock_email_service, "user@example.com")
    mock_email_service.send.assert_called_once()
```

## Advanced Patterns

### Fixture Composition

```python
@pytest.fixture
def base_config():
    return {"debug": True}

@pytest.fixture
def dev_config(base_config):
    return {**base_config, "env": "development"}

@pytest.fixture
def test_config(base_config):
    return {**base_config, "env": "testing", "debug": False}

def test_with_test_config(test_config):
    assert test_config["env"] == "testing"
    assert test_config["debug"] is False
```

### Fixture Override

```python
# conftest.py
@pytest.fixture
def config():
    return {"mode": "default"}

# test_custom.py
@pytest.fixture
def config():
    """Override default config for this module."""
    return {"mode": "custom"}

def test_config_override(config):
    assert config["mode"] == "custom"
```

### Cached Property Fixtures

```python
@pytest.fixture(scope="module")
def expensive_computation():
    """Compute once, use many times."""
    result = perform_expensive_computation()
    return result

def test_one(expensive_computation):
    assert expensive_computation > 0

def test_two(expensive_computation):
    # Uses cached result
    assert expensive_computation < 1000
```

## Fixture Organization

### conftest.py Hierarchy

```
project/
├── conftest.py          # Session-level fixtures
├── tests/
│   ├── conftest.py      # Shared test fixtures
│   ├── unit/
│   │   ├── conftest.py  # Unit test fixtures
│   │   └── test_*.py
│   └── integration/
│       ├── conftest.py  # Integration test fixtures
│       └── test_*.py
```

### Fixture Discovery

Pytest discovers fixtures from:
1. Same file as test
2. conftest.py in same directory
3. conftest.py in parent directories
4. conftest.py at project root

## Debugging Fixtures

### Using --fixtures Flag

```bash
# List all available fixtures
pytest --fixtures

# List fixtures with docstrings
pytest --fixtures -v

# List fixtures from specific file
pytest --fixtures tests/conftest.py
```

### Fixture Execution Order

```python
@pytest.fixture
def first():
    print("First setup")
    yield
    print("First teardown")

@pytest.fixture
def second(first):
    print("Second setup")
    yield
    print("Second teardown")

def test_order(second):
    print("Test execution")

# Output:
# First setup
# Second setup
# Test execution
# Second teardown
# First teardown
```

## Resources

- [Pytest Fixtures Documentation](https://docs.pytest.org/en/stable/fixture.html)
- [Fixture Scopes](https://docs.pytest.org/en/stable/fixture.html#scope-sharing-fixtures-across-classes-modules-packages-or-session)
- [Fixture Parametrization](https://docs.pytest.org/en/stable/fixture.html#parametrizing-fixtures)
