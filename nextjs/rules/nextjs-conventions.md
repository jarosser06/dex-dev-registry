<!-- dex:nextjs -->
---
name: nextjs-conventions
description: Next.js development conventions and structural requirements. Always follow these patterns when working with Next.js applications.
---

# Next.js Development Conventions

## File Structure Requirements

### Server Components
- MUST place all pages in `app/` directory
- MUST keep Server Components as default (no `'use client'` directive)
- MUST use async functions for Server Components that fetch data
- MUST place Server Actions in dedicated `actions.ts` files

### Client Components
- MUST use `'use client'` directive at the top of Client Component files
- MUST minimize Client Component usage - only use for interactivity
- MUST NOT fetch data in Client Components using useEffect
- MUST NOT perform mutations in Client Components directly

### Route Organization
- MUST use `page.tsx` for route entry points
- MUST use `layout.tsx` for shared layouts
- MUST use `loading.tsx` for loading states
- MUST use `error.tsx` for error boundaries
- MUST use `not-found.tsx` for 404 handling

## Data Fetching

### Server Components
- MUST fetch data directly in Server Components
- MUST use async/await syntax
- MUST fetch data at the component level, not just page boundaries
- MUST use `Promise.all()` for parallel data fetching
- MUST use `.lean()` with Mongoose to avoid serialization errors

### Client Components
- MUST NOT use useEffect for data fetching
- MUST use Server Actions for mutations
- MUST handle loading states when calling Server Actions
- MUST handle errors from Server Actions

## Server Actions

### Structure
- MUST place Server Actions in `actions.ts` files
- MUST use `'use server'` directive at the top of actions files
- MUST use Server Actions for all mutations (create, update, delete)
- MUST NOT create API routes for simple mutations

### Revalidation
- MUST call `revalidatePath()` after mutations that affect displayed data
- MUST call `revalidateTag()` when using tagged cache strategies
- MUST redirect using `redirect()` from 'next/navigation' after successful mutations

### Error Handling
- MUST validate authentication in Server Actions
- MUST validate user permissions in Server Actions
- MUST throw descriptive errors or return error objects
- MUST handle errors in the calling component

## Authentication

### Server-Side Authentication
- MUST check authentication in Server Components
- MUST use middleware for route protection
- MUST validate auth in all Server Actions
- MUST redirect unauthenticated users to login

### Client-Side Authentication
- MUST NOT rely solely on client-side auth checks
- MUST always enforce auth server-side
- MAY use client-side auth state for UI optimization only

## Performance

### Images
- MUST use `next/image` for all images
- MUST specify width and height or use fill mode
- MUST use appropriate priority prop for above-fold images

### Navigation
- MUST use `next/link` for internal navigation
- MUST use `next/navigation` hooks for programmatic navigation
- MUST NOT use `<a>` tags for internal links

### Loading States
- MUST create `loading.tsx` files for route segments
- MUST show loading states in forms during Server Action execution
- MUST use Suspense boundaries for streaming

## Type Safety

### TypeScript
- MUST use TypeScript for all files
- MUST define proper types for Server Action parameters
- MUST type form data properly (FormData or validated objects)
- MUST use proper return types for Server Actions

### Database
- MUST use `.lean()` with Mongoose queries passed to Client Components
- MUST convert ObjectId to string before passing to Client Components
- MUST validate data before database operations

## Code Organization

### Components
- MUST place reusable UI components in `components/ui/`
- MUST place feature-specific components in `components/features/`
- MUST keep Server and Client Components in separate files

### Libraries
- MUST place shared utilities in `lib/` directory
- MUST place database connection logic in `lib/db.ts`
- MUST place authentication config in `lib/auth.ts`

### Middleware
- MUST use middleware.ts in root for route protection
- MUST specify proper matcher patterns
- MUST return Response.redirect() for redirects in middleware

## Anti-Patterns to Avoid

### DO NOT:
- Create API routes for simple CRUD operations (use Server Actions)
- Fetch data in Client Components with useEffect
- Check authentication only on client side
- Forget to revalidate after mutations
- Pass Mongoose documents directly to Client Components (use .lean())
- Use client-side navigation for protected routes only
- Create deeply nested Client Component trees
- Perform database operations in Client Components
- Export non-serializable data from Server Components
- Use synchronous data fetching in Server Components

## Exceptions

You may deviate from these conventions only when:
- The user explicitly requests a different approach
- A specific third-party library requires a different pattern
- Edge cases require special handling (document why)

<!-- /dex:nextjs -->
