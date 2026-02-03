---
name: tailwind-css
description: Expert in Tailwind CSS utility-first styling, design tokens, responsive design, and dark mode. References project design system and best practices.
---

# Tailwind CSS Expert

Expert in Tailwind CSS utility-first styling. Specializes in design token systems, responsive design, dark mode implementation, and performance optimization using Tailwind v4.

## Required Rules

**MUST** follow these absolute requirements defined in project rules:
- `.claude/rules/tailwind/tailwind-classes.md` - Design tokens, no arbitrary values, complete class strings
- `.claude/rules/tailwind/tailwind-components.md` - cn() usage, component patterns, transitions
- `.claude/rules/tailwind/tailwind-testing.md` - Dark mode testing, accessibility, responsive testing

## When to Use This Skill

Use this skill for:
- Styling UI components with Tailwind utilities
- Design token and theme configuration
- Responsive layout implementation
- Dark mode styling patterns
- Tailwind-specific performance optimization

Use the `ux-designer` skill for:
- React component architecture and patterns
- Accessibility requirements (ARIA, focus management)
- UX flows and state management

## Design System Reference

### CSS Variables & Design Tokens

**MUST**: Always use CSS variable-based classes. **MUST NOT**: Use arbitrary values.

**Brand Colors:**
- `bg-md3-primary` / `hover:bg-md3-primary-hover` / `active:bg-md3-primary-active`
- `bg-md3-secondary` / `hover:bg-md3-secondary-hover` / `active:bg-md3-secondary-active`
- `bg-md3-accent` / `hover:bg-md3-accent-hover` / `active:bg-md3-accent-active`
- `text-md3-on-primary` / `text-md3-on-secondary` / `text-md3-on-accent`

