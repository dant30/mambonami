import React from 'react';

interface SheetProps {
  open: boolean;
  onClose: () => void;
  children: React.ReactNode;
}

export default function Sheet({ open, onClose, children }: SheetProps) {
  if (!open) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-end bg-slate-900/40 p-4 sm:items-center sm:justify-center">
      <div className="w-full max-w-xl rounded-t-3xl bg-white p-6 shadow-xl sm:rounded-3xl">
        <button type="button" onClick={onClose} className="mb-4 text-slate-500 hover:text-slate-900">
          Close
        </button>
        {children}
      </div>
    </div>
  );
}
