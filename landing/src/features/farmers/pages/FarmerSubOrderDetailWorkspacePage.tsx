import { ArrowLeft, Check, MapPin, PackageCheck, X } from "lucide-react";
import { Link, useParams } from "react-router-dom";
import { useCallback, useEffect, useState } from "react";

import { getFarmerWorkspaceSubOrder, useFarmerOrderActions } from "../../../core/lib";
import type { FarmerOrder } from "../../../core/lib";
import { getErrorMessage } from "../../../core/utils";

export function FarmerSubOrderDetailWorkspacePage() {
  const { id = "" } = useParams();
  const subOrderId = Number(id);
  const hasValidId = /^\d+$/.test(id) && Number.isSafeInteger(subOrderId);
  const [subOrder, setSubOrder] = useState<FarmerOrder | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState("");
  const actions = useFarmerOrderActions();

  const refresh = useCallback(() => {
    if (!hasValidId) {
      setError("Invalid order reference.");
      setIsLoading(false);
      return;
    }
    setIsLoading(true);
    setError("");
    getFarmerWorkspaceSubOrder(subOrderId)
      .then(setSubOrder)
      .catch((requestError: unknown) =>
        setError(getErrorMessage(requestError, "This order is unavailable.")),
      )
      .finally(() => setIsLoading(false));
  }, [hasValidId, subOrderId]);

  useEffect(() => {
    refresh();
  }, [refresh]);

  const run = async (action: () => Promise<unknown>) => {
    try {
      await action();
      refresh();
    } catch {
      return;
    }
  };

  if (isLoading && !subOrder)
    return (
      <main className="mx-auto max-w-3xl px-4 py-16 sm:px-6 lg:px-8">
        <div className="h-80 animate-pulse rounded-2xl bg-muted" />
      </main>
    );
  if (error && !subOrder)
    return (
      <main className="mx-auto max-w-2xl px-4 py-20 text-center">
        <h1 className="text-3xl font-semibold text-primary-dark">Order unavailable</h1>
        <p className="mt-3 text-sm text-muted-foreground">{error}</p>
        <Link
          to="/app/farmer/orders"
          className="mt-6 inline-flex rounded-full bg-primary px-5 py-3 text-sm font-bold text-primary-foreground"
        >
          Back to orders
        </Link>
      </main>
    );
  if (!subOrder) return null;

  const paid = subOrder.order_status === "paid_escrow";
  const busy = actions.busyId === subOrder.id;
  const runAction = (action: () => Promise<unknown>) => void run(action);

  return (
    <main className="mx-auto max-w-3xl px-4 py-4 sm:px-6 sm:py-8 lg:px-8">
      <Link
        to="/app/farmer/orders"
        className="inline-flex items-center gap-2 text-sm font-bold text-primary"
      >
        <ArrowLeft className="h-4 w-4" />
        Back to orders
      </Link>
      <div className="mt-5 flex flex-wrap items-end justify-between gap-4">
        <div>
          <p className="text-xs font-bold uppercase tracking-[0.18em] text-primary">
            Sub-order #{subOrder.id}
          </p>
          <h1 className="mt-2 text-3xl font-semibold capitalize text-primary-dark">
            {subOrder.status.replaceAll("_", " ")}
          </h1>
        </div>
        <p className="text-2xl font-bold text-primary-dark">
          KSh {Number(subOrder.subtotal).toLocaleString()}
        </p>
      </div>
      {!paid && subOrder.status !== "cancelled" && (
        <p
          role="status"
          className="mt-6 rounded-xl border border-border bg-muted p-4 text-sm text-muted-foreground"
        >
          Waiting for the buyer’s verified payment. Order confirmation and pickup preparation are
          locked until payment clears.
        </p>
      )}
      {Boolean(actions.error) && (
        <p role="alert" className="mt-6 rounded-xl bg-destructive/10 p-4 text-sm text-destructive">
          That action could not be completed. Refresh the page and try again.
        </p>
      )}
      <section className="mt-5 rounded-2xl border border-border bg-card p-4 sm:p-6">
        <h2 className="font-semibold text-primary-dark">Produce to prepare</h2>
        <div className="mt-4 divide-y divide-border">
          {subOrder.items.map((item) => (
            <div
              key={item.id}
              className="flex items-center justify-between gap-4 py-4 first:pt-0 last:pb-0"
            >
              <div>
                <p className="font-semibold text-primary-dark">
                  {item.product_detail?.name || "Produce"}
                </p>
                <p className="mt-1 text-sm text-muted-foreground">
                  {item.quantity} {item.product_detail?.unit || "unit"}
                </p>
              </div>
              <p className="font-bold text-primary-dark">
                KSh {Number(item.total_price).toLocaleString()}
              </p>
            </div>
          ))}
        </div>
        <p className="mt-6 flex gap-2 border-t border-border pt-5 text-sm text-muted-foreground">
          <MapPin className="h-4 w-4 shrink-0 text-primary" />
          After payment and confirmation, mark the produce ready for transporter collection.
        </p>
      </section>
      <div className="mt-6 flex flex-wrap gap-3">
        {subOrder.status === "pending" && paid && (
          <button
            type="button"
            disabled={busy}
            onClick={() => runAction(() => actions.confirm(subOrder.id))}
            className="inline-flex items-center gap-2 rounded-full bg-primary px-5 py-3 text-sm font-bold text-primary-foreground disabled:opacity-50"
          >
            <Check className="h-4 w-4" />
            Confirm paid order
          </button>
        )}
        {subOrder.status === "pending" && subOrder.order_status === "placed" && (
          <button
            type="button"
            disabled={busy}
            onClick={() => runAction(() => actions.reject(subOrder.id))}
            className="inline-flex items-center gap-2 rounded-full border border-destructive/30 px-5 py-3 text-sm font-bold text-destructive disabled:opacity-50"
          >
            <X className="h-4 w-4" />
            Reject unpaid order
          </button>
        )}
        {subOrder.status === "confirmed" && paid && (
          <button
            type="button"
            disabled={busy}
            onClick={() => runAction(() => actions.markReady(subOrder.id))}
            className="inline-flex items-center gap-2 rounded-full bg-primary px-5 py-3 text-sm font-bold text-primary-foreground disabled:opacity-50"
          >
            <PackageCheck className="h-4 w-4" />
            Mark ready for pickup
          </button>
        )}
        {subOrder.status === "ready" && (
          <p className="flex items-center gap-2 text-sm font-semibold text-primary">
            <MapPin className="h-4 w-4" />
            Ready for transporter collection
          </p>
        )}
      </div>
    </main>
  );
}
