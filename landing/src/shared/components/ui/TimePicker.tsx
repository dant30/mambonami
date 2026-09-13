import React, { useState, useRef, useEffect } from 'react';
import { Clock, Check, Sparkles, Moon, Sun, Sunset } from 'lucide-react';

interface TimePickerProps {
  label?: string;
  value: string; // e.g. "06:00 PM – 02:00 AM (Night Rush)"
  onChange: (timeStr: string) => void;
  required?: boolean;
  className?: string;
  helperText?: string;
}

export const TimePicker: React.FC<TimePickerProps> = ({
  label,
  value,
  onChange,
  required = false,
  className = '',
  helperText,
}) => {
  const [isOpen, setIsOpen] = useState(false);
  const containerRef = useRef<HTMLDivElement>(null);

  const [startTime, setStartTime] = useState('18:00');
  const [endTime, setEndTime] = useState('02:00');
  const [customShiftLabel, setCustomShiftLabel] = useState('Evening Rush');

  // Common Kenyan Hospitality & Casual Shift Presets
  const presets = [
    {
      title: '24-Hour Round-the-Clock Shift',
      time: '12:00 AM – 11:59 PM (24 hrs)',
      tag: '24hr Venue / Security / Care',
      icon: <Sparkles className="w-3.5 h-3.5 text-indigo-600" />
    },
    {
      title: 'Evening & Night Shift',
      time: '6:00 PM – 2:00 AM',
      tag: 'Peak Club / Bar',
      icon: <Moon className="w-3.5 h-3.5 text-indigo-500" />
    },
    {
      title: 'Full Day Permanent Shift',
      time: '8:00 AM – 5:00 PM',
      tag: 'Standard Hotel / Cafe',
      icon: <Sun className="w-3.5 h-3.5 text-amber-500" />
    },
    {
      title: 'Afternoon & Happy Hour',
      time: '2:00 PM – 10:00 PM',
      tag: 'Lounge / Restaurant',
      icon: <Sunset className="w-3.5 h-3.5 text-[#FF6B00]" />
    },
    {
      title: 'Late Night Graveyard',
      time: '10:00 PM – 6:00 AM',
      tag: 'Overnight Security / Steward',
      icon: <Moon className="w-3.5 h-3.5 text-slate-600" />
    },
    {
      title: 'Morning Breakfast Shift',
      time: '6:00 AM – 2:00 PM',
      tag: 'Bakery / Barista / Kitchen',
      icon: <Sun className="w-3.5 h-3.5 text-emerald-500" />
    },
    {
      title: 'Weekend Double Rush',
      time: '12:00 PM – 12:00 AM (12 hrs)',
      tag: 'Weekend Event',
      icon: <Sparkles className="w-3.5 h-3.5 text-rose-500" />
    }
  ];

  // Click outside to close
  useEffect(() => {
    const handleClickOutside = (e: MouseEvent) => {
      if (containerRef.current && !containerRef.current.contains(e.target as Node)) {
        setIsOpen(false);
      }
    };
    if (isOpen) {
      document.addEventListener('mousedown', handleClickOutside);
    }
    return () => {
      document.removeEventListener('mousedown', handleClickOutside);
    };
  }, [isOpen]);

  const handleApplyCustom = () => {
    const formatTime12h = (t: string) => {
      const [h, m] = t.split(':').map(Number);
      const period = h >= 12 ? 'PM' : 'AM';
      const h12 = h % 12 || 12;
      return `${h12}:${String(m).padStart(2, '0')} ${period}`;
    };

    const formatted = `${formatTime12h(startTime)} – ${formatTime12h(endTime)}${customShiftLabel ? ` (${customShiftLabel})` : ''}`;
    onChange(formatted);
    setIsOpen(false);
  };

  return (
    <div className={`relative space-y-1 ${className}`} ref={containerRef}>
      {label && (
        <label className="block text-xs font-bold text-slate-700 uppercase tracking-wider">
          {label} {required && <span className="text-[#FF6B00]">*</span>}
        </label>
      )}

      {/* Input Trigger */}
      <div
        onClick={() => setIsOpen(!isOpen)}
        className="w-full flex items-center justify-between px-3.5 py-2.5 bg-slate-50 border border-slate-300 hover:border-slate-400 rounded-xl text-sm cursor-pointer transition focus-within:ring-2 focus-within:ring-[#0A2540]/20 bg-white"
      >
        <div className="flex items-center gap-2.5 text-slate-800 font-medium truncate">
          <Clock className="w-4 h-4 text-[#FF6B00] shrink-0" />
          <span className="font-semibold text-slate-900 truncate">
            {value || 'Select Shift Schedule & Hours'}
          </span>
        </div>

        <span className="text-[10px] font-bold uppercase tracking-wider bg-slate-100 text-slate-600 px-1.5 py-0.5 rounded shrink-0">
          Set Hours
        </span>
      </div>

      {helperText && (
        <p className="text-[11px] text-slate-500">{helperText}</p>
      )}

      {/* Popover Dropdown */}
      {isOpen && (
        <div className="absolute top-full left-0 mt-1.5 z-50 bg-white rounded-2xl shadow-2xl border border-slate-200 p-4 w-80 sm:w-96 animate-fade-in divide-y divide-slate-100">
          
          {/* Quick Presets List */}
          <div className="pb-3 space-y-1.5">
            <div className="flex items-center justify-between mb-2">
              <span className="text-[11px] font-bold uppercase tracking-wider text-slate-400">
                Common Hospitality Shifts
              </span>
              <span className="text-[10px] text-emerald-600 font-bold bg-emerald-50 px-1.5 py-0.5 rounded">
                Quick Select
              </span>
            </div>

            <div className="grid grid-cols-1 gap-1.5 max-h-48 overflow-y-auto pr-1">
              {presets.map((preset, idx) => {
                const isSelected = value?.includes(preset.time);
                return (
                  <button
                    key={idx}
                    type="button"
                    onClick={() => {
                      onChange(`${preset.time} (${preset.title})`);
                      setIsOpen(false);
                    }}
                    className={`flex items-center justify-between p-2 rounded-xl text-left transition border ${
                      isSelected
                        ? 'bg-orange-50 border-[#FF6B00] text-[#0A2540]'
                        : 'bg-slate-50/70 border-slate-200/80 hover:bg-slate-100 text-slate-800'
                    }`}
                  >
                    <div className="flex items-center gap-2">
                      <div className="w-6 h-6 rounded-lg bg-white shadow-xs flex items-center justify-center shrink-0">
                        {preset.icon}
                      </div>
                      <div>
                        <p className="text-xs font-bold text-slate-900 leading-tight">{preset.title}</p>
                        <p className="text-[11px] text-slate-500 font-medium">{preset.time}</p>
                      </div>
                    </div>

                    <div className="flex items-center gap-1.5">
                      <span className="text-[10px] bg-slate-200 text-slate-700 px-1.5 py-0.5 rounded font-medium">
                        {preset.tag}
                      </span>
                      {isSelected && <Check className="w-3.5 h-3.5 text-[#FF6B00]" />}
                    </div>
                  </button>
                );
              })}
            </div>
          </div>

          {/* Custom Time Spinner */}
          <div className="pt-3 space-y-3">
            <span className="text-[11px] font-bold uppercase tracking-wider text-slate-400 block">
              Or Customize Shift Timing
            </span>

            <div className="grid grid-cols-2 gap-2 text-xs">
              <div>
                <label className="text-[10px] font-bold text-slate-500 block mb-1">Start Time</label>
                <input
                  type="time"
                  value={startTime}
                  onChange={(e) => setStartTime(e.target.value)}
                  className="w-full px-2.5 py-1.5 bg-slate-50 border border-slate-300 rounded-lg text-xs font-bold text-slate-800 focus:bg-white"
                />
              </div>
              <div>
                <label className="text-[10px] font-bold text-slate-500 block mb-1">End Time</label>
                <input
                  type="time"
                  value={endTime}
                  onChange={(e) => setEndTime(e.target.value)}
                  className="w-full px-2.5 py-1.5 bg-slate-50 border border-slate-300 rounded-lg text-xs font-bold text-slate-800 focus:bg-white"
                />
              </div>
            </div>

            <div>
              <label className="text-[10px] font-bold text-slate-500 block mb-1">Shift Label (Optional)</label>
              <input
                type="text"
                placeholder="e.g. Saturday Rush / Overtime"
                value={customShiftLabel}
                onChange={(e) => setCustomShiftLabel(e.target.value)}
                className="w-full px-2.5 py-1.5 bg-slate-50 border border-slate-300 rounded-lg text-xs font-medium text-slate-800 focus:bg-white"
              />
            </div>

            <div className="flex gap-2">
              <button
                type="button"
                onClick={() => setIsOpen(false)}
                className="w-1/3 py-1.5 border border-slate-300 text-slate-600 rounded-lg text-xs font-semibold hover:bg-slate-50"
              >
                Cancel
              </button>
              <button
                type="button"
                onClick={handleApplyCustom}
                className="w-2/3 py-1.5 bg-[#0A2540] hover:bg-[#061B2E] text-white rounded-lg text-xs font-bold transition shadow-xs"
              >
                Apply Custom Hours
              </button>
            </div>
          </div>

        </div>
      )}
    </div>
  );
};
