# Tailwind Component Standards

## cn() Utility

**MUST**: Use `cn()` utility for all className merging

**Reason**: Prevents Tailwind class conflicts and handles conditional classes

**Examples:**
```typescript
import { cn } from "@/lib/utils";

// ✅ CORRECT: Use cn() for merging
<div className={cn("base-class", conditional && "conditional-class", className)} />

// ❌ WRONG: String concatenation or manual merging
<div className={`base-class ${conditional ? 'conditional-class' : ''} ${className}`} />
```

## Component Pattern

**MUST**: Use Record types for variant/size mappings

**MUST**: Extend proper HTML element attributes

**MUST**: Include explicit TypeScript return types

**Example:**
```typescript
import { HTMLAttributes } from "react";
import { cn } from "@/lib/utils";

type Variant = "primary" | "secondary";

interface ComponentProps extends HTMLAttributes<HTMLDivElement> {
  variant?: Variant;
}

const variantStyles: Record<Variant, string> = {
  primary: "bg-md3-primary hover:bg-md3-primary-hover",
  secondary: "bg-md3-secondary hover:bg-md3-secondary-hover",
};

export function Component({
  variant = "primary",
  className,
  ...props
}: ComponentProps): JSX.Element {
  return (
    <div
      className={cn(
        "base-styles transition-all duration-200",
        variantStyles[variant],
        className
      )}
      {...props}
    />
  );
}
```

## Component Extraction

**MUST**: Extract component when pattern used 3+ times

**MUST**: Extract when utility list exceeds ~8 classes

**MUST NOT**: Extract one-off patterns

## Transitions

**MUST**: Use `transition-all duration-200` for interactive elements

**Examples:**
```typescript
<button className="bg-md3-primary hover:bg-md3-primary-hover transition-all duration-200" />
<div className="shadow-md3-1 hover:shadow-md3-2 transition-all duration-200" />
```
