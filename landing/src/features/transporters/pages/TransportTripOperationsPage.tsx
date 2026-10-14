import { useState } from "react";
import { ArrowLeft, CheckCircle2, Navigation, Truck } from "lucide-react";
import { Link, useParams } from "react-router-dom";

import {
  arriveDelivery,
  arrivePickup,
  generateTripOtp,
  recordPickup,
  startDeliveryNavigation,
  startPickupNavigation,
  useTrip,
} from "../../../core/lib";
import { Button } from "../../../shared/components/ui/Button";
import { Badge } from "../../../shared/components/ui/Badge";

const orderedStatuses = [
  "accepted",
  "en_route_pickup",
  "arrived_pickup",
  "picked_up",
  "en_route_delivery",
  "arrived_delivery",
  "otp_pending",
  "delivered",
];

export function TransportTripOperationsPage() {
  const { id = "" } = useParams();
  const { trip, isLoading, error } = useTrip(id);
  const [busy, setBusy] = useState(false);
  const [notice, setNotice] = useState("");
  const [actionError, setActionError] = useState("");

  const run = async (action: () => Promise<unknown>, successMessage: string) => {
    setBusy(true);
    setNotice("");
    setActionError("");
    try {
      await action();
      setNotice(successMessage);
      window.location.reload();
    } catch (requestError) {
      setActionError(
        requestError instanceof Error ? requestError.message : "Unable to update this trip.",
      );
    } finally {
      setBusy(false);
    }
  };

  if (isLoading)
    return (
      <main className="mx-auto max-w-4xl px-4 py-16">
        <div className="h-72 animate-pulse bg-muted" />
      </main>
    );
  if (error || !trip)
    return (
      <main className="mx-auto max-w-2xl px-4 py-20 text-center">
        <h1 className="text-3xl font-semibold text-primary-dark">Trip unavailable</h1>
        <Link to="/app/transport" className="mt-6 inline-flex text-sm font-bold text-primary">
          Back to trips
        </Link>
      </main>
    );

  const actionForStatus: Record<
    string,
    { label: string; run: () => Promise<unknown>; success: string }
  > = {
    accepted: {
      label: "Start pickup navigation",
      run: () => startPickupNavigation(id),
      success: "Pickup navigation started.",
    },
    en_route_pickup: {
      label: "Mark arrived at pickup",
      run: () => arrivePickup(id),
      success: "Pickup arrival recorded.",
    },
    arrived_pickup: {
      label: "Confirm pickup",
      run: () => recordPickup(id),
      success: "Pickup recorded.",
    },
    picked_up: {
      label: "Start delivery navigation",
      run: () => startDeliveryNavigation(id),
      success: "Delivery navigation started.",
    },
    en_route_delivery: {
      label: "Mark arrived at buyer",
      run: () => arriveDelivery(id),
      success: "Delivery arrival recorded.",
    },
    arrived_delivery: {
      label: "Send buyer confirmation code",
      run: () => generateTripOtp(id),
      success: "A delivery code was sent to the buyer.",
    },
    otp_pending: {
      label: "Resend buyer confirmation code",
      run: () => generateTripOtp(id),
      success: "A new delivery code was sent to the buyer.",
    },
  };
  const action = actionForStatus[trip.status];
  const stepIndex = orderedStatuses.indexOf(trip.status);

  return (
    <main className="mx-auto max-w-4xl px-4 py-4 sm:px-6 sm:py-8 lg:px-8">
      <Link
        to="/app/transport"
        className="inline-flex items-center gap-2 text-sm font-bold text-primary"
      >
        <ArrowLeft className="h-4 w-4" />
        Back to trips
      </Link>
      <header className="mt-5 flex flex-wrap items-end justify-between gap-4 border-b border-border pb-5">
        <div>
          <p className="text-xs font-bold uppercase text-primary">Trip #{trip.uuid.slice(0, 8)}</p>
          <h1 className="mt-2 text-3xl font-semibold capitalize text-primary-dark">
            {trip.status.replaceAll("_", " ")}
          </h1>
        </div>
        <Badge variant="info">
          KES {Number(trip.provider_payout ?? trip.agreed_fee ?? 0).toLocaleString()}
        </Badge>
      </header>
      {notice && (
        <p
          role="status"
          className="mt-5 border-l-4 border-emerald-600 bg-emerald-50 p-4 text-sm text-emerald-900"
        >
          {notice}
        </p>
      )}
      {actionError && (
        <p
          role="alert"
          className="mt-5 border-l-4 border-destructive bg-destructive/10 p-4 text-sm text-destructive"
        >
          {actionError}
        </p>
      )}
      <section className="mt-6 border-y border-border py-5">
        <h2 className="font-semibold text-primary-dark">Trip progress</h2>
        <ol className="mt-4 grid gap-3 sm:grid-cols-4">
          {orderedStatuses.map((status, index) => (
            <li key={status} className="flex items-center gap-2 text-sm">
              <span
                className={`flex h-7 w-7 shrink-0 items-center justify-center rounded-full ${index <= stepIndex ? "bg-primary text-primary-foreground" : "bg-muted text-muted-foreground"}`}
              >
                {index < stepIndex ? (
                  <CheckCircle2 className="h-4 w-4" />
                ) : index === stepIndex ? (
                  <Truck className="h-4 w-4" />
                ) : (
                  <span>{index + 1}</span>
                )}
              </span>
              <span
                className={
                  index <= stepIndex
                    ? "font-semibold capitalize text-foreground"
                    : "capitalize text-muted-foreground"
                }
              >
                {status.replaceAll("_", " ")}
              </span>
            </li>
          ))}
        </ol>
      </section>
      <section className="mt-6 grid gap-5 sm:grid-cols-2">
        <div className="border-b border-border py-4">
          <p className="text-xs font-bold uppercase text-muted-foreground">Pickup</p>
          <p className="mt-2 text-sm">{trip.pickup_address || "Pickup address unavailable"}</p>
        </div>
        <div className="border-b border-border py-4">
          <p className="text-xs font-bold uppercase text-muted-foreground">Delivery</p>
          <p className="mt-2 text-sm">
            {trip.delivery_address || trip.delivery_location || "Delivery address unavailable"}
          </p>
        </div>
      </section>
      {trip.status === "otp_pending" && (
        <div className="mt-6 flex items-start gap-3 border-l-4 border-primary bg-primary/5 p-4">
          <Navigation className="mt-0.5 h-4 w-4 shrink-0 text-primary" />
          <p className="text-sm text-foreground">
            A six-digit code has been sent to the buyer. Ask them to confirm receipt and upload
            their delivery photo from their order tracking page. Do not enter or share the buyer’s
            code.
          </p>
        </div>
      )}
      {action && (
        <div className="mt-7 flex justify-end">
          <Button disabled={busy} onClick={() => void run(action.run, action.success)}>
            {busy ? "Updating…" : action.label}
          </Button>
        </div>
      )}
      {trip.status === "delivered" && (
        <p className="mt-7 flex items-center gap-2 text-sm font-semibold text-emerald-700">
          <CheckCircle2 className="h-5 w-5" />
          Buyer confirmed delivery.
        </p>
      )}
    </main>
  );
}