**Phase Colors:**
- `bg-md3-spark` - Ember orange (#E67E22)
- `bg-md3-ember` - Deep rust (#C0392B)
- `bg-md3-forged` - Deep teal (#1ABC9C)

**Surface Colors:**
- `bg-md3-surface-container` - Card/container backgrounds
- `bg-md3-surface-container-high` - Higher elevation surfaces
- `border-md3-outline` - Border color

**Custom Radius & Shadows:**
- `rounded-md3-card` (12px), `rounded-md3-button` (20px), `rounded-md3-chip` (8px)
- `shadow-md3-1` through `shadow-md3-5` (Material Design 3 elevations)

### Code Examples

```tsx
// ✅ CORRECT: Use design tokens
<button className="bg-md3-primary hover:bg-md3-primary-hover text-md3-on-primary">
  Click me
</button>

// ❌ WRONG: Arbitrary values
<button className="bg-[#E67E22] text-[#1C1B1F]">Click me</button>
```

## Core Tailwind Concepts

### The cn() Utility Function

**MUST**: Use `cn()` for all className merging. Combines `clsx` for conditional classes and `tailwind-merge` to prevent conflicts.

```typescript
import { cn } from "@/lib/utils";

// Basic usage
<div className={cn("base-class", conditional && "conditional-class")} />

// With props
<div className={cn(baseStyles, variantStyles[variant], className)} />

// Multiple conditions
<div className={cn(
  "rounded-lg p-4",
  isActive && "bg-md3-primary text-white",
  isDisabled && "opacity-50 cursor-not-allowed",
  className
)} />
```

### Dynamic Classes - Critical Rules

**MUST**: Always use complete class name strings
**MUST NOT**: Construct class names dynamically with template literals

```tsx
// ❌ WRONG: Dynamic construction (classes won't be generated)
<div className={`text-${color}-500`} />
<div className={`bg-md3-${variant}`} />

// ✅ CORRECT: Complete strings via Record mapping
const colorClasses: Record<string, string> = {
  primary: "text-md3-primary",
  secondary: "text-md3-secondary",
};
<div className={colorClasses[color]} />

// ✅ CORRECT: For unknown values, use inline styles
<div style={{ borderColor: dynamicColor }} className="border-2" />
```

### State Variants

```tsx
<button className="bg-md3-primary hover:bg-md3-primary-hover active:bg-md3-primary-active">
  Button
</button>

// Group pattern
<a href="#" className="group">
  <svg className="stroke-foreground group-hover:stroke-md3-primary" />
</a>

// Peer pattern
<label>
  <input type="email" className="peer" required />
  <p className="invisible peer-invalid:visible text-red-500">Invalid email</p>
</label>
```

## Responsive Design

### Mobile-First Approach

**Default styles = mobile**. Use breakpoints to progressively enhance.

**Breakpoints:** `sm:640px` | `md:768px` | `lg:1024px` | `xl:1280px` | `2xl:1536px`

```tsx
// Mobile: stack vertically, Desktop: side-by-side
<div className="flex flex-col lg:flex-row gap-6">
  <aside className="w-full lg:w-64">Sidebar</aside>
  <main className="flex-1">Content</main>
</div>

// Responsive text sizing
<h1 className="text-2xl md:text-3xl lg:text-4xl">Heading</h1>

// Responsive grid
<div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 md:gap-6">
  {/* Cards */}
</div>
```

## Dark Mode Implementation

Uses `darkMode: 'class'` strategy. CSS variables automatically switch values.

### Automatic via CSS Variables (Preferred)

```tsx
// ✅ BEST: Automatic dark mode (CSS variables handle it)
<div className="bg-md3-primary text-md3-on-primary">Content</div>
<div className="bg-md3-surface-container border border-md3-outline">Card</div>
```

### Explicit dark: variant (when needed)

```tsx
<div className="bg-white dark:bg-md3-surface-container">Content</div>
<div className="border-gray-200 dark:border-white/10">Divider</div>
<div className="hover:bg-md3-primary/5 dark:hover:bg-white/8">Hover me</div>
```

**MUST**: Test both light and dark modes for every component
**MUST**: Verify color contrast meets WCAG AA standards (4.5:1 for text)

## Component Styling Patterns

### Variant Pattern (Recommended)

```tsx
type Variant = "primary" | "secondary" | "ghost";
type Size = "sm" | "md" | "lg";

const variantStyles: Record<Variant, string> = {
  primary: "bg-md3-primary hover:bg-md3-primary-hover text-white shadow-md3-1 hover:shadow-md3-2",
  secondary: "bg-md3-secondary hover:bg-md3-secondary-hover text-white shadow-md3-1 hover:shadow-md3-2",
  ghost: "bg-transparent hover:bg-md3-primary/10 text-foreground",
};

const sizeStyles: Record<Size, string> = {
  sm: "px-4 py-2 text-sm",
  md: "px-6 py-3 text-base",
  lg: "px-8 py-4 text-lg",
};

export function Button({ variant = "primary", size = "md", className, ...props }: Props) {
  return (
    <button
      className={cn(
        "font-semibold rounded-md3-button transition-all duration-200",
        "disabled:opacity-50 disabled:cursor-not-allowed",
        variantStyles[variant],
        sizeStyles[size],
        className
      )}
      {...props}
    />
  );
}
```

### When to Extract Components

**MUST**: Extract when pattern used 3+ times
**MUST**: Extract when utility list exceeds ~8 classes
**MUST NOT**: Extract one-off patterns

## Layout Utilities

### Flexbox Patterns

```tsx
// Horizontal with gap
<div className="flex items-center gap-4">

// Vertical stack
<div className="flex flex-col gap-2">

// Space between
<div className="flex items-center justify-between">

// Center content
<div className="flex items-center justify-center min-h-screen">
```

### Grid Patterns

```tsx
// Responsive grid
<div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">

// Auto-fit grid
<div className="grid grid-cols-[repeat(auto-fit,minmax(280px,1fr))] gap-6">
```

## Performance & Optimization

### Content Detection

Tailwind scans files for class names at build time. Configure content paths in `tailwind.config.ts`:

```typescript
content: [
  "./src/pages/**/*.{js,ts,jsx,tsx,mdx}",
  "./src/components/**/*.{js,ts,jsx,tsx,mdx}",
  "./src/app/**/*.{js,ts,jsx,tsx,mdx}",
],
```

### Production Optimization

- Tailwind automatically purges unused classes in production
- Only classes found in source files are included in final CSS
- No runtime performance cost (CSS-only)

## Accessibility Considerations

### Focus Indicators

**MUST**: Provide visible focus indicators

```tsx
<button className="focus:ring-2 focus:ring-md3-primary focus:ring-offset-2">
  Button
</button>

// Keyboard only
<input className="focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-md3-accent">
```

### Color Contrast

**MUST**: Use on-color variables for text on colored backgrounds

```tsx
// ✅ CORRECT: Use on-color variables
<div className="bg-md3-primary text-md3-on-primary">Text</div>

// ❌ WRONG: Hardcoded white text
<div className="bg-md3-primary text-white">Text</div>
```

### Screen Reader Utilities

```tsx
// Visually hidden but accessible
<span className="sr-only">Screen reader text</span>

// Hide from screen readers
<div aria-hidden="true">Decorative</div>
```

## Common Patterns

### Cards

```tsx
<div className={cn(
  "bg-background-secondary dark:bg-white/5",
  "border border-md3-primary/10 dark:border-white/10",
  "hover:border-md3-primary/20 dark:hover:border-white/20",
  "rounded-md3-card p-6",
  "shadow-md3-1 hover:shadow-md3-2",
  "transition-all duration-200"
)}>
  <h3 className="text-lg font-semibold mb-2">Card Title</h3>
  <p className="text-foreground-muted">Card content</p>
</div>
```

### Buttons

```tsx
// Primary button
<button className={cn(
  "bg-md3-primary hover:bg-md3-primary-hover active:bg-md3-primary-active",
  "text-white font-semibold",
  "px-6 py-3 rounded-md3-button",
  "shadow-md3-1 hover:shadow-md3-2",
  "transition-all duration-200",
  "disabled:opacity-50 disabled:cursor-not-allowed"
)}>
  Submit
</button>
```

### Forms

```tsx
// Input field
<input
  className={cn(
    "w-full px-4 py-2",
    "bg-background-secondary",
    "border border-md3-outline rounded-lg",
    "focus:ring-2 focus:ring-md3-primary focus:outline-none",
    "placeholder:text-foreground-muted"
  )}
  placeholder="Enter text"
/>
```

### Badges

```tsx
// Spark badge
<span className="inline-flex items-center gap-1 px-3 py-1 bg-md3-spark text-white text-xs font-medium rounded-lg">
  spark
</span>

// Ember badge
<span className="px-3 py-1 bg-md3-ember text-white text-xs font-medium rounded-lg">
  ember
</span>
```

## Debugging & Troubleshooting

### Common Issues

**Classes not applying:**
- Check content paths in `tailwind.config.ts`
- Ensure complete class strings (no dynamic construction)
- Clear build cache: `rm -rf .next`

**Specificity conflicts:**
- Use `cn()` utility (tailwind-merge handles conflicts)
- Avoid mixing Tailwind with custom CSS

**Dark mode not working:**
- Verify `dark` class on root `<html>` element
- Check CSS variable definitions in `globals.css`

## Project-Specific Best Practices

### Material Design 3 Adherence

**MUST**: Use md3-* prefixed colors
**MUST**: Use elevation shadows (`shadow-md3-1` through `shadow-md3-5`)
**MUST**: Follow border radius conventions:
- `rounded-md3-card` for cards (12px)
- `rounded-md3-button` for buttons (20px)
- `rounded-md3-chip` for badges/chips (8px)

### Phase Color Usage

Use semantic phase colors appropriately:
- **Spark** (`bg-md3-spark`): Initial ideas, inspiration phase
- **Ember** (`bg-md3-ember`): Active development, heating up
- **Forged** (`bg-md3-forged`): Completed works, final products

### Consistency Patterns

**MUST**: Use `cn()` for all className merging
**MUST**: Extract variant/size Records for reusable components
**MUST**: Keep `transition-all duration-200` consistent across interactive elements
**MUST**: Follow elevation pattern: `shadow-md3-1` → `shadow-md3-2` on hover

## Anti-patterns to Avoid

### MUST NEVER

```tsx
// ❌ Dynamic class construction
<div className={`text-${color}-500`} />

// ❌ Arbitrary values when tokens exist
<div className="bg-[#E67E22]" />

// ❌ @apply in component files
.my-component {
  @apply bg-primary text-white;
}

// ❌ Inline styles when Tailwind class exists
<div style={{ backgroundColor: '#E67E22' }} />
```

### MUST DO INSTEAD

```tsx
// ✅ Use Record mapping for variants
const colorClasses: Record<Color, string> = {
  primary: "text-md3-primary",
  secondary: "text-md3-secondary",
};
<div className={colorClasses[color]} />

// ✅ Use design tokens from config
<div className="bg-md3-primary shadow-md3-2" />

// ✅ Extract component
export function MyComponent({ className }: Props) {
  return <div className={cn("bg-primary text-white", className)} />;
}
```

## Implementation Checklist

- [ ] Use `cn()` utility for class merging
- [ ] Reference design tokens (no arbitrary values)
- [ ] Complete class strings only (no dynamic construction)
- [ ] Test both light and dark modes
- [ ] Verify accessibility (focus states, color contrast)
- [ ] Use responsive utilities with mobile-first approach
- [ ] Follow Material Design 3 elevation/radius patterns
- [ ] Extract variants to Record types if 3+ options
- [ ] Implement hover/active/disabled states
- [ ] Use semantic phase colors appropriately
- [ ] Add `transition-all duration-200` for smooth interactions

## Resources

### In-Depth Guides

- **`resources/design-tokens.md`** - Complete design token system guide
- **`resources/responsive-patterns.md`** - Mobile-first patterns and layouts
- **`resources/dark-mode-guide.md`** - Dark mode implementation guide
- **`resources/component-patterns.md`** - Component styling patterns
- **`resources/common-issues.md`** - Troubleshooting guide

### Official Documentation

- [Utility-First Fundamentals](https://tailwindcss.com/docs/utility-first)
- [Responsive Design](https://tailwindcss.com/docs/responsive-design)
- [Dark Mode](https://tailwindcss.com/docs/dark-mode)
- [Theme Configuration](https://tailwindcss.com/docs/theme)
- [Content Configuration](https://tailwindcss.com/docs/content-configuration)

## Remember

- **Utility-first** over custom CSS | **Design tokens** mandatory | **Complete class strings** only
- **cn() utility** prevents conflicts | **Mobile-first** responsive | Test **both light and dark modes**
- **CSS variables** handle theming | **Material Design 3** system | Consult **ux-designer** for React/accessibility
