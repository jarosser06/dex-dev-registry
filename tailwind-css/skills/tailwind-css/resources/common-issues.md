# Common Issues & Troubleshooting

Comprehensive troubleshooting guide for Tailwind CSS issues.

## Classes Not Applying

### Issue: Tailwind classes don't have any effect

**Symptoms:**
- Classes appear in DevTools but no styles apply
- Some classes work, others don't

**Causes & Solutions:**

#### 1. Dynamic Class Construction

```tsx
// ❌ PROBLEM: Tailwind can't detect these classes
<div className={`text-${color}-500`} />
<div className={`bg-md3-${variant}`} />

// ✅ SOLUTION: Use complete class strings
const colorClasses: Record<string, string> = {
  primary: "text-md3-primary",
  secondary: "text-md3-secondary",
};
<div className={colorClasses[color]} />
```

**Why it happens**: Tailwind scans source files for complete class names at build time using regex. Dynamic construction breaks this detection.

#### 2. Content Paths Missing

```typescript
// tailwind.config.ts
export default {
  content: [
    "./src/pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/components/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/app/**/*.{js,ts,jsx,tsx,mdx}",
    // Add if using other directories
    "./src/features/**/*.{js,ts,jsx,tsx}",
  ],
};
```

**Fix**: Ensure all directories with Tailwind classes are included in `content` array.

#### 3. Build Cache Issues

```bash
# Clear Next.js cache
rm -rf .next

# Rebuild
npm run dev
```

### Issue: Classes work in some files but not others

**Cause**: File not in content detection paths

**Solution**: Add the directory pattern to `tailwind.config.ts` content array

## Specificity Conflicts

### Issue: Custom CSS overrides Tailwind utilities

**Problem:**
```css
/* globals.css */
button {
  background: blue; /* Overrides Tailwind bg-* classes */
}
```

**Solution 1**: Use `@layer` directive

```css
@layer base {
  button {
    background: blue;
  }
}
```

**Solution 2**: Increase Tailwind specificity with `!` modifier

```tsx
<button className="!bg-md3-primary">
  Forces this to override custom CSS
</button>
```

### Issue: Conflicting Tailwind classes

```tsx
// ❌ PROBLEM: Which padding wins?
<div className="p-4 p-6">
```

**Without cn()**: Last class in CSS output wins (unpredictable)

**With cn()**: Automatically resolves conflicts

```tsx
// ✅ SOLUTION: Use cn() utility
import { cn } from "@/lib/utils";

<div className={cn("p-4", someCondition && "p-6")}>
  // p-6 properly overrides p-4 when condition is true
</div>
```

## Dark Mode Issues

### Issue: Dark mode not activating

**Check 1**: Verify `.dark` class on `<html>`

```tsx
// Browser console
document.documentElement.classList.contains('dark')
// Should return true in dark mode
```

**Check 2**: Verify `darkMode: 'class'` in config

```typescript
// tailwind.config.ts
export default {
  darkMode: 'class', // Not 'media'
  // ...
};
```

**Check 3**: Check `next-themes` setup

```tsx
// app/layout.tsx
import { ThemeProvider } from 'next-themes';

export default function RootLayout({ children }: Props) {
  return (
    <html suppressHydrationWarning>
      <body>
        <ThemeProvider attribute="class">
          {children}
        </ThemeProvider>
      </body>
    </html>
  );
}
```

### Issue: Colors not switching in dark mode

**Cause**: CSS variables not defined for `.dark`

```css
/* ❌ PROBLEM: Only defined in :root */
:root {
  --md3-primary: #E67E22;
}

/* ✅ SOLUTION: Also define in .dark */
.dark {
  --md3-primary: #FF8C42; /* Brighter for dark backgrounds */
}
```

### Issue: Flash of unstyled content (FOUC)

**Solution**: Add `suppressHydrationWarning` to `<html>`

```tsx
<html suppressHydrationWarning>
```

### Issue: Poor contrast in dark mode

**Problem**: Using same color values for light and dark

**Solution**: Adjust colors for dark backgrounds

```css
:root {
  --md3-primary: #E67E22;  /* Standard orange */
}

.dark {
  --md3-primary: #FF8C42;  /* Brighter for visibility */
}
```

**Test**: Use browser DevTools Accessibility panel to check contrast ratios

## Responsive Design Issues

### Issue: Responsive classes not working

**Check**: Mobile-first order

```tsx
// ❌ WRONG: Overrides don't work as expected
<div className="text-xl md:text-base">

// ✅ CORRECT: Mobile-first (base → larger)
<div className="text-base md:text-lg lg:text-xl">
```

### Issue: Layout breaks at certain screen sizes

**Debug steps**:

1. Test at exact breakpoints: 640px, 768px, 1024px
2. Check for hardcoded widths conflicting with responsive utilities
3. Verify flex/grid children have proper sizing

```tsx
// Common issue: Child with fixed width in flex
<div className="flex">
  <div className="w-64">Fixed width breaks responsive</div>
  <div className="flex-1">Flexible</div>
</div>

// Solution: Make responsive
<div className="flex">
  <div className="w-full md:w-64">Responsive width</div>
  <div className="flex-1">Flexible</div>
</div>
```

## Build/Production Issues

### Issue: Classes work in dev but not production

**Cause**: Dynamic class names not detected

