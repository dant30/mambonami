import { createFileRoute } from "@tanstack/react-router";

export const Route = createFileRoute("/_site/terms")({
  head: () => ({ meta: [{ title: "Terms of Service — MAMBONAMI" }, { name: "description", content: "Terms governing use of MAMBONAMI." }] }),
  component: () => (
    <section className="container mx-auto px-4 sm:px-6 lg:px-8 py-20 max-w-3xl">
      <h1 className="font-display text-5xl font-bold mb-6">Terms of Service</h1>
      <p className="text-muted-foreground text-lg leading-relaxed">By using MAMBONAMI you agree to fair and transparent dealings. Full terms are available on request — contact hello@mambonami.com.</p>
    </section>
  ),
});
