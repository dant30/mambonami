// web/src/shared/components/forms/ValidationErrors.tsx
import { cn } from '@/lib/utils';

interface ValidationErrorsProps {
  id?: string;
  errors?: string[];
  className?: string;
}

export default function ValidationErrors({
  id,
  errors = [],
  className = '',
}: ValidationErrorsProps) {
  if (!errors || errors.length === 0) return null;

  return (
    <div
      id={id}
      className={cn('grid gap-0.5', className)}
      role="alert"
      aria-live="polite"
    >
      <ul className="list-inside list-disc space-y-0.5">
        {errors.map((error, index) => (
          <li key={`${error}-${index}`} className="text-sm text-destructive">
            {error}
          </li>
        ))}
      </ul>
    </div>
  );
}