# Tailwind Testing Requirements

## Dark Mode Testing

**MUST**: Test both light and dark modes for every component

**MUST**: Verify colors switch correctly when dark mode is toggled

**MUST**: Check contrast ratios in both modes

**Minimum contrast ratios (WCAG AA)**:
- Normal text: 4.5:1
- Large text (18px+): 3:1

## Accessibility Requirements

**MUST**: Provide visible focus indicators

**MUST NOT**: Use `outline-none` without replacement

**Examples:**
```typescript
// ✅ CORRECT: Replace removed focus with custom indicator
<button className="focus:outline-none focus:ring-2 focus:ring-md3-primary" />

// ❌ WRONG: Removes focus indicator completely
<button className="outline-none" />
```

## Interactive States

**MUST**: Implement hover, active, and disabled states

**MUST**: Test all interactive states in both light and dark modes

**Examples:**
```typescript
// ✅ CORRECT: All states covered
<button className="
  bg-md3-primary hover:bg-md3-primary-hover active:bg-md3-primary-active
  disabled:opacity-50 disabled:cursor-not-allowed
" />
```

## Responsive Testing

**MUST**: Test at all breakpoints: 375px (mobile), 768px (tablet), 1024px (desktop)

**MUST**: Verify mobile-first approach (base styles work on mobile)

## Dark Mode Configuration

**MUST**: Verify `darkMode: 'class'` in `tailwind.config.ts`

**MUST**: Ensure `.dark` class is applied to `<html>` element

**MUST**: Add `suppressHydrationWarning` to `<html>` tag to prevent FOUC
