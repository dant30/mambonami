import { Heart, ShoppingBasket, Trash2 } from "lucide-react";
import { Link } from "react-router-dom";
import { useState } from "react";

import { addToCart, useBuyerWishlist, useBuyerWishlistActions } from "../../../core/lib";
import { EmptyState } from "../../../shared/components/feedback";
import { Button, PageHeader, Skeleton } from "../../../shared/components/ui";

export function BuyerWishlistPage() {
  const { items = [], isLoading, error } = useBuyerWishlist();
  const { remove } = useBuyerWishlistActions();
  const [busyProduct, setBusyProduct] = useState<string | null>(null);
  const visible = items.filter((item) => item.product);

  const removeItem = async (productUuid: string) => {
    setBusyProduct(productUuid);
    try {
      await remove(productUuid);
    } finally {
      setBusyProduct(null);
    }
  };

  return (
    <main className="mx-auto max-w-7xl px-4 py-4 sm:px-6 sm:py-8 lg:px-8">
      <PageHeader
        variant="minimal"
        eyebrow="Saved produce"
        title="Your wishlist"
        description="Keep frequently purchased produce close and move it to your cart when you are ready."
        icon={<Heart className="h-5 w-5" />}
      />
      {Boolean(error) && (
        <p role="alert" className="mt-4 rounded-xl bg-destructive/10 p-4 text-sm text-destructive">
          Unable to load your wishlist.
        </p>
      )}
      {isLoading ? (
        <div className="mt-5 grid grid-cols-2 gap-3 lg:grid-cols-4">
          {[1, 2, 3, 4].map((item) => (
            <Skeleton key={item} className="aspect-[0.72/1] rounded-2xl" />
          ))}
        </div>
      ) : visible.length === 0 ? (
        <EmptyState
          className="mt-5 rounded-2xl border border-dashed border-border bg-card px-4"
          size="sm"
          icon={<Heart className="h-6 w-6" />}
          title="Nothing saved yet"
          description="Save produce you buy often so your next order takes less time."
          action={
            <Link
              to="/app/buyer/products"
              className="inline-flex min-h-10 items-center rounded-xl bg-primary px-4 py-2 text-sm font-bold text-primary-foreground"
            >
              Explore produce
            </Link>
          }
        />
      ) : (
        <section
          className="mt-5 grid grid-cols-2 gap-3 sm:gap-4 lg:grid-cols-4"
          aria-label="Saved products"
        >
          {visible.map((item) => (
            <article
              key={item.id}
              className="min-w-0 overflow-hidden rounded-2xl border border-border bg-card shadow-sm"
            >
              <Link to={`/product/${item.product.uuid}`} className="block overflow-hidden bg-muted">
                <img
                  src={item.product.image_url || item.product.image || "/assets/images/produce.jpg"}
                  alt={item.product.name}
                  className="aspect-square w-full object-cover transition duration-300 hover:scale-105"
                  loading="lazy"
                />
              </Link>
              <div className="p-3 sm:p-4">
                <Link
                  to={`/product/${item.product.uuid}`}
                  className="line-clamp-2 text-sm font-semibold text-primary-dark hover:text-primary"
                >
                  {item.product.name}
                </Link>
                <p className="mt-1 text-sm font-bold text-primary-dark">
                  KSh {Number(item.product.price_per_unit).toLocaleString()}{" "}
                  <span className="text-xs font-normal text-muted-foreground">
                    / {item.product.unit}
                  </span>
                </p>
                <div className="mt-3 grid grid-cols-[1fr_auto] gap-2">
                  <Button
                    type="button"
                    size="sm"
                    onClick={() =>
                      addToCart({
                        product_uuid: item.product.uuid,
                        quantity: 1,
                        unit_price: item.product.price_per_unit,
                        product_detail: item.product,
                      })
                    }
                    leftIcon={<ShoppingBasket className="h-4 w-4" />}
                    className="min-h-10 min-w-0 px-2 text-[11px] sm:text-xs"
                  >
                    Add
                  </Button>
                  <Button
                    type="button"
                    size="sm"
                    variant="outline"
                    disabled={busyProduct === item.product.uuid}
                    onClick={() => void removeItem(item.product.uuid)}
                    aria-label={`Remove ${item.product.name}`}
                    className="h-10 w-10 px-0 text-destructive"
                  >
                    <Trash2 className="h-4 w-4" />
                  </Button>
                </div>
              </div>
            </article>
          ))}
        </section>
      )}
    </main>
  );
}
