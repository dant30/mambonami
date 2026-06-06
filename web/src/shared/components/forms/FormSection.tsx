import type { ReactNode } from 'react';

import { cn } from '../../../lib/utils';

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
    <section className={cn('ui-form-section anim-fade-in', className)}>
      {(title || description || actions) && (
        <header className="ui-form-section-header">
          <div>
            {title ? <h3 className="text-base font-semibold text-text-primary">{title}</h3> : null}
            {description ? <p className="mt-1 text-sm text-text-secondary">{description}</p> : null}
          </div>
          {actions ? <div>{actions}</div> : null}
        </header>
      )}
      <div className="ui-form-section-body">{children}</div>
    </section>
  );
}

export default FormSection;
