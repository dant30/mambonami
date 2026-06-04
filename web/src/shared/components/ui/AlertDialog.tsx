import React from 'react';

interface AlertDialogProps {
  open: boolean;
  title?: string;
  description?: string;
  onClose: () => void;
  children?: React.ReactNode;
}

export default function AlertDialog({ open, title, description, onClose, children }: AlertDialogProps) {
  if (!open) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-slate-900/50 px-4 py-6">
      <div className="w-full max-w-md rounded-3xl bg-white p-6 shadow-xl">
        {title ? <h2 className="text-lg font-semibold text-slate-900">{title}</h2> : null}
        {description ? <p className="mt-2 text-sm text-slate-600">{description}</p> : null}
        <div className="mt-4">{children}</div>
        <button type="button" onClick={onClose} className="mt-4 rounded-md bg-slate-100 px-4 py-2 text-sm text-slate-900 hover:bg-slate-200">
          Close
        </button>
      </div>
    </div>
  );
}
