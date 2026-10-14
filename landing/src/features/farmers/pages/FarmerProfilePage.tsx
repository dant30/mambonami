import { Check, MapPin, Phone, Save, Sprout, Wallet } from "lucide-react";
import { useEffect, useState } from "react";

import { useAuth } from "../../../core/contexts/AuthContext";
import { updateProfile } from "../../../core/lib";
import { FormField, FormSection } from "../../../shared/components/forms";
import { Button, Input, PageHeader, Select } from "../../../shared/components/ui";

type FarmerProfileForm = {
  first_name: string;
  last_name: string;
  email: string;
  phone: string;
  farm_name: string;
  farm_address: string;
  farm_region: string;
  mpesa_number: string;
};

const emptyForm: FarmerProfileForm = {
  first_name: "",
  last_name: "",
  email: "",
  phone: "",
  farm_name: "",
  farm_address: "",
  farm_region: "Nairobi",
  mpesa_number: "",
};

export function FarmerProfilePage() {
  const { user } = useAuth();
  const [form, setForm] = useState<FarmerProfileForm>(emptyForm);
  const [isSaving, setIsSaving] = useState(false);
  const [message, setMessage] = useState("");
  const [error, setError] = useState("");

  useEffect(() => {
    setForm({
      first_name: user?.first_name ?? "",
      last_name: user?.last_name ?? "",
      email: user?.email ?? "",
      phone: user?.phone ?? "",
      farm_name: String(user?.farm_name ?? user?.business_name ?? ""),
      farm_address: String(user?.farm_address ?? user?.business_address ?? ""),
      farm_region: String(user?.farm_region ?? "Nairobi"),
      mpesa_number: String(user?.mpesa_number ?? ""),
    });
  }, [user]);

  const updateField = <K extends keyof FarmerProfileForm>(
    field: K,
    value: FarmerProfileForm[K],
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
        farm_name: form.farm_name,
        farm_address: form.farm_address,
        farm_region: form.farm_region,
        mpesa_number: form.mpesa_number,
      });
      setMessage("Farm profile updated successfully.");
    } catch {
      setError("We could not update your farm profile. Please try again.");
    } finally {
      setIsSaving(false);
    }
  };

  return (
    <main className="mx-auto max-w-5xl px-4 py-4 sm:px-6 sm:py-8 lg:px-8">
      <PageHeader
        eyebrow="Farmer workspace"
        title="Your farm profile"
        description="Keep your contact, farm, and payment details ready for buyer orders and payouts."
        icon={<Sprout className="h-5 w-5" />}
        variant="light"
      />

      <form
        onSubmit={submit}
        className="mt-5 rounded-2xl border border-border bg-card p-4 shadow-sm sm:p-6"
      >
        <FormSection
          title="Primary details"
          description="Your personal information is shared with customers and support teams."
          icon={<Phone className="h-4 w-4" />}
        >
          <div className="grid gap-4 md:grid-cols-2">
            <FormField label="First name" htmlFor="farmer-first-name">
              <Input
                id="farmer-first-name"
                value={form.first_name}
                onChange={(event) => updateField("first_name", event.target.value)}
                placeholder="Akinyi"
              />
            </FormField>
            <FormField label="Last name" htmlFor="farmer-last-name">
              <Input
                id="farmer-last-name"
                value={form.last_name}
                onChange={(event) => updateField("last_name", event.target.value)}
                placeholder="Wanjiku"
              />
            </FormField>
            <FormField label="Email" htmlFor="farmer-email">
              <Input
                id="farmer-email"
                type="email"
                value={form.email}
                onChange={(event) => updateField("email", event.target.value)}
                placeholder="you@example.com"
              />
            </FormField>
            <FormField label="Phone number" htmlFor="farmer-phone">
              <Input
                id="farmer-phone"
                value={form.phone}
                readOnly
                className="bg-muted text-muted-foreground"
              />
            </FormField>
          </div>
        </FormSection>

        <FormSection
          title="Farm details"
          description="This information helps buyers identify and trust your farm."
          icon={<MapPin className="h-4 w-4" />}
        >
          <div className="grid gap-4 md:grid-cols-2">
            <FormField label="Farm name" htmlFor="farm-name">
              <Input
                id="farm-name"
                value={form.farm_name}
                onChange={(event) => updateField("farm_name", event.target.value)}
                placeholder="Nairobi Greens"
              />
            </FormField>
            <FormField label="Farm region" htmlFor="farm-region">
              <Select
                id="farm-region"
                aria-label="Farm region"
                value={form.farm_region}
                onChange={(value) => updateField("farm_region", value)}
                options={[
                  "Nairobi",
                  "Central",
                  "Eastern",
                  "Rift Valley",
                  "Western",
                  "Coast",
                  "Nyanza",
                ].map((region) => ({ value: region, label: region }))}
              />
            </FormField>
            <FormField label="Farm address" htmlFor="farm-address" className="md:col-span-2">
              <Input
                id="farm-address"
                value={form.farm_address}
                onChange={(event) => updateField("farm_address", event.target.value)}
                placeholder="Kisii Road, Kiambu"
              />
            </FormField>
          </div>
        </FormSection>

        <FormSection
          title="Payment details"
          description="Buyers and the platform use this information for escrow and payout flows."
          icon={<Wallet className="h-4 w-4" />}
        >
          <FormField label="M-Pesa number" htmlFor="mpesa-number">
            <Input
              id="mpesa-number"
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
