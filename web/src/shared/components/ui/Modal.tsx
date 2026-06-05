import type { KeyboardEvent, MouseEvent, PropsWithChildren, ReactNode } from 'react';
import { createPortal } from 'react-dom';
import { X } from 'lucide-react';
import Button from './Button';
import { cn } from '../../../lib/utils';

export interface ModalProps {
  children: ReactNode;
  isOpen: boolean;
  onClose: () => void;
  title?: string;
  size?: 'sm' | 'md' | 'lg' | 'xl' | '2xl' | '3xl' | '4xl' | '5xl' | 'full';
  closeOnBackdrop?: boolean;
  closeOnEscape?: boolean;
  showCloseButton?: boolean;
}

const sizeClasses = {
  sm: 'max-w-sm',
  md: 'max-w-md',
  lg: 'max-w-lg',
  xl: 'max-w-xl',
  '2xl': 'max-w-2xl',
  '3xl': 'max-w-3xl',
  '4xl': 'max-w-4xl',
  '5xl': 'max-w-5xl',
  full: 'max-w-full mx-4',
};

export function Modal({
  children,
  isOpen,
  onClose,
  title,
  size = 'md',
  closeOnBackdrop = true,
  closeOnEscape = true,
  showCloseButton = true,
}: ModalProps) {
  if (!isOpen) return null;

  const handleBackdropClick = (e: MouseEvent<HTMLDivElement>) => {
    if (e.target === e.currentTarget && closeOnBackdrop) {
      onClose();
    }
  };

  const handleKeyDown = (e: KeyboardEvent<HTMLDivElement>) => {
    if (e.key === 'Escape' && closeOnEscape) {
      onClose();
    }
  };

  const modalContent = (
    <div
      className="fixed inset-0 z-50 flex items-center justify-center bg-slate-900/50 p-6"
      onClick={handleBackdropClick}
      onKeyDown={handleKeyDown}
      role="dialog"
      aria-modal="true"
      aria-labelledby={title ? 'modal-title' : undefined}
    >
      <div className={cn('w-full overflow-hidden rounded-[28px] bg-white shadow-xl ring-1 ring-black/5', sizeClasses[size])}>
        {(title || showCloseButton) && (
          <div className="flex items-center justify-between border-b border-slate-200/80 bg-slate-50 px-8 py-5 dark:border-slate-800 dark:bg-slate-900/70">
            {title && (
              <h2 id="modal-title" className="text-xl font-semibold text-slate-900 dark:text-slate-100">
                {title}
              </h2>
            )}
            {showCloseButton && (
              <Button
                aria-label="Close modal"
                className="h-9 w-9 rounded-2xl p-0 text-slate-500 hover:bg-slate-100 dark:hover:bg-slate-800"
                onClick={onClose}
                size="sm"
                variant="ghost"
              >
                <X className="h-4 w-4" />
              </Button>
            )}
          </div>
        )}

        <div className="max-h-[80vh] overflow-y-auto px-8 py-6 sm:px-10 sm:py-8">
          {children}
        </div>
      </div>
    </div>
  );

  return createPortal(modalContent, document.body);
}

export function ModalHeader({ children, className, ...props }: PropsWithChildren<{ className?: string }>) {
  return (
    <div
      className={cn('flex items-center justify-between border-b border-slate-200/80 bg-slate-50/80 px-8 py-5 dark:border-slate-800 dark:bg-slate-900/70 sm:px-10 sm:py-6', className)}
      {...props}
    >
      {children}
    </div>
  );
}

export function ModalBody({ children, className, ...props }: PropsWithChildren<{ className?: string }>) {
  return (
    <div className={cn('px-8 py-6 sm:px-10 sm:py-8', className)} {...props}>
      {children}
    </div>
  );
}

export function ModalFooter({ children, className, ...props }: PropsWithChildren<{ className?: string }>) {
  return (
    <div className={cn('flex items-center justify-end gap-3 border-t border-slate-200/80 bg-slate-50/70 px-8 py-5 dark:border-slate-800 dark:bg-slate-900/70 sm:px-10 sm:py-6', className)} {...props}>
      {children}
    </div>
  );
}

