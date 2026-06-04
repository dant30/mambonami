import React from 'react';

interface DrawerProps {
  open: boolean;
  side?: 'left' | 'right';
  onClose: () => void;
  children: React.ReactNode;
}

export default function Drawer({ open, side = 'right', onClose, children }: DrawerProps) {
  if (!open) return null;

  return (
    <div className="fixed inset-0 z-50 flex bg-slate-900/50">
      <div className={`h-full w-full ${side === 'left' ? 'justify-start' : 'justify-end'} flex`}> 
        <div className="h-full w-full max-w-md bg-white p-6 shadow-xl">
          <button type="button" onClick={onClose} className="mb-4 text-slate-500 hover:text-slate-900">
            Close
          </button>
          {children}
        </div>
      </div>
    </div>
  );
}
