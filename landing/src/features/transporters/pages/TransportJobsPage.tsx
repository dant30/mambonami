import { ArrowRight, MapPin, Route, Truck } from "lucide-react";
import { Link } from "react-router-dom";
import { useState } from "react";

import { assignTripToMe, declineTrip, useAvailableOrders } from "../../../core/lib";
import { EmptyState } from "../../../shared/components/feedback";
import { Badge, Button, PageHeader, Skeleton } from "../../../shared/components/ui";

export function TransportJobsPage() {
  const { orders = [], isLoading, error } = useAvailableOrders();
  const [busyJob, setBusyJob] = useState<string | null>(null);
  const [message, setMessage] = useState("");

  const act = async (uuid: string, action: () => Promise<unknown>, success: string) => {
    setBusyJob(uuid);
    setMessage("");
    try {
      await action();
      setMessage(success);
    } finally {
      setBusyJob(null);
    }
  };

  return (
    <main className="mx-auto max-w-7xl px-4 py-4 sm:px-6 sm:py-8 lg:px-8">
      <PageHeader
        variant="minimal"
        eyebrow="Dispatch board"
        title="Available delivery jobs"
        description="Choose routes that fit your vehicle, location, and schedule."
        icon={<Truck className="h-5 w-5" />}
        metadata={[{ label: "Open jobs", value: isLoading ? "..." : orders.length }]}
      />
      {message && (
        <p
          role="status"
          className="mt-4 rounded-xl bg-primary/10 p-4 text-sm font-medium text-primary-dark"
        >
          {message}
        </p>
      )}
      {Boolean(error) && (
        <p role="alert" className="mt-4 rounded-xl bg-destructive/10 p-4 text-sm text-destructive">
          Unable to load available jobs.
        </p>
      )}
      {isLoading ? (
        <div className="mt-5 grid gap-3 lg:grid-cols-2">
          {[1, 2, 3, 4].map((item) => (
            <Skeleton key={item} className="h-56 rounded-2xl" />
          ))}
        </div>
      ) : orders.length === 0 ? (
        <EmptyState
          className="mt-5 rounded-2xl border border-dashed border-border bg-card px-4"
          size="sm"
          icon={<Truck className="h-6 w-6" />}
          title="No jobs available"
          description="New paid orders ready for collection will appear here."
        />
      ) : (
        <section className="mt-5 grid gap-3 lg:grid-cols-2" aria-label="Available jobs">
          {orders.map((trip) => (
            <article
              key={trip.uuid}
              className="rounded-2xl border border-border bg-card p-4 shadow-sm sm:p-5"
            >
              <div className="flex items-start justify-between gap-3">
                <div className="min-w-0">
                  <p className="text-[11px] font-bold uppercase tracking-wider text-primary">
                    Job #{trip.uuid.slice(0, 8)}
                  </p>
                  <h2 className="mt-1 line-clamp-2 text-lg font-semibold text-primary-dark">
                    {trip.order_detail?.item_summary || "Produce delivery"}
                  </h2>
                </div>
                <Badge variant="warning" size="sm">
                  {trip.status.replaceAll("_", " ")}
                </Badge>
              </div>
              <div className="mt-4 rounded-xl bg-muted/50 p-3 text-sm">
                <div className="grid grid-cols-[auto_1fr] gap-x-3 gap-y-3">
                  <MapPin className="h-4 w-4 text-primary" />
                  <div>
                    <p className="text-[10px] font-bold uppercase text-muted-foreground">
                      Collect from
                    </p>
                    <p className="mt-0.5 text-primary-dark">
                      {trip.pickup_address || "Pickup location pending"}
                    </p>
                  </div>
                  <Route className="h-4 w-4 text-secondary-foreground" />
                  <div>
                    <p className="text-[10px] font-bold uppercase text-muted-foreground">
                      Deliver to
                    </p>
                    <p className="mt-0.5 text-primary-dark">
                      {trip.delivery_address || "Delivery location pending"}
                    </p>
                  </div>
                </div>
              </div>
              <div className="mt-4 flex items-center justify-between gap-3">
                <div>
                  <p className="text-[10px] font-bold uppercase text-muted-foreground">Payout</p>
                  <p className="font-bold text-primary-dark">
                    KSh {Number(trip.provider_payout ?? trip.agreed_fee ?? 0).toLocaleString()}
                  </p>
                </div>
                <Link
                  to={`/app/transport/jobs/${trip.uuid}`}
                  className="inline-flex min-h-10 items-center gap-1 text-xs font-bold text-primary"
                >
                  Details <ArrowRight className="h-3.5 w-3.5" />
                </Link>
              </div>
              <div className="mt-4 grid grid-cols-2 gap-2 border-t border-border pt-3">
                <Button
                  type="button"
                  isLoading={busyJob === trip.uuid}
                  onClick={() =>
                    void act(
                      trip.uuid,
                      () => assignTripToMe(trip.uuid),
                      "Job accepted. It is now in Active trips.",
                    )
                  }
                >
                  Accept job
                </Button>
                <Button
                  type="button"
                  variant="outline"
                  disabled={busyJob === trip.uuid}
                  onClick={() =>
                    void act(
                      trip.uuid,
                      () => declineTrip(trip.uuid),
                      "Job removed from your dispatch board.",
                    )
                  }
                >
                  Decline
                </Button>
              </div>
            </article>
          ))}
        </section>
      )}
    </main>
  );
}
