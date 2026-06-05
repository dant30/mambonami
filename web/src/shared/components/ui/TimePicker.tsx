import * as React from 'react';
import * as ReactDOM from 'react-dom';
import { Clock, X } from 'lucide-react';
import { cn } from '../../../lib/utils';
import Input from './Input';

function Portal({ children }: { children: React.ReactNode }) {
  const [mounted, setMounted] = React.useState(false);
  React.useEffect(() => {
    setMounted(true);
  }, []);
  if (!mounted) return null;
  return ReactDOM.createPortal(children, document.body);
}

export const TimePicker = React.forwardRef<HTMLInputElement, React.ComponentProps<typeof Input>>(
  ({ className, value, defaultValue, onChange, ...props }, ref) => {
    const [time, setTime] = React.useState<string>(() => (value as string) || (defaultValue as string) || '');
    const [open, setOpen] = React.useState(false);
    const [panelStyle, setPanelStyle] = React.useState<React.CSSProperties>({});

    const triggerRef = React.useRef<HTMLButtonElement>(null);
    const panelRef = React.useRef<HTMLDivElement>(null);
    const hourScrollRef = React.useRef<HTMLDivElement>(null);
    const minuteScrollRef = React.useRef<HTMLDivElement>(null);
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
      if (value !== undefined) setTime(value as string);
    }, [value]);

    const positionPanel = React.useCallback(() => {
      if (!triggerRef.current) return;
      const rect = triggerRef.current.getBoundingClientRect();
      const PANEL_W = 260;
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
      }
      setOpen((value) => !value);
    };

    const get12hParts = (time24: string) => {
      if (!time24) return { h12: '12', m: '00', ampm: 'AM' };
      const [h24, m] = time24.split(':');
      let hour = parseInt(h24, 10);
      const ampm = hour >= 12 ? 'PM' : 'AM';
      hour = hour % 12;
      if (hour === 0) hour = 12;
      return { h12: String(hour).padStart(2, '0'), m, ampm: ampm as 'AM' | 'PM' };
    };

    const { h12: currentH12, m: currentM, ampm: currentAMPM } = get12hParts(time);

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

      setTimeout(() => {
        if (hourScrollRef.current) {
          const el = hourScrollRef.current.querySelector(`[data-hour="${currentH12}"]`);
          el?.scrollIntoView({ block: 'center', behavior: 'auto' });
        }
        if (minuteScrollRef.current) {
          const el = minuteScrollRef.current.querySelector(`[data-minute="${currentM}"]`);
          el?.scrollIntoView({ block: 'center', behavior: 'auto' });
        }
      }, 50);

      return () => {
        document.removeEventListener('mousedown', close);
        document.removeEventListener('touchstart', close);
        window.removeEventListener('scroll', reposition, true);
        window.removeEventListener('resize', reposition);
      };
    }, [open, positionPanel, currentH12, currentM]);

    const fireChange = (value: string) => {
      if (!hiddenInputRef.current) return;
      const setter = Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype, 'value')?.set;
      setter?.call(hiddenInputRef.current, value);
      hiddenInputRef.current.dispatchEvent(new Event('input', { bubbles: true }));
    };

    const updateTime = (h12: string, m: string, ampm: 'AM' | 'PM') => {
      let hour24 = parseInt(h12, 10);
      if (ampm === 'PM' && hour24 < 12) hour24 += 12;
      if (ampm === 'AM' && hour24 === 12) hour24 = 0;
      const next = `${String(hour24).padStart(2, '0')}:${m}`;
      setTime(next);
      fireChange(next);
    };

    const handleClear = (e: React.MouseEvent) => {
      e.stopPropagation();
      setTime('');
      fireChange('');
    };

    const hours12 = ['12', '01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11'];
    const minutes = Array.from({ length: 60 }, (_, i) => String(i).padStart(2, '0'));

    const displayTime = React.useMemo(() => {
      if (!time) return 'Select time...';
      return `${currentH12}:${currentM} ${currentAMPM}`;
    }, [time, currentH12, currentM, currentAMPM]);

    return (
      <div className={cn('relative w-full', className)}>
        <button
          ref={triggerRef}
          type="button"
          onClick={handleToggle}
          className={cn(
            'flex w-full items-center gap-3 rounded-2xl border px-4 py-3 text-sm font-medium transition duration-200',
            'bg-white text-slate-900 border-slate-200 hover:border-slate-300',
            open && 'ring-4 ring-primary/20 border-primary',
            !time && 'text-slate-400',
          )}
        >
          <Clock size={18} className={cn('shrink-0', time ? 'text-primary' : 'text-slate-400')} />
          <span className="flex-1 text-left truncate">{displayTime}</span>
          {time && (
            <span
              role="button"
              onClick={handleClear}
              className="shrink-0 rounded-full p-1 text-slate-400 hover:bg-slate-100 hover:text-slate-700 transition"
            >
              <X size={14} />
            </span>
          )}
        </button>

        {open && (
          <Portal>
            <div
              ref={panelRef}
              style={panelStyle}
              className={cn('rounded-3xl border border-slate-200 bg-white shadow-xl overflow-hidden')}
            >
              <div className="grid gap-2 border-b border-slate-100 px-4 py-3 bg-slate-50">
                <div className="text-xs font-semibold uppercase tracking-[0.24em] text-slate-500">Hour</div>
                <div className="text-xs font-semibold uppercase tracking-[0.24em] text-slate-500">Minute</div>
                <div className="text-xs font-semibold uppercase tracking-[0.24em] text-slate-500">AM/PM</div>
              </div>
              <div className="flex h-[240px] overflow-hidden">
                <div ref={hourScrollRef} className="flex-1 overflow-y-auto p-2">
                  {hours12.map((h) => (
                    <button
                      key={h}
                      data-hour={h}
                      type="button"
                      onClick={() => updateTime(h, currentM, currentAMPM as 'AM' | 'PM')}
                      className={cn(
                        'mb-2 flex w-full items-center justify-center rounded-2xl py-3 text-sm transition',
                        h === currentH12
                          ? 'bg-primary text-white shadow-lg'
                          : 'text-slate-600 hover:bg-slate-100',
                      )}
                    >
                      {h}
                    </button>
                  ))}
                </div>
                <div ref={minuteScrollRef} className="flex-1 overflow-y-auto p-2 border-l border-slate-100">
                  {minutes.map((m) => (
                    <button
                      key={m}
                      data-minute={m}
                      type="button"
                      onClick={() => updateTime(currentH12, m, currentAMPM as 'AM' | 'PM')}
                      className={cn(
                        'mb-2 flex w-full items-center justify-center rounded-2xl py-3 text-sm transition',
                        m === currentM
                          ? 'bg-primary text-white shadow-lg'
                          : 'text-slate-600 hover:bg-slate-100',
                      )}
                    >
                      {m}
                    </button>
                  ))}
                </div>
                <div className="w-24 border-l border-slate-100 p-2 bg-slate-50">
                  {(['AM', 'PM'] as const).map((period) => (
                    <button
                      key={period}
                      type="button"
                      onClick={() => updateTime(currentH12, currentM, period)}
                      className={cn(
                        'mb-2 flex w-full items-center justify-center rounded-2xl py-3 text-sm font-semibold transition',
                        period === currentAMPM
                          ? 'bg-primary text-white shadow-lg'
                          : 'text-slate-600 hover:bg-slate-100',
                      )}
                    >
                      {period}
                    </button>
                  ))}
                </div>
              </div>
              <div className="flex items-center justify-between gap-2 border-t border-slate-100 bg-slate-50 px-4 py-3">
                <button type="button" onClick={handleClear} className="rounded-2xl px-4 py-2 text-sm text-slate-500 transition hover:bg-slate-100">
                  Clear
                </button>
                <button type="button" onClick={() => setOpen(false)} className="rounded-2xl bg-primary px-4 py-2 text-sm font-semibold text-white transition hover:bg-primary/90">
                  Done
                </button>
              </div>
            </div>
          </Portal>
        )}

        <Input
          type="time"
          ref={setRefs}
          className="sr-only"
          value={time}
          onChange={onChange}
          {...props}
        />
      </div>
    );
  },
);

TimePicker.displayName = 'TimePicker';
export default TimePicker;

