# Next.js Testing Patterns

Comprehensive guide for testing Next.js applications with App Router.

## Testing Philosophy

1. **Test Behavior, Not Implementation**: Focus on what users experience
2. **Prioritize Critical Paths**: Auth, payments, data mutations first
3. **Balance Speed and Confidence**: Mix of unit, integration, and E2E tests
4. **Server-First Testing**: Test Server Actions and Components thoroughly
5. **Accessibility Matters**: Use semantic queries in component tests

## Test Setup

### Vitest Configuration

```typescript
// vitest.config.ts
import { defineConfig } from 'vitest/config';
import react from '@vitejs/plugin-react';
import path from 'path';

export default defineConfig({
  plugins: [react()],
  test: {
    environment: 'jsdom',
    globals: true,
    setupFiles: ['./test/setup.ts'],
    coverage: {
      provider: 'v8',
      reporter: ['text', 'json', 'html'],
      exclude: [
        'node_modules/',
        'test/',
        '**/*.config.*',
        '**/types.ts',
      ],
    },
  },
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
    },
  },
});
```

### Test Setup File

```typescript
// test/setup.ts
import { expect, afterEach, vi } from 'vitest';
import { cleanup } from '@testing-library/react';
import * as matchers from '@testing-library/jest-dom/matchers';

expect.extend(matchers);

// Cleanup after each test
afterEach(() => {
  cleanup();
});

// Mock Next.js navigation
vi.mock('next/navigation', () => ({
  useRouter: () => ({
    push: vi.fn(),
    replace: vi.fn(),
    prefetch: vi.fn(),
  }),
  usePathname: () => '/',
  useSearchParams: () => new URLSearchParams(),
  redirect: vi.fn(),
}));

// Mock Next.js cache
vi.mock('next/cache', () => ({
  revalidatePath: vi.fn(),
  revalidateTag: vi.fn(),
}));
```

## Testing Server Actions

### Basic Server Action Test

```typescript
// app/dashboard/actions.test.ts
import { describe, it, expect, beforeEach, vi } from 'vitest';
import { revalidatePath } from 'next/cache';
import { redirect } from 'next/navigation';
import { createPost, updatePost, deletePost } from './actions';
import * as authLib from '@/lib/auth';
import Post from '@/models/Post';

// Mock dependencies
vi.mock('@/lib/auth');
vi.mock('@/models/Post');
vi.mock('next/cache');
vi.mock('next/navigation');

describe('Dashboard Actions', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  describe('createPost', () => {
    it('should create post with valid data', async () => {
      const mockSession = { user: { id: 'user-123' } };
      vi.mocked(authLib.auth).mockResolvedValue(mockSession);

      const mockPost = {
        _id: 'post-123',
        title: 'Test Post',
        description: 'Test Description',
        userId: 'user-123',
      };
      vi.mocked(Post.create).mockResolvedValue(mockPost);

      const formData = new FormData();
      formData.set('title', 'Test Post');
      formData.set('description', 'Test Description');

      await createPost(formData);

      expect(Post.create).toHaveBeenCalledWith({
        userId: 'user-123',
        title: 'Test Post',
        description: 'Test Description',
        tags: [],
      });

      expect(revalidatePath).toHaveBeenCalledWith('/dashboard');
      expect(redirect).toHaveBeenCalledWith('/dashboard/posts/post-123');
    });

    it('should throw error if not authenticated', async () => {
      vi.mocked(authLib.auth).mockResolvedValue(null);

      const formData = new FormData();
      formData.set('title', 'Test Post');

      await expect(createPost(formData)).rejects.toThrow('Unauthorized');
      expect(Post.create).not.toHaveBeenCalled();
    });

    it('should validate required fields', async () => {
      const mockSession = { user: { id: 'user-123' } };
      vi.mocked(authLib.auth).mockResolvedValue(mockSession);

      const formData = new FormData();
      // Missing title

      await expect(createPost(formData)).rejects.toThrow();
    });
  });

  describe('updatePost', () => {
    it('should update post and revalidate', async () => {
      const mockSession = { user: { id: 'user-123' } };
      vi.mocked(authLib.auth).mockResolvedValue(mockSession);

      const mockPost = { _id: 'post-123', userId: 'user-123' };
      vi.mocked(Post.findById).mockResolvedValue(mockPost);
      vi.mocked(Post.findByIdAndUpdate).mockResolvedValue(mockPost);

      const formData = new FormData();
      formData.set('title', 'Updated Title');

      await updatePost('post-123', formData);

      expect(Post.findByIdAndUpdate).toHaveBeenCalledWith(
        'post-123',
        { title: 'Updated Title' }
      );
      expect(revalidatePath).toHaveBeenCalledWith('/dashboard');
    });

    it('should check post ownership', async () => {
      const mockSession = { user: { id: 'user-123' } };
      vi.mocked(authLib.auth).mockResolvedValue(mockSession);

      const mockPost = { _id: 'post-123', userId: 'other-user' };
      vi.mocked(Post.findById).mockResolvedValue(mockPost);

      const formData = new FormData();
      formData.set('title', 'Updated Title');

      await expect(updatePost('post-123', formData)).rejects.toThrow(
        'Forbidden'
      );
    });
  });

  describe('deletePost', () => {
    it('should delete post and revalidate', async () => {
      const mockSession = { user: { id: 'user-123' } };
      vi.mocked(authLib.auth).mockResolvedValue(mockSession);

      const mockPost = { _id: 'post-123', userId: 'user-123' };
      vi.mocked(Post.findById).mockResolvedValue(mockPost);
      vi.mocked(Post.findByIdAndDelete).mockResolvedValue(mockPost);

      await deletePost('post-123');

      expect(Post.findByIdAndDelete).toHaveBeenCalledWith('post-123');
      expect(revalidatePath).toHaveBeenCalledWith('/dashboard');
    });
  });
});
```

