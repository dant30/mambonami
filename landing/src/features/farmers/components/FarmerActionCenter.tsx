import { AlertTriangle, ArrowRight, ClipboardList, Package } from "lucide-react";
import { Link } from "react-router-dom";

import type { FarmerDashboardSummary, Product } from "../../../core/lib";

export function FarmerActionCenter({
  summary,
  products,
  isLoading,
}: {
  summary: FarmerDashboardSummary | null;
  products: Product[];
  isLoading?: boolean;
}) {
  const lowStock = products.filter((product) => Number(product.available_quantity) <= 10).length;
  const inactive = products.filter((product) => product.is_active === false).length;
  const actions = [
    {
      label: "Pending orders",
      value: summary?.pendingOrderCount ?? 0,
      detail: "Review and confirm fulfilment",
      icon: ClipboardList,
      href: "/app/farmer/orders",
    },
    {
      label: "Low stock",
      value: lowStock,
      detail: "Products need replenishing",
      icon: AlertTriangle,
      href: "/app/farmer/products",
    },
    {
      label: "Needs attention",
      value: inactive,
      detail: "Inactive storefront listings",
      icon: Package,
      href: "/app/farmer/products",
    },
  ];
  return (
    <section
      aria-labelledby="farmer-action-center"
      className="rounded-2xl border border-border bg-card p-4 shadow-sm sm:p-5"
    >
      <div className="flex items-end justify-between gap-4">
        <div>
          <p className="text-xs font-bold uppercase tracking-[0.16em] text-primary">
            Action center
          </p>
          <h2
            id="farmer-action-center"
            className="mt-1 text-lg font-semibold text-primary-dark sm:text-xl"
          >
            Next farm tasks
          </h2>
        </div>
        <span className="text-xs text-muted-foreground">{isLoading ? "Updating..." : "Live"}</span>
      </div>
      <div className="mt-4 grid gap-2 md:grid-cols-3 md:gap-3">
        {actions.map(({ label, value, detail, icon: Icon, href }) => (
          <Link
            key={label}
            to={href}
            className="flex items-center gap-3 rounded-xl border border-border bg-muted/30 p-3 transition hover:border-primary/30 hover:bg-muted/50 sm:p-4"
          >
            <span className="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl bg-primary/10 text-primary">
              <Icon className="h-5 w-5" />
            </span>
            <span className="min-w-0 flex-1">
              <span className="flex items-center justify-between gap-2">
                <strong className="text-sm text-primary-dark">{label}</strong>
                <b className="text-lg text-primary">{isLoading ? "..." : value}</b>
              </span>
              <span className="mt-1 block text-xs text-muted-foreground">{detail}</span>
            </span>
            <ArrowRight className="h-4 w-4 shrink-0 text-muted-foreground" />
          </Link>
        ))}
      </div>
    </section>
  );
}
