# Component Styling Patterns

Comprehensive patterns for building styled components with Tailwind CSS.

## Core Pattern: Record Types + cn()

The foundational pattern for building reusable components.

```typescript
import { HTMLAttributes } from "react";
import { cn } from "@/lib/utils";

type Variant = "primary" | "secondary" | "ghost";
type Size = "sm" | "md" | "lg";

interface ComponentProps extends HTMLAttributes<HTMLDivElement> {
  variant?: Variant;
  size?: Size;
}

const variantStyles: Record<Variant, string> = {
  primary: "bg-md3-primary hover:bg-md3-primary-hover text-white",
  secondary: "bg-md3-secondary hover:bg-md3-secondary-hover text-white",
  ghost: "bg-transparent hover:bg-md3-primary/10 text-foreground",
};

const sizeStyles: Record<Size, string> = {
  sm: "px-4 py-2 text-sm",
  md: "px-6 py-3 text-base",
  lg: "px-8 py-4 text-lg",
};

export function Component({
  variant = "primary",
  size = "md",
  className,
  ...props
}: ComponentProps): JSX.Element {
  return (
    <div
      className={cn(
        "base-styles transition-all duration-200",
        variantStyles[variant],
        sizeStyles[size],
        className
      )}
      {...props}
    />
  );
}
```

## Button Patterns

### Basic Button

```typescript
import { ButtonHTMLAttributes, ReactNode } from "react";
import { cn } from "@/lib/utils";

type ButtonVariant = "primary" | "secondary" | "ghost" | "accent";
type ButtonSize = "sm" | "md" | "lg";

interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: ButtonVariant;
  size?: ButtonSize;
  children: ReactNode;
}

const variantStyles: Record<ButtonVariant, string> = {
  primary: "bg-md3-primary hover:bg-md3-primary-hover active:bg-md3-primary-active text-white shadow-md3-1 hover:shadow-md3-2",
  secondary: "bg-md3-secondary hover:bg-md3-secondary-hover active:bg-md3-secondary-active text-white shadow-md3-1 hover:shadow-md3-2",
  ghost: "bg-white dark:bg-md3-surface-container border border-foreground/20 hover:bg-foreground/5 hover:border-foreground/30 text-foreground",
  accent: "bg-md3-accent hover:bg-md3-accent-hover active:bg-md3-accent-active text-white shadow-md3-1 hover:shadow-md3-2",
};

const sizeStyles: Record<ButtonSize, string> = {
  sm: "px-4 py-2 text-sm",
  md: "px-6 py-3 text-base",
  lg: "px-8 py-4 text-lg",
};

export function Button({
  variant = "primary",
  size = "md",
  className,
  disabled,
  children,
  ...props
}: ButtonProps): JSX.Element {
  return (
    <button
      className={cn(
        "font-semibold rounded-md3-button transition-all duration-200",
        "inline-flex items-center justify-center gap-2",
        "disabled:opacity-50 disabled:cursor-not-allowed",
        variantStyles[variant],
        sizeStyles[size],
        className
      )}
      disabled={disabled}
      {...props}
    >
      {children}
    </button>
  );
}
```

### Icon Button

```typescript
import { ButtonHTMLAttributes, ReactNode } from "react";
import { cn } from "@/lib/utils";

interface IconButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  icon: ReactNode;
  "aria-label": string;
  size?: "sm" | "md" | "lg";
}

const iconButtonSizes: Record<string, string> = {
  sm: "size-8",
  md: "size-10",
  lg: "size-12",
};

export function IconButton({
  icon,
  size = "md",
  className,
  ...props
}: IconButtonProps): JSX.Element {
  return (
    <button
      className={cn(
        "inline-flex items-center justify-center",
        "rounded-full",
        "bg-md3-surface-container",
        "hover:bg-md3-primary/10",
        "transition-colors",
        iconButtonSizes[size],
        className
      )}
      {...props}
    >
      {icon}
    </button>
  );
}
```

## Card Patterns

### Basic Card

```tsx
import { HTMLAttributes, ReactNode } from "react";
import { cn } from "@/lib/utils";

interface CardProps extends HTMLAttributes<HTMLDivElement> {
  children: ReactNode;
}

export function Card({ className, children, ...props }: CardProps) {
  return (
    <div
      className={cn(
        "bg-background-secondary dark:bg-white/5",
        "border border-md3-primary/10 dark:border-white/10",
        "hover:border-md3-primary/20 dark:hover:border-white/20",
        "rounded-md3-card",
        "shadow-md3-1 hover:shadow-md3-2",
        "transition-all duration-200",
        className
      )}
      {...props}
    >
      {children}
    </div>
  );
}

export function CardHeader({ className, children, ...props }: CardProps) {
  return (
    <div
      className={cn(
        "p-6 border-b border-md3-outline/20",
        className
      )}
      {...props}
    >
      {children}
    </div>
  );
}

export function CardContent({ className, children, ...props }: CardProps) {
  return (
    <div className={cn("p-6", className)} {...props}>
      {children}
    </div>
  );
}

export function CardFooter({ className, children, ...props }: CardProps) {
  return (
    <div
      className={cn(
        "p-6 border-t border-md3-outline/20",
        className
      )}
      {...props}
    >
      {children}
    </div>
  );
}
```

