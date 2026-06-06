import { cn } from '../../../lib/utils';

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
  if (!errors || errors.length === 0) {
    return null;
  }

  return (
    <div id={id} className={cn('grid gap-1', className)} role="alert" aria-live="polite">
      <ul>
        {errors.map((error, index) => (
          <li key={`${error}-${index}`} className="text-xs text-danger-600 dark:text-danger-400">
            {error}
          </li>
        ))}
      </ul>
    </div>
  );
}
