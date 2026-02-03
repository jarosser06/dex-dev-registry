---
name: nextjs
description: Expert in Next.js 16+ App Router patterns, Server/Client Components, Server Actions, API routes, middleware, authentication, and data fetching. Use when implementing Next.js features, routing, or server-side logic.
---

# Next.js App Router Skill

Expert knowledge of Next.js 16+ App Router for modern web applications.

## Core Philosophy

1. **Server Components by Default**: All components are Server Components unless marked with `'use client'`
2. **Server Actions > API Routes**: Use Server Actions for mutations, API routes only when needed
3. **Data Fetching at Component Level**: Fetch where you need it, not at page boundaries
4. **Type Safety**: TypeScript-first with proper types from database to UI
5. **Progressive Enhancement**: Forms work without JavaScript via Server Actions

## Recommended File Structure

```
src/
├── app/
│   ├── api/                  # API routes (minimal use)
│   ├── dashboard/
│   │   ├── page.tsx         # Server Component (dashboard view)
│   │   ├── layout.tsx       # Shared layout
│   │   └── actions.ts       # Server Actions for dashboard
│   ├── login/
│   │   └── page.tsx         # Login page (Client Component for form)
│   ├── layout.tsx           # Root layout
│   ├── page.tsx             # Home page (Server Component)
│   └── globals.css          # Global styles
├── components/
│   ├── ui/                  # Reusable UI components
│   └── features/            # Feature-specific components
├── lib/
│   ├── auth.ts             # Auth.js configuration
│   └── db.ts               # Database connection
├── models/                  # Database models
└── middleware.ts            # Route protection
```

## Common Patterns

### Server Component with Database Access

```typescript
// app/dashboard/page.tsx
import { auth } from '@/lib/auth';
import connectDB from '@/lib/db';
import Post from '@/models/Post';
import { redirect } from 'next/navigation';

export default async function DashboardPage() {
  const session = await auth();

  if (!session?.user) {
    redirect('/login');
  }

  await connectDB();
  const posts = await Post.find({ userId: session.user.id })
    .sort({ createdAt: -1 })
    .lean();

  return (
    <div>
      <h1>My Posts</h1>
      {posts.map(post => (
        <article key={post._id.toString()}>
          <h2>{post.title}</h2>
        </article>
      ))}
    </div>
  );
}
```

### Server Action for Mutations

```typescript
// app/dashboard/actions.ts
'use server';

import { auth } from '@/lib/auth';
import connectDB from '@/lib/db';
import Post from '@/models/Post';
import { revalidatePath } from 'next/cache';
import { redirect } from 'next/navigation';

export async function createPost(formData: FormData) {
  const session = await auth();

  if (!session?.user) {
    throw new Error('Unauthorized');
  }

  const title = formData.get('title') as string;
  const description = formData.get('description') as string;

  await connectDB();

  const post = await Post.create({
    userId: session.user.id,
    title,
    description,
    tags: [],
  });

  revalidatePath('/dashboard');
  redirect(`/dashboard/posts/${post._id}`);
}
```

### Client Component for Interactivity

```typescript
// components/PostForm.tsx
'use client';

import { createPost } from '@/app/dashboard/actions';
import { useState } from 'react';

export default function PostForm() {
  const [pending, setPending] = useState(false);

  return (
    <form
      action={async (formData) => {
        setPending(true);
        await createPost(formData);
        setPending(false);
      }}
    >
      <input name="title" required />
      <textarea name="description" />
      <button disabled={pending}>
        {pending ? 'Creating...' : 'Create Post'}
      </button>
    </form>
  );
}
```

### Middleware for Route Protection

```typescript
// middleware.ts
import { auth } from '@/lib/auth';

export default auth((req) => {
  const { pathname } = req.nextUrl;

  // Protect dashboard routes
  if (pathname.startsWith('/dashboard')) {
    if (!req.auth) {
      const loginUrl = new URL('/login', req.url);
      loginUrl.searchParams.set('callbackUrl', pathname);
      return Response.redirect(loginUrl);
    }
  }

  // Redirect logged-in users away from login
  if (pathname === '/login' && req.auth) {
    return Response.redirect(new URL('/dashboard', req.url));
  }
});

export const config = {
  matcher: ['/((?!api|_next/static|_next/image|favicon.ico).*)'],
};
```

### Parallel Data Fetching

```typescript
// app/dashboard/page.tsx
export default async function Dashboard() {
  const session = await auth();

  // Fetch in parallel for better performance
  const [posts, projects, userData] = await Promise.all([
    Post.find({ userId: session.user.id }).lean(),
    Project.find({ userId: session.user.id }).lean(),
    User.findById(session.user.id).select('name email').lean(),
  ]);

  return <div>{/* Render data */}</div>;
}
```

