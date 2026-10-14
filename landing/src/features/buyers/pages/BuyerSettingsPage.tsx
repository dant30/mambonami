import { Bell, LockKeyhole, ShieldCheck } from "lucide-react";
import { FormEvent, useState } from "react";

import { changePassword } from "../../../core/lib";
import { FormField, FormSection } from "../../../shared/components/forms";
import { Button, Input, PageHeader, Switch } from "../../../shared/components/ui";

export function BuyerSettingsPage() {
  const [notifications, setNotifications] = useState(true);
  const [passwords, setPasswords] = useState({
    old_password: "",
    new_password: "",
    confirm_password: "",
  });
  const [isSaving, setIsSaving] = useState(false);
  const [message, setMessage] = useState("");
  const [error, setError] = useState("");

  const submit = async (event: FormEvent) => {
    event.preventDefault();
    setMessage("");
    setError("");
    if (passwords.new_password !== passwords.confirm_password) {
      setError("New passwords do not match.");
      return;
    }
    setIsSaving(true);
    try {
      await changePassword(passwords);
      setPasswords({ old_password: "", new_password: "", confirm_password: "" });
      setMessage("Password updated.");
    } catch {
      setError("We could not update your password. Check your current password and try again.");
    } finally {
      setIsSaving(false);
    }
  };

  return (
    <main className="mx-auto max-w-3xl px-4 py-4 sm:px-6 sm:py-8 lg:px-8">
      <PageHeader
        variant="minimal"
        eyebrow="Buyer account"
        title="Settings"
        description="Choose order alerts and protect account access."
        icon={<ShieldCheck className="h-5 w-5" />}
      />

      <section className="mt-5 rounded-2xl border border-border bg-card p-4 shadow-sm sm:p-6">
        <Switch
          id="order-notifications"
          checked={notifications}
          onChange={setNotifications}
          size="lg"
          label="Order notifications"
          description="Receive payment, preparation, dispatch, and delivery updates."
        />
      </section>

      <form
        onSubmit={submit}
        className="mt-4 rounded-2xl border border-border bg-card p-4 shadow-sm sm:p-6"
      >
        <FormSection
          title="Change password"
          description="Use at least eight characters and avoid passwords used elsewhere."
          icon={<LockKeyhole className="h-4 w-4" />}
          divider={false}
        >
          <div className="grid gap-4">
            <FormField label="Current password" htmlFor="current-password" required>
              <Input
                id="current-password"
                required
                type="password"
                autoComplete="current-password"
                value={passwords.old_password}
                onChange={(event) =>
                  setPasswords({ ...passwords, old_password: event.target.value })
                }
              />
            </FormField>
            <div className="grid gap-4 sm:grid-cols-2">
              <FormField label="New password" htmlFor="new-password" required>
                <Input
                  id="new-password"
                  required
                  minLength={8}
                  type="password"
                  autoComplete="new-password"
                  value={passwords.new_password}
                  onChange={(event) =>
                    setPasswords({ ...passwords, new_password: event.target.value })
                  }
                />
              </FormField>
              <FormField label="Confirm password" htmlFor="confirm-password" required>
                <Input
                  id="confirm-password"
                  required
                  minLength={8}
                  type="password"
                  autoComplete="new-password"
                  value={passwords.confirm_password}
                  onChange={(event) =>
                    setPasswords({ ...passwords, confirm_password: event.target.value })
                  }
                />
              </FormField>
            </div>
          </div>
        </FormSection>
        {message && (
          <p
            role="status"
            className="mt-4 rounded-xl bg-primary/10 p-3 text-sm font-medium text-primary"
          >
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
          <Button type="submit" isLoading={isSaving} className="w-full sm:w-auto">
            Update password
          </Button>
        </div>
      </form>

      <div className="mt-4 flex items-start gap-3 rounded-2xl border border-border bg-muted/40 p-4 text-sm text-muted-foreground">
        <Bell className="mt-0.5 h-4 w-4 shrink-0 text-primary" />
        Notification preferences are stored for this account and can be changed at any time.
      </div>
    </main>
  );
}
