# Next.js Authentication Patterns

Comprehensive guide for implementing authentication in Next.js App Router applications.

## Authentication Philosophy

1. **Server-Side First**: Always validate auth on the server
2. **Defense in Depth**: Use middleware + Server Component checks
3. **Secure by Default**: Protect routes unless explicitly public
4. **Session Management**: Choose appropriate session strategy
5. **Type Safety**: Properly type session and user data

## Auth.js (NextAuth v5) Setup

### Installation

```bash
npm install next-auth@beta
npm install @auth/mongodb-adapter # or your database adapter
```

### Basic Configuration

```typescript
// lib/auth.ts
import NextAuth from 'next-auth';
import { MongoDBAdapter } from '@auth/mongodb-adapter';
import clientPromise from '@/lib/mongodb';
import Credentials from 'next-auth/providers/credentials';
import Google from 'next-auth/providers/google';
import bcrypt from 'bcryptjs';
import User from '@/models/User';
import connectDB from '@/lib/db';

export const {
  handlers: { GET, POST },
  auth,
  signIn,
  signOut,
} = NextAuth({
  adapter: MongoDBAdapter(clientPromise),
  session: {
    strategy: 'jwt', // or 'database'
  },
  pages: {
    signIn: '/login',
    error: '/auth/error',
  },
  providers: [
    Google({
      clientId: process.env.GOOGLE_CLIENT_ID!,
      clientSecret: process.env.GOOGLE_CLIENT_SECRET!,
    }),
    Credentials({
      credentials: {
        email: { label: 'Email', type: 'email' },
        password: { label: 'Password', type: 'password' },
      },
      async authorize(credentials) {
        if (!credentials?.email || !credentials?.password) {
          throw new Error('Invalid credentials');
        }

        await connectDB();
        const user = await User.findOne({ email: credentials.email });

        if (!user || !user.password) {
          throw new Error('Invalid credentials');
        }

        const isValid = await bcrypt.compare(
          credentials.password as string,
          user.password
        );

        if (!isValid) {
          throw new Error('Invalid credentials');
        }

        return {
          id: user._id.toString(),
          email: user.email,
          name: user.name,
          role: user.role,
        };
      },
    }),
  ],
  callbacks: {
    async jwt({ token, user, trigger, session }) {
      if (user) {
        token.id = user.id;
        token.role = user.role;
      }

      // Handle session updates
      if (trigger === 'update' && session) {
        token = { ...token, ...session.user };
      }

      return token;
    },
    async session({ session, token }) {
      if (session.user) {
        session.user.id = token.id as string;
        session.user.role = token.role as string;
      }
      return session;
    },
  },
});
```

### API Route Handlers

```typescript
// app/api/auth/[...nextauth]/route.ts
export { GET, POST } from '@/lib/auth';
```

### TypeScript Types

```typescript
// types/next-auth.d.ts
import 'next-auth';
import 'next-auth/jwt';

declare module 'next-auth' {
  interface Session {
    user: {
      id: string;
      email: string;
      name: string;
      role: string;
      image?: string;
    };
  }

  interface User {
    role: string;
  }
}

declare module 'next-auth/jwt' {
  interface JWT {
    id: string;
    role: string;
  }
}
```

## Route Protection Patterns

### Middleware Protection

```typescript
// middleware.ts
import { auth } from '@/lib/auth';

export default auth((req) => {
  const { pathname } = req.nextUrl;
  const isAuthenticated = !!req.auth;

  // Public routes
  const publicRoutes = ['/', '/about', '/contact'];
  if (publicRoutes.includes(pathname)) {
    return;
  }

  // Auth routes - redirect if already logged in
  if (pathname.startsWith('/login') || pathname.startsWith('/signup')) {
    if (isAuthenticated) {
      return Response.redirect(new URL('/dashboard', req.url));
    }
    return;
  }

  // Protected routes - require authentication
  if (pathname.startsWith('/dashboard') || pathname.startsWith('/profile')) {
    if (!isAuthenticated) {
      const loginUrl = new URL('/login', req.url);
      loginUrl.searchParams.set('callbackUrl', pathname);
      return Response.redirect(loginUrl);
    }
  }

  // Admin routes - require admin role
  if (pathname.startsWith('/admin')) {
    if (!isAuthenticated || req.auth.user.role !== 'admin') {
      return Response.redirect(new URL('/unauthorized', req.url));
    }
  }
});

export const config = {
  matcher: ['/((?!api|_next/static|_next/image|favicon.ico).*)'],
};
```