### Interactive Card

```tsx
interface InteractiveCardProps extends HTMLAttributes<HTMLDivElement> {
  onClick?: () => void;
  selected?: boolean;
  children: ReactNode;
}

export function InteractiveCard({
  onClick,
  selected = false,
  className,
  children,
  ...props
}: InteractiveCardProps) {
  return (
    <div
      onClick={onClick}
      className={cn(
        "bg-background-secondary",
        "rounded-md3-card p-6",
        "border-2 transition-all duration-200",
        "cursor-pointer",
        selected
          ? "border-md3-primary shadow-md3-2"
          : "border-md3-outline/20 hover:border-md3-primary/40 hover:shadow-md3-1",
        className
      )}
      {...props}
    >
      {children}
    </div>
  );
}
```

## Badge/Chip Patterns

### Phase Badge

```tsx
type Phase = "spark" | "ember" | "forged";

const phaseBadgeStyles: Record<Phase, string> = {
  spark: "bg-md3-spark text-white",
  ember: "bg-md3-ember text-white",
  forged: "bg-md3-forged text-white",
};

interface PhaseBadgeProps {
  phase: Phase;
  className?: string;
}

export function PhaseBadge({ phase, className }: PhaseBadgeProps) {
  return (
    <span
      className={cn(
        "inline-flex items-center gap-1",
        "px-3 py-1",
        "text-xs font-medium",
        "rounded-md3-chip",
        phaseBadgeStyles[phase],
        className
      )}
    >
      {phase}
    </span>
  );
}
```

### Status Badge

```tsx
type Status = "active" | "inactive" | "pending";

const statusBadgeStyles: Record<Status, string> = {
  active: "bg-md3-accent/10 text-md3-accent border-md3-accent/20",
  inactive: "bg-md3-neutral-100 text-md3-neutral-700 border-md3-neutral-200",
  pending: "bg-md3-fuel/10 text-md3-on-fuel border-md3-fuel/20",
};

interface StatusBadgeProps {
  status: Status;
  label: string;
  className?: string;
}

export function StatusBadge({ status, label, className }: StatusBadgeProps) {
  return (
    <span
      className={cn(
        "inline-flex items-center",
        "px-2.5 py-0.5",
        "text-xs font-medium",
        "border rounded-full",
        statusBadgeStyles[status],
        className
      )}
    >
      {label}
    </span>
  );
}
```

## Form Patterns

### Input Field

```tsx
import { InputHTMLAttributes, forwardRef } from "react";

interface InputProps extends InputHTMLAttributes<HTMLInputElement> {
  label?: string;
  error?: string;
  helper?: string;
}

export const Input = forwardRef<HTMLInputElement, InputProps>(
  ({ label, error, helper, className, ...props }, ref) => {
    return (
      <div className="space-y-2">
        {label && (
          <label className="block text-sm font-medium text-foreground">
            {label}
          </label>
        )}
        <input
          ref={ref}
          className={cn(
            "w-full px-4 py-2",
            "bg-background-secondary",
            "border rounded-lg",
            "focus:ring-2 focus:outline-none",
            "placeholder:text-foreground-muted",
            "transition-all",
            error
              ? "border-red-500 focus:ring-red-500"
              : "border-md3-outline focus:ring-md3-primary focus:border-md3-primary",
            className
          )}
          {...props}
        />
        {error && (
          <p className="text-sm text-red-500">{error}</p>
        )}
        {helper && !error && (
          <p className="text-sm text-foreground-muted">{helper}</p>
        )}
      </div>
    );
  }
);

Input.displayName = "Input";
```

### Select Field

```tsx
import { SelectHTMLAttributes, forwardRef } from "react";

interface SelectProps extends SelectHTMLAttributes<HTMLSelectElement> {
  label?: string;
  error?: string;
  options: Array<{ value: string; label: string }>;
}

export const Select = forwardRef<HTMLSelectElement, SelectProps>(
  ({ label, error, options, className, ...props }, ref) => {
    return (
      <div className="space-y-2">
        {label && (
          <label className="block text-sm font-medium text-foreground">
            {label}
          </label>
        )}
        <select
          ref={ref}
          className={cn(
            "w-full px-4 py-2",
            "bg-background-secondary",
            "border rounded-lg",
            "focus:ring-2 focus:outline-none",
            "transition-all",
            error
              ? "border-red-500 focus:ring-red-500"
              : "border-md3-outline focus:ring-md3-primary",
            className
          )}
          {...props}
        >
          {options.map((option) => (
            <option key={option.value} value={option.value}>
              {option.label}
            </option>
          ))}
        </select>
        {error && (
          <p className="text-sm text-red-500">{error}</p>
        )}
      </div>
    );
  }
);

Select.displayName = "Select";
```

