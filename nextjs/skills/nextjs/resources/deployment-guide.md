# Next.js Deployment Guide

Comprehensive guide for deploying Next.js App Router applications to production.

## Deployment Philosophy

1. **Environment-Specific Configuration**: Separate dev, staging, production
2. **Security First**: Proper secrets management
3. **Performance Optimization**: Enable all production optimizations
4. **Monitoring**: Track errors and performance
5. **CI/CD**: Automate testing and deployment

## Vercel Deployment (Recommended)

### Why Vercel

- Built by Next.js creators
- Zero-config deployment
- Automatic HTTPS
- Edge network (CDN)
- Serverless functions
- Preview deployments
- Analytics included
- Optimized for Next.js

### Setup

```bash
# Install Vercel CLI
npm install -g vercel

# Login
vercel login

# Deploy
vercel

# Deploy to production
vercel --prod
```

### vercel.json Configuration

```json
{
  "buildCommand": "npm run build",
  "devCommand": "npm run dev",
  "installCommand": "npm install",
  "framework": "nextjs",
  "regions": ["iad1"],
  "env": {
    "NEXT_PUBLIC_API_URL": "https://api.example.com"
  },
  "headers": [
    {
      "source": "/(.*)",
      "headers": [
        {
          "key": "X-Frame-Options",
          "value": "DENY"
        },
        {
          "key": "X-Content-Type-Options",
          "value": "nosniff"
        }
      ]
    }
  ],
  "redirects": [
    {
      "source": "/old-path",
      "destination": "/new-path",
      "permanent": true
    }
  ]
}
```

### Environment Variables

```bash
# Set via CLI
vercel env add MONGODB_URI production

# Or via dashboard
# Visit: https://vercel.com/your-project/settings/environment-variables
```

### Git Integration

```yaml
# Automatic deployments:
# - Push to main → Production
# - Push to other branches → Preview
# - Pull requests → Preview

# .gitignore
.vercel
.env*.local
```

## Self-Hosted Deployment

### Docker

```dockerfile
# Dockerfile
FROM node:20-alpine AS base

# Install dependencies only when needed
FROM base AS deps
RUN apk add --no-cache libc6-compat
WORKDIR /app

COPY package.json package-lock.json* ./
RUN npm ci

# Rebuild the source code only when needed
FROM base AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .

ENV NEXT_TELEMETRY_DISABLED 1

RUN npm run build

# Production image, copy all the files and run next
FROM base AS runner
WORKDIR /app

ENV NODE_ENV production
ENV NEXT_TELEMETRY_DISABLED 1

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

COPY --from=builder /app/public ./public
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

USER nextjs

EXPOSE 3000

ENV PORT 3000

CMD ["node", "server.js"]
```

```javascript
// next.config.js (required for standalone)
module.exports = {
  output: 'standalone',
};
```

```yaml
# docker-compose.yml
version: '3.8'

services:
  nextjs:
    build: .
    ports:
      - '3000:3000'
    environment:
      - DATABASE_URL=${DATABASE_URL}
      - NEXTAUTH_SECRET=${NEXTAUTH_SECRET}
      - NEXTAUTH_URL=${NEXTAUTH_URL}
    depends_on:
      - postgres
    restart: unless-stopped

  postgres:
    image: postgres:16
    environment:
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=postgres
      - POSTGRES_DB=myapp
    volumes:
      - postgres_data:/var/lib/postgresql/data
    restart: unless-stopped

volumes:
  postgres_data:
```

### Node.js Server

```bash
# Build for production
npm run build

# Start production server
npm run start

# Or with PM2
npm install -g pm2
pm2 start npm --name "nextjs" -- start
pm2 save
pm2 startup
```

### Nginx Reverse Proxy

```nginx
# /etc/nginx/sites-available/myapp
server {
    listen 80;
    server_name example.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}

# Enable site
ln -s /etc/nginx/sites-available/myapp /etc/nginx/sites-enabled/
nginx -t
systemctl reload nginx
```

### HTTPS with Certbot