## Best Practices

### 1. Use Server Components for Data Fetching

```typescript
// ✓ Server Component fetches data directly
export default async function Page() {
  await connectDB();
  const data = await Model.find().lean();
  return <div>{/* ... */}</div>;
}

// ❌ Don't fetch in Client Component
'use client';
export default function Page() {
  const [data, setData] = useState([]);
  useEffect(() => {
    fetch('/api/data').then(/* ... */); // Unnecessary
  }, []);
}
```

### 2. Minimize Client Components

```typescript
// ✓ Only interactive parts are Client Components
// app/page.tsx (Server Component)
import InteractiveButton from '@/components/InteractiveButton';

export default function Page() {
  const data = await fetchData(); // Server-side

  return (
    <div>
      <h1>{data.title}</h1>
      <InteractiveButton /> {/* Only this needs client JS */}
    </div>
  );
}
```

### 3. Use Server Actions for Mutations

```typescript
// ✓ Server Action handles form submission
'use server';
export async function updatePost(id: string, data: FormData) {
  await connectDB();
  await Post.findByIdAndUpdate(id, { title: data.get('title') });
  revalidatePath('/dashboard');
}

// ❌ Don't create API route for simple mutations
// app/api/posts/[id]/route.ts - unnecessary!
```

### 4. Revalidate Paths After Mutations

```typescript
// ✓ Revalidate to show updated data
'use server';
export async function deletePost(id: string) {
  await Post.findByIdAndDelete(id);
  revalidatePath('/dashboard'); // Refresh dashboard data
}
```

### 5. Handle Auth in Server Components

```typescript
// ✓ Check auth in Server Component or middleware
export default async function Page() {
  const session = await auth();
  if (!session) redirect('/login');
  // ... rest of component
}

// middleware.ts also protects routes
```

### 6. Use Loading UI

```typescript
// app/dashboard/loading.tsx
export default function Loading() {
  return <div>Loading posts...</div>;
}

// Automatic loading state for dashboard/page.tsx
```

### 7. Proper Error Handling

```typescript
// app/dashboard/error.tsx
'use client';

export default function Error({
  error,
  reset,
}: {
  error: Error;
  reset: () => void;
}) {
  return (
    <div>
      <h2>Something went wrong</h2>
      <button onClick={reset}>Try again</button>
    </div>
  );
}
```

## Anti-Patterns to Avoid

### ❌ Creating Unnecessary API Routes

```typescript
// ❌ Don't create API route for mutations
// app/api/posts/route.ts
export async function POST(req: Request) {
  const data = await req.json();
  // ... create post
}

// ✓ Use Server Action instead
'use server';
export async function createPost(data: FormData) {
  // ... create post
}
```

### ❌ Client Components for Data Fetching

```typescript
// ❌ Don't fetch data in Client Component
'use client';
export default function Page() {
  const [data, setData] = useState();
  useEffect(() => {
    fetch('/api/data').then(/* ... */);
  }, []);
  // ...
}

// ✓ Use Server Component
export default async function Page() {
  const data = await fetchData();
  // ...
}
```

### ❌ Not Handling Auth Properly

```typescript
// ❌ Don't check auth client-side only
'use client';
export default function Page() {
  const session = useSession(); // Client-side check only
  // User can bypass this!
}

// ✓ Check auth server-side
export default async function Page() {
  const session = await auth();
  if (!session) redirect('/login');
  // Server-enforced protection
}
```

### ❌ Forgetting to Revalidate

```typescript
// ❌ Data won't update without revalidation
'use server';
export async function updatePost(id: string, data: any) {
  await Post.findByIdAndUpdate(id, data);
  // Missing revalidatePath - UI shows stale data!
}

// ✓ Revalidate the path
'use server';
export async function updatePost(id: string, data: any) {
  await Post.findByIdAndUpdate(id, data);
  revalidatePath('/dashboard'); // UI updates
}
```

### ❌ Serialization Errors

```typescript
// ❌ Can't pass Mongoose documents to Client Components
export default async function Page() {
  const post = await Post.findById(id); // Mongoose document
  return <ClientComponent post={post} />; // Error!
}

// ✓ Use lean() or convert to plain object
export default async function Page() {
  const post = await Post.findById(id).lean(); // Plain object
  return <ClientComponent post={post} />;
}
```

## External Resources

- [Next.js Documentation](https://nextjs.org/docs)
- [App Router Guide](https://nextjs.org/docs/app)
- [Server Actions](https://nextjs.org/docs/app/building-your-application/data-fetching/server-actions-and-mutations)
- [Auth.js Documentation](https://authjs.dev/)
- [MCP Handler](https://www.npmjs.com/package/mcp-handler) - Model Context Protocol handler for Next.js applications
