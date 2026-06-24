// web/src/shared/components/forms/FormSection.tsx
import type { ReactNode } from 'react';
import { cn } from '@/lib/utils';

interface FormSectionProps {
  title?: string;
  description?: string;
  actions?: ReactNode;
  children: ReactNode;
  className?: string;
}

export function FormSection({
  title,
  description,
  actions,
  children,
  className = '',
}: FormSectionProps) {
  return (
    <section className={cn('space-y-4', className)}>
      {(title || description || actions) && (
        <div className="flex items-start justify-between gap-4">
          <div className="space-y-0.5">
            {title && (
              <h3 className="text-base font-semibold leading-none tracking-tight">
                {title}
              </h3>
            )}
            {description && (
              <p className="text-sm text-muted-foreground">{description}</p>
            )}
          </div>
          {actions && <div>{actions}</div>}
        </div>
      )}
      <div className="space-y-4">{children}</div>
    </section>
  );
}

export default FormSection;