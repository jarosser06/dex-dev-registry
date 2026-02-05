---
name: vite
description: Expert in Vite development patterns, native ES modules, lightning-fast HMR, production builds, framework integration, and modern build optimization. Use when working with Vite projects or build tooling.
---

# Vite Development Skill

Expert knowledge of Vite for modern web application development.

## Documentation-First Approach

**This skill provides patterns and best practices, but always consult the official Vite documentation for the most up-to-date and detailed information.**

The Vite ecosystem evolves rapidly. When implementing features:

1. **Check the official docs first**: [https://vite.dev/](https://vite.dev/)
2. **Review configuration options**: [https://vite.dev/config/](https://vite.dev/config/)
3. **Explore plugin APIs**: [https://vite.dev/guide/api-plugin](https://vite.dev/guide/api-plugin)
4. **Reference CLI options**: [https://vite.dev/guide/cli](https://vite.dev/guide/cli)

The examples below provide starting points, but the official documentation contains:
- Complete API references
- Up-to-date migration guides
- Framework-specific integration details
- Performance optimization strategies
- Troubleshooting guides

**When in doubt, always verify with the official documentation.**

## Core Philosophy

1. **Native ES Modules in Development**: No bundling during development, instant server start
2. **Lightning-Fast HMR**: Sub-second hot module replacement using native ESM
3. **Rollup for Production**: Optimized, tree-shaken builds using Rollup
4. **Framework Agnostic**: Works with React, Vue, Svelte, or vanilla JavaScript
5. **Modern Browser First**: Targets modern browsers, with legacy support via plugin

## Recommended File Structure

### Basic Vite + React + TypeScript Project

```
project/
├── index.html              # Entry point (in root!)
├── src/
│   ├── main.tsx           # Application entry
│   ├── App.tsx            # Root component
│   ├── components/        # Reusable components
│   ├── pages/             # Page components
│   ├── lib/               # Utilities
│   ├── assets/            # Static assets (images, fonts)
│   └── vite-env.d.ts      # Vite client types
├── public/                # Static files (copied as-is)
├── vite.config.ts         # Vite configuration
├── tsconfig.json          # TypeScript config
├── tsconfig.node.json     # TypeScript config for build
└── package.json
```

### Multi-Page Application

```
project/
├── index.html             # Main page
├── about.html             # About page
├── contact.html           # Contact page
├── src/
│   ├── main.ts           # Main entry
│   ├── about.ts          # About entry
│   └── contact.ts        # Contact entry
└── vite.config.ts        # Configure multiple entries
```

## Common Patterns

> **Documentation**: See the [Configuration Reference](https://vite.dev/config/) for all available options.

### Basic Vite Configuration

```typescript
// vite.config.ts
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import path from 'path';

export default defineConfig({
  plugins: [react()],

  // Path aliases
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
      '@components': path.resolve(__dirname, './src/components'),
      '@lib': path.resolve(__dirname, './src/lib'),
    },
  },

  // Dev server configuration
  server: {
    port: 3000,
    open: true,
    cors: true,
  },

  // Build configuration
  build: {
    outDir: 'dist',
    sourcemap: true,
    rollupOptions: {
      output: {
        manualChunks: {
          vendor: ['react', 'react-dom'],
        },
      },
    },
  },
});
```

### Environment Variables

> **Documentation**: [Env Variables and Modes](https://vite.dev/guide/env-and-mode)

Vite exposes environment variables through `import.meta.env`.

```typescript
// .env
VITE_API_URL=https://api.example.com
VITE_APP_TITLE=My App
```

```typescript
// src/config.ts
export const config = {
  apiUrl: import.meta.env.VITE_API_URL,
  appTitle: import.meta.env.VITE_APP_TITLE,
  isDev: import.meta.env.DEV,
  isProd: import.meta.env.PROD,
  mode: import.meta.env.MODE,
};
```

### TypeScript Environment Variable Types

```typescript
// src/vite-env.d.ts
/// <reference types="vite/client" />

interface ImportMetaEnv {
  readonly VITE_API_URL: string;
  readonly VITE_APP_TITLE: string;
  readonly VITE_FEATURE_FLAG: boolean;
}

interface ImportMeta {
  readonly env: ImportMetaEnv;
}
```

### Hot Module Replacement (HMR) API

> **Documentation**: [HMR API Reference](https://vite.dev/guide/api-hmr)

```typescript
// src/main.ts
import { setupApp } from './app';

setupApp();

// HMR for development
if (import.meta.hot) {
  import.meta.hot.accept('./app', (newModule) => {
    if (newModule) {
      newModule.setupApp();
    }
  });

  // Dispose callback for cleanup
  import.meta.hot.dispose(() => {
    console.log('Module disposing...');
  });
}
```

### Dynamic Imports & Code Splitting

> **Documentation**: [Features - Dynamic Import](https://vite.dev/guide/features#dynamic-import)

```typescript
// Lazy loading routes
const Dashboard = lazy(() => import('./pages/Dashboard'));
const Settings = lazy(() => import('./pages/Settings'));

// Dynamic imports for conditional loading
async function loadAnalytics() {
  if (import.meta.env.PROD) {
    const analytics = await import('./lib/analytics');
    analytics.init();
  }
}

// Preloading modules
const preloadAbout = () => import('./pages/About');
// Call preloadAbout() on hover or other trigger
```

### Asset Handling

> **Documentation**: [Static Asset Handling](https://vite.dev/guide/assets)

```typescript
// Importing assets (gets optimized URL)
import logo from './assets/logo.png';
import styles from './styles.module.css';

function App() {
  return (
    <div className={styles.container}>
      <img src={logo} alt="Logo" />
    </div>
  );
}

// Explicit URL imports
import workerUrl from './worker?url';
import shaderCode from './shader.glsl?raw';
import jsonData from './data.json';

// Static assets in public/ (not processed)
// Reference with absolute path: /favicon.ico
```

### CSS & Styling Patterns

```typescript
// CSS Modules
import styles from './Button.module.css';

export function Button({ children }) {
  return <button className={styles.primary}>{children}</button>;
}

// PostCSS (auto-detected if postcss.config.js exists)
// Sass/SCSS (install sass package)
import './styles.scss';

// CSS-in-JS (styled-components, emotion)
import styled from 'styled-components';

const Button = styled.button`
  background: blue;
  color: white;
`;
```

### Multi-Page Application Setup

```typescript
// vite.config.ts
import { defineConfig } from 'vite';
import { resolve } from 'path';

export default defineConfig({
  build: {
    rollupOptions: {
      input: {
        main: resolve(__dirname, 'index.html'),
        about: resolve(__dirname, 'about.html'),
        contact: resolve(__dirname, 'contact.html'),
      },
    },
  },
});
```

### Library Mode

> **Documentation**: [Library Mode](https://vite.dev/guide/build#library-mode)

```typescript
// vite.config.ts for building a library
import { defineConfig } from 'vite';
import { resolve } from 'path';

export default defineConfig({
  build: {
    lib: {
      entry: resolve(__dirname, 'src/index.ts'),
      name: 'MyLib',
      fileName: (format) => `my-lib.${format}.js`,
      formats: ['es', 'umd'],
    },
    rollupOptions: {
      // Externalize dependencies
      external: ['react', 'react-dom'],
      output: {
        globals: {
          react: 'React',
          'react-dom': 'ReactDOM',
        },
      },
    },
  },
});
```

## Framework Integration

> **Documentation**: Always check the official framework plugin documentation for the latest features and configuration options.

### React + Vite

> **Plugin Docs**: [@vitejs/plugin-react](https://github.com/vitejs/vite-plugin-react/tree/main/packages/plugin-react)

```bash
npm create vite@latest my-app -- --template react-ts
```

```typescript
// vite.config.ts
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [
    react({
      // Enable Fast Refresh
      fastRefresh: true,
      // Use automatic JSX runtime
      jsxRuntime: 'automatic',
    }),
  ],
});
```

### Vue + Vite

> **Plugin Docs**: [@vitejs/plugin-vue](https://github.com/vitejs/vite-plugin-vue/tree/main/packages/plugin-vue)

```bash
npm create vite@latest my-app -- --template vue-ts
```

```typescript
// vite.config.ts
import { defineConfig } from 'vite';
import vue from '@vitejs/plugin-vue';

export default defineConfig({
  plugins: [
    vue({
      // Vue plugin options
      script: {
        defineModel: true,
        propsDestructure: true,
      },
    }),
  ],
});
```

### Svelte + Vite

> **Plugin Docs**: [@sveltejs/vite-plugin-svelte](https://github.com/sveltejs/vite-plugin-svelte/tree/main/packages/vite-plugin-svelte)

```bash
npm create vite@latest my-app -- --template svelte-ts
```

```typescript
// vite.config.ts
import { defineConfig } from 'vite';
import { svelte } from '@sveltejs/vite-plugin-svelte';

export default defineConfig({
  plugins: [svelte()],
});
```

## Best Practices

> **Note**: These practices cover common scenarios. For advanced use cases and edge cases, consult the [official Vite guides](https://vite.dev/guide/) and [configuration reference](https://vite.dev/config/).

### 1. Use Environment Variables Correctly

```typescript
// ✓ Environment variables prefixed with VITE_
// .env
VITE_API_URL=https://api.example.com

// src/config.ts
const apiUrl = import.meta.env.VITE_API_URL;

// ❌ Don't use dynamic access
const key = 'VITE_API_URL';
const apiUrl = import.meta.env[key]; // Won't work in production!
```

### 2. Optimize Dependencies

```typescript
// vite.config.ts
export default defineConfig({
  optimizeDeps: {
    // Include dependencies that need pre-bundling
    include: ['lodash-es', 'date-fns'],
    // Exclude dependencies from pre-bundling
    exclude: ['@my-local-package'],
  },
});
```

### 3. Code Splitting Strategies

```typescript
// ✓ Split by route
const routes = [
  {
    path: '/dashboard',
    component: lazy(() => import('./pages/Dashboard')),
  },
  {
    path: '/settings',
    component: lazy(() => import('./pages/Settings')),
  },
];

// ✓ Manual chunk splitting
// vite.config.ts
export default defineConfig({
  build: {
    rollupOptions: {
      output: {
        manualChunks: {
          'react-vendor': ['react', 'react-dom', 'react-router-dom'],
          'ui-library': ['@mui/material', '@mui/icons-material'],
        },
      },
    },
  },
});
```

### 4. Asset Optimization

```typescript
// vite.config.ts
export default defineConfig({
  build: {
    // Asset inline threshold (kb)
    assetsInlineLimit: 4096, // 4kb

    // Chunk size warnings
    chunkSizeWarningLimit: 1000,

    rollupOptions: {
      output: {
        // Asset file naming
        assetFileNames: (assetInfo) => {
          const info = assetInfo.name.split('.');
          const ext = info[info.length - 1];
          if (/png|jpe?g|svg|gif|tiff|bmp|ico/i.test(ext)) {
            return `assets/images/[name]-[hash][extname]`;
          }
          return `assets/[name]-[hash][extname]`;
        },
      },
    },
  },
});
```

### 5. TypeScript Configuration

```json
// tsconfig.json
{
  "compilerOptions": {
    "target": "ES2020",
    "useDefineForClassFields": true,
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "skipLibCheck": true,

    /* Bundler mode */
    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "jsx": "react-jsx",

    /* Linting */
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noFallthroughCasesInSwitch": true
  },
  "include": ["src"],
  "references": [{ "path": "./tsconfig.node.json" }]
}
```

### 6. Development Server Proxy

```typescript
// vite.config.ts - proxy API requests
export default defineConfig({
  server: {
    proxy: {
      '/api': {
        target: 'http://localhost:8080',
        changeOrigin: true,
        rewrite: (path) => path.replace(/^\/api/, ''),
      },
      '/ws': {
        target: 'ws://localhost:8080',
        ws: true,
      },
    },
  },
});
```

### 7. Build Modes & Environment Files

```bash
# Environment files
.env                # Loaded in all cases
.env.local          # Loaded in all cases, ignored by git
.env.[mode]         # Only loaded in specified mode
.env.[mode].local   # Only loaded in specified mode, ignored by git
```

```bash
# Build with different modes
vite build --mode staging
vite build --mode production
```

```typescript
// Access current mode
console.log(import.meta.env.MODE); // 'development' | 'production' | 'staging'
console.log(import.meta.env.DEV);  // boolean
console.log(import.meta.env.PROD); // boolean
```

## Anti-Patterns to Avoid

### ❌ Dynamic Environment Variable Access

```typescript
// ❌ Don't use dynamic access
const envKey = 'VITE_API_URL';
const url = import.meta.env[envKey]; // Won't work in production!

// ✓ Use static access
const url = import.meta.env.VITE_API_URL;
```

### ❌ Missing Vite Client Types

```typescript
// ❌ Missing type reference
// Will cause TypeScript errors for import.meta.env

// ✓ Include in vite-env.d.ts
/// <reference types="vite/client" />
```

### ❌ Incorrect Asset References

```typescript
// ❌ Don't use relative paths for public assets
<img src="../public/logo.png" /> // Wrong!

// ✓ Reference public assets with absolute path
<img src="/logo.png" /> // Correct (file in public/)

// ✓ Or import processed assets
import logo from './assets/logo.png';
<img src={logo} /> // Correct (file in src/assets/)
```

### ❌ Not Configuring Base Path for Subdirectory Deployment

```typescript
// ❌ Default base is '/' - breaks subdirectory deploys
// Deployed to: https://example.com/my-app/
// Assets try to load from: https://example.com/assets/... (404!)

// ✓ Configure base for subdirectory
// vite.config.ts
export default defineConfig({
  base: '/my-app/',
});
```

### ❌ Ignoring Browser Compatibility

```typescript
// ❌ Using modern syntax without build target config
// May break in older browsers

// ✓ Configure build targets
// vite.config.ts
export default defineConfig({
  build: {
    target: 'es2015', // or ['chrome87', 'firefox78']
  },
});

// ✓ Or use legacy plugin for old browsers
import legacy from '@vitejs/plugin-legacy';

export default defineConfig({
  plugins: [
    legacy({
      targets: ['defaults', 'not IE 11'],
    }),
  ],
});
```

### ❌ Large Dependencies in Main Bundle

```typescript
// ❌ Importing entire library
import _ from 'lodash'; // Large bundle!

// ✓ Use tree-shakeable imports
import { debounce, throttle } from 'lodash-es';

// ✓ Or dynamic imports for heavy libraries
async function loadChartLibrary() {
  const Chart = await import('chart.js');
  return Chart;
}
```

### ❌ Not Handling Import.meta.glob Correctly

```typescript
// ❌ Dynamic pattern won't work
const pattern = './*.ts';
const modules = import.meta.glob(pattern); // Error!

// ✓ Use static glob pattern
const modules = import.meta.glob('./*.ts');

// ✓ Eager import if needed immediately
const modules = import.meta.glob('./*.ts', { eager: true });
```

### ❌ Incorrect CSS Module Usage

```typescript
// ❌ Wrong CSS module import
import './Button.module.css'; // Imported but not used

// ✓ Import CSS module as object
import styles from './Button.module.css';
<button className={styles.primary}>Click</button>

// ✓ Regular CSS (not module)
import './global.css'; // Side effect import
```

## Performance Optimization

> **Documentation**: [Performance Guide](https://vite.dev/guide/performance) | [Dependency Pre-Bundling](https://vite.dev/guide/dep-pre-bundling)

### Dependency Pre-Bundling

```typescript
// vite.config.ts
export default defineConfig({
  optimizeDeps: {
    // Force pre-bundle specific dependencies
    include: [
      'react',
      'react-dom',
      'react-router-dom',
    ],
    // Exclude from pre-bundling
    exclude: ['@vite/client'],
    // Force optimization on server start
    force: true,
  },
});
```

### Build Analysis

```typescript
// vite.config.ts
import { visualizer } from 'rollup-plugin-visualizer';

export default defineConfig({
  plugins: [
    visualizer({
      open: true,
      gzipSize: true,
      brotliSize: true,
    }),
  ],
});
```

### Compression

```typescript
// vite.config.ts
import viteCompression from 'vite-plugin-compression';

export default defineConfig({
  plugins: [
    viteCompression({
      algorithm: 'gzip',
      ext: '.gz',
    }),
    viteCompression({
      algorithm: 'brotliCompress',
      ext: '.br',
    }),
  ],
});
```

## External Resources

**Always refer to the official documentation for the most accurate and up-to-date information.**

### Official Documentation

- [Vite Documentation](https://vite.dev/) - Main documentation site
- [Getting Started Guide](https://vite.dev/guide/) - Quick start and core concepts
- [CLI Reference](https://vite.dev/guide/cli) - Command-line interface options
- [Configuration Reference](https://vite.dev/config/) - Complete config options
- [Migration Guide](https://vite.dev/guide/migration) - Upgrading between versions

### Core Features

- [Environment Variables and Modes](https://vite.dev/guide/env-and-mode) - Managing environment configuration
- [Static Asset Handling](https://vite.dev/guide/assets) - Images, fonts, and other assets
- [Building for Production](https://vite.dev/guide/build) - Production build configuration
- [Server Options](https://vite.dev/config/server-options) - Dev server configuration
- [Shared Options](https://vite.dev/config/shared-options) - Common configuration

### API References

- [HMR API](https://vite.dev/guide/api-hmr) - Hot Module Replacement API
- [Plugin API](https://vite.dev/guide/api-plugin) - Creating custom plugins
- [JavaScript API](https://vite.dev/guide/api-javascript) - Programmatic usage
- [SSR API](https://vite.dev/guide/ssr) - Server-Side Rendering

### Advanced Topics

- [Dependency Pre-Bundling](https://vite.dev/guide/dep-pre-bundling) - Optimization strategy
- [Backend Integration](https://vite.dev/guide/backend-integration) - Using with backend servers
- [Comparisons](https://vite.dev/guide/comparisons) - How Vite differs from other tools
- [Troubleshooting](https://vite.dev/guide/troubleshooting) - Common issues and solutions
- [Performance](https://vite.dev/guide/performance) - Optimization techniques

### Framework Plugins

- [@vitejs/plugin-react](https://github.com/vitejs/vite-plugin-react/tree/main/packages/plugin-react) - React support with Fast Refresh
- [@vitejs/plugin-vue](https://github.com/vitejs/vite-plugin-vue/tree/main/packages/plugin-vue) - Vue 3 support
- [@sveltejs/vite-plugin-svelte](https://github.com/sveltejs/vite-plugin-svelte) - Svelte support
- [@vitejs/plugin-legacy](https://github.com/vitejs/vite/tree/main/packages/plugin-legacy) - Legacy browser support

### Community Resources

- [Vite Plugin Directory](https://vite.dev/plugins/) - Official plugin list
- [Awesome Vite](https://github.com/vitejs/awesome-vite) - Curated community resources
- [Vite Examples](https://github.com/vitejs/vite/tree/main/playground) - Official example projects
- [Rollup Plugins](https://github.com/rollup/awesome) - Compatible Rollup plugins

### Getting Help

When encountering issues:

1. **Check the documentation** - Most common questions are answered in the guides
2. **Search existing issues** - [GitHub Issues](https://github.com/vitejs/vite/issues)
3. **Ask the community** - [Discord](https://chat.vite.dev/) or [GitHub Discussions](https://github.com/vitejs/vite/discussions)
4. **Review changelog** - [Releases](https://github.com/vitejs/vite/releases) for breaking changes

**Remember**: The examples in this skill are starting points. Always consult the official documentation for implementation details, edge cases, and the latest best practices.
