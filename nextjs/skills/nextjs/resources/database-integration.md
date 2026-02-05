# Next.js Database Integration Guide

Comprehensive guide for integrating databases with Next.js App Router applications.

## Database Philosophy for Next.js

1. **Server-Side Only**: Database access only in Server Components and Server Actions
2. **Connection Pooling**: Reuse connections efficiently
3. **Type Safety**: Use TypeScript for schema and queries
4. **Optimize Queries**: Select only needed fields
5. **Edge Considerations**: Some databases work better at the edge

## Prisma Integration

### Setup

```bash
npm install prisma @prisma/client
npx prisma init
```

### Schema Definition

```prisma
// prisma/schema.prisma
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model User {
  id        String   @id @default(cuid())
  email     String   @unique
  name      String?
  password  String
  role      String   @default("user")
  posts     Post[]
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt

  @@index([email])
}

model Post {
  id          String   @id @default(cuid())
  title       String
  description String?
  content     String?
  published   Boolean  @default(false)
  userId      String
  user        User     @relation(fields: [userId], references: [id], onDelete: Cascade)
  tags        Tag[]
  createdAt   DateTime @default(now())
  updatedAt   DateTime @updatedAt

  @@index([userId])
  @@index([published])
}

model Tag {
  id    String @id @default(cuid())
  name  String @unique
  posts Post[]
}
```

### Prisma Client Singleton

```typescript
// lib/prisma.ts
import { PrismaClient } from '@prisma/client';

const globalForPrisma = globalThis as unknown as {
  prisma: PrismaClient | undefined;
};

export const prisma =
  globalForPrisma.prisma ??
  new PrismaClient({
    log:
      process.env.NODE_ENV === 'development'
        ? ['query', 'error', 'warn']
        : ['error'],
  });

if (process.env.NODE_ENV !== 'production') {
  globalForPrisma.prisma = prisma;
}

export default prisma;
```

### Server Component with Prisma

```typescript
// app/posts/page.tsx
import prisma from '@/lib/prisma';
import { auth } from '@/lib/auth';
import { redirect } from 'next/navigation';

export default async function PostsPage() {
  const session = await auth();
  if (!session?.user) redirect('/login');

  // Fetch with relations
  const posts = await prisma.post.findMany({
    where: {
      userId: session.user.id,
    },
    include: {
      tags: true,
    },
    orderBy: {
      createdAt: 'desc',
    },
    take: 20,
  });

  return (
    <div>
      {posts.map((post) => (
        <article key={post.id}>
          <h2>{post.title}</h2>
          <p>{post.description}</p>
          <div>
            {post.tags.map((tag) => (
              <span key={tag.id}>{tag.name}</span>
            ))}
          </div>
        </article>
      ))}
    </div>
  );
}
```

### Server Actions with Prisma

```typescript
// app/posts/actions.ts
'use server';

import prisma from '@/lib/prisma';
import { auth } from '@/lib/auth';
import { revalidatePath } from 'next/cache';
import { redirect } from 'next/navigation';

export async function createPost(formData: FormData) {
  const session = await auth();
  if (!session?.user) throw new Error('Unauthorized');

  const title = formData.get('title') as string;
  const description = formData.get('description') as string;
  const tags = (formData.get('tags') as string).split(',').map((t) => t.trim());

  const post = await prisma.post.create({
    data: {
      title,
      description,
      userId: session.user.id,
      tags: {
        connectOrCreate: tags.map((name) => ({
          where: { name },
          create: { name },
        })),
      },
    },
  });

  revalidatePath('/posts');
  redirect(`/posts/${post.id}`);
}

export async function updatePost(postId: string, formData: FormData) {
  const session = await auth();
  if (!session?.user) throw new Error('Unauthorized');

  // Check ownership
  const post = await prisma.post.findUnique({
    where: { id: postId },
    select: { userId: true },
  });

  if (!post || post.userId !== session.user.id) {
    throw new Error('Forbidden');
  }

  const title = formData.get('title') as string;
  const description = formData.get('description') as string;

  await prisma.post.update({
    where: { id: postId },
    data: { title, description },
  });

  revalidatePath('/posts');
  revalidatePath(`/posts/${postId}`);
  return { success: true };
}

export async function deletePost(postId: string) {
  const session = await auth();
  if (!session?.user) throw new Error('Unauthorized');

  const post = await prisma.post.findUnique({
    where: { id: postId },
    select: { userId: true },
  });

  if (!post || post.userId !== session.user.id) {
    throw new Error('Forbidden');
  }

  await prisma.post.delete({
    where: { id: postId },
  });

  revalidatePath('/posts');
  return { success: true };
}
```

