// web/src/shared/components/ui/DropdownMenu.tsx
import React, {
  useState,
  useEffect,
  useRef,
  useCallback,
  ReactNode,
  createContext,
  useContext,
  cloneElement,
} from 'react';
import { cn } from '@/lib/utils';

// ---------- Context ----------
type DropdownContextType = {
  open: boolean;
  setOpen: (open: boolean) => void;
};

const DropdownContext = createContext<DropdownContextType | null>(null);

const useDropdown = () => {
  const context = useContext(DropdownContext);
  if (!context) {
    throw new Error('Dropdown components must be used within a DropdownMenu');
  }
  return context;
};

// ---------- Root ----------
interface DropdownMenuProps {
  children: ReactNode;
  open?: boolean;
  onOpenChange?: (open: boolean) => void;
}

const DropdownMenuRoot = ({ children, open: controlledOpen, onOpenChange }: DropdownMenuProps) => {
  const [internalOpen, setInternalOpen] = useState(false);
  const open = controlledOpen !== undefined ? controlledOpen : internalOpen;
  const setOpen = useCallback(
    (value: boolean) => {
      if (controlledOpen === undefined) {
        setInternalOpen(value);
      }
      onOpenChange?.(value);
    },
    [controlledOpen, onOpenChange]
  );

  const ref = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (ref.current && !ref.current.contains(event.target as Node)) {
        setOpen(false);
      }
    };
    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, [setOpen]);

  useEffect(() => {
    const handleEscape = (event: KeyboardEvent) => {
      if (event.key === 'Escape') {
        setOpen(false);
      }
    };
    document.addEventListener('keydown', handleEscape);
    return () => document.removeEventListener('keydown', handleEscape);
  }, [setOpen]);

  return (
    <DropdownContext.Provider value={{ open, setOpen }}>
      <div ref={ref} className="relative inline-block text-left">
        {children}
      </div>
    </DropdownContext.Provider>
  );
};

// ---------- Trigger ----------
interface DropdownTriggerProps {
  children: ReactNode;
  asChild?: boolean;
}

const DropdownMenuTrigger = ({ children, asChild = false }: DropdownTriggerProps) => {
  const { open, setOpen } = useDropdown();

  const handleClick = () => {
    setOpen(!open);
  };

  if (asChild) {
    return cloneElement(children as React.ReactElement, {
      onClick: handleClick,
      'aria-expanded': open,
    });
  }

  return (
    <button
      type="button"
      onClick={handleClick}
      aria-expanded={open}
      className="inline-flex w-full items-center justify-between rounded-md border border-slate-300 bg-white px-3 py-2 text-sm text-slate-900 shadow-sm hover:bg-slate-50 dark:border-slate-700 dark:bg-slate-950 dark:text-slate-100 dark:hover:bg-slate-800"
    >
      {children}
    </button>
  );
};

// ---------- Content ----------
interface DropdownMenuContentProps {
  children: ReactNode;
  align?: 'start' | 'center' | 'end';
  className?: string;
  side?: 'top' | 'bottom' | 'left' | 'right';
}

const DropdownMenuContent = ({
  children,
  align = 'end',
  className = '',
  side = 'bottom',
}: DropdownMenuContentProps) => {
  const { open, setOpen } = useDropdown();

  if (!open) return null;

  const alignClasses = {
    start: 'left-0',
    center: 'left-1/2 -translate-x-1/2',
    end: 'right-0',
  };

  const sideClasses = {
    top: 'bottom-full mb-2',
    bottom: 'top-full mt-2',
    left: 'right-full mr-2',
    right: 'left-full ml-2',
  };

  return (
    <div
      className={cn(
        'absolute z-50 min-w-[8rem] overflow-hidden rounded-md border border-slate-200 bg-white p-1 text-slate-950 shadow-lg dark:border-slate-800 dark:bg-slate-950 dark:text-slate-50',
        alignClasses[align],
        sideClasses[side],
        className
      )}
      onClick={() => setOpen(false)}
    >
      {children}
    </div>
  );
};

