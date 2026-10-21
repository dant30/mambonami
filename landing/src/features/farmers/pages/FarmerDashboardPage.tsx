import { ClipboardList, Plus } from "lucide-react";
import { useNavigate } from "react-router-dom";

import { useAuth } from "../../../core/contexts/AuthContext";
import { useFarmerDashboard } from "../../../core/lib";
import { getTimeGreeting } from "../../../core/utils";
import { Button, PageHeader } from "../../../shared/components/ui";
import {
  FarmerEarningsSnapshot,
  FarmerMetricCards,
  FarmerOrderList,
  FarmerProductPreview,
  FarmerQuickActions,
} from "../components";

export function FarmerDashboardPage() {
  const navigate = useNavigate();
  const { user } = useAuth();
  const { data, summary, isLoading, error } = useFarmerDashboard();
  const products = data?.products ?? [];
  const subOrders = data?.subOrders ?? [];

  return (
    <main className="min-h-full bg-background">
      <div className="mx-auto max-w-7xl space-y-4 px-4 py-4 sm:space-y-6 sm:px-6 sm:py-6 lg:px-8 lg:py-8">
        <PageHeader
          variant="dark"
          eyebrow="Your farm business"
          title={`${getTimeGreeting()}, ${user?.first_name || "Farmer"}.`}
          description="Prioritise paid orders, keep available stock accurate, and monitor payouts."
          actions={
            <div className="grid w-full grid-cols-2 gap-2 sm:flex sm:w-auto">
              <Button
                type="button"
                size="sm"
                leftIcon={<Plus className="h-4 w-4" />}
                onClick={() => navigate("/app/farmer/products/new")}
              >
                Add product
              </Button>
              <Button
                type="button"
                size="sm"
                variant="outline"
                className="!text-white hover:!text-primary-dark"
                leftIcon={<ClipboardList className="h-4 w-4" />}
                onClick={() => navigate("/app/farmer/orders")}
              >
                View orders
              </Button>
            </div>
          }
        />
        {Boolean(error) && (
          <p role="alert" className="rounded-xl bg-destructive/10 p-4 text-sm text-destructive">
            Unable to load your farm workspace.
          </p>
        )}
        <FarmerMetricCards summary={summary} products={products} isLoading={isLoading} />
        <section className="grid gap-4 sm:gap-6 lg:grid-cols-[1fr_1fr]">
          <FarmerProductPreview products={products} />
          <FarmerOrderList subOrders={subOrders} isLoading={isLoading} />
        </section>
        <FarmerEarningsSnapshot summary={summary} isLoading={isLoading} />
        <FarmerQuickActions />
      </div>
    </main>
  );
}
