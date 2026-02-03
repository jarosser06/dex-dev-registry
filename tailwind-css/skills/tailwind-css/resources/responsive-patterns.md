# Responsive Design Patterns

Comprehensive guide to responsive design with Tailwind CSS, focusing on mobile-first patterns.

## Mobile-First Philosophy

**Default styles target mobile devices**. Use breakpoint prefixes to progressively enhance for larger screens.

```tsx
// ✅ CORRECT: Mobile-first
<div className="text-base md:text-lg lg:text-xl">
  Text scales up on larger screens
</div>

// ❌ WRONG: Desktop-first (harder to maintain)
<div className="text-xl lg:text-lg md:text-base">
  Scales down (confusing)
</div>
```

## Breakpoint System

```typescript
// Default Tailwind breakpoints
sm: '640px'   // Small tablets
md: '768px'   // Tablets
lg: '1024px'  // Small laptops
xl: '1280px'  // Desktops
2xl: '1536px' // Large desktops
```

### Breakpoint Usage

```tsx
// Single property responsive
<div className="w-full md:w-1/2 lg:w-1/3">
  Responsive width
</div>

// Multiple properties
<div className="p-4 md:p-6 lg:p-8 text-sm md:text-base">
  Responsive padding and text
</div>

// Complex responsive layout
<div className="
  flex flex-col md:flex-row
  gap-4 md:gap-6 lg:gap-8
  items-stretch md:items-center
">
  Layout changes at md breakpoint
</div>
```

## Common Layout Patterns

### 1. Dashboard Layout

Sidebar + main content pattern with responsive behavior.

```typescript
import { ReactNode } from "react";

interface DashboardLayoutProps {
  children: ReactNode;
}

export function DashboardLayout({ children }: DashboardLayoutProps): JSX.Element {
  return (
    <div className="flex flex-col lg:flex-row min-h-screen">
      {/* Sidebar: Full width on mobile, fixed width on desktop */}
      <aside className="
        w-full lg:w-64
        bg-md3-surface-container
        border-b lg:border-r lg:border-b-0
        border-md3-outline
      ">
        <Sidebar />
      </aside>

      {/* Main content: Flexible */}
      <main className="flex-1 p-4 md:p-6 lg:p-8">
        {children}
      </main>
    </div>
  );
}
```

### 2. Card Grid

Responsive grid that adapts to screen size.

```tsx
// Basic responsive grid
<div className="
  grid
  grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4
  gap-4 md:gap-6
">
  {items.map(item => <Card key={item.id} {...item} />)}
</div>

// Auto-fit grid (no breakpoints needed)
<div className="
  grid
  grid-cols-[repeat(auto-fit,minmax(280px,1fr))]
  gap-6
">
  {items.map(item => <Card key={item.id} {...item} />)}
</div>
```

### 3. Header Navigation

```typescript
export function Header(): JSX.Element {
  return (
    <header className="
      sticky top-0 z-50
      bg-md3-surface-container
      border-b border-md3-outline
      px-4 md:px-6 lg:px-8
      py-4
    ">
      <div className="
        flex items-center justify-between
        max-w-7xl mx-auto
      ">
        {/* Logo: Always visible */}
        <Logo />

        {/* Desktop nav: Hidden on mobile */}
        <nav className="hidden md:flex items-center gap-6">
          <NavLinks />
        </nav>

        {/* Mobile menu button: Hidden on desktop */}
        <button className="md:hidden">
          <MenuIcon />
        </button>
      </div>
    </header>
  );
}
```

### 4. Spark/Creation Detail Page

Two-column layout that stacks on mobile.

```typescript
export function DetailPage(): JSX.Element {
  return (
    <div className="
      grid
      grid-cols-1 lg:grid-cols-[2fr_1fr]
      gap-6 lg:gap-8
      p-4 md:p-6 lg:p-8
    ">
      {/* Main content */}
      <div className="space-y-6">
        <ContentSection />
      </div>

      {/* Sidebar */}
      <aside className="
        space-y-4
        lg:sticky lg:top-24 lg:self-start
      ">
        <MetadataPanel />
        <AttachmentsPanel />
      </aside>
    </div>
  );
}
```

### 5. Search Bar

Responsive search with adaptive sizing.

```typescript
export function SearchBar(): JSX.Element {
  return (
    <div className="
      w-full md:w-96 lg:w-[500px]
      relative
    ">
      <input
        className="
          w-full
          pl-10 pr-4
          py-2 md:py-3
          text-sm md:text-base
          rounded-lg
          bg-md3-surface-container
          border border-md3-outline
          focus:ring-2 focus:ring-md3-primary
        "
        placeholder="Search..."
      />
      <SearchIcon className="
        absolute left-3 top-1/2 -translate-y-1/2
        size-4 md:size-5
        text-foreground-muted
      " />
    </div>
  );
}
```

## Typography Scaling

### Heading Hierarchy

```tsx
// H1 - Page titles
<h1 className="
  text-3xl md:text-4xl lg:text-5xl
  font-bold
  leading-tight
">
  Page Title
</h1>

// H2 - Section headings
<h2 className="
  text-2xl md:text-3xl lg:text-4xl
  font-semibold
">
  Section Title
</h2>

// H3 - Subsection headings
<h3 className="
  text-xl md:text-2xl
  font-semibold
">
  Subsection
</h3>

// Body text
<p className="text-base md:text-lg leading-relaxed">
  Body content
</p>
```

## Spacing Patterns

### Container Padding

