import * as React from 'react';
import * as ReactDOM from 'react-dom';
import { Calendar as CalendarIcon, ChevronDown, ChevronLeft, ChevronRight, X } from 'lucide-react';
import { format, parseISO, isValid, addMonths, subMonths, startOfMonth, endOfMonth, eachDayOfInterval, getDay, isSameMonth, isSameDay, isToday } from 'date-fns';
import { cn } from '../../../lib/utils';
import Input from './Input';

const DAYS = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];
const MONTHS = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];

function buildCalendarGrid(viewDate: Date) {
  const start = startOfMonth(viewDate);
  const end = endOfMonth(viewDate);
  const days = eachDayOfInterval({ start, end });
  const leadingBlanks = getDay(start);
  const trailingBlanks = 6 - getDay(end);
  return { days, leadingBlanks, trailingBlanks };
}

function Portal({ children }: { children: React.ReactNode }) {
  const [mounted, setMounted] = React.useState(false);
  React.useEffect(() => {
    setMounted(true);
  }, []);
  if (!mounted) return null;
  return ReactDOM.createPortal(children, document.body);
}

export const DatePicker = React.forwardRef<HTMLInputElement, React.ComponentProps<typeof Input>>(
  ({ className, value, defaultValue, onChange, ...props }, ref) => {
    const [date, setDate] = React.useState<Date | undefined>(() => {
      const initial = value ?? defaultValue;
      if (!initial) return undefined;
      if (initial instanceof Date) {
        return isValid(initial) ? initial : undefined;
      }
      if (typeof initial === 'string') {
        const parsed = parseISO(initial);
        return isValid(parsed) ? parsed : undefined;
      }
      return undefined;
    });
    const [open, setOpen] = React.useState(false);
    const [viewMode, setViewMode] = React.useState<'days' | 'years'>('days');
    const [viewDate, setViewDate] = React.useState<Date>(date ?? new Date());
    const [panelStyle, setPanelStyle] = React.useState<React.CSSProperties>({});

    const triggerRef = React.useRef<HTMLButtonElement>(null);
    const panelRef = React.useRef<HTMLDivElement>(null);
    const hiddenInputRef = React.useRef<HTMLInputElement | null>(null);

    const setRefs = React.useCallback(
      (node: HTMLInputElement | null) => {
        hiddenInputRef.current = node;
        if (typeof ref === 'function') ref(node);
        else if (ref && 'current' in ref) ref.current = node;
      },
      [ref],
    );

    React.useEffect(() => {
      if (!value) {
        setDate(undefined);
        return;
      }

      let nextDate: Date;
      if (value instanceof Date) {
        nextDate = value;
      } else if (typeof value === 'string') {
        nextDate = parseISO(value);
      } else {
        return;
      }

      if (isValid(nextDate) && nextDate.getTime() !== date?.getTime()) {
        setDate(nextDate);
        setViewDate(nextDate);
      }
    }, [value]);

    const positionPanel = React.useCallback(() => {
      if (!triggerRef.current) return;
      const rect = triggerRef.current.getBoundingClientRect();
      const PANEL_W = 288;
      const PANEL_H = 320;
      const gap = 6;
      const vw = window.innerWidth;
      const vh = window.innerHeight;

      let top: number;
      let bottom: number | undefined;
      if (rect.bottom + gap + PANEL_H > vh && rect.top - gap - PANEL_H > 0) {
        bottom = vh - rect.top + gap;
        top = -9999;
      } else {
        top = rect.bottom + gap;
        bottom = undefined;
      }

      const triggerCenter = rect.left + rect.width / 2;
      let left = triggerCenter - PANEL_W / 2;
      left = Math.max(8, Math.min(left, vw - PANEL_W - 8));

      setPanelStyle({
        position: 'fixed',
        top: bottom !== undefined ? 'auto' : top,
        bottom: bottom !== undefined ? bottom : 'auto',
        left,
        width: PANEL_W,
        zIndex: 9999,
      });
    }, []);

    const handleToggle = () => {
      if (!open) {
        positionPanel();
        setViewDate(date ?? new Date());
        setViewMode('days');
      }
      setOpen((value) => !value);
    };

    React.useEffect(() => {
      if (!open) return;
      const close = (e: MouseEvent | TouchEvent) => {
        if (
          panelRef.current && !panelRef.current.contains(e.target as Node) &&
          triggerRef.current && !triggerRef.current.contains(e.target as Node)
        ) setOpen(false);
      };
      const reposition = () => positionPanel();
      document.addEventListener('mousedown', close);
      document.addEventListener('touchstart', close);
      window.addEventListener('scroll', reposition, true);
      window.addEventListener('resize', reposition);
      return () => {
        document.removeEventListener('mousedown', close);
        document.removeEventListener('touchstart', close);
        window.removeEventListener('scroll', reposition, true);
        window.removeEventListener('resize', reposition);
      };
    }, [open, positionPanel]);

    const fireChange = (dateString: string) => {
      if (!hiddenInputRef.current) return;
      const setter = Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype, 'value')?.set;
      setter?.call(hiddenInputRef.current, dateString);
      hiddenInputRef.current.dispatchEvent(new Event('input', { bubbles: true }));
    };

    const handleDayClick = (day: Date) => {
      setDate(day);
      fireChange(format(day, 'yyyy-MM-dd'));
      setOpen(false);
    };

    const handleClear = (e: React.MouseEvent) => {
      e.stopPropagation();
      setDate(undefined);
      fireChange('');
    };

    const handleYearSelect = (year: number) => {
      const nextDate = new Date(viewDate);
      nextDate.setFullYear(year);
      setViewDate(nextDate);
      setViewMode('days');
    };

    const { days, leadingBlanks, trailingBlanks } = buildCalendarGrid(viewDate);
    const currentYear = viewDate.getFullYear();
    const startYear = currentYear - (currentYear % 12);
    const years = Array.from({ length: 12 }, (_, i) => startYear + i);

    return (
      <div className={cn('relative w-full', className)}>
        <button
          ref={triggerRef}
          type="button"
          onClick={handleToggle}
          className={cn(
            'flex w-full h-11 items-center gap-3 rounded-2xl border px-4 text-sm font-medium transition duration-200',
            'bg-white text-slate-900 border-slate-200 hover:border-slate-300',
            open && 'ring-4 ring-primary/20 border-primary',
            !date && 'text-slate-400',
          )}
        >
          <CalendarIcon size={18} className={cn('shrink-0', date ? 'text-primary' : 'text-slate-400')} />
          <span className="flex-1 text-left truncate">
            {date && isValid(date) ? format(date, 'MMM d, yyyy') : 'Select date...'}
          </span>
          {date && (
            <span
              role="button"
              onClick={handleClear}
              className="shrink-0 rounded-full p-1 text-slate-400 hover:bg-slate-100 hover:text-slate-700 transition"
            >
              <X size={14} />
            </span>
          )}
          <ChevronDown size={16} className={cn('text-slate-400 transition-transform duration-200', open && 'rotate-180')} />
        </button>

        {open && (
          <Portal>
            <div
              ref={panelRef}
              style={panelStyle}
              className={cn(
                'rounded-3xl border border-slate-200 bg-white shadow-xl',
                'overflow-hidden',
              )}
            >
              <div className="flex items-center justify-between gap-2 border-b border-slate-100 px-4 py-3">
                <button
                  type="button"
                  onClick={() => {
                    if (viewMode === 'days') setViewDate(subMonths(viewDate, 1));
                    else setViewDate(new Date(viewDate.getFullYear() - 12, viewDate.getMonth(), 1));
                  }}
                  className="flex h-9 w-9 items-center justify-center rounded-2xl border border-slate-200 text-slate-500 transition hover:bg-slate-100"
                >
                  <ChevronLeft size={18} />
                </button>
                <button
                  type="button"
                  onClick={() => setViewMode(viewMode === 'days' ? 'years' : 'days')}
                  className="rounded-full border border-slate-200 bg-slate-50 px-3 py-2 text-sm font-semibold text-slate-800 transition hover:bg-slate-100"
                >
                  {viewMode === 'days'
                    ? `${MONTHS[viewDate.getMonth()]} ${viewDate.getFullYear()}`
                    : `${years[0]} - ${years[years.length - 1]}`}
                </button>
                <button
                  type="button"
                  onClick={() => {
                    if (viewMode === 'days') setViewDate(addMonths(viewDate, 1));
                    else setViewDate(new Date(viewDate.getFullYear() + 12, viewDate.getMonth(), 1));
                  }}
                  className="flex h-9 w-9 items-center justify-center rounded-2xl border border-slate-200 text-slate-500 transition hover:bg-slate-100"
                >
                  <ChevronRight size={18} />
                </button>
              </div>

              <div className="p-4">
                {viewMode === 'days' ? (
                  <>
                    <div className="grid grid-cols-7 gap-1 text-[11px] font-semibold uppercase tracking-[0.18em] text-slate-400">
                      {DAYS.map((day) => (
                        <div key={day} className="flex h-8 items-center justify-center">
                          {day}
                        </div>
                      ))}
                    </div>
                    <div className="grid grid-cols-7 gap-1">
                      {Array.from({ length: leadingBlanks }).map((_, index) => (
                        <div key={`blank-${index}`} className="h-10" />
                      ))}
                      {days.map((day) => {
                        const selected = date ? isSameDay(day, date) : false;
                        const current = isToday(day);
                        const inMonth = isSameMonth(day, viewDate);
                        return (
                          <button
                            key={day.toISOString()}
                            type="button"
                            onClick={() => handleDayClick(day)}
                            className={cn(
                              'flex h-10 w-full items-center justify-center rounded-2xl text-sm transition',
                              inMonth ? 'text-slate-900 hover:bg-primary/10' : 'text-slate-300',
                              selected ? 'bg-primary text-white shadow-sm' : current ? 'bg-slate-100 text-slate-900' : 'bg-transparent',
                            )}
                          >
                            {day.getDate()}
                          </button>
                        );
                      })}
                      {Array.from({ length: trailingBlanks }).map((_, index) => (
                        <div key={`blank-end-${index}`} className="h-10" />
                      ))}
                    </div>
                  </>
                ) : (
                  <div className="grid grid-cols-3 gap-2">
                    {years.map((year) => (
                      <button
                        key={year}
                        type="button"
                        onClick={() => handleYearSelect(year)}
                        className={cn(
                          'flex h-12 items-center justify-center rounded-2xl text-sm font-semibold transition',
                          year === viewDate.getFullYear()
                            ? 'bg-primary text-white shadow-sm'
                            : 'text-slate-700 hover:bg-slate-100',
                        )}
                      >
                        {year}
                      </button>
                    ))}
                  </div>
                )}
              </div>

              <div className="flex items-center justify-between gap-3 border-t border-slate-100 bg-slate-50 px-4 py-3">
                <button
                  type="button"
                  onClick={handleClear}
                  className="text-sm text-slate-500 hover:text-slate-700"
                >
                  Clear
                </button>
                <button
                  type="button"
                  onClick={() => {
                    const today = new Date();
                    handleDayClick(today);
                  }}
                  className="rounded-2xl bg-primary px-4 py-2 text-sm font-semibold text-white transition hover:bg-primary/90"
                >
                  Today
                </button>
              </div>
            </div>
          </Portal>
        )}

        <Input
          type="date"
          ref={setRefs}
          className="sr-only"
          value={date && isValid(date) ? format(date, 'yyyy-MM-dd') : ''}
          onChange={onChange}
          {...props}
        />
      </div>
    );
  },
);

DatePicker.displayName = 'DatePicker';
export default DatePicker;