// ---------- Menu Item ----------
interface DropdownMenuItemProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  inset?: boolean;
  onSelect?: () => void;
  asChild?: boolean;
}

const DropdownMenuItem = ({
  className,
  inset = false,
  onSelect,
  children,
  asChild = false,
  ...props
}: DropdownMenuItemProps) => {
  const { setOpen } = useDropdown();

  const handleClick = (e: React.MouseEvent<HTMLButtonElement>) => {
    props.onClick?.(e);
    onSelect?.();
    setOpen(false);
  };

  if (asChild) {
    // For use with Link or other components, we need to pass onClick to child
    const child = children as React.ReactElement;
    return cloneElement(child, {
      onClick: (e: React.MouseEvent) => {
        child.props?.onClick?.(e);
        handleClick(e);
      },
      className: cn(
        'relative flex w-full cursor-default select-none items-center rounded-sm px-2 py-1.5 text-sm outline-none transition-colors hover:bg-slate-100 focus:bg-slate-100 data-[disabled]:pointer-events-none data-[disabled]:opacity-50 dark:hover:bg-slate-800 dark:focus:bg-slate-800',
        inset && 'pl-8',
        className
      ),
    });
  }

  return (
    <button
      className={cn(
        'relative flex w-full cursor-default select-none items-center rounded-sm px-2 py-1.5 text-sm outline-none transition-colors hover:bg-slate-100 focus:bg-slate-100 data-[disabled]:pointer-events-none data-[disabled]:opacity-50 dark:hover:bg-slate-800 dark:focus:bg-slate-800',
        inset && 'pl-8',
        className
      )}
      onClick={handleClick}
      {...props}
    >
      {children}
    </button>
  );
};

// ---------- Label ----------
interface DropdownMenuLabelProps extends React.HTMLAttributes<HTMLDivElement> {
  inset?: boolean;
}

const DropdownMenuLabel = ({ className, inset = false, ...props }: DropdownMenuLabelProps) => (
  <div className={cn('px-2 py-1.5 text-sm font-semibold', inset && 'pl-8', className)} {...props} />
);

// ---------- Separator ----------
const DropdownMenuSeparator = ({ className, ...props }: React.HTMLAttributes<HTMLDivElement>) => (
  <div className={cn('-mx-1 my-1 h-px bg-slate-200 dark:bg-slate-800', className)} {...props} />
);

// ---------- Shortcut ----------
const DropdownMenuShortcut = ({
  className,
  ...props
}: React.HTMLAttributes<HTMLSpanElement>) => (
  <span className={cn('ml-auto text-xs tracking-widest opacity-60', className)} {...props} />
);

// ---------- Simple Dropdown (wrapper) ----------
interface SimpleDropdownProps {
  trigger: ReactNode;
  children: ReactNode;
  align?: 'start' | 'center' | 'end';
  side?: 'top' | 'bottom' | 'left' | 'right';
  open?: boolean;
  onOpenChange?: (open: boolean) => void;
  contentClassName?: string;
}

const Dropdown = ({
  trigger,
  children,
  align = 'end',
  side = 'bottom',
  open,
  onOpenChange,
  contentClassName,
}: SimpleDropdownProps) => {
  return (
    <DropdownMenuRoot open={open} onOpenChange={onOpenChange}>
      <DropdownMenuTrigger asChild>{trigger}</DropdownMenuTrigger>
      <DropdownMenuContent align={align} side={side} className={contentClassName}>
        {children}
      </DropdownMenuContent>
    </DropdownMenuRoot>
  );
};

// ---------- Exports ----------
export {
  DropdownMenuRoot as DropdownMenu,
  DropdownMenuTrigger,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuShortcut,
  Dropdown, // simple wrapper
};