```bash
# Install Certbot
sudo apt install certbot python3-certbot-nginx

# Get certificate
sudo certbot --nginx -d example.com

# Auto-renewal (already set up)
sudo certbot renew --dry-run
```

## AWS Deployment

### Amplify

```bash
# Install Amplify CLI
npm install -g @aws-amplify/cli

# Initialize
amplify init

# Add hosting
amplify add hosting

# Deploy
amplify publish
```

```yaml
# amplify.yml
version: 1
frontend:
  phases:
    preBuild:
      commands:
        - npm ci
    build:
      commands:
        - npm run build
  artifacts:
    baseDirectory: .next
    files:
      - '**/*'
  cache:
    paths:
      - node_modules/**/*
      - .next/cache/**/*
```

### EC2 with Auto Scaling

```bash
# User Data script for EC2
#!/bin/bash
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt-get install -y nodejs nginx

# Clone and build app
cd /opt
git clone https://github.com/your/repo.git app
cd app
npm ci
npm run build

# Setup PM2
npm install -g pm2
pm2 start npm --name "nextjs" -- start
pm2 startup systemd
pm2 save

# Configure Nginx (copy config from above)
```

### CloudFront + S3 (Static Export Only)

```javascript
// next.config.js (for static export)
module.exports = {
  output: 'export',
  images: {
    unoptimized: true,
  },
};
```

```bash
# Build static site
npm run build

# Upload to S3
aws s3 sync out/ s3://your-bucket-name

# Invalidate CloudFront cache
aws cloudfront create-invalidation \
  --distribution-id YOUR_DIST_ID \
  --paths "/*"
```

## Environment Variables

### Development

```env
# .env.local
DATABASE_URL="postgresql://localhost:5432/dev"
NEXTAUTH_URL="http://localhost:3000"
NEXTAUTH_SECRET="dev-secret-change-in-production"
```

### Production

```env
# .env.production
DATABASE_URL="postgresql://prod-server:5432/prod"
NEXTAUTH_URL="https://example.com"
NEXTAUTH_SECRET="strong-random-secret-here"

# Never commit this file!
# Use platform's secret management instead
```

### Client-Side Variables

```env
# Must use NEXT_PUBLIC_ prefix
NEXT_PUBLIC_API_URL="https://api.example.com"
NEXT_PUBLIC_ANALYTICS_ID="GA-123456"
```

```typescript
// Access in any component
console.log(process.env.NEXT_PUBLIC_API_URL);

// Server-side only (no prefix)
console.log(process.env.DATABASE_URL); // undefined on client
```

## Build Optimization

### Production next.config.js

```javascript
// next.config.js
module.exports = {
  // Enable React strict mode
  reactStrictMode: true,

  // Compress output
  compress: true,

  // Remove console logs in production
  compiler: {
    removeConsole: process.env.NODE_ENV === 'production',
  },

  // Optimize images
  images: {
    formats: ['image/avif', 'image/webp'],
    deviceSizes: [640, 750, 828, 1080, 1200, 1920, 2048, 3840],
    imageSizes: [16, 32, 48, 64, 96, 128, 256, 384],
    minimumCacheTTL: 60,
  },

  // Security headers
  async headers() {
    return [
      {
        source: '/(.*)',
        headers: [
          {
            key: 'X-DNS-Prefetch-Control',
            value: 'on',
          },
          {
            key: 'Strict-Transport-Security',
            value: 'max-age=63072000; includeSubDomains; preload',
          },
          {
            key: 'X-Frame-Options',
            value: 'SAMEORIGIN',
          },
          {
            key: 'X-Content-Type-Options',
            value: 'nosniff',
          },
          {
            key: 'X-XSS-Protection',
            value: '1; mode=block',
          },
          {
            key: 'Referrer-Policy',
            value: 'origin-when-cross-origin',
          },
        ],
      },
    ];
  },

  // Redirects
  async redirects() {
    return [
      {
        source: '/old-blog/:slug',
        destination: '/blog/:slug',
        permanent: true,
      },
    ];
  },

  // Rewrites
  async rewrites() {
    return [
      {
        source: '/api/external/:path*',
        destination: 'https://external-api.com/:path*',
      },
    ];
  },
};
```

