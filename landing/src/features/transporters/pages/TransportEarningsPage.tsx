import { ArrowUpRight, Banknote, Clock3, Wallet } from "lucide-react";

import { usePayouts, usePayoutSummary } from "../../../core/lib";
import { StatCard } from "../../../shared/components/cards";
import { EmptyState } from "../../../shared/components/feedback";
import { Badge, PageHeader, Skeleton } from "../../../shared/components/ui";

export function TransportEarningsPage() {
  const { summary, isLoading: summaryLoading } = usePayoutSummary();
  const { payouts = [], isLoading: payoutsLoading } = usePayouts();
  const metrics = [
    ["Total earned", summary?.total_payout_amount, "All recorded payouts"],
    ["Completed", summary?.completed_payout_amount, "Settled to M-Pesa"],
    ["Pending", summary?.pending_payout_amount, "Processing"],
    ["Today", summary?.today_payout_amount, "Today's deliveries"],
  ] as const;

  return (
    <main className="mx-auto max-w-7xl px-4 py-4 sm:px-6 sm:py-8 lg:px-8">
      <PageHeader
        variant="minimal"
        eyebrow="Driver finances"
        title="Earnings & payouts"
        description="Track delivery income and settlement status."
        icon={<Wallet className="h-5 w-5" />}
      />
      <section
        className="mt-5 grid grid-cols-2 gap-2 sm:gap-3 lg:grid-cols-4"
        aria-label="Earnings summary"
      >
        {metrics.map(([label, value, detail], index) =>
          summaryLoading ? (
            <Skeleton key={label} className="h-28 rounded-2xl" />
          ) : (
            <StatCard
              key={label}
              title={label}
              value={`KSh ${Number(value ?? 0).toLocaleString()}`}
              subtitle={detail}
              icon={index === 2 ? <Clock3 className="h-5 w-5" /> : <Banknote className="h-5 w-5" />}
              className="min-w-0"
            />
          ),
        )}
      </section>
      <section className="mt-5 overflow-hidden rounded-2xl border border-border bg-card shadow-sm sm:mt-7">
        <div className="flex items-center justify-between gap-3 border-b border-border p-4 sm:p-5">
          <div>
            <p className="text-[11px] font-bold uppercase tracking-wider text-primary">
              Settlements
            </p>
            <h2 className="mt-1 font-semibold text-primary-dark">Payout history</h2>
          </div>
          <Badge variant="neutral" size="sm">
            {payouts.length} records
          </Badge>
        </div>
        {payoutsLoading ? (
          <div className="space-y-3 p-4">
            <Skeleton className="h-16" />
            <Skeleton className="h-16" />
          </div>
        ) : payouts.length === 0 ? (
          <EmptyState
            size="sm"
            icon={<Wallet className="h-6 w-6" />}
            title="No payouts yet"
            description="Completed delivery payouts will be recorded here."
          />
        ) : (
          payouts.map((payout) => (
            <div
              key={payout.uuid}
              className="flex items-center justify-between gap-3 border-b border-border p-4 last:border-b-0 sm:p-5"
            >
              <div className="min-w-0">
                <p className="font-semibold text-primary-dark">Delivery payout</p>
                <p className="mt-1 text-xs text-muted-foreground">
                  {payout.created_at
                    ? new Date(payout.created_at).toLocaleDateString()
                    : "Date pending"}
                </p>
              </div>
              <div className="shrink-0 text-right">
                <p className="flex items-center gap-1 font-bold text-primary-dark">
                  KSh {Number(payout.amount).toLocaleString()}
                  <ArrowUpRight className="h-4 w-4 text-primary" />
                </p>
                <Badge variant={payout.status === "completed" ? "success" : "warning"} size="sm">
                  {payout.status}
                </Badge>
              </div>
            </div>
          ))
        )}
      </section>
    </main>
  );
}
