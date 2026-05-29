import { createFileRoute } from "@tanstack/react-router";

export const Route = createFileRoute("/_site/how-it-works")({
  head: () => ({
    meta: [
      { title: "How It Works — MAMBONAMI" },
      { name: "description", content: "Browse, order and pay via M-Pesa. Funds released only when produce is delivered." },
      { property: "og:title", content: "How MAMBONAMI Works" },
      { property: "og:description", content: "Simple steps from farm listing to home delivery." },
    ],
  }),
  component: HowItWorks,
});

const steps = [
  { n: "01", t: "Farmers list produce", d: "Verified cooperatives upload products with harvest date and GPS location." },
  { n: "02", t: "Buyers shop", d: "Browse by produce, region or season. Add to cart and checkout in seconds." },
  { n: "03", t: "Pay via M-Pesa", d: "Funds are held safely in escrow until your order is confirmed delivered." },
  { n: "04", t: "Fast delivery", d: "Trusted transporters pick up from the farm and deliver to your doorstep." },
  { n: "05", t: "Farmers paid", d: "When you receive your order, the farmer is paid instantly. Everyone wins." },
];

function HowItWorks() {
  return (
    <>
      <section className="bg-gradient-warm py-20">
        <div className="container mx-auto px-4 sm:px-6 lg:px-8 max-w-3xl text-center">
          <h1 className="font-display text-5xl md:text-6xl font-bold mb-6">How it works</h1>
          <p className="text-xl text-muted-foreground">Five simple steps from harvest to home.</p>
        </div>
      </section>

      <section className="py-20">
        <div className="container mx-auto px-4 sm:px-6 lg:px-8 max-w-4xl">
          <ol className="space-y-6">
            {steps.map((s) => (
              <li key={s.n} className="bg-card rounded-2xl p-8 border border-border shadow-soft flex gap-6 items-start">
                <span className="font-display text-4xl font-black text-secondary shrink-0">{s.n}</span>
                <div>
                  <h3 className="font-display text-2xl font-bold mb-2">{s.t}</h3>
                  <p className="text-muted-foreground leading-relaxed">{s.d}</p>
                </div>
              </li>
            ))}
          </ol>
        </div>
      </section>
    </>
  );
}