## CI/CD with GitHub Actions

### Basic Workflow

```yaml
# .github/workflows/deploy.yml
name: Deploy

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

env:
  NODE_VERSION: '20'

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Run linter
        run: npm run lint

      - name: Run type check
        run: npm run type-check

      - name: Run tests
        run: npm test

      - name: Build
        run: npm run build
        env:
          DATABASE_URL: ${{ secrets.DATABASE_URL }}

  deploy:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v4

      - name: Deploy to Vercel
        uses: amondnet/vercel-action@v25
        with:
          vercel-token: ${{ secrets.VERCEL_TOKEN }}
          vercel-org-id: ${{ secrets.VERCEL_ORG_ID }}
          vercel-project-id: ${{ secrets.VERCEL_PROJECT_ID }}
          vercel-args: '--prod'
```

### With E2E Tests

```yaml
# .github/workflows/e2e.yml
name: E2E Tests

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  e2e:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'

      - name: Install dependencies
        run: npm ci

      - name: Install Playwright
        run: npx playwright install --with-deps

      - name: Build app
        run: npm run build

      - name: Run E2E tests
        run: npm run test:e2e
        env:
          DATABASE_URL: ${{ secrets.TEST_DATABASE_URL }}

      - name: Upload test results
        if: always()
        uses: actions/upload-artifact@v3
        with:
          name: playwright-report
          path: playwright-report/
```

## Database Migrations

### Prisma

```bash
# In CI/CD, run migrations before deployment
npx prisma migrate deploy

# Or in package.json
{
  "scripts": {
    "deploy": "prisma migrate deploy && npm start"
  }
}
```

### Automated in GitHub Actions

```yaml
- name: Run database migrations
  run: npx prisma migrate deploy
  env:
    DATABASE_URL: ${{ secrets.DATABASE_URL }}
```

## Monitoring and Logging

### Vercel Analytics

```typescript
// app/layout.tsx
import { Analytics } from '@vercel/analytics/react';
import { SpeedInsights } from '@vercel/speed-insights/next';

export default function RootLayout({ children }) {
  return (
    <html>
      <body>
        {children}
        <Analytics />
        <SpeedInsights />
      </body>
    </html>
  );
}
```

### Sentry Error Tracking

```bash
npm install @sentry/nextjs
```

```javascript
// sentry.client.config.js
import * as Sentry from '@sentry/nextjs';

Sentry.init({
  dsn: process.env.NEXT_PUBLIC_SENTRY_DSN,
  tracesSampleRate: 1.0,
  environment: process.env.NODE_ENV,
});
```

```javascript
// sentry.server.config.js
import * as Sentry from '@sentry/nextjs';

Sentry.init({
  dsn: process.env.SENTRY_DSN,
  tracesSampleRate: 1.0,
  environment: process.env.NODE_ENV,
});
```

### Custom Logging

```typescript
// lib/logger.ts
import pino from 'pino';

export const logger = pino({
  level: process.env.LOG_LEVEL || 'info',
  transport:
    process.env.NODE_ENV === 'development'
      ? {
          target: 'pino-pretty',
          options: {
            colorize: true,
          },
        }
      : undefined,
});

// Usage
logger.info({ userId: '123' }, 'User logged in');
logger.error({ error }, 'Database connection failed');
```

## Health Checks

```typescript
// app/api/health/route.ts
import { NextResponse } from 'next/server';
import prisma from '@/lib/prisma';

export async function GET() {
  try {
    // Check database connection
    await prisma.$queryRaw`SELECT 1`;

    return NextResponse.json({
      status: 'healthy',
      timestamp: new Date().toISOString(),
      uptime: process.uptime(),
    });
  } catch (error) {
    return NextResponse.json(
      {
        status: 'unhealthy',
        error: 'Database connection failed',
      },
      { status: 503 }
    );
  }
}
```

## Performance Monitoring

### Web Vitals Reporting

