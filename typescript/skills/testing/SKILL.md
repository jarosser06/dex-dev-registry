---
name: testing
description: Expert in testing TypeScript applications with unit tests and E2E validation using Chrome DevTools MCP
allowed-tools: mcp__chrome-devtools__*
---

# Testing Skill

Expert in creating comprehensive test suites for TypeScript applications using Chrome DevTools MCP for end-to-end testing and validation.

## Test Framework

**Unit Tests:** Jest (or your preferred test framework like Vitest, Mocha)
**E2E Validation:** Chrome DevTools MCP

**Run unit tests:**
```bash
npm run test              # Run all unit tests with coverage
npm run test:watch        # Run in watch mode
npm run test:coverage     # Generate coverage report
```

## Coverage Requirements

- **Minimum:** 90% unit test coverage for all code
- **Target:** 95% for core business logic
- **E2E Coverage Focus:**
  - All authentication flows
  - All API routes
  - Critical user journeys
  - Error handling paths

## Recommended Test Organization

```
tests/
  ├── unit/               # Unit tests
  │   ├── api/           # API route tests
  │   ├── models/        # Model tests
  │   └── services/      # Service tests
  └── fixtures/          # Test fixtures and helpers
```

**File naming:** `*.test.ts` for unit tests

## Testing Standards

### Unit Tests with Jest

- Test business logic in isolation
- Mock external dependencies
- Use descriptive test names
- Follow AAA pattern (Arrange, Act, Assert)
- Test edge cases and error scenarios

### E2E Validation with Chrome DevTools MCP

- Use `mcp__chrome-devtools` for interactive browser testing
- Validate UI functionality manually during development
- Test complete user workflows
- Verify accessibility with snapshots
- Test interactions and form submissions

### API Route Tests

- Test all API endpoints
- Verify request/response formats
- Test authentication/authorization
- Test error handling
- Validate data persistence

## Chrome DevTools MCP Tools

**Navigation:**
- `mcp__chrome-devtools__navigate_page` - Navigate to pages
- `mcp__chrome-devtools__navigate_back` - Go back in history

**Inspection:**
- `mcp__chrome-devtools__take_snapshot` - Accessibility snapshot
- `mcp__chrome-devtools__take_screenshot` - Visual screenshot

**Interaction:**
- `mcp__chrome-devtools__click` - Click elements
- `mcp__chrome-devtools__fill` - Fill form fields
- `mcp__chrome-devtools__browser_type` - Type text
- `mcp__chrome-devtools__browser_fill_form` - Fill multiple fields

**Validation:**
- `mcp__chrome-devtools__evaluate_script` - Run JavaScript
- `mcp__chrome-devtools__browser_console_messages` - Check console
- `mcp__chrome-devtools__browser_network_requests` - Check network

## Code Examples

### Unit Test Example

```typescript
import { describe, it, expect } from '@jest/globals';
import { createUser } from '@/services/user';

describe('User Service', () => {
  it('should create a new user', async () => {
    // Arrange
    const userData = {
      email: 'test@example.com',
      name: 'Test User'
    };

    // Act
    const user = await createUser(userData);

    // Assert
    expect(user).toBeDefined();
    expect(user.email).toBe(userData.email);
  });
});
```

### API Route Test

```typescript
import { describe, it, expect } from '@jest/globals';

describe('POST /api/items', () => {
  it('should create a new item', async () => {
    const request = new Request('http://localhost:3000/api/items', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        title: 'Test Item',
        description: 'Test Description'
      })
    });

    const response = await fetch(request);
    const data = await response.json();

    expect(response.status).toBe(201);
    expect(data.title).toBe('Test Item');
  });
});
```

### E2E Validation Workflow

When validating a new feature:

1. **Start your development server:**
   ```bash
   npm run dev   # or your project's dev server command
   ```

2. **Use Chrome DevTools MCP to validate:**
   ```
   - Navigate to the feature page
   - Take accessibility snapshot
   - Test interactions (clicks, form fills)
   - Verify expected behavior
   - Check console for errors
   - Review network requests
   ```

## Best Practices

1. **Test Isolation:** Each test should be independent
2. **Descriptive Names:** Test names should describe the expected behavior
3. **Edge Cases:** Test boundary conditions and error scenarios
4. **Mock External Services:** Don't depend on external APIs in tests
5. **Fast Tests:** Unit tests should run quickly
6. **TDD:** Write tests before implementation (Red-Green-Refactor)

## Test-Driven Development Workflow

1. **Red:** Write a failing test
2. **Green:** Write code to make the test pass
3. **Refactor:** Improve code while keeping tests passing
4. **Repeat:** Continue for next behavior

## Remember

- **ALWAYS** write tests before implementation (TDD)
- **ALWAYS** aim for 90%+ unit test coverage
- **ALWAYS** test edge cases and error scenarios
- **ALWAYS** validate UI functionality with Chrome DevTools MCP after implementing features
- **NEVER** skip tests for "quick fixes"
- **NEVER** commit code without tests
