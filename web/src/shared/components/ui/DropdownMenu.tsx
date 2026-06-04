import React from 'react';

interface DropdownMenuProps {
  trigger: React.ReactNode;
  content: React.ReactNode;
}

export default function DropdownMenu({ trigger, content }: DropdownMenuProps) {
  return (
    <div className="relative inline-block">
      {trigger}
      <div className="absolute left-0 mt-2 rounded-2xl border border-slate-200 bg-white shadow-lg">
        {content}
      </div>
    </div>
  );
}
