
interface RadioGroupOption {
  label: string;
  value: string;
}

interface RadioGroupProps {
  options: RadioGroupOption[];
  value: string;
  onChange: (value: string) => void;
}

export default function RadioGroup({ options, value, onChange }: RadioGroupProps) {
  return (
    <div className="flex flex-wrap gap-3">
      {options.map((option) => (
        <label key={option.value} className="inline-flex items-center gap-2 rounded-xl border border-slate-200 bg-white px-3 py-2 text-sm text-slate-700 shadow-sm">
          <input
            type="radio"
            name="radio-group"
            checked={value === option.value}
            onChange={() => onChange(option.value)}
            className="h-4 w-4 text-blue-600"
          />
          {option.label}
        </label>
      ))}
    </div>
  );
}
