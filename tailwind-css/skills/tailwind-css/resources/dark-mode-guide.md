# Dark Mode Implementation Guide

Complete guide to implementing and maintaining dark mode using Tailwind CSS.

## Dark Mode Strategy

Uses the **class-based** dark mode strategy with CSS variables for automatic color switching.

```typescript
// tailwind.config.ts
import type { Config } from "tailwindcss";

const config: Config = {
  darkMode: 'class', // Dark mode enabled via .dark class
  // ...
};

export default config;
```

## Architecture

### Two-Tier System

1. **CSS Variables** switch values when `.dark` class is present
2. **Tailwind utilities** reference CSS variables automatically

```css
/* globals.css */
:root {
  --md3-primary: #E67E22;           /* Light mode */
  --background: #F8FAFC;
  --foreground: #0F172A;
}

.dark {
  --md3-primary: #FF8C42;           /* Dark mode */
  --background: #0F172A;
  --foreground: #F8FAFC;
}
```

### Benefits

- Single source of truth for colors
- Automatic switching without `dark:` prefix for most utilities
- Consistent across entire application
- No duplicate color definitions

## Color Strategy

### Automatic Colors (Preferred)

Colors automatically adapt to dark mode through CSS variables.

```tsx
// ✅ BEST: Automatic dark mode
<div className="bg-md3-primary text-md3-on-primary">
  Color automatically switches
</div>

<div className="bg-md3-surface-container border border-md3-outline">
  Surface and border both adapt
</div>

<p className="text-foreground">
  Text color adapts automatically
</p>
```

### Explicit dark: Variant

Use only when CSS variables are insufficient or you need different styling.

```tsx
// Custom dark mode adjustments
<div className="bg-white dark:bg-md3-surface-container">
  Explicit override
</div>

// Different borders in dark mode
<div className="border-gray-200 dark:border-white/10">
  Light gray border → semi-transparent white
</div>

// Glass-morphism
<div className="bg-white/5 dark:bg-white/8 backdrop-blur-glass">
  Different opacity in dark mode
</div>
```

## Dark Mode Color Palette

### Light Mode (`:root`)

```css
:root {
  /* Backgrounds */
  --background: #F8FAFC;              /* Main background */
  --background-secondary: #FFFFFF;    /* Cards/panels */

  /* Text */
  --foreground: #0F172A;              /* Primary text */
  --foreground-secondary: #334155;    /* Secondary text */
  --foreground-muted: #64748B;        /* Muted text */

  /* Brand */
  --md3-primary: #E67E22;             /* Ember orange */
  --md3-secondary: #C0392B;           /* Deep rust */
  --md3-accent: #1ABC9C;              /* Deep teal */

  /* Surfaces */
  --md3-surface-container: #FFFFFF;
  --md3-outline: #79747E;
}
```

### Dark Mode (`.dark`)

```css
.dark {
  /* Backgrounds */
  --background: #0F172A;              /* Dark main */
  --background-secondary: #1E293B;    /* Elevated surfaces */

  /* Text */
  --foreground: #F8FAFC;              /* Light text */
  --foreground-secondary: #CBD5E1;    /* Secondary text */
  --foreground-muted: #94A3B8;        /* Muted text */

  /* Brand (adjusted for dark backgrounds) */
  --md3-primary: #FF8C42;             /* Brighter orange */
  --md3-secondary: #E74C3C;           /* Brighter rust */
  --md3-accent: #1DD1A1;              /* Brighter teal */

  /* Surfaces */
  --md3-surface-container: #1E293B;
  --md3-outline: #9CA3AF;
}
```

## Implementation Patterns

### Cards

```tsx
// Automatic adaptation
<div className="
  bg-background-secondary
  border border-md3-primary/10 dark:border-white/10
  rounded-md3-card
  shadow-md3-1
  p-6
">
  Card content
</div>
```

### Buttons