### Transactions

```typescript
// Complex multi-step operation
'use server';

import prisma from '@/lib/prisma';
import { auth } from '@/lib/auth';

export async function transferPost(postId: string, newOwnerId: string) {
  const session = await auth();
  if (!session?.user) throw new Error('Unauthorized');

  // Use transaction for atomic operations
  await prisma.$transaction(async (tx) => {
    // Verify current ownership
    const post = await tx.post.findUnique({
      where: { id: postId },
      select: { userId: true },
    });

    if (!post || post.userId !== session.user.id) {
      throw new Error('Forbidden');
    }

    // Verify new owner exists
    const newOwner = await tx.user.findUnique({
      where: { id: newOwnerId },
    });

    if (!newOwner) {
      throw new Error('New owner not found');
    }

    // Transfer ownership
    await tx.post.update({
      where: { id: postId },
      data: { userId: newOwnerId },
    });

    // Create notification
    await tx.notification.create({
      data: {
        userId: newOwnerId,
        type: 'POST_TRANSFERRED',
        message: `Post "${post.title}" transferred to you`,
      },
    });
  });

  revalidatePath('/posts');
  return { success: true };
}
```

### Pagination

```typescript
// Cursor-based pagination
export async function getPosts(cursor?: string, limit: number = 20) {
  const posts = await prisma.post.findMany({
    take: limit + 1, // Fetch one extra to check if there's more
    ...(cursor && {
      skip: 1,
      cursor: {
        id: cursor,
      },
    }),
    orderBy: {
      createdAt: 'desc',
    },
    include: {
      user: {
        select: {
          name: true,
          avatar: true,
        },
      },
    },
  });

  let nextCursor: string | undefined = undefined;
  if (posts.length > limit) {
    const nextItem = posts.pop();
    nextCursor = nextItem!.id;
  }

  return {
    posts,
    nextCursor,
  };
}

// Offset-based pagination
export async function getPostsPaginated(page: number = 1, limit: number = 20) {
  const skip = (page - 1) * limit;

  const [posts, total] = await Promise.all([
    prisma.post.findMany({
      skip,
      take: limit,
      orderBy: {
        createdAt: 'desc',
      },
    }),
    prisma.post.count(),
  ]);

  return {
    posts,
    pagination: {
      page,
      limit,
      total,
      totalPages: Math.ceil(total / limit),
    },
  };
}
```

## MongoDB with Mongoose

### Setup

```bash
npm install mongoose
```

### Connection Singleton

```typescript
// lib/db.ts
import mongoose from 'mongoose';

const MONGODB_URI = process.env.MONGODB_URI!;

if (!MONGODB_URI) {
  throw new Error('Please define MONGODB_URI environment variable');
}

interface MongooseCache {
  conn: typeof mongoose | null;
  promise: Promise<typeof mongoose> | null;
}

declare global {
  var mongoose: MongooseCache;
}

let cached: MongooseCache = global.mongoose;

if (!cached) {
  cached = global.mongoose = { conn: null, promise: null };
}

async function connectDB(): Promise<typeof mongoose> {
  if (cached.conn) {
    return cached.conn;
  }

  if (!cached.promise) {
    const opts = {
      bufferCommands: false,
      maxPoolSize: 10,
    };

    cached.promise = mongoose.connect(MONGODB_URI, opts).then((mongoose) => {
      console.log('MongoDB connected');
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

### Schema and Models

```typescript
// models/User.ts
import mongoose, { Schema, Document, Model } from 'mongoose';

export interface IUser extends Document {
  email: string;
  name: string;
  password: string;
  role: string;
  createdAt: Date;
  updatedAt: Date;
}

const userSchema = new Schema<IUser>(
  {
    email: {
      type: String,
      required: true,
      unique: true,
      lowercase: true,
      trim: true,
    },
    name: {
      type: String,
      required: true,
      trim: true,
    },
    password: {
      type: String,
      required: true,
    },
    role: {
      type: String,
      enum: ['user', 'admin', 'moderator'],
      default: 'user',
    },
  },
  {
    timestamps: true,
  }
);

// Indexes
userSchema.index({ email: 1 });

const User: Model<IUser> =
  mongoose.models.User || mongoose.model<IUser>('User', userSchema);