### Testing Form Data Validation

```typescript
// lib/validation.test.ts
import { describe, it, expect } from 'vitest';
import { validatePostData, PostFormData } from './validation';

describe('validatePostData', () => {
  it('should validate correct data', () => {
    const data: PostFormData = {
      title: 'Valid Title',
      description: 'Valid description',
      tags: ['tag1', 'tag2'],
    };

    const result = validatePostData(data);
    expect(result.success).toBe(true);
  });

  it('should reject empty title', () => {
    const data: PostFormData = {
      title: '',
      description: 'Description',
      tags: [],
    };

    const result = validatePostData(data);
    expect(result.success).toBe(false);
    expect(result.errors.title).toBeDefined();
  });

  it('should reject too-long title', () => {
    const data: PostFormData = {
      title: 'a'.repeat(101),
      description: 'Description',
      tags: [],
    };

    const result = validatePostData(data);
    expect(result.success).toBe(false);
  });
});
```

## Testing Server Components

### Server Component with Data Fetching

```typescript
// app/dashboard/page.test.tsx
import { describe, it, expect, vi } from 'vitest';
import { render, screen } from '@testing-library/react';
import DashboardPage from './page';
import * as authLib from '@/lib/auth';
import Post from '@/models/Post';

vi.mock('@/lib/auth');
vi.mock('@/models/Post');

describe('DashboardPage', () => {
  it('should render posts for authenticated user', async () => {
    const mockSession = { user: { id: 'user-123', name: 'Test User' } };
    vi.mocked(authLib.auth).mockResolvedValue(mockSession);

    const mockPosts = [
      { _id: 'post-1', title: 'Post 1', createdAt: new Date() },
      { _id: 'post-2', title: 'Post 2', createdAt: new Date() },
    ];
    vi.mocked(Post.find).mockReturnValue({
      sort: vi.fn().mockReturnValue({
        lean: vi.fn().mockResolvedValue(mockPosts),
      }),
    } as any);

    const Component = await DashboardPage();
    render(Component);

    expect(screen.getByText('Post 1')).toBeInTheDocument();
    expect(screen.getByText('Post 2')).toBeInTheDocument();
  });

  it('should redirect if not authenticated', async () => {
    vi.mocked(authLib.auth).mockResolvedValue(null);

    // Expect redirect to be called
    await expect(DashboardPage()).rejects.toThrow('NEXT_REDIRECT');
  });
});
```

## Testing Client Components

### Form Component Test

