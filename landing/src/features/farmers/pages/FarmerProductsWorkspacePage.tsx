import { Edit3, LoaderCircle, PackagePlus, Trash2 } from "lucide-react";
import { Link } from "react-router-dom";
import { useState } from "react";

import { deleteFarmerWorkspaceProduct, useFarmerProductsWorkspace } from "../../../core/lib";
import { getErrorMessage } from "../../../core/utils";
import { EmptyState } from "../../../shared/components/feedback";
import { Badge, PageHeader, Skeleton } from "../../../shared/components/ui";

const fallbackImage = "/assets/images/produce.jpg";

export function FarmerProductsWorkspacePage() {
  const { products, isLoading, error, refresh } = useFarmerProductsWorkspace();
  const [deleting, setDeleting] = useState<string | null>(null);
  const [deleteError, setDeleteError] = useState("");

  const remove = async (uuid: string) => {
    if (!window.confirm("Remove this product from your listings?")) return;
    setDeleting(uuid);
    setDeleteError("");
    try {
      await deleteFarmerWorkspaceProduct(uuid);
      refresh();
    } catch (requestError) {
      setDeleteError(
        getErrorMessage(requestError, "We could not remove that product. Please try again."),
      );
    } finally {
      setDeleting(null);
    }
  };

  return (
    <main className="mx-auto max-w-7xl px-4 py-4 sm:px-6 sm:py-8 lg:px-8">
      <PageHeader
        variant="minimal"
        eyebrow="Farm storefront"
        title="My products"
        description="Keep stock, pricing, harvest dates, and listing status accurate."
        icon={<PackagePlus className="h-5 w-5" />}
        actions={
          <Link
            to="/app/farmer/products/new"
            className="inline-flex min-h-10 items-center justify-center gap-2 rounded-xl bg-primary px-4 py-2 text-sm font-bold text-primary-foreground"
          >
            <PackagePlus className="h-4 w-4" />
            Add product
          </Link>
        }
      />

      {deleteError && (
        <p role="alert" className="mt-6 rounded-xl bg-destructive/10 p-4 text-sm text-destructive">
          {deleteError}
        </p>
      )}
      {Boolean(error) && (
        <p role="alert" className="mt-6 rounded-xl bg-destructive/10 p-4 text-sm text-destructive">
          Unable to load your products.
        </p>
      )}

      {isLoading ? (
        <div
          className="mt-5 grid grid-cols-2 gap-3 sm:gap-5 lg:grid-cols-3"
          aria-label="Loading products"
        >
          {[1, 2, 3].map((item) => (
            <Skeleton
              key={item}
              className="aspect-[0.72/1] rounded-xl sm:aspect-auto sm:h-80 sm:rounded-2xl"
            />
          ))}
        </div>
      ) : products.length === 0 ? (
        <div className="mt-8">
          <EmptyState
            title="Your storefront is empty"
            description="Add your first harvest so buyers can discover it."
            action={
              <Link
                to="/app/farmer/products/new"
                className="inline-flex rounded-full bg-primary px-4 py-2.5 text-sm font-bold text-primary-foreground"
              >
                Add product
              </Link>
            }
          />
        </div>
      ) : (
        <div className="mt-5 grid grid-cols-2 gap-3 sm:gap-5 lg:grid-cols-3">
          {products.map((product) => {
            const quantity = Number(product.available_quantity);
            const isListed = product.is_active !== false;
            const status = !isListed ? "Unlisted" : quantity > 0 ? "In stock" : "Out of stock";
            const statusClass = !isListed
              ? "bg-muted text-muted-foreground"
              : quantity > 0
                ? "bg-emerald-100 text-emerald-700"
                : "bg-amber-100 text-amber-700";
            const isDeleting = deleting === product.uuid;
            return (
              <article
                key={product.uuid}
                className="overflow-hidden rounded-xl border border-border bg-card shadow-sm sm:rounded-2xl"
              >
                <img
                  src={product.image_url || product.image || fallbackImage}
                  alt={product.name}
                  className="aspect-square w-full object-cover"
                  onError={(event) => {
                    event.currentTarget.src = fallbackImage;
                  }}
                />
                <div className="p-3 sm:p-5">
                  <div className="flex items-start justify-between gap-3">
                    <div className="min-w-0">
                      <h2 className="line-clamp-1 text-sm font-semibold text-primary-dark sm:text-base">
                        {product.name}
                      </h2>
                      <p className="mt-1 truncate text-xs text-muted-foreground sm:text-sm">
                        KSh {Number(product.price_per_unit).toLocaleString()} / {product.unit}
                      </p>
                    </div>
                    <Badge
                      variant={!isListed ? "neutral" : quantity > 0 ? "success" : "warning"}
                      size="sm"
                      className={statusClass}
                    >
                      {status}
                    </Badge>
                  </div>
                  <div className="mt-3 flex flex-col gap-1 text-[10px] text-muted-foreground sm:mt-4 sm:flex-row sm:justify-between sm:text-xs">
                    <span className="truncate">
                      {product.available_quantity} {product.unit} available
                    </span>
                    <span>{product.is_organic ? "Organic" : "Standard"}</span>
                  </div>
                  <div className="mt-3 flex gap-2 sm:mt-5">
                    <Link
                      to={`/app/farmer/products/${product.uuid}/edit`}
                      className="inline-flex min-h-10 flex-1 items-center justify-center gap-1 rounded-full border border-border px-2 py-2 text-[11px] font-bold text-primary-dark hover:bg-muted sm:gap-2 sm:px-3 sm:text-xs"
                    >
                      <Edit3 className="h-3.5 w-3.5" />
                      Edit
                    </Link>
                    <button
                      type="button"
                      disabled={isDeleting}
                      onClick={() => void remove(product.uuid)}
                      className="inline-flex h-10 w-10 shrink-0 items-center justify-center rounded-full border border-destructive/25 text-destructive hover:bg-destructive/10 disabled:opacity-50"
                      aria-label={`Delete ${product.name}`}
                      aria-busy={isDeleting}
                    >
                      {isDeleting ? (
                        <LoaderCircle className="h-4 w-4 animate-spin" />
                      ) : (
                        <Trash2 className="h-3.5 w-3.5" />
                      )}
                    </button>
                  </div>
                </div>
              </article>
            );
          })}
        </div>
      )}
    </main>
  );
}
