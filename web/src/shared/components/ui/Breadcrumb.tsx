
interface BreadcrumbItem {
  label: string;
  href?: string;
}

interface BreadcrumbProps {
  items: BreadcrumbItem[];
}

export default function Breadcrumb({ items }: BreadcrumbProps) {
  return (
    <nav aria-label="Breadcrumb" className="text-sm text-slate-600">
      <ol className="flex items-center gap-2">
        {items.map((item, index) => (
          <li key={item.label} className="inline-flex items-center gap-2">
            {item.href ? (
              <a href={item.href} className="text-slate-600 hover:text-slate-900">
                {item.label}
              </a>
            ) : (
              <span className="text-slate-900">{item.label}</span>
            )}
            {index < items.length - 1 ? <span className="text-slate-400">/</span> : null}
          </li>
        ))}
      </ol>
    </nav>
  );
}
