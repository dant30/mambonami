
interface TabItem {
  label: string;
  value: string;
}

interface TabsProps {
  items: TabItem[];
  activeValue: string;
  onChange: (value: string) => void;
}

export default function Tabs({ items, activeValue, onChange }: TabsProps) {
  return (
    <div className="flex flex-wrap gap-2">
      {items.map((item) => (
        <button
          key={item.value}
          type="button"
          onClick={() => onChange(item.value)}
          className={`rounded-full px-4 py-2 text-sm transition ${item.value === activeValue ? 'bg-blue-600 text-white' : 'bg-slate-100 text-slate-700 hover:bg-slate-200'}`}
        >
          {item.label}
        </button>
      ))}
    </div>
  );
}

