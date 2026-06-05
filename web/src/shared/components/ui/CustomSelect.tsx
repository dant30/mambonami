import * as React from 'react';
import * as ReactDOM from 'react-dom';
import { ChevronDown } from 'lucide-react';
import { cn } from '../../../lib/utils';

interface Option {
  id: string | number;
  label: string;
  subtitle?: string;
}

interface CustomSelectProps {
  options: Option[];
  value: string | number;
  onChange: (value: string) => void;
  placeholder?: string;
  label?: string;
  error?: string;
  className?: string;
  icon?: React.ReactNode;
  size?: 'sm' | 'md';
}

function Portal({ children }: { children: React.ReactNode }) {
  const [mounted, setMounted] = React.useState(false);

  React.useEffect(() => {
    setMounted(true);
  }, []);

  if (!mounted) return null;
  return ReactDOM.createPortal(children, document.body);
}

function SelectOptionsPanel({
  open,
  options,
  panelStyle,
  panelRef,
  onSelect,
}: {
  open: boolean;
  options: Option[];
  panelStyle: React.CSSProperties;
  panelRef: React.RefObject<HTMLDivElement>;
  onSelect: (value: string) => void;
}) {
  if (!open) return null;

  return (
    <Portal>
      <div
        ref={panelRef}
        style={panelStyle}
        className="overflow-hidden rounded-3xl bg-white shadow-[0_20px_50px_rgba(0,0,0,0.15)] ring-1 ring-black/5 focus:outline-none"
      >
        <div className="max-h-64 overflow-y-auto py-1">
          <div className="divide-y divide-slate-100">
            {options.map((option) => (
              <button
                key={option.id}
                type="button"
                onMouseDown={(event) => {
                  event.preventDefault();
                  event.stopPropagation();
                  onSelect(String(option.id));
                }}
                className="group relative w-full cursor-pointer select-none rounded-none border-transparent px-4 py-3 text-left text-sm transition duration-150 hover:bg-slate-50"
              >
                <div className="flex flex-col gap-0.5">
                  <span className="block truncate font-medium text-slate-800 transition group-hover:text-brand-600">
                    {option.label}
                  </span>
                  {option.subtitle && (
                    <span className="text-[11px] uppercase tracking-[0.24em] text-slate-400">
                      {option.subtitle}
                    </span>
                  )}
                </div>
              </button>
            ))}
          </div>
        </div>
      </div>
    </Portal>
  );
}

export function CustomSelect({
  options,
  value,
  onChange,
  placeholder = 'Select an option',
  label,
  error,
  icon,
  size = 'md',
  className,
}: CustomSelectProps) {
  const selectedOption = options.find((opt) => String(opt.id) === String(value));
  const [open, setOpen] = React.useState(false);
  const [panelStyle, setPanelStyle] = React.useState<React.CSSProperties>({});
  const wrapRef = React.useRef<HTMLDivElement>(null);
  const panelRef = React.useRef<HTMLDivElement>(null);

  const positionPanel = React.useCallback(() => {
    if (!wrapRef.current) return;

    const rect = wrapRef.current.getBoundingClientRect();
    const gap = 8;
    const vw = window.innerWidth;
    const vh = window.innerHeight;
    const panelWidth = Math.min(Math.max(rect.width, 280), vw - 16);
    const preferAbove = rect.bottom + 320 > vh && rect.top > 320;
    const left = Math.max(8, Math.min(rect.left, vw - panelWidth - 8));

    setPanelStyle({
      position: 'fixed',
      top: preferAbove ? 'auto' : rect.bottom + gap,
      bottom: preferAbove ? vh - rect.top + gap : 'auto',
      left,
      width: panelWidth,
      zIndex: 9999,
    });
  }, []);

  React.useEffect(() => {
    if (!open) return undefined;

    positionPanel();

    const handleClose = (event: MouseEvent) => {
      const target = event.target as Node;
      if (wrapRef.current && wrapRef.current.contains(target)) return;
      if (panelRef.current && panelRef.current.contains(target)) return;
      setOpen(false);
    };

    const handleReposition = () => positionPanel();

    document.addEventListener('mousedown', handleClose);
    window.addEventListener('scroll', handleReposition, true);
    window.addEventListener('resize', handleReposition);

    return () => {
      document.removeEventListener('mousedown', handleClose);
      window.removeEventListener('scroll', handleReposition, true);
      window.removeEventListener('resize', handleReposition);
    };
  }, [open, positionPanel]);

  const selectOption = (selectedValue: string) => {
    onChange(selectedValue);
    setOpen(false);
  };

  return (
    <div className="w-full">
      <div ref={wrapRef} className="relative mt-1">
        {label && <span className="form-label mb-1.5 block">{label}</span>}
        <button
          type="button"
          onClick={() => {
            if (!open) {
              positionPanel();
            }
            setOpen((prev) => !prev);
          }}
          className={cn(
            'relative flex w-full items-center justify-between rounded-2xl border bg-white px-4 text-left shadow-sm transition duration-200 focus:outline-none',
            size === 'sm' ? 'h-10 text-sm' : 'h-12 text-base',
            'border-slate-200 hover:border-slate-300 hover:bg-slate-50 focus:border-primary focus:ring-2 focus:ring-primary/10',
            className,
          )}
        >
          <div className="flex min-w-0 items-center gap-3">
            {icon && selectedOption && (
              <div className="flex h-8 w-8 items-center justify-center rounded-full bg-primary/10 text-primary">
                {icon}
              </div>
            )}
            <span className={cn('block min-w-0 truncate', !selectedOption && 'text-slate-400')}>{selectedOption ? selectedOption.label : placeholder}</span>
          </div>
          <ChevronDown className={cn('h-4 w-4 text-slate-400 transition-transform duration-200', open && 'rotate-180')} />
        </button>

        <SelectOptionsPanel open={open} options={options} panelStyle={panelStyle} panelRef={panelRef} onSelect={selectOption} />
      </div>
      {error && <p className="form-error mt-1.5 text-sm text-rose-600">{error}</p>}
    </div>
  );
}