```tsx
// Primary button (automatic)
<button className="
  bg-md3-primary hover:bg-md3-primary-hover
  text-md3-on-primary
  px-6 py-3 rounded-md3-button
">
  Primary
</button>

// Ghost button (explicit dark styles)
<button className="
  bg-white dark:bg-md3-surface-container
  border border-foreground/20 hover:border-foreground/30
  text-foreground
">
  Ghost
</button>
```

### Forms

```tsx
<input className="
  bg-background-secondary
  border border-md3-outline
  text-foreground
  placeholder:text-foreground-muted
  focus:ring-2 focus:ring-md3-primary
  rounded-lg px-4 py-2
" />
```

### Text Hierarchy

```tsx
<div>
  <h1 className="text-foreground text-2xl font-bold">
    Main heading
  </h1>
  <p className="text-foreground-secondary">
    Secondary text
  </p>
  <span className="text-foreground-muted text-sm">
    Helper text
  </span>
</div>
```

## Interactive States

### Hover Effects

```tsx
// Background hover
<div className="
  hover:bg-md3-primary/5 dark:hover:bg-white/8
  transition-colors
">
  Subtle hover
</div>

// Border hover
<div className="
  border border-md3-primary/10 dark:border-white/10
  hover:border-md3-primary/20 dark:hover:border-white/20
">
  Border intensifies on hover
</div>
```

### Focus States

```tsx
// Input focus
<input className="
  focus:ring-2 focus:ring-md3-primary
  focus:border-md3-primary
  dark:focus:ring-md3-primary
" />

// Button focus
<button className="
  focus-visible:ring-2 focus-visible:ring-md3-accent
  focus-visible:ring-offset-2
  dark:focus-visible:ring-offset-background
">
  Button
</button>
```

## Opacity and Transparency

### Semi-transparent Overlays

```tsx
// Backdrop
<div className="
  bg-black/50 dark:bg-black/70
  backdrop-blur-sm
">
  Modal backdrop
</div>

// Glass-morphism card
<div className="
  bg-white/5 dark:bg-white/8
  backdrop-blur-glass
  border border-white/10 dark:border-white/20
">
  Glass panel
</div>
```

### Color with Opacity

```tsx
// Primary with opacity
<div className="bg-md3-primary/10 dark:bg-md3-primary/20">
  Light tint
</div>

// Text with opacity
<p className="text-foreground/70">
  Semi-transparent text
</p>
```

## Shadows and Elevation

Shadows adapt automatically through CSS variables.

```css
/* globals.css */
:root {
  --md3-elevation-1: 0 1px 2px 0 rgba(0, 0, 0, 0.05);
  --md3-elevation-2: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
}

.dark {
  --md3-elevation-1: 0 1px 2px 0 rgba(0, 0, 0, 0.3);
  --md3-elevation-2: 0 4px 6px -1px rgba(0, 0, 0, 0.4);
}
```

```tsx
// Usage (automatic adaptation)
<div className="shadow-md3-1 hover:shadow-md3-2">
  Elevated card
</div>
```

## Images and Media

### Images

```tsx
// Images with dark mode overlay
<div className="relative">
  <Image src={src} alt={alt} />
  <div className="absolute inset-0 bg-black/0 dark:bg-black/20" />
</div>

// Logos with variants
{theme === 'dark' ? (
  <Image src="/logo-light.svg" alt="Logo" />
) : (
  <Image src="/logo-dark.svg" alt="Logo" />
)}
```

### Icons

```tsx
// Icon color adapts
<Icon className="text-foreground" />

// Icon with custom dark mode color
<Icon className="text-md3-primary dark:text-md3-accent" />
```

## Implementing Dark Mode Toggle

### Toggle Component

```typescript
'use client';

import { useTheme } from 'next-themes';

export function DarkModeToggle(): JSX.Element {
  const { theme, setTheme } = useTheme();

  return (
    <button
      onClick={() => setTheme(theme === 'dark' ? 'light' : 'dark')}
      className="
        p-2 rounded-lg
        bg-md3-surface-container
        hover:bg-md3-primary/10
        transition-colors
      "
    >
      {theme === 'dark' ? <SunIcon /> : <MoonIcon />}
    </button>
  );
}
```

