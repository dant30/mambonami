import { ArrowRight, ShoppingBasket, Truck } from "lucide-react";
import { Link } from "react-router-dom";

import type { Order } from "../../../core/lib";
import { Skeleton } from "../../../shared/components/ui";

function statusStep(status: string | null | undefined) {
  const value = String(status || "").toLowerCase();
  if (value === "delivered") return 4;
  if (
    ["shipped", "in_transit", "out_for_delivery", "transport_assigned", "picked_up"].includes(value)
  )
    return 3;
  if (["processing", "placed", "paid_escrow"].includes(value)) return 2;
  return value ? 1 : 2;
}
function statusLabel(status: string | null | undefined) {
  const value = String(status || "").toLowerCase();
  if (value === "delivered") return "Delivered";
  if (
    ["shipped", "in_transit", "out_for_delivery", "transport_assigned", "picked_up"].includes(value)
  )
    return "On the way";
  if (["processing", "placed", "paid_escrow"].includes(value)) return "Preparing";
  if (["confirmed", "accepted"].includes(value)) return "Confirmed";
  return String(status || "Processing").replaceAll("_", " ");
}

export function BuyerActiveOrder({
  order,
  isLoading,
}: {
  order: Order | null;
  isLoading?: boolean;
}) {
  if (isLoading)
    return (
      <section className="mt-5 sm:mt-7">
        <div className="rounded-2xl border border-border bg-card p-6">
          <Skeleton className="h-5 w-40" />
          <Skeleton className="mt-5 h-3 w-full" />
        </div>
      </section>
    );
  return (
    <section className="mt-5 sm:mt-7">
      <div className="mb-3 flex items-center justify-between">
        <div>
          <p className="text-xs font-bold uppercase tracking-[0.16em] text-primary">Your order</p>
          <h2 className="mt-1 text-lg font-semibold text-primary-dark">Track your delivery</h2>
        </div>
        <Link to="/app/buyer/orders" className="text-sm font-bold text-primary">
          View all
        </Link>
      </div>
      {order ? (
        <div className="rounded-2xl border border-border bg-card p-4 shadow-sm sm:p-6">
          <div className="flex flex-col gap-5 sm:flex-row sm:items-start sm:justify-between">
            <div>
              <div className="flex items-center gap-2">
                <span className="flex h-9 w-9 items-center justify-center rounded-xl bg-primary/10">
                  <Truck className="h-4 w-4 text-primary" />
                </span>
                <div>
                  <p className="text-xs text-muted-foreground">Active order</p>
                  <p className="font-semibold text-primary-dark">
                    {order.item_summary || "Marketplace order"}
                  </p>
                </div>
              </div>
              <p className="mt-3 text-sm text-muted-foreground">
                Status:{" "}
                <span className="font-semibold text-primary-dark">{statusLabel(order.status)}</span>
              </p>
            </div>
            <Link
              to={`/app/buyer/orders/${order.uuid || order.id}`}
              className="inline-flex items-center gap-2 self-start rounded-full bg-primary px-4 py-2.5 text-sm font-bold text-primary-foreground"
            >
              Track delivery <ArrowRight className="h-4 w-4" />
            </Link>
          </div>
          <div className="mt-5 grid grid-cols-4 gap-1 sm:gap-2">
            {["Confirmed", "Preparing", "On the way", "Delivered"].map((step, index) => (
              <div key={step} className="text-center">
                <div
                  className={`mx-auto flex h-8 w-8 items-center justify-center rounded-full border-2 text-xs font-bold ${statusStep(order.status) >= index + 1 ? "border-primary bg-primary text-primary-foreground" : "border-border text-muted-foreground"}`}
                >
                  {index + 1}
                </div>
                <span className="mt-2 block text-[10px] font-medium text-muted-foreground sm:text-xs">
                  {step}
                </span>
              </div>
            ))}
          </div>
        </div>
      ) : (
        <div className="rounded-2xl border border-dashed border-border bg-card p-6 text-center">
          <ShoppingBasket className="mx-auto h-7 w-7 text-muted-foreground" />
          <p className="mt-3 text-sm text-muted-foreground">Nothing is on the way.</p>
          <Link
            to="/app/buyer/products"
            className="mt-4 inline-flex items-center gap-2 text-sm font-bold text-primary"
          >
            Start shopping <ArrowRight className="h-4 w-4" />
          </Link>
        </div>
      )}
    </section>
  );
}
