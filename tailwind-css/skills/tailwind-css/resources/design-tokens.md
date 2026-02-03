# Design Tokens & Theme Configuration

Complete guide to design tokens, CSS variables, and theme configuration in Tailwind CSS.

## Design Token System

### CSS Variable Architecture

Two-tier CSS variable system:
1. **CSS Variables** (in `globals.css`) - Define actual color values
2. **Tailwind Config** (in `tailwind.config.ts`) - Maps variables to utility classes

This architecture enables automatic dark mode switching and consistent theming.

### Color Token Structure

```css
/* globals.css */
:root {
  /* Brand colors point to MD3 colors */
  --primary: var(--md3-primary);
  --primary-hover: var(--md3-primary-hover);
  --primary-active: var(--md3-primary-active);

  /* MD3 Brand Colors - Light Mode */
  --md3-primary: #E67E22;           /* Ember Orange */
  --md3-primary-hover: #D35400;
  --md3-primary-active: #A04000;
  --md3-on-primary: #1C1B1F;        /* Text on primary */

  --md3-secondary: #C0392B;         /* Deep Rust */
  --md3-secondary-hover: #A93226;
  --md3-secondary-active: #922B21;
  --md3-on-secondary: #FFFFFF;

  --md3-accent: #1ABC9C;            /* Deep Teal */
  --md3-accent-hover: #16A085;
  --md3-accent-active: #117864;
  --md3-on-accent: #FFFFFF;
}

.dark {
  /* Dark mode values automatically override */
  --md3-primary: #FF8C42;
  --md3-primary-hover: #FF9D5C;
  /* ... */
}
```

### Tailwind Config Mapping

```typescript
// tailwind.config.ts
import type { Config } from "tailwindcss";

const config: Config = {
  theme: {
    extend: {
      colors: {
        'md3-primary': {
          DEFAULT: 'var(--md3-primary)',
          hover: 'var(--md3-primary-hover)',
          active: 'var(--md3-primary-active)',
        },
        'md3-on-primary': 'var(--md3-on-primary)',
        // ...
      },
    },
  },
};

export default config;
```

## Design Token Categories

### 1. Brand Colors

Primary interaction colors used throughout the application.

**Usage:**
```typescript
import { ButtonHTMLAttributes } from "react";

interface PrimaryButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  children: React.ReactNode;
}

export function PrimaryButton({ children, ...props }: PrimaryButtonProps): JSX.Element {
  return (
    <button
      className="bg-md3-primary hover:bg-md3-primary-hover active:bg-md3-primary-active"
      {...props}
    >
      {children}
    </button>
  );
}

<button className="bg-md3-secondary hover:bg-md3-secondary-hover">
  Secondary Action
</button>

<button className="bg-md3-accent hover:bg-md3-accent-hover">
  Accent Action
</button>
```

**On-Colors (Text on Colored Backgrounds):**
```tsx
<div className="bg-md3-primary text-md3-on-primary p-4">
  Text automatically has correct contrast
</div>
```

### 2. Phase Colors

Semantic colors representing different project phases.

```typescript
// CSS Variables
--md3-spark: #E67E22;    // Initial ideas (ember orange)
--md3-ember: #C0392B;    // Active development (deep rust)
--md3-forged: #1ABC9C;   // Completed works (deep teal)
```

**Usage:**
```tsx
// Phase badges
<span className="bg-md3-spark text-white px-3 py-1 rounded-lg">
  spark
</span>

<span className="bg-md3-ember text-white px-3 py-1 rounded-lg">
  ember
</span>

<span className="bg-md3-forged text-white px-3 py-1 rounded-lg">
  forged
</span>
```

### 3. Semantic Colors

Purpose-specific colors for resources and materials.

```typescript
// Fuel - Resources/attachments
--md3-fuel: #F59E0B;
--md3-on-fuel: #78350F;

// Kindling - Supporting materials
--md3-kindling: #FFE6D5;
--md3-on-kindling: #78281F;
```

**Usage:**
```tsx
<div className="bg-md3-fuel text-md3-on-fuel px-4 py-2 rounded-lg">
  Fuel: 3 attachments
</div>

<div className="bg-md3-kindling text-md3-on-kindling px-4 py-2 rounded-lg">
  Kindling resources
</div>
```

### 4. Surface Colors

Background colors for cards, containers, and elevated surfaces.

```typescript
--background: #F8FAFC;              // Main background
--background-secondary: #FFFFFF;    // Cards/panels
--md3-surface-container: #FFFFFF;   // MD3 container
--md3-surface-variant: #E7E0EC;     // Variant surfaces
```

**Usage:**
```tsx
<div className="bg-background min-h-screen">
  <div className="bg-md3-surface-container rounded-md3-card p-6">
    Card content
  </div>
</div>
```

### 5. Text Colors

Hierarchy of text colors for different content levels.

```typescript
--foreground: #0F172A;           // Primary text
--foreground-secondary: #334155;  // Secondary text
--foreground-muted: #64748B;      // Muted/helper text
```

**Usage:**
```tsx
<h1 className="text-foreground text-2xl font-bold">Title</h1>
<p className="text-foreground-secondary">Description</p>
<span className="text-foreground-muted text-sm">Helper text</span>
```

### 6. Elevation System

Material Design 3 elevation levels using shadows.

