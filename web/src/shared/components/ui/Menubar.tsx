// web/src/shared/components/ui/Menubar.tsx
import React from 'react';

interface MenubarProps {
  children: React.ReactNode;
}

export default function Menubar({ children }: MenubarProps) {
  return <div className="flex items-center gap-2 rounded-2xl border border-slate-200 bg-white px-3 py-2 shadow-sm">{children}</div>;
}
