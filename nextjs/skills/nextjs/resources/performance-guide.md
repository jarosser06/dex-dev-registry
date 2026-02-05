# Next.js Performance Optimization Guide

Comprehensive guide for optimizing Next.js App Router applications.

## Performance Philosophy

1. **Measure First**: Use Next.js built-in analytics and tools
2. **Server-Side by Default**: Minimize client JavaScript
3. **Progressive Enhancement**: Start with Server Components
4. **Smart Caching**: Leverage Next.js caching strategies
5. **Optimize Critical Path**: Focus on what users see first

## Core Web Vitals

### Understanding Metrics

- **LCP (Largest Contentful Paint)**: Time to render main content (target: <2.5s)
- **FID (First Input Delay)**: Time to interactive (target: <100ms)
- **CLS (Cumulative Layout Shift)**: Visual stability (target: <0.1)
- **INP (Interaction to Next Paint)**: Responsiveness (target: <200ms)
- **TTFB (Time to First Byte)**: Server response time (target: <600ms)

### Monitoring with Next.js

```typescript
// app/layout.tsx
import { SpeedInsights } from '@vercel/speed-insights/next';
import { Analytics } from '@vercel/analytics/react';

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body>
        {children}
        <SpeedInsights />
        <Analytics />
      </body>
    </html>
  );
}
```

## Bundle Optimization

### Analyze Bundle Size

```bash
# Install analyzer
npm install @next/bundle-analyzer

# Add to next.config.js
const withBundleAnalyzer = require('@next/bundle-analyzer')({
  enabled: process.env.ANALYZE === 'true',
});

module.exports = withBundleAnalyzer({
  // your config
});

# Run analysis
ANALYZE=true npm run build
```

### Code Splitting

#### Dynamic Imports

```typescript
// ✓ Dynamic import for large components
import dynamic from 'next/dynamic';

const HeavyChart = dynamic(() => import('@/components/HeavyChart'), {
  loading: () => <div>Loading chart...</div>,
  ssr: false, // Don't render on server if not needed
});

export default function Dashboard() {
  return (
    <div>
      <h1>Dashboard</h1>
      <HeavyChart />
    </div>
  );
}
```

#### Conditional Loading

```typescript
// ✓ Load only when needed
'use client';

import { useState } from 'react';
import dynamic from 'next/dynamic';

const PdfViewer = dynamic(() => import('@/components/PdfViewer'));

export default function DocumentPage() {
  const [showPdf, setShowPdf] = useState(false);

  return (
    <div>
      <button onClick={() => setShowPdf(true)}>View PDF</button>
      {showPdf && <PdfViewer />}
    </div>
  );
}
```

#### Third-Party Scripts

```typescript
// ✓ Use Next.js Script component
import Script from 'next/script';

export default function Page() {
  return (
    <>
      <Script
        src="https://example.com/analytics.js"
        strategy="lazyOnload" // or 'afterInteractive', 'beforeInteractive'
      />
      {/* Your content */}
    </>
  );
}
```

### Tree Shaking

```typescript
// ✓ Import only what you need
import { format } from 'date-fns';

// ❌ Don't import entire library
import * as dateFns from 'date-fns';

// ✓ Use specific imports for lodash
import debounce from 'lodash/debounce';

// ❌ Don't import all of lodash
import _ from 'lodash';
```

## Image Optimization

### Using next/image

```typescript
// ✓ Automatic optimization
import Image from 'next/image';

export default function ProfileCard({ user }) {
  return (
    <div>
      <Image
        src={user.avatar}
        alt={user.name}
        width={200}
        height={200}
        priority={false} // Set true for above-fold images
      />
    </div>
  );
}
```

### Responsive Images

```typescript
// ✓ Responsive with sizes
import Image from 'next/image';

export default function Hero() {
  return (
    <Image
      src="/hero.jpg"
      alt="Hero"
      fill
      sizes="(max-width: 768px) 100vw, (max-width: 1200px) 50vw, 33vw"
      priority
      style={{ objectFit: 'cover' }}
    />
  );
}
```

### Image Loading Strategies

```typescript
// ✓ Priority for LCP images
<Image src="/hero.jpg" priority alt="Hero" width={1200} height={600} />

// ✓ Lazy loading for below-fold
<Image src="/footer-logo.jpg" loading="lazy" alt="Logo" width={200} height={50} />

// ✓ Blur placeholder for better UX
<Image
  src={post.image}
  alt={post.title}
  width={800}
  height={400}
  placeholder="blur"
  blurDataURL={post.blurDataURL}
/>
```

### Remote Images

```javascript
// next.config.js
module.exports = {
  images: {
    remotePatterns: [
      {
        protocol: 'https',
        hostname: 'example.com',
        port: '',
        pathname: '/images/**',
      },
    ],
  },
};
```