### Server Component Protection

```typescript
// app/dashboard/page.tsx
import { auth } from '@/lib/auth';
import { redirect } from 'next/navigation';

export default async function DashboardPage() {
  const session = await auth();

  if (!session?.user) {
    redirect('/login');
  }

  return (
    <div>
      <h1>Welcome, {session.user.name}</h1>
      {/* Dashboard content */}
    </div>
  );
}
```

### Reusable Auth Guard

```typescript
// lib/auth-guard.ts
import { auth } from '@/lib/auth';
import { redirect } from 'next/navigation';

export async function requireAuth() {
  const session = await auth();
  if (!session?.user) {
    redirect('/login');
  }
  return session;
}

export async function requireRole(role: string | string[]) {
  const session = await requireAuth();
  const roles = Array.isArray(role) ? role : [role];

  if (!roles.includes(session.user.role)) {
    redirect('/unauthorized');
  }

  return session;
}

// Usage in page
export default async function AdminPage() {
  const session = await requireRole('admin');
  return <div>Admin content</div>;
}
```

## Server Actions with Auth

### Protected Server Actions

```typescript
// app/dashboard/actions.ts
'use server';

import { auth } from '@/lib/auth';
import { revalidatePath } from 'next/cache';
import connectDB from '@/lib/db';
import Post from '@/models/Post';

export async function createPost(formData: FormData) {
  const session = await auth();

  if (!session?.user) {
    throw new Error('Unauthorized');
  }

  const title = formData.get('title') as string;
  const description = formData.get('description') as string;

  if (!title || title.length === 0) {
    return { error: 'Title is required' };
  }

  await connectDB();

  const post = await Post.create({
    userId: session.user.id,
    title,
    description,
  });

  revalidatePath('/dashboard');
  return { success: true, postId: post._id.toString() };
}

export async function updatePost(postId: string, formData: FormData) {
  const session = await auth();

  if (!session?.user) {
    throw new Error('Unauthorized');
  }

  await connectDB();

  // Check ownership
  const post = await Post.findById(postId);
  if (!post) {
    return { error: 'Post not found' };
  }

  if (post.userId.toString() !== session.user.id) {
    throw new Error('Forbidden');
  }

  const title = formData.get('title') as string;
  await Post.findByIdAndUpdate(postId, { title });

  revalidatePath('/dashboard');
  return { success: true };
}

export async function deletePost(postId: string) {
  const session = await auth();

  if (!session?.user) {
    throw new Error('Unauthorized');
  }

  await connectDB();

  const post = await Post.findById(postId);
  if (!post) {
    return { error: 'Post not found' };
  }

  // Check ownership or admin
  if (
    post.userId.toString() !== session.user.id &&
    session.user.role !== 'admin'
  ) {
    throw new Error('Forbidden');
  }

  await Post.findByIdAndDelete(postId);

  revalidatePath('/dashboard');
  return { success: true };
}
```

### Role-Based Actions

```typescript
// lib/actions/auth.ts
'use server';

import { auth } from '@/lib/auth';

async function requireRole(role: string | string[]) {
  const session = await auth();

  if (!session?.user) {
    throw new Error('Unauthorized');
  }

  const roles = Array.isArray(role) ? role : [role];
  if (!roles.includes(session.user.role)) {
    throw new Error('Forbidden: Insufficient permissions');
  }

  return session;
}

// Admin-only action
export async function deleteUser(userId: string) {
  await requireRole('admin');

  // Delete user logic
  await User.findByIdAndDelete(userId);

  revalidatePath('/admin/users');
  return { success: true };
}

// Moderator or admin action
export async function moderatePost(postId: string, action: 'approve' | 'reject') {
  await requireRole(['admin', 'moderator']);

  // Moderate post logic
  await Post.findByIdAndUpdate(postId, { status: action });

  revalidatePath('/admin/posts');
  return { success: true };
}
```

## Authentication UI Components

### Login Form