**Debug**:
```bash
# Search for dynamic construction
grep -r "className={\`" src/
grep -r 'className={`' src/
```

**Fix**: Convert to complete class strings via Record types

### Issue: CSS file size too large

**Check**: Content paths are too broad

```typescript
// ❌ TOO BROAD: Scans node_modules
content: [
  "./**/*.{js,ts,jsx,tsx}",
],

// ✅ SPECIFIC: Only app code
content: [
  "./src/**/*.{js,ts,jsx,tsx,mdx}",
],
```

### Issue: Missing classes in production bundle

**Cause**: Classes not in source files (possibly generated)

**Solution**: Use safelist for required dynamic classes

```typescript
// tailwind.config.ts
export default {
  safelist: [
    'bg-md3-spark',
    'bg-md3-ember',
    'bg-md3-forged',
  ],
};
```

## Performance Issues

### Issue: Slow dev server hot reload

**Causes**:
1. Too many files in content detection
2. Complex glob patterns

**Solution**:
```typescript
// Optimize content paths
export default {
  content: [
    "./src/app/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/components/**/*.{js,ts,jsx,tsx}", // More specific
  ],
};
```

### Issue: cn() performance problems

**Rare, but if noticed**:

```tsx
// Memoize for frequently re-rendering components
const className = useMemo(
  () => cn(
    "base-styles",
    variantStyles[variant],
    sizeStyles[size],
    propClassName
  ),
  [variant, size, propClassName]
);
```

## TypeScript Issues

### Issue: Type errors with cn()

```tsx
// ❌ ERROR: Type '{ className: string; } & Props' is not assignable
<Component className={cn("styles", className)} {...props} />
```

**Solution**: Extract className from props

```tsx
const { className, ...rest } = props;
<Component className={cn("styles", className)} {...rest} />
```

### Issue: Tailwind IntelliSense not working

**Check VSCode settings**:

```json
// .vscode/settings.json
{
  "tailwindCSS.experimental.classRegex": [
    ["cn\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]"]
  ]
}
```

## Design Token Issues

### Issue: Arbitrary value instead of token

**Problem**:
```tsx
<div className="bg-[#E67E22]">
```

**Find all instances**:
```bash
grep -r "bg-\[#" src/
grep -r "text-\[#" src/
```

**Fix**: Use design tokens

```tsx
<div className="bg-md3-primary">
```

### Issue: CSS variable not resolving

**Debug**:
```tsx
// Browser console
getComputedStyle(document.documentElement).getPropertyValue('--md3-primary')
// Should return a color value
```

**Verify definition**:
```css
/* src/app/globals.css */
:root {
  --md3-primary: #E67E22; /* Must be defined */
}
```

## Accessibility Issues

### Issue: Focus states not visible

**Problem**:
```tsx
<button className="outline-none">
  // Removes default focus indicator
</button>
```

**Solution**: Always replace removed focus

```tsx
<button className="focus:outline-none focus:ring-2 focus:ring-md3-primary">
  Accessible focus
</button>
```

### Issue: Poor color contrast

**Test**: Use browser DevTools Accessibility panel

**Common fixes**:

```tsx
// ❌ POOR CONTRAST
<div className="bg-md3-primary-100 text-md3-primary-300">

// ✅ GOOD CONTRAST
<div className="bg-md3-primary text-md3-on-primary">
```

**Minimum ratios** (WCAG AA):
- Normal text: 4.5:1
- Large text (18px+): 3:1

## Debugging Tools

### Browser DevTools

**Check computed styles**:
1. Inspect element
2. Computed tab
3. Verify Tailwind classes applied

**Check CSS variables**:
```javascript
// Console
getComputedStyle(document.documentElement).getPropertyValue('--md3-primary')
```

### VS Code Extensions

**Tailwind CSS IntelliSense**:
- Autocomplete
- Hover preview
- Linting

**Headwind** (optional):
- Auto-sort Tailwind classes

### Command Line Debug

**Find dynamic classes**:
```bash
# Search for template literals in className
grep -r 'className={`' src/

# Search for string concatenation
grep -r 'className={".*\+' src/
```

**Check for arbitrary values**:
```bash
grep -r '\[#[0-9A-Fa-f]' src/
```

## Quick Fixes Reference

| Issue | Quick Fix |
|-------|-----------|
| Classes not applying | Check for dynamic construction, verify content paths |
| Dark mode not working | Add `.dark` class to `<html>`, check CSS variables |
| Specificity conflicts | Use cn() utility, add `!` modifier if needed |
| Responsive not working | Verify mobile-first order (sm → md → lg) |
| FOUC | Add `suppressHydrationWarning` to `<html>` |
| Poor contrast | Use on-color variables, test with DevTools |
| Missing focus | Replace `outline-none` with `focus:ring-2` |
| Slow hot reload | Optimize content paths in config |

## Getting Help

1. **Check this guide** for common issues
2. **Browser DevTools** - Inspect computed styles
3. **Tailwind Docs** - [https://tailwindcss.com/docs](https://tailwindcss.com/docs)

## Reference

- [Tailwind CSS Troubleshooting](https://tailwindcss.com/docs/installation#troubleshooting)
- [Content Configuration](https://tailwindcss.com/docs/content-configuration)
- [VS Code Setup](https://tailwindcss.com/docs/editor-setup)
