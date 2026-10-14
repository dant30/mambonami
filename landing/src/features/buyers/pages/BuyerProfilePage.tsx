import { Check, Save, UserCircle } from "lucide-react";
import { FormEvent, useState } from "react";

import { useAuth } from "../../../core/contexts/AuthContext";
import { updateProfile } from "../../../core/lib";
import { FormField, FormSection } from "../../../shared/components/forms";
import { Button, Input, PageHeader } from "../../../shared/components/ui";

export function BuyerProfilePage() {
  const { user } = useAuth();
  const [form, setForm] = useState({
    first_name: user?.first_name ?? "",
    last_name: user?.last_name ?? "",
    email: user?.email ?? "",
    phone: user?.phone ?? "",
  });
  const [isSaving, setIsSaving] = useState(false);
  const [message, setMessage] = useState("");
  const [error, setError] = useState("");

  const submit = async (event: FormEvent) => {
    event.preventDefault();
    setIsSaving(true);
    setMessage("");
    setError("");
    try {
      await updateProfile(form);
      setMessage("Profile details saved.");
    } catch {
      setError("We could not save your profile. Please try again.");
    } finally {
      setIsSaving(false);
    }
  };

  return (
    <main className="mx-auto max-w-3xl px-4 py-4 sm:px-6 sm:py-8 lg:px-8">
      <PageHeader
        variant="minimal"
        eyebrow="Buyer account"
        title="Your profile"
        description="Keep your contact details current for payment and delivery updates."
        icon={<UserCircle className="h-5 w-5" />}
      />
      <form
        onSubmit={submit}
        className="mt-5 rounded-2xl border border-border bg-card p-4 shadow-sm sm:p-6"
      >
        <FormSection
          title="Contact details"
          description="Your phone number is verified and cannot be changed here."
          icon={<UserCircle className="h-4 w-4" />}
          divider={false}
        >
          <div className="grid gap-4 sm:grid-cols-2">
            <FormField label="First name" htmlFor="buyer-first-name" required>
              <Input
                id="buyer-first-name"
                required
                autoComplete="given-name"
                value={form.first_name}
                onChange={(event) => setForm({ ...form, first_name: event.target.value })}
              />
            </FormField>
            <FormField label="Last name" htmlFor="buyer-last-name" required>
              <Input
                id="buyer-last-name"
                required
                autoComplete="family-name"
                value={form.last_name}
                onChange={(event) => setForm({ ...form, last_name: event.target.value })}
              />
            </FormField>
            <FormField label="Email" htmlFor="buyer-email">
              <Input
                id="buyer-email"
                type="email"
                autoComplete="email"
                value={form.email}
                onChange={(event) => setForm({ ...form, email: event.target.value })}
              />
            </FormField>
            <FormField label="Verified phone" htmlFor="buyer-phone">
              <Input
                id="buyer-phone"
                value={form.phone}
                readOnly
                className="bg-muted text-muted-foreground"
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
            {isSaving ? "Saving..." : "Save profile"}
          </Button>
        </div>
      </form>
    </main>
  );
}