```tsx
// Page container
<div className="px-4 md:px-6 lg:px-8 py-6 md:py-8 lg:py-12">
  Content
</div>

// Card padding
<div className="p-4 md:p-6">
  Card content
</div>

// Section spacing
<section className="space-y-4 md:space-y-6 lg:space-y-8">
  {/* Sections */}
</section>
```

### Gap Spacing

```tsx
// Flex gap
<div className="flex gap-2 md:gap-4 lg:gap-6">
  Items
</div>

// Grid gap
<div className="grid gap-4 md:gap-6 lg:gap-8">
  Items
</div>
```

## Image Responsiveness

### Responsive Images

```tsx
// Full width with aspect ratio
<div className="relative w-full aspect-video">
  <Image
    src={src}
    alt={alt}
    fill
    className="object-cover rounded-lg"
  />
</div>

// Responsive sizing
<Image
  src={src}
  alt={alt}
  className="
    w-full md:w-1/2 lg:w-1/3
    h-auto
    rounded-lg
  "
/>

// Avatar sizes
<Image
  src={avatar}
  alt={name}
  className="
    size-10 md:size-12 lg:size-14
    rounded-full
  "
/>
```

## Show/Hide Patterns

### Display Utilities

```tsx
// Show only on mobile
<div className="block md:hidden">
  Mobile menu
</div>

// Show only on desktop
<div className="hidden md:block">
  Desktop nav
</div>

// Show on tablet and up
<div className="hidden md:block">
  Tablet and desktop
</div>

// Complex visibility
<div className="
  block sm:hidden lg:block
">
  Visible on mobile and large screens only
</div>
```

## Interactive Elements

### Buttons

```tsx
// Responsive button sizing
<button className="
  px-4 md:px-6 lg:px-8
  py-2 md:py-3
  text-sm md:text-base
  rounded-md3-button
  bg-md3-primary hover:bg-md3-primary-hover
">
  Action
</button>

// Full width on mobile
<button className="
  w-full md:w-auto
  px-6 py-3
  bg-md3-primary
">
  Submit
</button>
```

### Form Fields

```tsx
// Responsive form layout
<form className="space-y-4 md:space-y-6">
  <div className="
    grid
    grid-cols-1 md:grid-cols-2
    gap-4 md:gap-6
  ">
    <input className="..." />
    <input className="..." />
  </div>

  <button className="
    w-full md:w-auto md:ml-auto
    px-8 py-3
  ">
    Submit
  </button>
</form>
```

## Advanced Patterns

### Container Queries (Tailwind v4)

Component-level responsiveness based on container size, not viewport.

```tsx
<div className="@container">
  {/* Card adapts to container size */}
  <div className="
    flex flex-col @md:flex-row
    gap-4 @md:gap-6
  ">
    <Image />
    <Content />
  </div>
</div>
```

### Custom Breakpoints

For specific use cases beyond default breakpoints.

```tsx
// Arbitrary breakpoint
<div className="
  grid
  grid-cols-1
  min-[900px]:grid-cols-3
">
  Custom breakpoint at 900px
</div>

// Max-width queries
<div className="
  block max-md:hidden
">
  Hidden below md breakpoint
</div>
```

### Range Queries

Target specific breakpoint ranges.

```tsx
// Only show on medium screens
<div className="
  hidden md:block lg:hidden
">
  Visible only on md breakpoint
</div>

// Tablet-only styles
<div className="
  md:max-lg:text-center
">
  Centered only on tablets
</div>
```

## Performance Considerations

### Image Optimization

```tsx
import Image from 'next/image';

// Responsive images with Next.js
<Image
  src={src}
  alt={alt}
  width={800}
  height={600}
  sizes="(max-width: 768px) 100vw, (max-width: 1200px) 50vw, 33vw"
  className="w-full h-auto"
/>
```

### Lazy Loading

```tsx
// Lazy load below-the-fold content
<Image
  src={src}
  alt={alt}
  loading="lazy"
  className="..."
/>

// Use Intersection Observer for custom lazy loading
<LazyLoad once>
  <HeavyComponent />
</LazyLoad>
```

## Testing Responsive Design

### Browser DevTools

1. Open DevTools (F12 or Cmd+Opt+I)
2. Toggle device toolbar (Cmd+Shift+M)
3. Test at each breakpoint: 375px (mobile), 768px (tablet), 1024px (desktop)
4. Test orientation changes (portrait/landscape)
5. Test zoom levels (100%, 150%, 200%)

### Common Breakpoint Tests

- **320px** - Small mobile (iPhone SE)
- **375px** - Standard mobile (iPhone X)
- **768px** - Tablet (iPad)
- **1024px** - Small laptop
- **1440px** - Desktop
- **1920px** - Large desktop

## Best Practices

### DO

✅ Design mobile-first, enhance for larger screens
✅ Test at each breakpoint
✅ Use semantic breakpoint names (not device-specific)
✅ Keep responsive changes minimal and purposeful
✅ Use container queries for component responsiveness

### DON'T

❌ Design desktop-first and scale down
❌ Create too many custom breakpoints
❌ Use device-specific language in class names
❌ Over-complicate responsive patterns
❌ Forget to test actual devices (not just DevTools)

## Reference

- [Tailwind Responsive Design](https://tailwindcss.com/docs/responsive-design)
- [Container Queries](https://tailwindcss.com/docs/hover-focus-and-other-states#container-queries)
- [MDN: Responsive Design](https://developer.mozilla.org/en-US/docs/Learn/CSS/CSS_layout/Responsive_Design)
