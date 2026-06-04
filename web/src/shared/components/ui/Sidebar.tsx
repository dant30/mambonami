import React from 'react';

interface SidebarProps extends React.HTMLAttributes<HTMLElement> {}

export default function Sidebar({ className = '', children, ...props }: SidebarProps) {
  return (
    <aside className={`w-72 border-r border-slate-200 bg-white p-4 ${className}`} {...props}>
      {children}
    </aside>
  );
}
