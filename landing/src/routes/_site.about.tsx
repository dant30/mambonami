import { createFileRoute } from "@tanstack/react-router";
import farmerImg from "@/assets/farmer.jpg";

export const Route = createFileRoute("/_site/about")({
  head: () => ({
    meta: [
      { title: "About — MAMBONAMI" },
      { name: "description", content: "Our mission: connect Kenyan farmers directly to consumers with fair trade and transparency." },
      { property: "og:title", content: "About MAMBONAMI" },
      { property: "og:description", content: "Empowering local farmers, feeding families with fresh produce." },
    ],
  }),
  component: About,
});

function About() {
  return (
    <>
      <section className="bg-gradient-warm py-20">
        <div className="container mx-auto px-4 sm:px-6 lg:px-8 max-w-3xl">
          <span className="text-secondary font-semibold uppercase tracking-wider text-sm">Our Story</span>
          <h1 className="font-display text-5xl md:text-6xl font-bold mt-3 mb-6">Food, the way it should be.</h1>
          <p className="text-xl text-muted-foreground leading-relaxed">
            MAMBONAMI was founded to fix a broken supply chain — one where farmers earn pennies and buyers pay a premium. We're building a direct bridge between Kenya's growers and its kitchens.
          </p>
        </div>
      </section>

      <section className="py-20">
        <div className="container mx-auto px-4 sm:px-6 lg:px-8 grid lg:grid-cols-2 gap-12 items-center">
          <img src={farmerImg} alt="Farmer" loading="lazy" width={1200} height={1400} className="rounded-3xl shadow-soft object-cover aspect-[5/6]" />
          <div>
            <h2 className="font-display text-4xl font-bold mb-6">Our mission</h2>
            <p className="text-muted-foreground text-lg leading-relaxed mb-4">
              Every meal tells a story of the hands that grew it. We believe those hands deserve fair recognition, fair pay, and a direct line to the people they feed.
            </p>
            <p className="text-muted-foreground text-lg leading-relaxed">
              By cutting out exploitative middlemen and embracing transparent technology, we're creating a marketplace where everyone wins — farmers, families, and our shared land.
            </p>
          </div>
        </div>
      </section>

      <section className="py-20 bg-accent/40">
        <div className="container mx-auto px-4 sm:px-6 lg:px-8 max-w-5xl">
          <h2 className="font-display text-4xl font-bold text-center mb-12">What we stand for</h2>
          <div className="grid md:grid-cols-3 gap-6">
            {[
              { t: "Fair Trade", d: "Transparent pricing so farmers earn what their work is worth." },
              { t: "Freshness", d: "From harvest to home in under 24 hours, always." },
              { t: "Community", d: "Supporting local cooperatives and growing rural prosperity." },
            ].map((v) => (
              <div key={v.t} className="bg-card rounded-2xl p-8 border border-border">
                <h3 className="font-display text-2xl font-bold mb-2 text-primary">{v.t}</h3>
                <p className="text-muted-foreground">{v.d}</p>
              </div>
            ))}
          </div>
        </div>
      </section>
    </>
  );
}
