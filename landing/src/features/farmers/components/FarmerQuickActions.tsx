import { BarChart3, ClipboardList, Package, Plus } from "lucide-react";
import { Link } from "react-router-dom";

export function FarmerQuickActions() {
  const actions = [
    { label: "Add product", href: "/app/farmer/products/new", icon: Plus },
    { label: "Manage products", href: "/app/farmer/products", icon: Package },
    { label: "View orders", href: "/app/farmer/orders", icon: ClipboardList },
    { label: "View earnings", href: "/app/farmer/earnings", icon: BarChart3 },
  ];
  return (
    <section>
      <p className="text-xs font-bold uppercase tracking-[0.16em] text-primary">Quick actions</p>
      <div className="mt-3 grid grid-cols-2 gap-2 sm:grid-cols-4 sm:gap-3">
        {actions.map(({ label, href, icon: Icon }) => (
          <Link
            key={label}
            to={href}
            className="flex min-h-16 items-center gap-2 rounded-xl border border-border bg-card p-3 text-xs font-semibold text-primary-dark transition hover:border-primary/30 hover:bg-muted sm:min-h-20 sm:gap-3 sm:rounded-2xl sm:p-4 sm:text-sm"
          >
            <Icon className="h-5 w-5 shrink-0 text-primary" />
            {label}
          </Link>
        ))}
      </div>
    </section>
  );
}
