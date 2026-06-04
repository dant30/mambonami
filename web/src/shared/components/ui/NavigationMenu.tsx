
interface NavigationMenuItem {
  label: string;
  href: string;
}

interface NavigationMenuProps {
  items: NavigationMenuItem[];
}

export default function NavigationMenu({ items }: NavigationMenuProps) {
  return (
    <nav className="flex gap-3">
      {items.map((item) => (
        <a key={item.href} href={item.href} className="rounded-full px-3 py-2 text-sm text-slate-700 hover:bg-slate-100">
          {item.label}
        </a>
      ))}
    </nav>
  );
}