```typescript
// components/PostForm.test.tsx
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import PostForm from './PostForm';
import * as actions from '@/app/dashboard/actions';

vi.mock('@/app/dashboard/actions');

describe('PostForm', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('should render form fields', () => {
    render(<PostForm />);

    expect(screen.getByLabelText(/title/i)).toBeInTheDocument();
    expect(screen.getByLabelText(/description/i)).toBeInTheDocument();
    expect(screen.getByRole('button', { name: /create/i })).toBeInTheDocument();
  });

  it('should call server action on submit', async () => {
    const user = userEvent.setup();
    vi.mocked(actions.createPost).mockResolvedValue(undefined);

    render(<PostForm />);

    await user.type(screen.getByLabelText(/title/i), 'Test Post');
    await user.type(
      screen.getByLabelText(/description/i),
      'Test Description'
    );
    await user.click(screen.getByRole('button', { name: /create/i }));

    await waitFor(() => {
      expect(actions.createPost).toHaveBeenCalled();
    });
  });

  it('should show loading state during submission', async () => {
    const user = userEvent.setup();
    let resolveAction: () => void;
    const actionPromise = new Promise<void>((resolve) => {
      resolveAction = resolve;
    });
    vi.mocked(actions.createPost).mockReturnValue(actionPromise);

    render(<PostForm />);

    await user.type(screen.getByLabelText(/title/i), 'Test Post');
    await user.click(screen.getByRole('button', { name: /create/i }));

    expect(screen.getByText(/creating/i)).toBeInTheDocument();
    expect(screen.getByRole('button')).toBeDisabled();

    resolveAction!();
    await waitFor(() => {
      expect(screen.queryByText(/creating/i)).not.toBeInTheDocument();
    });
  });

  it('should display error message on failure', async () => {
    const user = userEvent.setup();
    vi.mocked(actions.createPost).mockRejectedValue(
      new Error('Failed to create post')
    );

    render(<PostForm />);

    await user.type(screen.getByLabelText(/title/i), 'Test Post');
    await user.click(screen.getByRole('button', { name: /create/i }));

    await waitFor(() => {
      expect(screen.getByText(/failed to create post/i)).toBeInTheDocument();
    });
  });

  it('should reset form after successful submission', async () => {
    const user = userEvent.setup();
    vi.mocked(actions.createPost).mockResolvedValue(undefined);

    render(<PostForm />);

    const titleInput = screen.getByLabelText(/title/i) as HTMLInputElement;
    await user.type(titleInput, 'Test Post');
    await user.click(screen.getByRole('button', { name: /create/i }));

    await waitFor(() => {
      expect(titleInput.value).toBe('');
    });
  });
});
```

### Interactive Component Test

```typescript
// components/LikeButton.test.tsx
import { describe, it, expect, vi } from 'vitest';
import { render, screen, fireEvent } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import LikeButton from './LikeButton';
import * as actions from '@/app/posts/actions';

vi.mock('@/app/posts/actions');

describe('LikeButton', () => {
  it('should toggle like state', async () => {
    const user = userEvent.setup();
    vi.mocked(actions.toggleLike).mockResolvedValue({ liked: true });

    render(<LikeButton postId="post-123" initialLiked={false} />);

    const button = screen.getByRole('button');
    expect(button).toHaveAttribute('aria-pressed', 'false');

    await user.click(button);

    expect(actions.toggleLike).toHaveBeenCalledWith('post-123');
    expect(button).toHaveAttribute('aria-pressed', 'true');
  });

  it('should show optimistic update', async () => {
    const user = userEvent.setup();
    let resolveAction: (value: any) => void;
    const actionPromise = new Promise((resolve) => {
      resolveAction = resolve;
    });
    vi.mocked(actions.toggleLike).mockReturnValue(actionPromise);

    render(<LikeButton postId="post-123" initialLiked={false} />);

    const button = screen.getByRole('button');
    await user.click(button);

    // Should show optimistic state immediately
    expect(button).toHaveAttribute('aria-pressed', 'true');

    resolveAction!({ liked: true });
  });
});
```

## Testing API Routes

### API Route Handler Test

