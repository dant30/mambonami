import React from 'react';

interface HoverCardProps {
  content: React.ReactNode;
  children: React.ReactNode;
}

export default function HoverCard({ content, children }: HoverCardProps) {
  return (
    <div className="group relative inline-flex">
      {children}
      <div className="pointer-events-none invisible absolute left-1/2 top-full z-10 mt-2 -translate-x-1/2 whitespace-nowrap rounded-md bg-slate-900 px-3 py-2 text-xs text-white opacity-0 transition-opacity duration-150 group-hover:visible group-hover:opacity-100">
        {content}
      </div>
    </div>
  );
}