```typescript
// app/login/page.tsx
'use client';

import { signIn } from 'next-auth/react';
import { useRouter, useSearchParams } from 'next/navigation';
import { useState } from 'react';

export default function LoginPage() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const callbackUrl = searchParams.get('callbackUrl') || '/dashboard';

  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  async function handleSubmit(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault();
    setLoading(true);
    setError('');

    const formData = new FormData(e.currentTarget);
    const email = formData.get('email') as string;
    const password = formData.get('password') as string;

    try {
      const result = await signIn('credentials', {
        email,
        password,
        redirect: false,
      });

      if (result?.error) {
        setError('Invalid email or password');
        return;
      }

      router.push(callbackUrl);
      router.refresh();
    } catch (error) {
      setError('An error occurred. Please try again.');
    } finally {
      setLoading(false);
    }
  }

  return (
    <div>
      <h1>Login</h1>
      <form onSubmit={handleSubmit}>
        <input
          type="email"
          name="email"
          placeholder="Email"
          required
          disabled={loading}
        />
        <input
          type="password"
          name="password"
          placeholder="Password"
          required
          disabled={loading}
        />
        <button type="submit" disabled={loading}>
          {loading ? 'Logging in...' : 'Login'}
        </button>
        {error && <p className="error">{error}</p>}
      </form>

      <button
        onClick={() => signIn('google', { callbackUrl })}
        disabled={loading}
      >
        Sign in with Google
      </button>
    </div>
  );
}
```

### Sign Up Form with Server Action

```typescript
// app/signup/page.tsx
import { redirect } from 'next/navigation';
import { signUp } from './actions';

export default function SignUpPage() {
  return (
    <div>
      <h1>Sign Up</h1>
      <form action={signUp}>
        <input type="text" name="name" placeholder="Name" required />
        <input type="email" name="email" placeholder="Email" required />
        <input
          type="password"
          name="password"
          placeholder="Password"
          minLength={8}
          required
        />
        <button type="submit">Sign Up</button>
      </form>
    </div>
  );
}

// app/signup/actions.ts
'use server';

import { signIn } from '@/lib/auth';
import connectDB from '@/lib/db';
import User from '@/models/User';
import bcrypt from 'bcryptjs';
import { redirect } from 'next/navigation';

export async function signUp(formData: FormData) {
  const name = formData.get('name') as string;
  const email = formData.get('email') as string;
  const password = formData.get('password') as string;

  if (!name || !email || !password) {
    return { error: 'All fields are required' };
  }

  if (password.length < 8) {
    return { error: 'Password must be at least 8 characters' };
  }

  await connectDB();

  const existingUser = await User.findOne({ email });
  if (existingUser) {
    return { error: 'Email already in use' };
  }

  const hashedPassword = await bcrypt.hash(password, 10);

  await User.create({
    name,
    email,
    password: hashedPassword,
    role: 'user',
  });

  // Auto login after signup
  await signIn('credentials', {
    email,
    password,
    redirect: false,
  });

  redirect('/dashboard');
}
```

### User Menu Component

```typescript
// components/UserMenu.tsx
import { auth } from '@/lib/auth';
import { signOut } from '@/lib/auth';
import Link from 'next/link';

export default async function UserMenu() {
  const session = await auth();

  if (!session?.user) {
    return (
      <div>
        <Link href="/login">Login</Link>
        <Link href="/signup">Sign Up</Link>
      </div>
    );
  }

  return (
    <div>
      <span>Welcome, {session.user.name}</span>
      <Link href="/dashboard">Dashboard</Link>
      <Link href="/profile">Profile</Link>
      {session.user.role === 'admin' && (
        <Link href="/admin">Admin</Link>
      )}
      <form
        action={async () => {
          'use server';
          await signOut();
        }}
      >
        <button type="submit">Logout</button>
      </form>
    </div>
  );
}
```

## Session Management

### Client-Side Session Access

```typescript
// components/ClientUserMenu.tsx
'use client';

import { useSession, signOut } from 'next-auth/react';
import Link from 'next/link';

export default function ClientUserMenu() {
  const { data: session, status } = useSession();

  if (status === 'loading') {
    return <div>Loading...</div>;
  }

  if (!session) {
    return <Link href="/login">Login</Link>;
  }

  return (
    <div>
      <span>{session.user.name}</span>
      <button onClick={() => signOut()}>Logout</button>
    </div>
  );
}
```