```typescript
// app/api/posts/route.test.ts
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { GET, POST } from './route';
import * as authLib from '@/lib/auth';
import Post from '@/models/Post';

vi.mock('@/lib/auth');
vi.mock('@/models/Post');

describe('POST /api/posts', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('should create post with valid data', async () => {
    const mockSession = { user: { id: 'user-123' } };
    vi.mocked(authLib.auth).mockResolvedValue(mockSession);

    const mockPost = {
      _id: 'post-123',
      title: 'Test Post',
      userId: 'user-123',
    };
    vi.mocked(Post.create).mockResolvedValue(mockPost);

    const request = new Request('http://localhost:3000/api/posts', {
      method: 'POST',
      body: JSON.stringify({
        title: 'Test Post',
        description: 'Test Description',
      }),
    });

    const response = await POST(request);
    const data = await response.json();

    expect(response.status).toBe(201);
    expect(data.post).toEqual(mockPost);
  });

  it('should return 401 if not authenticated', async () => {
    vi.mocked(authLib.auth).mockResolvedValue(null);

    const request = new Request('http://localhost:3000/api/posts', {
      method: 'POST',
      body: JSON.stringify({ title: 'Test' }),
    });

    const response = await POST(request);

    expect(response.status).toBe(401);
  });

  it('should return 400 for invalid data', async () => {
    const mockSession = { user: { id: 'user-123' } };
    vi.mocked(authLib.auth).mockResolvedValue(mockSession);

    const request = new Request('http://localhost:3000/api/posts', {
      method: 'POST',
      body: JSON.stringify({}), // Missing title
    });

    const response = await POST(request);

    expect(response.status).toBe(400);
  });
});

describe('GET /api/posts', () => {
  it('should return posts for authenticated user', async () => {
    const mockSession = { user: { id: 'user-123' } };
    vi.mocked(authLib.auth).mockResolvedValue(mockSession);

    const mockPosts = [
      { _id: 'post-1', title: 'Post 1' },
      { _id: 'post-2', title: 'Post 2' },
    ];
    vi.mocked(Post.find).mockReturnValue({
      lean: vi.fn().mockResolvedValue(mockPosts),
    } as any);

    const request = new Request('http://localhost:3000/api/posts');
    const response = await GET(request);
    const data = await response.json();

    expect(response.status).toBe(200);
    expect(data.posts).toEqual(mockPosts);
  });
});
```

## Testing Middleware

```typescript
// middleware.test.ts
import { describe, it, expect, vi } from 'vitest';
import middleware from './middleware';
import { NextRequest } from 'next/server';

describe('middleware', () => {
  it('should allow authenticated users to access dashboard', async () => {
    const request = new NextRequest('http://localhost:3000/dashboard', {
      headers: { cookie: 'session=valid-token' },
    });
    request.auth = { user: { id: 'user-123' } };

    const response = await middleware(request);

    expect(response).toBeUndefined(); // Allows request through
  });

  it('should redirect unauthenticated users to login', async () => {
    const request = new NextRequest('http://localhost:3000/dashboard');

    const response = await middleware(request);

    expect(response?.status).toBe(307);
    expect(response?.headers.get('location')).toContain('/login');
  });

  it('should add callback URL to login redirect', async () => {
    const request = new NextRequest(
      'http://localhost:3000/dashboard/settings'
    );

    const response = await middleware(request);

    expect(response?.headers.get('location')).toContain(
      'callbackUrl=%2Fdashboard%2Fsettings'
    );
  });

  it('should redirect authenticated users away from login', async () => {
    const request = new NextRequest('http://localhost:3000/login');
    request.auth = { user: { id: 'user-123' } };

    const response = await middleware(request);

    expect(response?.status).toBe(307);
    expect(response?.headers.get('location')).toContain('/dashboard');
  });
});
```

## E2E Testing with Playwright

### Setup Playwright

```typescript
// playwright.config.ts
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './e2e',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: 'html',
  use: {
    baseURL: 'http://localhost:3000',
    trace: 'on-first-retry',
  },
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
  ],
  webServer: {
    command: 'npm run dev',
    url: 'http://localhost:3000',
    reuseExistingServer: !process.env.CI,
  },
});
```

### Authentication Flow Test

```typescript
// e2e/auth.spec.ts
import { test, expect } from '@playwright/test';

test.describe('Authentication', () => {
  test('user can sign up and login', async ({ page }) => {
    // Sign up
    await page.goto('/signup');
    await page.fill('input[name="email"]', 'test@example.com');
    await page.fill('input[name="password"]', 'password123');
    await page.fill('input[name="name"]', 'Test User');
    await page.click('button[type="submit"]');

    // Should redirect to dashboard
    await expect(page).toHaveURL('/dashboard');
    await expect(page.getByText('Welcome, Test User')).toBeVisible();
  });

  test('user cannot access protected routes without login', async ({
    page,
  }) => {
    await page.goto('/dashboard');

    // Should redirect to login
    await expect(page).toHaveURL(/\/login/);
  });

  test('user can logout', async ({ page }) => {
    // Login first
    await page.goto('/login');
    await page.fill('input[name="email"]', 'test@example.com');
    await page.fill('input[name="password"]', 'password123');
    await page.click('button[type="submit"]');

    await expect(page).toHaveURL('/dashboard');

    // Logout
    await page.click('button:has-text("Logout")');

    // Should redirect to home
    await expect(page).toHaveURL('/');
  });
});
```

