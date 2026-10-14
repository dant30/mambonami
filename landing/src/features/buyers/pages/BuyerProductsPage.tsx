import { Search, SlidersHorizontal } from "lucide-react";
import { useEffect, useState } from "react";
import { useSearchParams } from "react-router-dom";

import { useDebounce } from "../../../core/hooks";
import { useProductCategories, useProducts } from "../../../core/lib";
import { Button, Input, PageHeader } from "../../../shared/components/ui";
import { MarketplaceProductGrid } from "../../home/components/MarketplaceProductGrid";

export function BuyerProductsPage() {
  const [params, setParams] = useSearchParams();
  const [search, setSearch] = useState(params.get("search") || "");
  const [category, setCategory] = useState(params.get("category") || "");
  const debouncedSearch = useDebounce(search, 300);
  const { categories = [] } = useProductCategories();
  const { products = [], isLoading, error } = useProducts({ search: debouncedSearch, category });

  useEffect(() => {
    const next = new URLSearchParams();
    if (debouncedSearch) next.set("search", debouncedSearch);
    if (category) next.set("category", category);
    setParams(next, { replace: true });
  }, [category, debouncedSearch, setParams]);

  const categoryOptions = [{ code: "", name: "All produce" }, ...categories];

  return (
    <main className="mx-auto max-w-7xl px-4 py-4 sm:px-6 sm:py-8 lg:px-8">
      <PageHeader
        variant="minimal"
        eyebrow="Buyer marketplace"
        title="Fresh produce, ready to order"
        description="Compare verified local supply, current prices, and available quantities."
        icon={<Search className="h-5 w-5" />}
      />

      <section
        aria-label="Product filters"
        className="mt-4 rounded-2xl border border-border bg-card p-3 sm:mt-6 sm:p-5"
      >
        <div className="flex items-center gap-2 text-xs font-bold uppercase tracking-wider text-muted-foreground">
          <SlidersHorizontal className="h-4 w-4 text-primary" />
          Filter marketplace
        </div>
        <div className="mt-3">
          <Input
            value={search}
            onChange={(event) => setSearch(event.target.value)}
            placeholder="Search tomatoes, onions, avocado..."
            aria-label="Search products"
            leftIcon={<Search className="h-4 w-4" />}
          />
        </div>
        <div
          className="mobile-scroll-row mt-3 flex gap-2 overflow-x-auto pb-1"
          aria-label="Product categories"
        >
          {categoryOptions.map((item) => (
            <Button
              key={item.code || "all"}
              type="button"
              size="sm"
              variant={category === item.code ? "primary" : "outline"}
              onClick={() => setCategory(item.code)}
              aria-pressed={category === item.code}
              className="min-h-10 shrink-0 rounded-full whitespace-nowrap"
            >
              {item.name}
            </Button>
          ))}
        </div>
      </section>

      <section className="mt-5 sm:mt-7" aria-live="polite">
        <div className="mb-3 flex items-center justify-between gap-3">
          <p className="text-sm font-semibold text-primary-dark">
            {isLoading
              ? "Checking availability..."
              : `${products.length} available ${products.length === 1 ? "product" : "products"}`}
          </p>
          {(search || category) && (
            <Button
              type="button"
              size="sm"
              variant="ghost"
              onClick={() => {
                setSearch("");
                setCategory("");
              }}
            >
              Clear filters
            </Button>
          )}
        </div>
        {error ? (
          <p role="alert" className="rounded-xl bg-destructive/10 p-4 text-sm text-destructive">
            Unable to load products. Check your connection and try again.
          </p>
        ) : (
          <MarketplaceProductGrid products={products} loading={isLoading} />
        )}
      </section>
    </main>
  );
}
