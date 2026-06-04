
interface CommandProps {
  placeholder?: string;
  value?: string;
  onChange?: (value: string) => void;
}

export default function Command({ placeholder = 'Search...', value, onChange }: CommandProps) {
  return (
    <div className="rounded-2xl border border-slate-200 bg-white px-4 py-3 shadow-sm">
      <input
        type="search"
        value={value}
        onChange={(event) => onChange?.(event.target.value)}
        placeholder={placeholder}
        className="w-full bg-transparent text-sm text-slate-900 outline-none"
      />
    </div>
  );
}