### CRUD Flow Test

```typescript
// e2e/posts.spec.ts
import { test, expect } from '@playwright/test';

test.describe('Posts', () => {
  test.beforeEach(async ({ page }) => {
    // Login
    await page.goto('/login');
    await page.fill('input[name="email"]', 'test@example.com');
    await page.fill('input[name="password"]', 'password123');
    await page.click('button[type="submit"]');
    await page.waitForURL('/dashboard');
  });

  test('user can create a post', async ({ page }) => {
    await page.goto('/dashboard');
    await page.click('a:has-text("New Post")');

    await page.fill('input[name="title"]', 'Test Post');
    await page.fill('textarea[name="description"]', 'Test Description');
    await page.click('button[type="submit"]');

    await expect(page.getByText('Test Post')).toBeVisible();
  });

  test('user can edit their post', async ({ page }) => {
    await page.goto('/dashboard');
    await page.click('article:has-text("Test Post")');
    await page.click('button:has-text("Edit")');

    await page.fill('input[name="title"]', 'Updated Post');
    await page.click('button[type="submit"]');

    await expect(page.getByText('Updated Post')).toBeVisible();
  });

  test('user can delete their post', async ({ page }) => {
    await page.goto('/dashboard');

    const postCount = await page.locator('article').count();

    await page.click('article:first-child button:has-text("Delete")');
    await page.click('button:has-text("Confirm")');

    await expect(page.locator('article')).toHaveCount(postCount - 1);
  });
});
```

## Test Utilities and Helpers

### Test Factories

```typescript
// test/factories.ts
import { faker } from '@faker-js/faker';

export const createMockUser = (overrides = {}) => ({
  id: faker.string.uuid(),
  email: faker.internet.email(),
  name: faker.person.fullName(),
  ...overrides,
});

export const createMockPost = (overrides = {}) => ({
  _id: faker.string.uuid(),
  title: faker.lorem.sentence(),
  description: faker.lorem.paragraph(),
  userId: faker.string.uuid(),
  createdAt: faker.date.recent(),
  ...overrides,
});

export const createMockSession = (overrides = {}) => ({
  user: createMockUser(),
  expires: faker.date.future().toISOString(),
  ...overrides,
});
```

### Custom Render Helper

```typescript
// test/render.tsx
import { ReactElement } from 'react';
import { render, RenderOptions } from '@testing-library/react';

// Add providers if needed (e.g., theme, i18n)
function AllProviders({ children }: { children: React.ReactNode }) {
  return <>{children}</>;
}

export function renderWithProviders(
  ui: ReactElement,
  options?: Omit<RenderOptions, 'wrapper'>
) {
  return render(ui, { wrapper: AllProviders, ...options });
}

export * from '@testing-library/react';
```

## Running Tests

### Package.json Scripts

```json
{
  "scripts": {
    "test": "vitest",
    "test:ui": "vitest --ui",
    "test:run": "vitest run",
    "test:coverage": "vitest run --coverage",
    "test:e2e": "playwright test",
    "test:e2e:ui": "playwright test --ui"
  }
}
```

### CI Configuration

```yaml
# .github/workflows/test.yml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '20'
      - run: npm ci
      - run: npm run test:run
      - run: npm run test:coverage

  e2e:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '20'
      - run: npm ci
      - run: npx playwright install --with-deps
      - run: npm run test:e2e
```

## Best Practices Summary

1. **Write tests for critical functionality**: Auth, Server Actions, API routes
2. **Use proper mocking**: Mock dependencies, not implementation details
3. **Test user behavior**: Focus on what users see and do
4. **Keep tests isolated**: Each test should be independent
5. **Use descriptive test names**: Clearly state what's being tested
6. **Test edge cases**: Empty states, errors, boundary conditions
7. **Maintain test performance**: Fast unit tests, selective E2E tests
8. **Update tests with code**: Keep tests in sync with implementation
