
interface ToggleGroupProps {
  options: { label: string; value: string }[];
  value: string;
  onChange: (value: string) => void;
}

export default function ToggleGroup({ options, value, onChange }: ToggleGroupProps) {
  return (
    <div className="inline-flex rounded-full border border-slate-200 bg-slate-100 p-1">
      {options.map((option) => (
        <button
          key={option.value}
          type="button"
          onClick={() => onChange(option.value)}
          className={`rounded-full px-4 py-2 text-sm ${value === option.value ? 'bg-white text-slate-900 shadow-sm' : 'text-slate-600 hover:bg-slate-200'}`}
        >
          {option.label}
        </button>
      ))}
    </div>
  );
}
