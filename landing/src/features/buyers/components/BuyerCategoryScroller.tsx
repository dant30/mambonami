import { ArrowRight } from "lucide-react";
import { Link } from "react-router-dom";

import type { ProductCategory } from "../../../core/lib";
import { Skeleton } from "../../../shared/components/ui";

const fallbackCategories: ProductCategory[] = [
  { id: 0, code: "MA", name: "Matunda (Fruits)" },
  { id: 1, code: "MBO", name: "Mboga (Vegetables)" },
  { id: 2, code: "NA", name: "Nafaka (Cereals)" },
  { id: 3, code: "MI", name: "Mizizi (Roots)" },
];

const categoryNames: Record<string, string> = {
  MA: "Matunda (Fruits)",
  MBO: "Mboga (Vegetables)",
  NA: "Nafaka (Cereals)",
  MI: "Mizizi (Roots)",
};

export function BuyerCategoryScroller({
  categories,
  isLoading,
}: {
  categories: ProductCategory[];
  isLoading?: boolean;
}) {
  const visible = categories.length > 0 ? categories.slice(0, 6) : fallbackCategories;
  return (
    <section className="mt-5 sm:mt-7">
      <div className="flex items-end justify-between">
        <div>
          <p className="text-xs font-bold uppercase tracking-[0.16em] text-primary">Explore</p>
          <h2 className="mt-1 text-lg font-semibold text-primary-dark">Shop by category</h2>
        </div>
        <Link to="/app/buyer/products" className="text-sm font-bold text-primary">
          View marketplace
        </Link>
      </div>
      <div className="mobile-scroll-row mt-3 flex gap-3 overflow-x-auto pb-2">
        {isLoading
          ? [1, 2, 3, 4].map((item) => (
              <Skeleton key={item} className="h-24 w-36 shrink-0 rounded-2xl" />
            ))
          : visible.map((category) => {
              const code = category.code.toUpperCase();
              return (
                <Link
                  key={category.code}
                  to={`/app/buyer/products?category=${encodeURIComponent(category.code)}`}
                  className="group min-w-36 shrink-0 rounded-2xl border border-border bg-card p-4 transition hover:-translate-y-0.5 hover:border-primary/30 hover:shadow-sm"
                >
                  <span className="text-xs font-bold uppercase tracking-[0.14em] text-primary">
                    {code}
                  </span>
                  <p className="mt-2 text-sm font-semibold text-primary-dark">
                    {categoryNames[code] || category.name}
                  </p>
                  <span className="mt-2 flex items-center gap-1 text-xs text-muted-foreground group-hover:text-primary">
                    Shop <ArrowRight className="h-3 w-3" />
                  </span>
                </Link>
              );
            })}
      </div>
    </section>
  );
}
