import { createFileRoute } from "@tanstack/react-router";

export const Route = createFileRoute("/_site/privacy")({
  head: () => ({ meta: [{ title: "Privacy Policy — MAMBONAMI" }, { name: "description", content: "How MAMBONAMI handles your data." }] }),
  component: () => (
    <section className="container mx-auto px-4 sm:px-6 lg:px-8 py-20 max-w-3xl prose">
      <h1 className="font-display text-5xl font-bold mb-6">Privacy Policy</h1>
      <p className="text-muted-foreground text-lg leading-relaxed">We respect your privacy. We collect only the information needed to deliver fresh produce and connect you with farmers. Your data is never sold. Contact hello@mambonami.com for any privacy questions.</p>
    </section>
  ),
});