```typescript
// CSS Variables
--md3-elevation-1: 0 1px 2px 0 rgba(0, 0, 0, 0.05);
--md3-elevation-2: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
--md3-elevation-3: 0 10px 15px -3px rgba(0, 0, 0, 0.1);
--md3-elevation-4: 0 20px 25px -5px rgba(0, 0, 0, 0.1);
--md3-elevation-5: 0 25px 50px -12px rgba(0, 0, 0, 0.25);

// Tailwind Config
boxShadow: {
  'md3-1': 'var(--md3-elevation-1)',
  'md3-2': 'var(--md3-elevation-2)',
  'md3-3': 'var(--md3-elevation-3)',
  'md3-4': 'var(--md3-elevation-4)',
  'md3-5': 'var(--md3-elevation-5)',
}
```

**Usage:**
```tsx
// Resting state
<div className="shadow-md3-1">Card</div>

// Hover state
<div className="shadow-md3-1 hover:shadow-md3-2 transition-shadow">
  Interactive card
</div>

// Elevated modal
<div className="shadow-md3-5">Modal</div>
```

### 7. Border Radius System

Consistent corner rounding following Material Design 3.

```typescript
borderRadius: {
  DEFAULT: '0.5rem',        // 8px
  'md3-card': '12px',       // Cards
  'md3-button': '20px',     // Buttons
  'md3-chip': '8px',        // Badges/chips
}
```

**Usage:**
```tsx
<div className="rounded-md3-card">Card</div>
<button className="rounded-md3-button">Button</button>
<span className="rounded-md3-chip">Badge</span>
```

## Extended Palette

### Primary Palette (Ember Orange)

Full tonal palette for nuanced color usage.

```typescript
--md3-primary-50: #FFF5ED;   // Lightest
--md3-primary-100: #FFE6D5;
--md3-primary-200: #FFCBA8;
--md3-primary-300: #FFA06B;
--md3-primary-400: #FF7A3D;
--md3-primary-500: #E67E22;  // Base
--md3-primary-600: #D35400;
--md3-primary-700: #A04000;
--md3-primary-800: #702D00;  // Darkest
```

**Usage:**
```tsx
// Light backgrounds
<div className="bg-md3-primary-50 text-md3-primary-700">
  Light primary surface
</div>

// Borders and accents
<div className="border-md3-primary-200 hover:border-md3-primary-400">
  Subtle border
</div>
```

### Secondary Palette (Deep Rust)

```typescript
--md3-secondary-50: #FADBD8;
--md3-secondary-100: #F5B7B1;
--md3-secondary-200: #EC7063;
--md3-secondary-300: #E74C3C;
--md3-secondary-400: #CB4335;
--md3-secondary-500: #C0392B;  // Base
--md3-secondary-600: #A93226;
--md3-secondary-700: #922B21;
--md3-secondary-800: #78281F;
```

### Accent Palette (Deep Teal)

```typescript
--md3-accent-50: #F0FAFA;
--md3-accent-100: #D5F4F5;
--md3-accent-200: #A8E7E9;
--md3-accent-300: #7CD9DC;
--md3-accent-400: #4FCBD0;
--md3-accent-500: #1ABC9C;  // Base
--md3-accent-600: #16A085;
--md3-accent-700: #117864;
```

### Neutral Palette

Grayscale for borders, disabled states, and subtle backgrounds.

```typescript
--md3-neutral-50: #F8F9FA;
--md3-neutral-100: #F1F3F4;
--md3-neutral-200: #E8EAED;
--md3-neutral-300: #DADCE0;
--md3-neutral-400: #BDC1C6;
--md3-neutral-500: #9AA0A6;
--md3-neutral-600: #80868B;
--md3-neutral-700: #5F6368;
--md3-neutral-800: #3C4043;
--md3-neutral-900: #202124;
```

**Usage:**
```tsx
// Subtle borders
<div className="border border-md3-neutral-200 dark:border-md3-neutral-700">
  Content
</div>

// Disabled states
<button disabled className="bg-md3-neutral-300 text-md3-neutral-600 cursor-not-allowed">
  Disabled
</button>
```

## Adding Custom Design Tokens

### 1. Define CSS Variables

Add to `src/app/globals.css`:

```css
:root {
  --custom-token: #value;
}

.dark {
  --custom-token: #dark-value;
}
```

### 2. Map to Tailwind Config

Add to `tailwind.config.ts`:

```typescript
export default {
  theme: {
    extend: {
      colors: {
        'custom-token': 'var(--custom-token)',
      },
    },
  },
};
```

### 3. Use in Components

```tsx
<div className="bg-custom-token">Content</div>
```

## Best Practices

### DO

✅ Always use design tokens (never arbitrary values)
✅ Use on-color variables for text on colored backgrounds
✅ Follow the extended palette for subtle variations
✅ Use elevation system for depth
✅ Keep token names semantic (what they represent, not what they look like)

### DON'T

❌ Never use arbitrary color values: `bg-[#E67E22]`
❌ Never hardcode colors: `text-orange-500`
❌ Never use raw hex values in components
❌ Never skip on-color variables for contrast

## Testing Design Tokens

### Verify Token Usage

```bash
# Search for arbitrary values (should return nothing)
grep -r "bg-\[#" src/

# Search for hardcoded Tailwind colors (should be minimal)
grep -r "bg-orange-" src/
```

### Test Dark Mode

1. Toggle dark mode in browser
2. Verify all colors switch correctly
3. Check contrast ratios (WCAG AA: 4.5:1)
4. Test interactive states (hover, active, focus)

## Reference

- [Material Design 3 Color System](https://m3.material.io/styles/color/system/overview)
- [Tailwind Theme Configuration](https://tailwindcss.com/docs/theme)
