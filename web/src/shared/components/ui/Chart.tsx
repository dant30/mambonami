import React from 'react';

interface ChartProps {
  title?: string;
  children: React.ReactNode;
}

export default function Chart({ title, children }: ChartProps) {
  return (
    <div className="rounded-3xl border border-slate-200 bg-white p-4 shadow-sm">
      {title ? <h3 className="mb-3 text-base font-semibold text-slate-900">{title}</h3> : null}
      <div className="min-h-[220px]">{children}</div>
    </div>
  );
}