### Textarea Field

```tsx
import { TextareaHTMLAttributes, forwardRef } from "react";

interface TextareaProps extends TextareaHTMLAttributes<HTMLTextAreaElement> {
  label?: string;
  error?: string;
}

export const Textarea = forwardRef<HTMLTextAreaElement, TextareaProps>(
  ({ label, error, className, ...props }, ref) => {
    return (
      <div className="space-y-2">
        {label && (
          <label className="block text-sm font-medium text-foreground">
            {label}
          </label>
        )}
        <textarea
          ref={ref}
          className={cn(
            "w-full px-4 py-2",
            "bg-background-secondary",
            "border rounded-lg",
            "focus:ring-2 focus:outline-none",
            "placeholder:text-foreground-muted",
            "transition-all",
            "min-h-[120px] resize-y",
            error
              ? "border-red-500 focus:ring-red-500"
              : "border-md3-outline focus:ring-md3-primary",
            className
          )}
          {...props}
        />
        {error && (
          <p className="text-sm text-red-500">{error}</p>
        )}
      </div>
    );
  }
);

Textarea.displayName = "Textarea";
```

## Modal/Dialog Patterns

### Basic Modal

```tsx
import { ReactNode } from "react";
import { cn } from "@/lib/utils";

interface ModalProps {
  isOpen: boolean;
  onClose: () => void;
  children: ReactNode;
  className?: string;
}

export function Modal({ isOpen, onClose, children, className }: ModalProps) {
  if (!isOpen) return null;

  return (
    <div
      className="fixed inset-0 z-50 flex items-center justify-center p-4"
      onClick={onClose}
    >
      {/* Backdrop */}
      <div className="absolute inset-0 bg-black/50 dark:bg-black/70 backdrop-blur-sm" />

      {/* Modal */}
      <div
        className={cn(
          "relative z-10",
          "bg-background-secondary",
          "rounded-md3-card",
          "shadow-md3-5",
          "max-w-lg w-full",
          "max-h-[90vh] overflow-y-auto",
          className
        )}
        onClick={(e) => e.stopPropagation()}
      >
        {children}
      </div>
    </div>
  );
}

export function ModalHeader({ children, className }: { children: ReactNode; className?: string }) {
  return (
    <div className={cn("p-6 border-b border-md3-outline/20", className)}>
      {children}
    </div>
  );
}

export function ModalContent({ children, className }: { children: ReactNode; className?: string }) {
  return (
    <div className={cn("p-6", className)}>
      {children}
    </div>
  );
}

export function ModalFooter({ children, className }: { children: ReactNode; className?: string }) {
  return (
    <div className={cn("p-6 border-t border-md3-outline/20 flex justify-end gap-3", className)}>
      {children}
    </div>
  );
}
```

## List Patterns

### List Item

```tsx
interface ListItemProps extends HTMLAttributes<HTMLLIElement> {
  title: string;
  description?: string;
  icon?: ReactNode;
  action?: ReactNode;
}

export function ListItem({
  title,
  description,
  icon,
  action,
  className,
  ...props
}: ListItemProps) {
  return (
    <li
      className={cn(
        "flex items-center gap-4 p-4",
        "hover:bg-md3-primary/5 dark:hover:bg-white/5",
        "border-b border-md3-outline/20 last:border-b-0",
        "transition-colors",
        className
      )}
      {...props}
    >
      {icon && (
        <div className="flex-shrink-0">
          {icon}
        </div>
      )}
      <div className="flex-1 min-w-0">
        <p className="font-medium text-foreground truncate">
          {title}
        </p>
        {description && (
          <p className="text-sm text-foreground-muted truncate">
            {description}
          </p>
        )}
      </div>
      {action && (
        <div className="flex-shrink-0">
          {action}
        </div>
      )}
    </li>
  );
}
```

## When to Extract Components

### Extract if:

1. **Used 3+ times** across the codebase
2. **Complex styling** (more than ~8 utility classes)
3. **Consistent pattern** that should remain uniform
4. **Variants needed** (different sizes, colors, states)

### Keep inline if:

1. **One-off usage** unique to a single page
2. **Simple styling** (few utility classes)
3. **Highly contextual** to specific use case

## Performance Tips

### Avoid Prop Spreading

```tsx
// ❌ SLOW: Spreads all props including className
<div {...props} className={cn("styles", className)} />

// ✅ FAST: Extract className first
const { className, ...rest } = props;
<div className={cn("styles", className)} {...rest} />
```

### Memoize Complex Styles

```tsx
// For frequently re-rendering components
const buttonStyles = useMemo(
  () => cn(
    "base",
    variantStyles[variant],
    sizeStyles[size],
    className
  ),
  [variant, size, className]
);
```