## Font Optimization

### Using next/font

```typescript
// app/layout.tsx
import { Inter, Roboto_Mono } from 'next/font/google';

const inter = Inter({
  subsets: ['latin'],
  display: 'swap',
  variable: '--font-inter',
});

const robotoMono = Roboto_Mono({
  subsets: ['latin'],
  display: 'swap',
  variable: '--font-roboto-mono',
});

export default function RootLayout({ children }) {
  return (
    <html lang="en" className={`${inter.variable} ${robotoMono.variable}`}>
      <body>{children}</body>
    </html>
  );
}
```

### Custom Fonts

```typescript
// app/layout.tsx
import localFont from 'next/font/local';

const myFont = localFont({
  src: './fonts/CustomFont.woff2',
  display: 'swap',
  variable: '--font-custom',
});

export default function RootLayout({ children }) {
  return (
    <html lang="en" className={myFont.variable}>
      <body>{children}</body>
    </html>
  );
}
```

## Caching Strategies

### Data Cache

```typescript
// ✓ Cache by default (Server Component)
async function getData() {
  const res = await fetch('https://api.example.com/data');
  return res.json();
}

// ✓ Revalidate every hour
async function getData() {
  const res = await fetch('https://api.example.com/data', {
    next: { revalidate: 3600 },
  });
  return res.json();
}

// ✓ No cache for dynamic data
async function getData() {
  const res = await fetch('https://api.example.com/data', {
    cache: 'no-store',
  });
  return res.json();
}
```

### Route Cache

```typescript
// Force dynamic rendering
export const dynamic = 'force-dynamic';

// Revalidate page every 60 seconds
export const revalidate = 60;

// Opt out of static generation
export const dynamic = 'force-dynamic';

export default async function Page() {
  const data = await getData();
  return <div>{/* ... */}</div>;
}
```

### Tag-Based Revalidation

```typescript
// Tag data fetches
async function getPosts() {
  const res = await fetch('https://api.example.com/posts', {
    next: { tags: ['posts'] },
  });
  return res.json();
}

// Revalidate specific tags
'use server';
import { revalidateTag } from 'next/cache';

export async function createPost(data: FormData) {
  // Create post...
  revalidateTag('posts'); // Revalidate all posts
}
```

### Path-Based Revalidation

```typescript
// Revalidate specific paths
'use server';
import { revalidatePath } from 'next/cache';

export async function updatePost(id: string, data: FormData) {
  // Update post...
  revalidatePath('/posts'); // Revalidate posts list
  revalidatePath(`/posts/${id}`); // Revalidate specific post
}
```

## Server Components Optimization

### Parallel Data Fetching

```typescript
// ✓ Fetch in parallel
export default async function Page() {
  const [posts, categories, user] = await Promise.all([
    getPosts(),
    getCategories(),
    getUser(),
  ]);

  return <div>{/* Use data */}</div>;
}

// ❌ Sequential fetching (slow)
export default async function Page() {
  const posts = await getPosts(); // Wait
  const categories = await getCategories(); // Wait
  const user = await getUser(); // Wait
  return <div>{/* ... */}</div>;
}
```

### Streaming with Suspense

```typescript
// app/page.tsx
import { Suspense } from 'react';
import Posts from '@/components/Posts';
import Sidebar from '@/components/Sidebar';

export default function Page() {
  return (
    <div>
      <Suspense fallback={<div>Loading posts...</div>}>
        <Posts />
      </Suspense>
      <Suspense fallback={<div>Loading sidebar...</div>}>
        <Sidebar />
      </Suspense>
    </div>
  );
}

// components/Posts.tsx (Server Component)
export default async function Posts() {
  const posts = await getPosts(); // Streamed
  return <div>{/* Render posts */}</div>;
}
```

### Preloading Data

```typescript
// ✓ Preload data to avoid waterfalls
import { preload } from 'react-dom';

function preloadPosts() {
  void getPosts();
}

export default function Page() {
  preloadPosts(); // Start fetching early
  return (
    <Suspense fallback={<div>Loading...</div>}>
      <Posts />
    </Suspense>
  );
}
```

## Client Component Optimization

### Minimize Client JavaScript

```typescript
// ✓ Server Component with small Client Component
// app/page.tsx (Server Component)
import LikeButton from '@/components/LikeButton';

export default async function PostPage() {
  const post = await getPost();

  return (
    <article>
      <h1>{post.title}</h1>
      <p>{post.content}</p>
      <LikeButton postId={post.id} /> {/* Only this is client-side */}
    </article>
  );
}

// ❌ Entire page as Client Component
'use client';
export default function PostPage() {
  const [post, setPost] = useState(null);
  useEffect(() => {
    fetchPost().then(setPost);
  }, []);
  // Everything runs on client
}
```

