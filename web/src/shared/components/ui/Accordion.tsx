import React, { useState } from 'react';

interface AccordionProps {
  title: string;
  children: React.ReactNode;
  defaultOpen?: boolean;
}

export default function Accordion({ title, children, defaultOpen = false }: AccordionProps) {
  const [open, setOpen] = useState(defaultOpen);

  return (
    <div className="rounded-2xl border border-slate-200 bg-white shadow-sm">
      <button
        type="button"
        onClick={() => setOpen((current) => !current)}
        className="flex w-full items-center justify-between px-4 py-3 text-left text-sm font-medium text-slate-900"
      >
        <span>{title}</span>
        <span>{open ? '−' : '+'}</span>
      </button>
      {open ? <div className="px-4 pb-4 text-sm text-slate-600">{children}</div> : null}
    </div>
  );
}