### Session Provider

```typescript
// app/providers.tsx
'use client';

import { SessionProvider } from 'next-auth/react';

export default function Providers({ children }: { children: React.ReactNode }) {
  return <SessionProvider>{children}</SessionProvider>;
}

// app/layout.tsx
import Providers from './providers';

export default function RootLayout({ children }) {
  return (
    <html>
      <body>
        <Providers>{children}</Providers>
      </body>
    </html>
  );
}
```

### Update Session

```typescript
// Update session after profile change
'use client';

import { useSession } from 'next-auth/react';

export default function ProfileForm() {
  const { data: session, update } = useSession();

  async function handleUpdate(formData: FormData) {
    const name = formData.get('name') as string;

    // Update in database
    await updateProfile({ name });

    // Update session
    await update({ name });
  }

  return (
    <form action={handleUpdate}>
      <input name="name" defaultValue={session?.user.name} />
      <button type="submit">Update</button>
    </form>
  );
}
```

## Password Reset Flow

### Request Reset

```typescript
// app/forgot-password/page.tsx
import { requestPasswordReset } from './actions';

export default function ForgotPasswordPage() {
  return (
    <form action={requestPasswordReset}>
      <input type="email" name="email" required />
      <button type="submit">Send Reset Link</button>
    </form>
  );
}

// app/forgot-password/actions.ts
'use server';

import connectDB from '@/lib/db';
import User from '@/models/User';
import crypto from 'crypto';
import { sendEmail } from '@/lib/email';

export async function requestPasswordReset(formData: FormData) {
  const email = formData.get('email') as string;

  await connectDB();
  const user = await User.findOne({ email });

  if (!user) {
    // Don't reveal if user exists
    return { success: true };
  }

  // Generate reset token
  const resetToken = crypto.randomBytes(32).toString('hex');
  const resetTokenExpiry = Date.now() + 3600000; // 1 hour

  user.resetToken = resetToken;
  user.resetTokenExpiry = resetTokenExpiry;
  await user.save();

  // Send email
  const resetUrl = `${process.env.NEXT_PUBLIC_URL}/reset-password?token=${resetToken}`;
  await sendEmail({
    to: email,
    subject: 'Password Reset',
    html: `Click <a href="${resetUrl}">here</a> to reset your password.`,
  });

  return { success: true };
}
```

### Reset Password

```typescript
// app/reset-password/page.tsx
import { resetPassword } from './actions';

export default function ResetPasswordPage({
  searchParams,
}: {
  searchParams: { token: string };
}) {
  return (
    <form action={resetPassword}>
      <input type="hidden" name="token" value={searchParams.token} />
      <input type="password" name="password" minLength={8} required />
      <button type="submit">Reset Password</button>
    </form>
  );
}

// app/reset-password/actions.ts
'use server';

import connectDB from '@/lib/db';
import User from '@/models/User';
import bcrypt from 'bcryptjs';
import { redirect } from 'next/navigation';

export async function resetPassword(formData: FormData) {
  const token = formData.get('token') as string;
  const password = formData.get('password') as string;

  await connectDB();

  const user = await User.findOne({
    resetToken: token,
    resetTokenExpiry: { $gt: Date.now() },
  });

  if (!user) {
    return { error: 'Invalid or expired token' };
  }

  const hashedPassword = await bcrypt.hash(password, 10);
  user.password = hashedPassword;
  user.resetToken = undefined;
  user.resetTokenExpiry = undefined;
  await user.save();

  redirect('/login');
}
```

## Multi-Factor Authentication

### Setup TOTP

