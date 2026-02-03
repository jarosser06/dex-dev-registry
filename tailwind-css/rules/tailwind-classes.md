# Tailwind CSS Class Standards

## Design Tokens

**MUST**: Always use design tokens from `tailwind.config.ts`

**MUST NOT**: Use arbitrary values

**Examples:**
```typescript
// ✅ CORRECT: Use design tokens
<div className="bg-md3-primary" />
<div className="shadow-md3-2" />
<div className="rounded-md3-card" />

// ❌ WRONG: Arbitrary values
<div className="bg-[#E67E22]" />
<div className="shadow-[0_2px_4px_rgba(0,0,0,0.3)]" />
<div className="rounded-[12px]" />
```

## Dynamic Class Construction

**MUST**: Use complete class name strings

**MUST NOT**: Construct class names dynamically with template literals or concatenation

**Reason**: Tailwind scans source files for complete class names at build time. Dynamic construction breaks detection.

**Examples:**
```typescript
// ❌ WRONG: Dynamic construction
<div className={`text-${color}-500`} />
<div className={`bg-md3-${variant}`} />

// ✅ CORRECT: Complete strings via Record
const colorClasses: Record<string, string> = {
  primary: "text-md3-primary",
  secondary: "text-md3-secondary",
};
<div className={colorClasses[color]} />

// ✅ CORRECT: For unknown values, use inline styles
<div style={{ borderColor: dynamicColor }} className="border-2" />
```

## Material Design 3 Adherence

**MUST**: Use md3-* prefixed colors for all brand colors

**MUST**: Use elevation shadows (`shadow-md3-1` through `shadow-md3-5`)

**MUST**: Use MD3 border radius:
- `rounded-md3-card` for cards (12px)
- `rounded-md3-button` for buttons (20px)
- `rounded-md3-chip` for badges/chips (8px)

## On-Colors for Contrast

**MUST**: Use on-color variables for text on colored backgrounds

**Examples:**
```typescript
// ✅ CORRECT: Use on-color variables
<div className="bg-md3-primary text-md3-on-primary" />
<div className="bg-md3-accent text-md3-on-accent" />

// ❌ WRONG: Hardcoded text color (may have poor contrast)
<div className="bg-md3-primary text-white" />
```
