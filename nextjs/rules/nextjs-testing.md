<!-- dex:nextjs -->
---
name: nextjs-testing
description: Next.js testing requirements and best practices. Always write tests for critical functionality.
---

# Next.js Testing Requirements

## Test Coverage Requirements

### Server Actions
- MUST write tests for all Server Actions
- MUST test authentication checks
- MUST test authorization logic
- MUST test data validation
- MUST test error handling
- MUST test revalidation behavior

### API Routes
- MUST write integration tests for all API routes
- MUST test all HTTP methods (GET, POST, PUT, DELETE)
- MUST test authentication requirements
- MUST test error responses
- MUST test rate limiting if implemented

### Components

#### Server Components
- MUST test data fetching logic
- MUST test error states
- MUST test loading states
- MUST test conditional rendering based on auth

#### Client Components
- MUST test all interactive behavior
- MUST test form submissions
- MUST test event handlers
- MUST test state changes
- MUST test accessibility

### Middleware
- MUST test route protection logic
- MUST test redirect behavior
- MUST test authenticated and unauthenticated flows

## Testing Tools

### Unit and Integration Tests
- Use Vitest as the primary test runner
- Use React Testing Library for component tests
- Use MSW (Mock Service Worker) for API mocking when needed

### End-to-End Tests
- Use Playwright for E2E tests
- Test critical user flows (signup, login, core features)
- Test across different browsers if targeting broad audience

## Test Structure

### Server Actions Tests
```typescript
// actions.test.ts
import { describe, it, expect, beforeEach, vi } from 'vitest';
import { createPost } from './actions';

describe('createPost', () => {
  it('should create post with valid data', async () => {
    // Test implementation
  });

  it('should throw error if not authenticated', async () => {
    // Test implementation
  });

  it('should revalidate dashboard path', async () => {
    // Test implementation
  });
});
```

### Component Tests
```typescript
// PostForm.test.tsx
import { describe, it, expect, vi } from 'vitest';
import { render, screen, fireEvent } from '@testing-library/react';
import PostForm from './PostForm';

describe('PostForm', () => {
  it('should render form fields', () => {
    // Test implementation
  });

  it('should call server action on submit', async () => {
    // Test implementation
  });

  it('should show loading state during submission', async () => {
    // Test implementation
  });
});
```

## Test Coverage Goals

### Minimum Coverage
- Server Actions: 100% (critical for data integrity)
- API Routes: 90%
- Client Components: 80%
- Server Components: 70% (focus on logic, not markup)
- Utility functions: 90%

### Priority Testing Areas
1. Authentication and authorization logic
2. Data mutations (create, update, delete)
3. Form validation
4. Error handling
5. Permission checks
6. Payment processing
7. Data transformations

## Testing Best Practices

### DO:
- Test behavior, not implementation details
- Use data-testid sparingly (prefer accessible queries)
- Mock external dependencies (database, APIs)
- Test error cases and edge cases
- Write tests before fixing bugs (TDD for bugs)
- Keep tests isolated and independent
- Use factories or fixtures for test data
- Test accessibility with ARIA queries

### DO NOT:
- Test Next.js framework internals
- Test third-party library behavior
- Write tests that depend on other tests
- Mock everything (balance between unit and integration)
- Test only the happy path
- Forget to test authentication requirements
- Skip testing error states

## E2E Testing Strategy

### Critical Flows to Test
1. User registration and login
2. Core feature workflows
3. Checkout and payment flows
4. Form submissions with validation
5. Protected route access
6. Data persistence across navigation

### E2E Test Structure
```typescript
// e2e/auth.spec.ts
import { test, expect } from '@playwright/test';

test('user can sign up and login', async ({ page }) => {
  await page.goto('/signup');
  // Test implementation
});
```

## Testing Environment

### Setup Requirements
- MUST use separate test database
- MUST mock external API calls in unit tests
- MUST clean up test data after each test
- MUST use consistent test fixtures
- MUST set up proper test environment variables

### Configuration
- Configure Vitest in `vitest.config.ts`
- Configure Playwright in `playwright.config.ts`
- Set up test utilities in `test/setup.ts`
- Create test helpers and factories

## Continuous Integration

### Pre-commit
- MUST run type checking (`tsc --noEmit`)
- MUST run linting (`next lint`)
- SHOULD run unit tests (if fast enough)

### CI Pipeline
- MUST run all tests (unit, integration, E2E)
- MUST check test coverage thresholds
- MUST run on all pull requests
- MUST block merge if tests fail

## When Tests Are Required

### Always Test
- New Server Actions
- New API routes
- Complex Client Component logic
- Authentication changes
- Authorization changes
- Data validation logic
- Bug fixes (write test first)

### Testing Can Be Skipped
- Simple presentational components (pure markup)
- Trivial UI changes
- Documentation updates
- Configuration changes

## Test Maintenance

### Keep Tests Updated
- Update tests when requirements change
- Refactor tests when code is refactored
- Remove obsolete tests
- Update test data and fixtures
- Keep test dependencies updated

### Code Review Requirements
- All new features MUST include tests
- Bug fixes MUST include regression tests
- Complex logic MUST have comprehensive test coverage
- PRs without required tests should be rejected

<!-- /dex:nextjs -->