```typescript
// lib/totp.ts
import * as OTPAuth from 'otpauth';
import QRCode from 'qrcode';

export function generateTOTPSecret(email: string) {
  const totp = new OTPAuth.TOTP({
    issuer: 'YourApp',
    label: email,
    algorithm: 'SHA1',
    digits: 6,
    period: 30,
  });

  return totp.secret.base32;
}

export async function generateQRCode(secret: string, email: string) {
  const totp = new OTPAuth.TOTP({
    issuer: 'YourApp',
    label: email,
    secret: OTPAuth.Secret.fromBase32(secret),
    algorithm: 'SHA1',
    digits: 6,
    period: 30,
  });

  const otpauthURL = totp.toString();
  return await QRCode.toDataURL(otpauthURL);
}

export function verifyTOTP(token: string, secret: string): boolean {
  const totp = new OTPAuth.TOTP({
    secret: OTPAuth.Secret.fromBase32(secret),
    algorithm: 'SHA1',
    digits: 6,
    period: 30,
  });

  const delta = totp.validate({ token, window: 1 });
  return delta !== null;
}
```

### Enable 2FA

```typescript
// app/settings/security/actions.ts
'use server';

import { auth } from '@/lib/auth';
import { generateTOTPSecret, generateQRCode, verifyTOTP } from '@/lib/totp';
import User from '@/models/User';
import connectDB from '@/lib/db';

export async function setupTwoFactor() {
  const session = await auth();
  if (!session?.user) throw new Error('Unauthorized');

  const secret = generateTOTPSecret(session.user.email);
  const qrCode = await generateQRCode(secret, session.user.email);

  // Store temp secret (confirm before enabling)
  await connectDB();
  await User.findByIdAndUpdate(session.user.id, {
    totpSecretTemp: secret,
  });

  return { qrCode, secret };
}

export async function enableTwoFactor(token: string) {
  const session = await auth();
  if (!session?.user) throw new Error('Unauthorized');

  await connectDB();
  const user = await User.findById(session.user.id);

  if (!user?.totpSecretTemp) {
    return { error: 'No setup in progress' };
  }

  const isValid = verifyTOTP(token, user.totpSecretTemp);
  if (!isValid) {
    return { error: 'Invalid code' };
  }

  // Enable 2FA
  user.totpSecret = user.totpSecretTemp;
  user.totpSecretTemp = undefined;
  user.twoFactorEnabled = true;
  await user.save();

  return { success: true };
}
```

## API Route Protection

```typescript
// app/api/posts/route.ts
import { auth } from '@/lib/auth';
import { NextRequest } from 'next/server';

export async function GET(request: NextRequest) {
  const session = await auth();

  if (!session?.user) {
    return Response.json({ error: 'Unauthorized' }, { status: 401 });
  }

  // Fetch posts for user
  const posts = await getPosts(session.user.id);

  return Response.json({ posts });
}

export async function POST(request: NextRequest) {
  const session = await auth();

  if (!session?.user) {
    return Response.json({ error: 'Unauthorized' }, { status: 401 });
  }

  // Check role
  if (session.user.role !== 'admin') {
    return Response.json({ error: 'Forbidden' }, { status: 403 });
  }

  const body = await request.json();
  // Create post...

  return Response.json({ success: true }, { status: 201 });
}
```

## Security Best Practices

### Environment Variables

```env
# .env.local
NEXTAUTH_URL=http://localhost:3000
NEXTAUTH_SECRET=your-secret-key-here

GOOGLE_CLIENT_ID=your-google-client-id
GOOGLE_CLIENT_SECRET=your-google-client-secret

MONGODB_URI=your-mongodb-uri
```

### Security Checklist

- [ ] Use HTTPS in production
- [ ] Set secure session cookie settings
- [ ] Implement rate limiting on auth endpoints
- [ ] Hash passwords with bcrypt (min 10 rounds)
- [ ] Validate all user input
- [ ] Implement CSRF protection (built into Auth.js)
- [ ] Use HTTP-only cookies for sessions
- [ ] Implement password complexity requirements
- [ ] Add account lockout after failed attempts
- [ ] Log authentication events
- [ ] Implement email verification
- [ ] Use secure password reset tokens
- [ ] Set appropriate session expiration
- [ ] Implement logout on all devices
- [ ] Sanitize error messages (don't reveal user existence)

## Common Patterns Summary

1. **Always validate auth server-side**: Never trust client
2. **Use middleware for route protection**: First line of defense
3. **Check auth in Server Components**: Second layer
4. **Validate in Server Actions**: Protect mutations
5. **Type your session data**: Avoid runtime errors
6. **Handle errors gracefully**: Don't leak information
7. **Implement proper logout**: Clear all session data
8. **Use secure defaults**: Auth.js has good defaults