### Provider Setup

```typescript
// app/layout.tsx
import { ReactNode } from "react";
import { ThemeProvider } from 'next-themes';

interface RootLayoutProps {
  children: ReactNode;
}

export default function RootLayout({ children }: RootLayoutProps): JSX.Element {
  return (
    <html suppressHydrationWarning>
      <body>
        <ThemeProvider attribute="class" defaultTheme="system">
          {children}
        </ThemeProvider>
      </body>
    </html>
  );
}
```

## Testing Dark Mode

### Manual Testing Checklist

- [ ] Toggle between light and dark modes
- [ ] Verify all text is readable (sufficient contrast)
- [ ] Check hover/focus states in both modes
- [ ] Test interactive elements (buttons, forms)
- [ ] Verify images and media display correctly
- [ ] Check shadows and elevation
- [ ] Test on different screen brightness levels
- [ ] Verify modal/dialog backdrops

### Contrast Testing

Use browser DevTools or online tools to verify WCAG compliance:

- **AA (minimum)**: 4.5:1 for normal text, 3:1 for large text
- **AAA (enhanced)**: 7:1 for normal text, 4.5:1 for large text

```tsx
// Good contrast examples
<div className="bg-md3-primary text-white">        // High contrast
<div className="bg-md3-surface-container text-foreground">  // High contrast
<div className="text-foreground-muted">            // Sufficient for secondary text
```

### Browser DevTools

1. Inspect element
2. Check computed CSS variables
3. Verify `--md3-*` variables switch when `.dark` class toggles
4. Use Accessibility tools to check contrast ratios

## Common Patterns

### Section Dividers

```tsx
<hr className="border-md3-outline/20 dark:border-white/10" />
```

### Code Blocks

```tsx
<pre className="
  bg-md3-neutral-900 dark:bg-md3-neutral-950
  text-md3-neutral-100
  p-4 rounded-lg
  overflow-x-auto
">
  <code>{code}</code>
</pre>
```

### Tooltips

```tsx
<div className="
  bg-md3-neutral-900 dark:bg-md3-neutral-800
  text-white
  px-3 py-2 rounded-lg
  shadow-md3-3
  text-sm
">
  Tooltip content
</div>
```

## Troubleshooting

### Issue: Dark mode not activating

**Solution**: Verify `.dark` class is on `<html>` element

```tsx
// Check in browser console
document.documentElement.classList.contains('dark')
```

### Issue: Colors not switching

**Solution**: Check CSS variables are defined for both modes

```css
/* Ensure both :root and .dark have the variable */
:root {
  --md3-primary: #E67E22;
}

.dark {
  --md3-primary: #FF8C42;  /* Must be defined */
}
```

### Issue: Flash of unstyled content (FOUC)

**Solution**: Use `next-themes` with proper `suppressHydrationWarning`

```tsx
<html suppressHydrationWarning>
```

### Issue: Poor contrast in dark mode

**Solution**: Test and adjust color values

```css
.dark {
  /* Increase brightness for dark backgrounds */
  --md3-primary: #FF8C42;  /* Brighter than light mode */
}
```

## Best Practices

### DO

✅ Use CSS variables for automatic switching
✅ Test both modes for every component
✅ Verify contrast ratios (WCAG AA minimum)
✅ Use semantic color names
✅ Provide system preference detection
✅ Add `suppressHydrationWarning` to `<html>`

### DON'T

❌ Hardcode colors for specific modes
❌ Use `dark:` prefix when CSS variables suffice
❌ Forget to test interactive states
❌ Use insufficient contrast
❌ Over-complicate with too many explicit overrides

## Reference

- [Tailwind Dark Mode](https://tailwindcss.com/docs/dark-mode)
- [next-themes Documentation](https://github.com/pacocoursey/next-themes)
- [WCAG Contrast Guidelines](https://www.w3.org/WAI/WCAG21/Understanding/contrast-minimum.html)
