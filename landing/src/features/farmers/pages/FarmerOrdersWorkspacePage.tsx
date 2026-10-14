import { Check, ClipboardList, MapPin, PackageCheck, X } from "lucide-react";
import { Link } from "react-router-dom";

import { useFarmerOrderActions, useFarmerSubOrders } from "../../../core/lib";
import { formatRelativeTime } from "../../../core/utils";
import { EmptyState } from "../../../shared/components/feedback";
import { Badge, Button, PageHeader, Skeleton } from "../../../shared/components/ui";

export function FarmerOrdersWorkspacePage() {
  const { subOrders, isLoading, error, refresh } = useFarmerSubOrders();
  const actions = useFarmerOrderActions();

  const run = async (action: () => Promise<unknown>) => {
    try {
      await action();
      refresh();
    } catch {
      return;
    }
  };

  return (
    <main className="mx-auto max-w-7xl px-4 py-4 sm:px-6 sm:py-8 lg:px-8">
      <PageHeader
        variant="minimal"
        eyebrow="Farm operations"
        title="Orders received"
        description="Confirm paid orders, prepare exact quantities, and release produce for collection."
        icon={<ClipboardList className="h-5 w-5" />}
        metadata={[{ label: "Orders", value: isLoading ? "..." : subOrders.length }]}
      />

      {Boolean(error) && (
        <p role="alert" className="mt-6 rounded-xl bg-destructive/10 p-4 text-sm text-destructive">
          Unable to load incoming orders. Refresh the page to try again.
        </p>
      )}
      {Boolean(actions.error) && (
        <p role="alert" className="mt-6 rounded-xl bg-destructive/10 p-4 text-sm text-destructive">
          That order action could not be completed. Check your connection and try again.
        </p>
      )}

      {isLoading ? (
        <div className="mt-5 grid gap-3 lg:grid-cols-2" aria-label="Loading orders">
          {[1, 2, 3].map((item) => (
            <Skeleton key={item} className="h-48 rounded-2xl" />
          ))}
        </div>
      ) : subOrders.length === 0 ? (
        <EmptyState
          className="mt-5 rounded-2xl border border-dashed border-border bg-card px-4"
          size="sm"
          icon={<ClipboardList className="h-6 w-6" />}
          title="No incoming orders"
          description="Paid buyer orders for your published produce will appear here."
          action={
            <Link
              to="/app/farmer/products"
              className="inline-flex min-h-10 items-center rounded-xl border border-border px-4 py-2 text-sm font-semibold text-primary-dark"
            >
              Review storefront
            </Link>
          }
        />
      ) : (
        <div className="mt-5 grid gap-3 sm:gap-5 lg:grid-cols-2">
          {subOrders.map((subOrder) => {
            const busy = actions.busyId === subOrder.id;
            const paid = subOrder.order_status === "paid_escrow";
            return (
              <article
                key={subOrder.id}
                className="rounded-xl border border-border bg-card p-4 shadow-sm sm:rounded-2xl sm:p-6"
              >
                <div className="flex items-start justify-between gap-4">
                  <div>
                    <p className="text-xs font-bold uppercase tracking-[0.14em] text-primary">
                      Sub-order #{subOrder.id}
                    </p>
                    <h2 className="mt-2 text-xl font-semibold capitalize text-primary-dark">
                      {subOrder.status.replaceAll("_", " ")}
                    </h2>
                  </div>
                  <Badge
                    variant={subOrder.status === "ready" ? "success" : paid ? "info" : "warning"}
                    size="sm"
                  >
                    {subOrder.status.replaceAll("_", " ")}
                  </Badge>
                </div>
                <div className="mt-5 space-y-3 text-sm text-muted-foreground">
                  {subOrder.items.map((item) => (
                    <p key={item.id} className="flex items-start justify-between gap-4">
                      <span>
                        {item.product_detail?.name || "Produce"}{" "}
                        <span className="text-foreground">
                          × {item.quantity} {item.product_detail?.unit || "unit"}
                        </span>
                      </span>
                      <span className="shrink-0 font-semibold text-foreground">
                        KSh {Number(item.total_price).toLocaleString()}
                      </span>
                    </p>
                  ))}
                </div>
                <div className="mt-5 flex flex-wrap items-center justify-between gap-3 border-t border-border pt-4 text-sm">
                  <span className="text-muted-foreground">
                    {formatRelativeTime(subOrder.created_at)}
                  </span>
                  <span className="font-bold text-primary-dark">
                    Payout KSh {Number(subOrder.farmer_payout).toLocaleString()}
                  </span>
                </div>
                <div className="mt-5 flex flex-wrap gap-2">
                  {subOrder.status === "pending" && subOrder.order_status === "placed" && (
                    <>
                      <p className="w-full text-sm text-muted-foreground">
                        Waiting for the buyer’s payment before you can confirm.
                      </p>
                      <Button
                        type="button"
                        size="sm"
                        variant="danger"
                        disabled={busy}
                        onClick={() => void run(() => actions.reject(subOrder.id))}
                        leftIcon={<X className="h-4 w-4" />}
                      >
                        Reject unpaid
                      </Button>
                    </>
                  )}
                  {subOrder.status === "pending" && paid && (
                    <Button
                      type="button"
                      size="sm"
                      disabled={busy}
                      onClick={() => void run(() => actions.confirm(subOrder.id))}
                      leftIcon={<Check className="h-4 w-4" />}
                    >
                      Confirm paid order
                    </Button>
                  )}
                  {subOrder.status === "confirmed" && paid && (
                    <Button
                      type="button"
                      size="sm"
                      disabled={busy}
                      onClick={() => void run(() => actions.markReady(subOrder.id))}
                      leftIcon={<PackageCheck className="h-4 w-4" />}
                    >
                      Mark ready
                    </Button>
                  )}
                  {subOrder.status === "ready" && (
                    <p className="flex items-center gap-2 text-sm font-semibold text-primary">
                      <MapPin className="h-4 w-4" />
                      Ready for transporter collection
                    </p>
                  )}
                  <Link
                    to={`/app/farmer/orders/${subOrder.id}`}
                    className="ml-auto inline-flex items-center rounded-full border border-border px-4 py-2.5 text-sm font-semibold text-primary-dark hover:bg-muted"
                  >
                    Order details
                  </Link>
                </div>
              </article>
            );
          })}
        </div>
      )}
    </main>
  );
}
