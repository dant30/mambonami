import React from 'react';

interface PopoverProps {
  content: React.ReactNode;
  children: React.ReactNode;
}

export default function Popover({ content, children }: PopoverProps) {
  return (
    <div className="group relative inline-flex">
      {children}
      <div className="invisible absolute left-1/2 top-full z-10 mt-2 w-max -translate-x-1/2 rounded-xl border border-slate-200 bg-white p-3 text-sm text-slate-700 shadow-lg transition-opacity duration-150 group-hover:visible group-hover:opacity-100">
        {content}
      </div>
    </div>
  );
}