export default User;
```

```typescript
// models/Post.ts
import mongoose, { Schema, Document, Model, Types } from 'mongoose';

export interface IPost extends Document {
  title: string;
  description: string;
  content?: string;
  userId: Types.ObjectId;
  tags: string[];
  published: boolean;
  createdAt: Date;
  updatedAt: Date;
}

const postSchema = new Schema<IPost>(
  {
    title: {
      type: String,
      required: true,
      trim: true,
    },
    description: {
      type: String,
      required: true,
    },
    content: {
      type: String,
    },
    userId: {
      type: Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    tags: {
      type: [String],
      default: [],
    },
    published: {
      type: Boolean,
      default: false,
    },
  },
  {
    timestamps: true,
  }
);

// Indexes
postSchema.index({ userId: 1, createdAt: -1 });
postSchema.index({ published: 1, createdAt: -1 });
postSchema.index({ tags: 1 });

const Post: Model<IPost> =
  mongoose.models.Post || mongoose.model<IPost>('Post', postSchema);

export default Post;
```

### Server Component with Mongoose

```typescript
// app/posts/page.tsx
import connectDB from '@/lib/db';
import Post from '@/models/Post';
import { auth } from '@/lib/auth';
import { redirect } from 'next/navigation';

export default async function PostsPage() {
  const session = await auth();
  if (!session?.user) redirect('/login');

  await connectDB();

  // Use .lean() to get plain objects (better performance)
  const posts = await Post.find({ userId: session.user.id })
    .sort({ createdAt: -1 })
    .limit(20)
    .select('title description tags createdAt')
    .lean();

  return (
    <div>
      {posts.map((post) => (
        <article key={post._id.toString()}>
          <h2>{post.title}</h2>
          <p>{post.description}</p>
          <div>
            {post.tags.map((tag) => (
              <span key={tag}>{tag}</span>
            ))}
          </div>
        </article>
      ))}
    </div>
  );
}
```

### Server Actions with Mongoose

```typescript
// app/posts/actions.ts
'use server';

import connectDB from '@/lib/db';
import Post from '@/models/Post';
import { auth } from '@/lib/auth';
import { revalidatePath } from 'next/cache';
import { redirect } from 'next/navigation';

export async function createPost(formData: FormData) {
  const session = await auth();
  if (!session?.user) throw new Error('Unauthorized');

  const title = formData.get('title') as string;
  const description = formData.get('description') as string;
  const tags = (formData.get('tags') as string)
    .split(',')
    .map((t) => t.trim())
    .filter(Boolean);

  await connectDB();

  const post = await Post.create({
    title,
    description,
    userId: session.user.id,
    tags,
  });

  revalidatePath('/posts');
  redirect(`/posts/${post._id.toString()}`);
}

export async function updatePost(postId: string, formData: FormData) {
  const session = await auth();
  if (!session?.user) throw new Error('Unauthorized');

  await connectDB();

  const post = await Post.findById(postId);
  if (!post) {
    return { error: 'Post not found' };
  }

  if (post.userId.toString() !== session.user.id) {
    throw new Error('Forbidden');
  }

  const title = formData.get('title') as string;
  const description = formData.get('description') as string;

  await Post.findByIdAndUpdate(postId, { title, description });

  revalidatePath('/posts');
  revalidatePath(`/posts/${postId}`);
  return { success: true };
}
```

### Aggregations

```typescript
// Complex aggregation query
export async function getPostStats(userId: string) {
  await connectDB();

  const stats = await Post.aggregate([
    { $match: { userId: new Types.ObjectId(userId) } },
    {
      $group: {
        _id: '$published',
        count: { $sum: 1 },
        avgTags: { $avg: { $size: '$tags' } },
      },
    },
  ]);

  return stats;
}

// Popular tags
export async function getPopularTags(limit: number = 10) {
  await connectDB();

  const tags = await Post.aggregate([
    { $unwind: '$tags' },
    { $group: { _id: '$tags', count: { $sum: 1 } } },
    { $sort: { count: -1 } },
    { $limit: limit },
  ]);

  return tags;
}
```

## SQL with Drizzle ORM

### Setup

```bash
npm install drizzle-orm postgres
npm install -D drizzle-kit
```

### Schema Definition

```typescript
// lib/db/schema.ts
import {
  pgTable,
  text,
  timestamp,
  boolean,
  uuid,
  index,
} from 'drizzle-orm/pg-core';
import { relations } from 'drizzle-orm';

export const users = pgTable(
  'users',
  {
    id: uuid('id').primaryKey().defaultRandom(),
    email: text('email').notNull().unique(),
    name: text('name').notNull(),
    password: text('password').notNull(),
    role: text('role').notNull().default('user'),
    createdAt: timestamp('created_at').defaultNow().notNull(),
    updatedAt: timestamp('updated_at').defaultNow().notNull(),
  },
  (table) => ({
    emailIdx: index('email_idx').on(table.email),
  })
);

export const posts = pgTable(
  'posts',
  {
    id: uuid('id').primaryKey().defaultRandom(),
    title: text('title').notNull(),
    description: text('description'),
    content: text('content'),
    userId: uuid('user_id')
      .notNull()
      .references(() => users.id, { onDelete: 'cascade' }),
    published: boolean('published').notNull().default(false),
    createdAt: timestamp('created_at').defaultNow().notNull(),
    updatedAt: timestamp('updated_at').defaultNow().notNull(),
  },
  (table) => ({
    userIdIdx: index('user_id_idx').on(table.userId),
    publishedIdx: index('published_idx').on(table.published),
  })
);

export const usersRelations = relations(users, ({ many }) => ({
  posts: many(posts),
}));

export const postsRelations = relations(posts, ({ one }) => ({
  user: one(users, {
    fields: [posts.userId],
    references: [users.id],
  }),
}));
```

### Database Client

```typescript
// lib/db/index.ts
import { drizzle } from 'drizzle-orm/postgres-js';
import postgres from 'postgres';
import * as schema from './schema';

const connectionString = process.env.DATABASE_URL!;

// Disable prefetch as it's not supported for "Transaction" pool mode
const client = postgres(connectionString, { prepare: false });

export const db = drizzle(client, { schema });
```

### Server Component with Drizzle

```typescript
// app/posts/page.tsx
import { db } from '@/lib/db';
import { posts } from '@/lib/db/schema';
import { auth } from '@/lib/auth';
import { redirect } from 'next/navigation';
import { eq, desc } from 'drizzle-orm';

export default async function PostsPage() {
  const session = await auth();
  if (!session?.user) redirect('/login');

  const userPosts = await db.query.posts.findMany({
    where: eq(posts.userId, session.user.id),
    orderBy: [desc(posts.createdAt)],
    limit: 20,
    with: {
      user: {
        columns: {
          name: true,
          email: true,
        },
      },
    },
  });

  return (
    <div>
      {userPosts.map((post) => (
        <article key={post.id}>
          <h2>{post.title}</h2>
          <p>{post.description}</p>
        </article>
      ))}
    </div>
  );
}
```

### Server Actions with Drizzle

```typescript
// app/posts/actions.ts
'use server';

import { db } from '@/lib/db';
import { posts } from '@/lib/db/schema';
import { auth } from '@/lib/auth';
import { revalidatePath } from 'next/cache';
import { eq, and } from 'drizzle-orm';
import { redirect } from 'next/navigation';

export async function createPost(formData: FormData) {
  const session = await auth();
  if (!session?.user) throw new Error('Unauthorized');

  const title = formData.get('title') as string;
  const description = formData.get('description') as string;

  const [post] = await db
    .insert(posts)
    .values({
      title,
      description,
      userId: session.user.id,
    })
    .returning();

  revalidatePath('/posts');
  redirect(`/posts/${post.id}`);
}

export async function updatePost(postId: string, formData: FormData) {
  const session = await auth();
  if (!session?.user) throw new Error('Unauthorized');

  // Verify ownership
  const [post] = await db
    .select()
    .from(posts)
    .where(eq(posts.id, postId))
    .limit(1);

  if (!post || post.userId !== session.user.id) {
    throw new Error('Forbidden');
  }

  const title = formData.get('title') as string;
  const description = formData.get('description') as string;

  await db
    .update(posts)
    .set({ title, description, updatedAt: new Date() })
    .where(eq(posts.id, postId));

  revalidatePath('/posts');
  revalidatePath(`/posts/${postId}`);
  return { success: true };
}
```

## Edge-Compatible Databases

### Vercel KV (Redis)

```typescript
// lib/kv.ts
import { kv } from '@vercel/kv';

// Cache user data
export async function cacheUser(userId: string, data: any) {
  await kv.set(`user:${userId}`, data, { ex: 3600 }); // 1 hour
}

export async function getCachedUser(userId: string) {
  return await kv.get(`user:${userId}`);
}

// Rate limiting
export async function checkRateLimit(ip: string): Promise<boolean> {
  const key = `ratelimit:${ip}`;
  const count = await kv.incr(key);

  if (count === 1) {
    await kv.expire(key, 60); // 60 seconds window
  }

  return count <= 10; // 10 requests per minute
}

// Session storage
export async function storeSession(sessionId: string, data: any) {
  await kv.set(`session:${sessionId}`, data, { ex: 86400 }); // 24 hours
}
```

### Vercel Postgres (Neon)

```typescript
// lib/postgres.ts
import { sql } from '@vercel/postgres';

export async function getUser(email: string) {
  const { rows } = await sql`
    SELECT id, email, name, role
    FROM users
    WHERE email = ${email}
    LIMIT 1
  `;
  return rows[0];
}

export async function createUser(email: string, name: string, password: string) {
  const { rows } = await sql`
    INSERT INTO users (email, name, password, role)
    VALUES (${email}, ${name}, ${password}, 'user')
    RETURNING id, email, name, role
  `;
  return rows[0];
}
```

## Query Optimization

### Select Only Needed Fields

```typescript
// ✓ Prisma - select specific fields
const users = await prisma.user.findMany({
  select: {
    id: true,
    name: true,
    email: true,
  },
});

// ✓ Mongoose - select specific fields
const users = await User.find().select('name email').lean();

// ✓ Drizzle - select specific columns
const users = await db
  .select({
    id: users.id,
    name: users.name,
    email: users.email,
  })
  .from(users);
```

### Use Indexes

```typescript
// Prisma
@@index([userId, createdAt])
@@index([email])

// Mongoose
schema.index({ userId: 1, createdAt: -1 });
schema.index({ email: 1 });

// Drizzle
index('user_created_idx').on(table.userId, table.createdAt)
```

### Batch Operations

```typescript
// ✓ Prisma - batch create
await prisma.post.createMany({
  data: postsData,
  skipDuplicates: true,
});

// ✓ Mongoose - batch insert
await Post.insertMany(postsData);

// ✓ Drizzle - batch insert
await db.insert(posts).values(postsData);
```

## Testing Database Code

### Mock Prisma

```typescript
// test/mocks/prisma.ts
import { PrismaClient } from '@prisma/client';
import { mockDeep, mockReset, DeepMockProxy } from 'vitest-mock-extended';

export const prismaMock = mockDeep<PrismaClient>();

// test/setup.ts
vi.mock('@/lib/prisma', () => ({
  default: prismaMock,
}));
```

### Test Database Setup

```typescript
// Use separate test database
// .env.test
DATABASE_URL="postgresql://test:test@localhost:5432/test_db"

// Run migrations before tests
beforeAll(async () => {
  await prisma.$executeRaw`CREATE DATABASE IF NOT EXISTS test_db`;
  execSync('npx prisma migrate deploy');
});

// Clean up after tests
afterEach(async () => {
  await prisma.post.deleteMany();
  await prisma.user.deleteMany();
});

afterAll(async () => {
  await prisma.$disconnect();
});
```

## Database Best Practices

### DO:
- Use connection pooling
- Select only needed fields
- Add indexes for frequent queries
- Use transactions for multi-step operations
- Use .lean() with Mongoose for better performance
- Close connections in tests
- Use prepared statements (automatic with ORMs)
- Validate data before database operations
- Handle connection errors gracefully
- Use appropriate data types

### DON'T:
- Query databases in Client Components
- Fetch all fields when you need a few
- Forget to add indexes
- N+1 query problems (use includes/populate)
- Store sensitive data unencrypted
- Use string concatenation for queries (SQL injection)
- Open multiple connections
- Query in loops (batch instead)
- Forget to handle errors

## Migration Management

### Prisma Migrations

```bash
# Create migration
npx prisma migrate dev --name add_user_role

# Apply migrations
npx prisma migrate deploy

# Reset database (dev only)
npx prisma migrate reset
```

### Drizzle Migrations

```bash
# Generate migration
npx drizzle-kit generate:pg

# Apply migration
npx drizzle-kit push:pg
```

## Resources

- [Prisma Documentation](https://www.prisma.io/docs)
- [Mongoose Documentation](https://mongoosejs.com/docs/)
- [Drizzle Documentation](https://orm.drizzle.team/docs/overview)
- [Vercel Postgres](https://vercel.com/docs/storage/vercel-postgres)
- [Vercel KV](https://vercel.com/docs/storage/vercel-kv)
