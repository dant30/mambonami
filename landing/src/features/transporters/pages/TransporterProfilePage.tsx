import { Check, Save, Truck, UserCircle, Wallet } from "lucide-react";
import { useEffect, useState } from "react";

import { useAuth } from "../../../core/contexts/AuthContext";
import { updateProfile, updateTransportProfile } from "../../../core/lib";
import { FormField, FormSection } from "../../../shared/components/forms";
import { Button, Input, PageHeader, Select } from "../../../shared/components/ui";

type TransporterProfileForm = {
  first_name: string;
  last_name: string;
  email: string;
  phone: string;
  vehicle_type: string;
  license_plate: string;
  driver_license: string;
  capacity_kg: string;
  mpesa_number: string;
};

const emptyForm: TransporterProfileForm = {
  first_name: "",
  last_name: "",
  email: "",
  phone: "",
  vehicle_type: "van",
  license_plate: "",
  driver_license: "",
  capacity_kg: "100",
  mpesa_number: "",
};

export function TransporterProfilePage() {
  const { user } = useAuth();
  const [form, setForm] = useState<TransporterProfileForm>(emptyForm);
  const [isSaving, setIsSaving] = useState(false);
  const [message, setMessage] = useState("");
  const [error, setError] = useState("");

  useEffect(() => {
    const profile = (user?.transport_profile ?? {}) as Record<string, unknown>;
    setForm({
      first_name: user?.first_name ?? "",
      last_name: user?.last_name ?? "",
      email: user?.email ?? "",
      phone: user?.phone ?? "",
      vehicle_type: String(profile.vehicle_type ?? "van"),
      license_plate: String(profile.license_plate ?? ""),
      driver_license: String(profile.driver_license ?? ""),
      capacity_kg: String(profile.capacity_kg ?? "100"),
      mpesa_number: String(user?.mpesa_number ?? ""),
    });
  }, [user]);

  const updateField = <K extends keyof TransporterProfileForm>(
    field: K,
    value: TransporterProfileForm[K],
  ) => {
    setForm((current) => ({ ...current, [field]: value }));
  };

  const submit = async (event: React.FormEvent) => {
    event.preventDefault();
    setIsSaving(true);
    setMessage("");
    setError("");
    try {
      await updateProfile({
        first_name: form.first_name,
        last_name: form.last_name,
        email: form.email,
        mpesa_number: form.mpesa_number,
      });
      await updateTransportProfile({
        vehicle_type: form.vehicle_type,
        license_plate: form.license_plate,
        driver_license: form.driver_license,
        capacity_kg: Number(form.capacity_kg || 0),
      });
      setMessage("Transport profile updated successfully.");
    } catch {
      setError("We could not update your transport profile. Please try again.");
    } finally {
      setIsSaving(false);
    }
  };

  return (
    <main className="mx-auto max-w-5xl px-4 py-4 sm:px-6 sm:py-8 lg:px-8">
      <PageHeader
        eyebrow="Transport provider"
        title="Your transport profile"
        description="Update your delivery profile so customers can trust your service and assign routes faster."
        icon={<Truck className="h-5 w-5" />}
        variant="light"
      />

      <form
        onSubmit={submit}
        className="mt-5 rounded-2xl border border-border bg-card p-4 shadow-sm sm:p-6"
      >
        <FormSection
          title="Driver details"
          description="This information appears on your account and in dispatch coordination."
          icon={<UserCircle className="h-4 w-4" />}
        >
          <div className="grid gap-4 md:grid-cols-2">
            <FormField label="First name" htmlFor="driver-first-name">
              <Input
                id="driver-first-name"
                value={form.first_name}
                onChange={(event) => updateField("first_name", event.target.value)}
                placeholder="John"
              />
            </FormField>
            <FormField label="Last name" htmlFor="driver-last-name">
              <Input
                id="driver-last-name"
                value={form.last_name}
                onChange={(event) => updateField("last_name", event.target.value)}
                placeholder="Kamau"
              />
            </FormField>
            <FormField label="Email" htmlFor="driver-email">
              <Input
                id="driver-email"
                type="email"
                value={form.email}
                onChange={(event) => updateField("email", event.target.value)}
                placeholder="driver@example.com"
              />
            </FormField>
            <FormField label="Phone number" htmlFor="driver-phone">
              <Input
                id="driver-phone"
                value={form.phone}
                readOnly
                className="bg-muted text-muted-foreground"
              />
            </FormField>
          </div>
        </FormSection>

        <FormSection
          title="Vehicle information"
          description="Customers and dispatch teams rely on these details for route matching and verification."
          icon={<Truck className="h-4 w-4" />}
        >
          <div className="grid gap-4 md:grid-cols-2">
            <FormField label="Vehicle type" htmlFor="vehicle-type">
              <Select
                id="vehicle-type"
                aria-label="Vehicle type"
                value={form.vehicle_type}
                onChange={(value) => updateField("vehicle_type", value)}
                options={["motorcycle", "pickup", "van", "lorry"].map((type) => ({
                  value: type,
                  label: type.charAt(0).toUpperCase() + type.slice(1),
                }))}
              />
            </FormField>
            <FormField label="Capacity (kg)" htmlFor="capacity-kg">
              <Input
                id="capacity-kg"
                type="number"
                min="1"
                value={form.capacity_kg}
                onChange={(event) => updateField("capacity_kg", event.target.value)}
              />
            </FormField>
            <FormField label="License plate" htmlFor="license-plate">
              <Input
                id="license-plate"
                value={form.license_plate}
                onChange={(event) => updateField("license_plate", event.target.value)}
                placeholder="KBA 123A"
              />
            </FormField>
            <FormField label="Driver license" htmlFor="driver-license">
              <Input
                id="driver-license"
                value={form.driver_license}
                onChange={(event) => updateField("driver_license", event.target.value)}
                placeholder="DL-xxxx"
              />
            </FormField>
          </div>
        </FormSection>

        <FormSection
          title="Payment setup"
          description="For payouts and verification, keep the active M-Pesa account current."
          icon={<Wallet className="h-4 w-4" />}
        >
          <FormField label="M-Pesa number" htmlFor="transport-mpesa-number">
            <Input
              id="transport-mpesa-number"
              value={form.mpesa_number}
              onChange={(event) => updateField("mpesa_number", event.target.value)}
              placeholder="0712345678"
            />
          </FormField>
        </FormSection>

        {message && (
          <p
            role="status"
            className="flex items-center gap-2 rounded-xl bg-primary/10 p-3 text-sm text-primary"
          >
            <Check className="h-4 w-4" />
            {message}
          </p>
        )}
        {error && (
          <p role="alert" className="rounded-xl bg-destructive/10 p-3 text-sm text-destructive">
            {error}
          </p>
        )}

        <div className="flex justify-end border-t border-border pt-5">
          <Button type="submit" isLoading={isSaving} leftIcon={<Save className="h-4 w-4" />}>
            {isSaving ? "Saving profile..." : "Save changes"}
          </Button>
        </div>
      </form>
    </main>
  );
}
