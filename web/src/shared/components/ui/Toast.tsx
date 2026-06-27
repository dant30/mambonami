
interface ToastProps {
  message: string;
  type?: 'info' | 'success' | 'warning' | 'error';
  title?: string;
  onClose?: () => void;
}

const toastStyles = {
  info: 'bg-slate-800 text-white',
  success: 'bg-emerald-600 text-white',
  warning: 'bg-amber-500 text-slate-900',
  error: 'bg-rose-600 text-white',
};

export default function Toast({ message, type = 'info', title, onClose }: ToastProps) {
  return (
    <div className={`pointer-events-auto rounded-xl px-4 py-3 shadow-lg ${toastStyles[type]}`}>
      <div className="flex items-start justify-between gap-4">
        <div className="space-y-1">
          {title ? <p className="text-sm font-semibold">{title}</p> : null}
          <p className="text-sm">{message}</p>
        </div>
        {onClose ? (
          <button type="button" onClick={onClose} className="text-sm font-semibold opacity-80 hover:opacity-100">
            Close
          </button>
        ) : null}
      </div>
    </div>
  );
}

