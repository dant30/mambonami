import { ArrowRight, CheckCircle2, MapPin, Navigation } from "lucide-react";
import { Link } from "react-router-dom";

import { useMyTrips } from "../../../core/lib";
import { EmptyState } from "../../../shared/components/feedback";
import { Badge, PageHeader, Skeleton } from "../../../shared/components/ui";

const formatStatus = (status: string) => status.replaceAll("_", " ");

export function TransportTripsPage({ completedOnly = false }: { completedOnly?: boolean }) {
  const { trips = [], isLoading, error } = useMyTrips();
  const visible = trips.filter((trip) =>
    completedOnly ? trip.status === "delivered" : !["delivered", "cancelled"].includes(trip.status),
  );

  return (
    <main className="mx-auto max-w-7xl px-4 py-4 sm:px-6 sm:py-8 lg:px-8">
      <PageHeader
        variant="minimal"
        eyebrow="Route operations"
        title={completedOnly ? "Completed deliveries" : "Active trips"}
        description={
          completedOnly
            ? "Review completed routes, delivery records, and earnings."
            : "See the next stop, route status, and expected payout for every assigned trip."
        }
        icon={<Navigation className="h-5 w-5" />}
        actions={
          !completedOnly ? (
            <Link
              to="/app/transport/jobs"
              className="inline-flex min-h-10 items-center rounded-xl bg-primary px-4 py-2 text-sm font-bold text-primary-foreground"
            >
              Find jobs
            </Link>
          ) : undefined
        }
      />
      {Boolean(error) && (
        <p role="alert" className="mt-4 rounded-xl bg-destructive/10 p-4 text-sm text-destructive">
          Unable to load your trips.
        </p>
      )}
      {isLoading ? (
        <div className="mt-5 space-y-3">
          {[1, 2, 3].map((item) => (
            <Skeleton key={item} className="h-32 rounded-2xl" />
          ))}
        </div>
      ) : visible.length === 0 ? (
        <EmptyState
          className="mt-5 rounded-2xl border border-dashed border-border bg-card px-4"
          size="sm"
          icon={<Navigation className="h-6 w-6" />}
          title={completedOnly ? "No completed deliveries yet" : "No active trips"}
          description={
            completedOnly
              ? "Successfully delivered trips will be recorded here."
              : "Accept an available job to start your next route."
          }
          action={
            !completedOnly ? (
              <Link
                to="/app/transport/jobs"
                className="inline-flex min-h-10 items-center rounded-xl bg-primary px-4 py-2 text-sm font-bold text-primary-foreground"
              >
                Open dispatch board
              </Link>
            ) : undefined
          }
        />
      ) : (
        <section className="mt-5 grid gap-3 lg:grid-cols-2" aria-label="Delivery trips">
          {visible.map((trip) => (
            <article
              key={trip.uuid}
              className="rounded-2xl border border-border bg-card p-4 shadow-sm sm:p-5"
            >
              <div className="flex items-start justify-between gap-3">
                <div className="min-w-0">
                  <p className="text-[11px] font-bold uppercase tracking-wider text-primary">
                    Trip #{trip.uuid.slice(0, 8)}
                  </p>
                  <h2 className="mt-1 line-clamp-2 font-semibold text-primary-dark">
                    {trip.order_detail?.item_summary || "Produce delivery"}
                  </h2>
                </div>
                <Badge
                  variant={trip.status === "delivered" ? "success" : "warning"}
                  size="sm"
                  icon={
                    trip.status === "delivered" ? (
                      <CheckCircle2 className="h-3.5 w-3.5" />
                    ) : undefined
                  }
                >
                  {formatStatus(trip.status)}
                </Badge>
              </div>
              <p className="mt-3 flex items-start gap-2 text-sm text-muted-foreground">
                <MapPin className="mt-0.5 h-4 w-4 shrink-0 text-primary" />
                <span className="line-clamp-2">
                  {trip.delivery_address || "Destination pending"}
                </span>
              </p>
              <div className="mt-4 flex items-center justify-between gap-3 border-t border-border pt-3">
                <div>
                  <p className="text-[10px] font-bold uppercase text-muted-foreground">
                    Expected payout
                  </p>
                  <p className="font-bold text-primary-dark">
                    KSh {Number(trip.provider_payout ?? trip.agreed_fee ?? 0).toLocaleString()}
                  </p>
                </div>
                <Link
                  to={`/app/transport/jobs/${trip.uuid}`}
                  className="inline-flex min-h-10 items-center gap-2 rounded-xl border border-border px-3 py-2 text-xs font-bold text-primary-dark hover:bg-muted"
                >
                  Manage <ArrowRight className="h-3.5 w-3.5" />
                </Link>
              </div>
            </article>
          ))}
        </section>
      )}
    </main>
  );
}
