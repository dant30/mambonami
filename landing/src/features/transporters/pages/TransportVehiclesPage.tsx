import { Check, Save, Scale, Truck } from "lucide-react";
import { useEffect, useState } from "react";

import { getProfile, updateTransportProfile } from "../../../core/lib";
import type { TransportProfile } from "../../../core/lib";
import { FormField, FormSection } from "../../../shared/components/forms";
import { Button, Input, PageHeader, Select, Skeleton } from "../../../shared/components/ui";

const emptyVehicle: TransportProfile = {
  vehicle_type: "motorcycle",
  capacity_kg: 1,
  license_plate: "",
  driver_license: "",
};

export function TransportVehiclesPage() {
  const [form, setForm] = useState<TransportProfile>(emptyVehicle);
  const [isLoading, setIsLoading] = useState(true);
  const [isSaving, setIsSaving] = useState(false);
  const [message, setMessage] = useState("");
  const [error, setError] = useState("");

  useEffect(() => {
    void getProfile()
      .then((profile) => {
        setForm({ ...emptyVehicle, ...(profile.transport_profile || {}) });
      })
      .catch(() => setError("Unable to load vehicle details."))
      .finally(() => setIsLoading(false));
  }, []);

  const update = (field: keyof TransportProfile, value: string | number) =>
    setForm((current) => ({ ...current, [field]: value }));
  const submit = async (event: React.FormEvent) => {
    event.preventDefault();
    setIsSaving(true);
    setMessage("");
    setError("");
    try {
      await updateTransportProfile(form);
      setMessage("Vehicle details saved.");
    } catch {
      setError("We could not save the vehicle. Please check the details and try again.");
    } finally {
      setIsSaving(false);
    }
  };

  if (isLoading)
    return (
      <main className="mx-auto max-w-3xl px-4 py-4 sm:px-6 sm:py-8">
        <Skeleton className="h-96 rounded-2xl" />
      </main>
    );

  return (
    <main className="mx-auto max-w-3xl px-4 py-4 sm:px-6 sm:py-8 lg:px-8">
      <PageHeader
        variant="minimal"
        eyebrow="Fleet setup"
        title="Primary vehicle"
        description="Accurate capacity and licensing help match you with suitable delivery jobs."
        icon={<Truck className="h-5 w-5" />}
      />
      <form
        onSubmit={submit}
        className="mt-5 rounded-2xl border border-border bg-card p-4 shadow-sm sm:p-6"
      >
        <FormSection
          title="Vehicle details"
          description="Use the vehicle currently available for Mambonami deliveries."
          icon={<Scale className="h-4 w-4" />}
          divider={false}
        >
          <div className="grid gap-4 sm:grid-cols-2">
            <FormField label="Vehicle type" htmlFor="vehicle-type" required>
              <Select
                id="vehicle-type"
                aria-label="Vehicle type"
                value={form.vehicle_type || "motorcycle"}
                onChange={(value) => update("vehicle_type", value)}
                options={[
                  { value: "motorcycle", label: "Motorcycle" },
                  { value: "pickup", label: "Pickup truck" },
                  { value: "van", label: "Van" },
                  { value: "lorry", label: "Lorry" },
                ]}
              />
            </FormField>
            <FormField
              label="Capacity (kg)"
              htmlFor="vehicle-capacity"
              required
              helperText="Maximum safe produce load."
            >
              <Input
                id="vehicle-capacity"
                required
                min="1"
                type="number"
                inputMode="numeric"
                value={form.capacity_kg ?? ""}
                onChange={(event) => update("capacity_kg", Number(event.target.value))}
              />
            </FormField>
            <FormField label="License plate" htmlFor="license-plate" required>
              <Input
                id="license-plate"
                required
                autoCapitalize="characters"
                value={form.license_plate || ""}
                onChange={(event) => update("license_plate", event.target.value.toUpperCase())}
                placeholder="KBA 123A"
              />
            </FormField>
            <FormField label="Driver licence" htmlFor="driver-license" required>
              <Input
                id="driver-license"
                required
                value={form.driver_license || ""}
                onChange={(event) => update("driver_license", event.target.value)}
              />
            </FormField>
          </div>
        </FormSection>
        {message && (
          <p
            role="status"
            className="mt-4 flex items-center gap-2 rounded-xl bg-primary/10 p-3 text-sm font-medium text-primary"
          >
            <Check className="h-4 w-4" />
            {message}
          </p>
        )}
        {error && (
          <p
            role="alert"
            className="mt-4 rounded-xl bg-destructive/10 p-3 text-sm text-destructive"
          >
            {error}
          </p>
        )}
        <div className="mt-5 flex justify-end border-t border-border pt-4">
          <Button
            type="submit"
            isLoading={isSaving}
            leftIcon={<Save className="h-4 w-4" />}
            className="w-full sm:w-auto"
          >
            {isSaving ? "Saving..." : "Save vehicle"}
          </Button>
        </div>
      </form>
    </main>
  );
}
