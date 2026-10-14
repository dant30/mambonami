import { ArrowRight, Heart } from "lucide-react";
import { Link } from "react-router-dom";

import type { WishlistItem } from "../../../core/lib";

function money(value: string | number) {
  return `KSh ${Number(value).toLocaleString()}`;
}

export function BuyerWishlistPreview({ items }: { items: WishlistItem[] }) {
  return (
    <section className="mt-5 sm:mt-7">
      <div className="flex items-end justify-between">
        <div>
          <p className="text-xs font-bold uppercase tracking-[0.16em] text-primary">Saved</p>
          <h2 className="mt-1 text-lg font-semibold text-primary-dark">Your saved produce</h2>
        </div>
        <Link to="/app/buyer/wishlist" className="text-sm font-bold text-primary">
          View wishlist
        </Link>
      </div>
      {items.length > 0 ? (
        <div className="mt-3 grid grid-cols-2 gap-3 sm:grid-cols-4">
          {items.slice(0, 4).map((item) => (
            <Link
              key={item.id}
              to={`/product/${item.product.uuid}`}
              className="rounded-2xl border border-border bg-card p-4 transition hover:border-primary/30"
            >
              <div className="flex aspect-square items-center justify-center overflow-hidden rounded-xl bg-muted">
                <img
                  src={item.product.image_url || item.product.image || "/assets/images/produce.jpg"}
                  alt={item.product.name}
                  className="h-full w-full object-cover"
                />
              </div>
              <p className="mt-3 truncate text-sm font-semibold text-primary-dark">
                {item.product.name}
              </p>
              <p className="mt-1 text-xs text-muted-foreground">
                {money(item.product.price_per_unit)} / {item.product.unit}
              </p>
            </Link>
          ))}
        </div>
      ) : (
        <div className="mt-4 rounded-2xl border border-dashed border-border bg-card p-6 text-center">
          <Heart className="mx-auto h-7 w-7 text-muted-foreground" />
          <p className="mt-3 text-sm text-muted-foreground">Save produce you want to revisit.</p>
          <Link
            to="/app/buyer/products"
            className="mt-4 inline-flex items-center gap-2 text-sm font-bold text-primary"
          >
            Explore produce <ArrowRight className="h-4 w-4" />
          </Link>
        </div>
      )}
    </section>
  );
}
