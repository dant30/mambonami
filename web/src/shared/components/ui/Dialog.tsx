import React from 'react';

interface DialogProps {
  open: boolean;
  title?: string;
  onClose: () => void;
  children: React.ReactNode;
}

export default function Dialog({ open, title, onClose, children }: DialogProps) {
  if (!open) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-slate-900/50 p-4">
      <div className="w-full max-w-lg rounded-3xl bg-white p-6 shadow-xl">
        <div className="mb-4 flex items-center justify-between">
          {title ? <h2 className="text-lg font-semibold text-slate-900">{title}</h2> : null}
          <button type="button" onClick={onClose} className="text-slate-500 hover:text-slate-900">
            ×
          </button>
        </div>
        <div>{children}</div>
      </div>
    </div>
  );
}
