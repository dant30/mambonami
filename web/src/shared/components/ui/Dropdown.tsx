import React, { useEffect, useRef, useState } from 'react';

interface DropdownProps {
  label: React.ReactNode;
  children: React.ReactNode;
  className?: string;
}

export default function Dropdown({ label, children, className = '' }: DropdownProps) {
  const [open, setOpen] = useState(false);
  const ref = useRef<HTMLDivElement | null>(null);

  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (ref.current && !ref.current.contains(event.target as Node)) {
        setOpen(false);
      }
    };
    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  return (
    <div ref={ref} className={`relative inline-block text-left ${className}`}>
      <button
        type="button"
        onClick={() => setOpen((current) => !current)}
        className="inline-flex w-full items-center justify-between rounded-md border border-slate-300 bg-white px-3 py-2 text-sm text-slate-900 shadow-sm hover:bg-slate-50"
      >
        {label}
        <span className="ml-2">▼</span>
      </button>
      {open ? (
        <div className="absolute left-0 z-20 mt-2 w-56 rounded-md border border-slate-200 bg-white shadow-lg">
          <div className="py-1">{children}</div>
        </div>
      ) : null}
    </div>
  );
}