### React Optimization Hooks

```typescript
// ✓ useMemo for expensive calculations
'use client';

import { useMemo } from 'react';

export default function DataTable({ data }) {
  const sortedData = useMemo(() => {
    return data.sort((a, b) => a.value - b.value);
  }, [data]);

  return <div>{/* Render sorted data */}</div>;
}

// ✓ useCallback for function props
'use client';

import { useCallback } from 'react';

export default function Parent() {
  const handleClick = useCallback((id: string) => {
    console.log('Clicked:', id);
  }, []);

  return <Child onClick={handleClick} />;
}

// ✓ React.memo for expensive components
import { memo } from 'react';

const ExpensiveComponent = memo(function ExpensiveComponent({ data }) {
  // Expensive rendering logic
  return <div>{/* ... */}</div>;
});
```

### Virtual Lists

```typescript
// ✓ Use virtualization for long lists
'use client';

import { useVirtualizer } from '@tanstack/react-virtual';
import { useRef } from 'react';

export default function VirtualList({ items }) {
  const parentRef = useRef<HTMLDivElement>(null);

  const virtualizer = useVirtualizer({
    count: items.length,
    getScrollElement: () => parentRef.current,
    estimateSize: () => 50,
  });

  return (
    <div ref={parentRef} style={{ height: '400px', overflow: 'auto' }}>
      <div style={{ height: `${virtualizer.getTotalSize()}px` }}>
        {virtualizer.getVirtualItems().map((virtualRow) => (
          <div
            key={virtualRow.index}
            style={{
              position: 'absolute',
              top: 0,
              left: 0,
              width: '100%',
              height: `${virtualRow.size}px`,
              transform: `translateY(${virtualRow.start}px)`,
            }}
          >
            {items[virtualRow.index].name}
          </div>
        ))}
      </div>
    </div>
  );
}
```

## Database Query Optimization

### Efficient Queries

```typescript
// ✓ Select only needed fields
const users = await User.find()
  .select('name email avatar')
  .lean();

// ❌ Select all fields
const users = await User.find();

// ✓ Use pagination
const posts = await Post.find()
  .limit(20)
  .skip(page * 20)
  .lean();

// ✓ Use indexes for frequent queries
// In your model file
postSchema.index({ userId: 1, createdAt: -1 });

// ✓ Populate only what's needed
const posts = await Post.find()
  .populate('author', 'name avatar')
  .lean();
```

### Connection Pooling

```typescript
// lib/db.ts
import mongoose from 'mongoose';

const MONGODB_URI = process.env.MONGODB_URI!;

if (!MONGODB_URI) {
  throw new Error('Please define MONGODB_URI');
}

let cached = global.mongoose;

if (!cached) {
  cached = global.mongoose = { conn: null, promise: null };
}

async function connectDB() {
  if (cached.conn) {
    return cached.conn;
  }

  if (!cached.promise) {
    const opts = {
      bufferCommands: false,
      maxPoolSize: 10, // Connection pool size
    };

    cached.promise = mongoose.connect(MONGODB_URI, opts).then((mongoose) => {
      return mongoose;
    });
  }

  try {
    cached.conn = await cached.promise;
  } catch (e) {
    cached.promise = null;
    throw e;
  }

  return cached.conn;
}

export default connectDB;
```

### Query Batching

```typescript
// ✓ Use DataLoader for batching
import DataLoader from 'dataloader';

const userLoader = new DataLoader(async (userIds: string[]) => {
  const users = await User.find({ _id: { $in: userIds } }).lean();
  const userMap = new Map(users.map((u) => [u._id.toString(), u]));
  return userIds.map((id) => userMap.get(id));
});

// Use in component
const user = await userLoader.load(userId);
```

## Static Generation Optimization

### Static Params

```typescript
// app/posts/[id]/page.tsx

// Generate static pages for all posts
export async function generateStaticParams() {
  const posts = await getPosts();

  return posts.map((post) => ({
    id: post.id,
  }));
}

export default async function PostPage({ params }) {
  const post = await getPost(params.id);
  return <div>{/* ... */}</div>;
}
```

### Incremental Static Regeneration (ISR)

```typescript
// Revalidate every 60 seconds
export const revalidate = 60;

export default async function Page() {
  const data = await getData();
  return <div>{/* ... */}</div>;
}
```

### On-Demand Revalidation

```typescript
// API route for webhook
import { revalidatePath } from 'next/cache';

export async function POST(request: Request) {
  const body = await request.json();

  // Verify webhook secret
  if (body.secret !== process.env.REVALIDATE_SECRET) {
    return new Response('Invalid secret', { status: 401 });
  }

  // Revalidate specific path
  revalidatePath('/posts');

  return new Response('Revalidated', { status: 200 });
}
```