```typescript
// app/components/WebVitals.tsx
'use client';

import { useReportWebVitals } from 'next/web-vitals';

export function WebVitals() {
  useReportWebVitals((metric) => {
    // Send to analytics
    fetch('/api/analytics', {
      method: 'POST',
      body: JSON.stringify({
        name: metric.name,
        value: metric.value,
        id: metric.id,
      }),
    });
  });

  return null;
}
```

## Security Checklist

### Pre-Deployment

- [ ] Use HTTPS in production
- [ ] Set secure environment variables
- [ ] Enable security headers
- [ ] Implement rate limiting
- [ ] Validate all user input
- [ ] Use CSP (Content Security Policy)
- [ ] Enable CORS only for trusted domains
- [ ] Hash passwords properly
- [ ] Use secure session cookies
- [ ] Implement CSRF protection
- [ ] Keep dependencies updated
- [ ] Remove development tools in production
- [ ] Set up error monitoring
- [ ] Configure logging
- [ ] Test authentication flows
- [ ] Review API permissions

### Content Security Policy

```javascript
// next.config.js
const cspHeader = `
  default-src 'self';
  script-src 'self' 'unsafe-eval' 'unsafe-inline';
  style-src 'self' 'unsafe-inline';
  img-src 'self' blob: data: https:;
  font-src 'self';
  object-src 'none';
  base-uri 'self';
  form-action 'self';
  frame-ancestors 'none';
  upgrade-insecure-requests;
`;

module.exports = {
  async headers() {
    return [
      {
        source: '/(.*)',
        headers: [
          {
            key: 'Content-Security-Policy',
            value: cspHeader.replace(/\n/g, ''),
          },
        ],
      },
    ];
  },
};
```

## Deployment Checklist

### Before Deploy

- [ ] Run all tests (`npm test`)
- [ ] Check type errors (`npm run type-check`)
- [ ] Run linter (`npm run lint`)
- [ ] Build successfully (`npm run build`)
- [ ] Test production build locally (`npm start`)
- [ ] Review environment variables
- [ ] Check database migrations
- [ ] Review security headers
- [ ] Test error handling
- [ ] Verify analytics setup
- [ ] Check performance (Lighthouse)
- [ ] Test on real devices
- [ ] Review bundle size
- [ ] Verify image optimization
- [ ] Test authentication flows

### After Deploy

- [ ] Verify site is accessible
- [ ] Test critical user flows
- [ ] Check error tracking works
- [ ] Verify analytics tracking
- [ ] Monitor performance metrics
- [ ] Check database connections
- [ ] Test API endpoints
- [ ] Verify email delivery (if applicable)
- [ ] Check logs for errors
- [ ] Test from different locations
- [ ] Verify SSL certificate
- [ ] Check redirects work
- [ ] Test mobile experience

## Rollback Strategy

### Vercel

```bash
# List deployments
vercel ls

# Rollback to previous deployment
vercel rollback <deployment-url>

# Or promote a specific deployment
vercel promote <deployment-url>
```

### Docker

```bash
# Keep previous image
docker tag myapp:latest myapp:previous

# Build new image
docker build -t myapp:latest .

# Rollback if needed
docker stop myapp
docker run --name myapp myapp:previous
```

## Scaling Considerations

### Horizontal Scaling

- Use serverless functions (automatic on Vercel)
- Configure auto-scaling (EC2, ECS)
- Use load balancer (ALB, nginx)
- Implement health checks
- Use database connection pooling

### Caching Strategy

- Enable Next.js caching (built-in)
- Use CDN for static assets
- Implement Redis for session/data cache
- Use stale-while-revalidate
- Configure proper cache headers

### Database Optimization

- Add appropriate indexes
- Use read replicas
- Implement connection pooling
- Cache frequent queries
- Use database query optimization

## Resources

- [Next.js Deployment Documentation](https://nextjs.org/docs/deployment)
- [Vercel Documentation](https://vercel.com/docs)
- [Docker Documentation](https://docs.docker.com/)
- [AWS Amplify Documentation](https://docs.amplify.aws/)
- [Nginx Documentation](https://nginx.org/en/docs/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
