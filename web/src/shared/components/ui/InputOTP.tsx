
interface InputOTPProps {
  length?: number;
  value: string[];
  onChange: (value: string[]) => void;
}

export default function InputOTP({ length = 4, value, onChange }: InputOTPProps) {
  const handleChange = (index: number, nextValue: string) => {
    const next = [...value];
    next[index] = nextValue.slice(-1);
    onChange(next);
  };

  return (
    <div className="flex gap-2">
      {Array.from({ length }, (_, idx) => (
        <input
          key={idx}
          type="text"
          inputMode="numeric"
          maxLength={1}
          value={value[idx] ?? ''}
          onChange={(event) => handleChange(idx, event.target.value)}
          className="h-12 w-12 rounded-xl border border-slate-300 text-center text-lg focus:border-blue-500 focus:outline-none focus:ring-1 focus:ring-blue-500"
        />
      ))}
    </div>
  );
}