## Metadata Optimization

### Static Metadata

```typescript
// app/page.tsx
import { Metadata } from 'next';

export const metadata: Metadata = {
  title: 'Home',
  description: 'Welcome to our site',
  openGraph: {
    title: 'Home',
    description: 'Welcome to our site',
    images: ['/og-image.jpg'],
  },
};

export default function Page() {
  return <div>Home</div>;
}
```

### Dynamic Metadata

```typescript
// app/posts/[id]/page.tsx
import { Metadata } from 'next';

export async function generateMetadata({ params }): Promise<Metadata> {
  const post = await getPost(params.id);

  return {
    title: post.title,
    description: post.excerpt,
    openGraph: {
      title: post.title,
      description: post.excerpt,
      images: [post.image],
    },
  };
}
```

## Edge Runtime

### Use Edge for Fast Response

```typescript
// app/api/data/route.ts
export const runtime = 'edge';

export async function GET(request: Request) {
  const data = await fetch('https://api.example.com/data').then((r) =>
    r.json()
  );

  return Response.json(data);
}
```

### Edge Middleware

```typescript
// middleware.ts
export const config = {
  matcher: '/api/:path*',
  runtime: 'edge',
};

export function middleware(request: Request) {
  // Fast edge logic
  return Response.next();
}
```

## Performance Monitoring

### Web Vitals API

```typescript
// app/components/WebVitals.tsx
'use client';

import { useReportWebVitals } from 'next/web-vitals';

export function WebVitals() {
  useReportWebVitals((metric) => {
    console.log(metric);
    // Send to analytics
    if (window.gtag) {
      window.gtag('event', metric.name, {
        value: Math.round(
          metric.name === 'CLS' ? metric.value * 1000 : metric.value
        ),
        event_category: 'Web Vitals',
        non_interaction: true,
      });
    }
  });

  return null;
}
```

### Custom Performance Marks

```typescript
// Measure component render time
export default async function SlowComponent() {
  performance.mark('slow-component-start');

  const data = await getSlowData();

  performance.mark('slow-component-end');
  performance.measure(
    'slow-component',
    'slow-component-start',
    'slow-component-end'
  );

  return <div>{/* ... */}</div>;
}
```

## Build Configuration

### Production Optimization

```javascript
// next.config.js
module.exports = {
  // Compress output
  compress: true,

  // Enable SWC minification
  swcMinify: true,

  // Remove console logs in production
  compiler: {
    removeConsole: process.env.NODE_ENV === 'production',
  },

  // Strict mode
  reactStrictMode: true,

  // Optimize images
  images: {
    formats: ['image/avif', 'image/webp'],
    deviceSizes: [640, 750, 828, 1080, 1200, 1920, 2048, 3840],
  },

  // Enable experimental features
  experimental: {
    optimizeCss: true,
    optimizePackageImports: ['lucide-react', '@radix-ui/react-icons'],
  },
};
```

## Performance Checklist

### Before Deployment

- [ ] Run `ANALYZE=true npm run build` to check bundle size
- [ ] Verify all images use `next/image`
- [ ] Check fonts are optimized with `next/font`
- [ ] Ensure critical data is cached appropriately
- [ ] Minimize use of Client Components
- [ ] Implement loading states with Suspense
- [ ] Add proper metadata for SEO
- [ ] Enable compression in production
- [ ] Set up monitoring (Vercel Analytics, etc.)
- [ ] Test on real devices and networks
- [ ] Verify Core Web Vitals scores
- [ ] Check Lighthouse performance score (aim for 90+)

### Common Performance Issues

1. **Large JavaScript bundles**: Use dynamic imports
2. **Unoptimized images**: Use `next/image`
3. **Sequential data fetching**: Use `Promise.all()`
4. **Too many Client Components**: Convert to Server Components
5. **Missing caching**: Add appropriate cache strategies
6. **Slow database queries**: Add indexes, use `.lean()`
7. **No loading states**: Add `loading.tsx` or Suspense
8. **Large font files**: Use `next/font` with subset selection
9. **Blocking third-party scripts**: Use `next/script` with proper strategy
10. **Layout shifts**: Reserve space for dynamic content

## Tools and Resources

- **Lighthouse**: Built into Chrome DevTools
- **WebPageTest**: https://www.webpagetest.org
- **Vercel Speed Insights**: Built into Vercel deployments
- **Next.js Bundle Analyzer**: Analyze bundle composition
- **Chrome DevTools Performance**: Profile rendering and loading
- **React DevTools Profiler**: Identify slow React renders
