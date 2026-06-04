import React from 'react';
import { cn } from '../../../lib/utils';

interface DialogProps {
  open: boolean;
  title?: string;
  onClose: () => void;
  children: React.ReactNode;
  className?: string;
}

export default function Dialog({ open, title, onClose, children, className = '' }: DialogProps) {
  if (!open) return null;

  return (
    <div className="fixed inset-0 z-50 grid place-items-center bg-slate-950/60 p-4 backdrop-blur-sm">
      <div
        className={cn(
          'w-full max-w-3xl overflow-hidden rounded-[28px] border border-border bg-card p-6 shadow-glow transition-transform duration-200 ease-out',
          className,
        )}
      >
        <div className="mb-6 flex items-center justify-between gap-4">
          {title ? <h2 className="text-xl font-semibold text-card-foreground">{title}</h2> : null}
          <button
            type="button"
            onClick={onClose}
            className="rounded-full border border-border bg-input px-3 py-2 text-sm text-foreground transition hover:bg-muted"
            aria-label="Close dialog"
          >
            ×
          </button>
        </div>
        <div>{children}</div>
      </div>
    </div>
  );
}
