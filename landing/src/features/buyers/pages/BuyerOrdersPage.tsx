import { ArrowRight, ClipboardList, MapPin, ShoppingBasket } from "lucide-react";
import { Link } from "react-router-dom";

import { useOrders } from "../../../core/lib";
import { EmptyState } from "../../../shared/components/feedback";
import { Badge, PageHeader, Skeleton } from "../../../shared/components/ui";

const terminalStatuses = ["delivered", "cancelled", "refunded"];
const formatStatus = (status: string) => status.replaceAll("_", " ");
const statusVariant = (status: string) =>
  status === "delivered"
    ? "success"
    : status === "cancelled" || status === "refunded"
      ? "danger"
      : "warning";

export function BuyerOrdersPage({ activeOnly = false }: { activeOnly?: boolean }) {
  const { orders = [], isLoading, error } = useOrders();
  const visibleOrders = activeOnly
    ? orders.filter((order) => !terminalStatuses.includes(order.status))
    : orders;

  return (
    <main className="mx-auto max-w-7xl px-4 py-4 sm:px-6 sm:py-8 lg:px-8">
      <PageHeader
        variant="minimal"
        eyebrow="Purchases"
        title={activeOnly ? "Active orders" : "Order history"}
        description={
          activeOnly
            ? "Track paid orders from preparation through delivery."
            : "Review payments, delivery status, and previous purchases."
        }
        icon={<ClipboardList className="h-5 w-5" />}
        actions={
          <Link
            to="/app/buyer/products"
            className="inline-flex min-h-10 items-center justify-center gap-2 rounded-xl bg-primary px-4 py-2 text-sm font-bold text-primary-foreground"
          >
            <ShoppingBasket className="h-4 w-4" /> Shop produce
          </Link>
        }
      />

      {error && (
        <p role="alert" className="mt-4 rounded-xl bg-destructive/10 p-4 text-sm text-destructive">
          Unable to load your orders.
        </p>
      )}
      {isLoading ? (
        <div className="mt-5 space-y-3">
          {[1, 2, 3].map((item) => (
            <Skeleton key={item} className="h-32 rounded-2xl" />
          ))}
        </div>
      ) : visibleOrders.length === 0 ? (
        <EmptyState
          className="mt-5 rounded-2xl border border-dashed border-border bg-card px-4"
          size="sm"
          icon={<ClipboardList className="h-6 w-6" />}
          title={activeOnly ? "No active orders" : "No orders yet"}
          description="Your paid marketplace orders and delivery updates will appear here."
          action={
            <Link
              to="/app/buyer/products"
              className="inline-flex min-h-10 items-center rounded-xl bg-primary px-4 py-2 text-sm font-bold text-primary-foreground"
            >
              Browse produce
            </Link>
          }
        />
      ) : (
        <section className="mt-5 grid gap-3 lg:grid-cols-2" aria-label="Orders">
          {visibleOrders.map((order) => (
            <article
              key={order.uuid}
              className="rounded-2xl border border-border bg-card p-4 shadow-sm sm:p-5"
            >
              <div className="flex items-start justify-between gap-3">
                <div className="min-w-0">
                  <p className="text-[11px] font-bold uppercase tracking-wider text-primary">
                    Order #{order.account_number || order.uuid.slice(0, 8)}
                  </p>
                  <h2 className="mt-1 line-clamp-2 text-base font-semibold text-primary-dark">
                    {order.item_summary || "Marketplace produce order"}
                  </h2>
                </div>
                <Badge variant={statusVariant(order.status)} size="sm">
                  {formatStatus(order.status)}
                </Badge>
              </div>
              <p className="mt-3 flex items-start gap-2 text-sm text-muted-foreground">
                <MapPin className="mt-0.5 h-4 w-4 shrink-0 text-primary" />
                <span className="line-clamp-2">
                  {order.delivery_city || order.delivery_address || "Delivery destination pending"}
                </span>
              </p>
              <div className="mt-4 flex items-center justify-between gap-3 border-t border-border pt-3">
                <p className="font-bold text-primary-dark">
                  KSh {Number(order.total_amount).toLocaleString()}
                </p>
                <Link
                  to={`/app/buyer/orders/${order.uuid}`}
                  className="inline-flex min-h-10 items-center gap-2 rounded-xl border border-border px-3 py-2 text-xs font-bold text-primary-dark hover:bg-muted"
                >
                  View order <ArrowRight className="h-3.5 w-3.5" />
                </Link>
              </div>
            </article>
          ))}
        </section>
      )}
    </main>
  );
}
