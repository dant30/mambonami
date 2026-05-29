import { createFileRoute } from "@tanstack/react-router";
import { useState } from "react";
import { ChevronDown } from "lucide-react";

export const Route = createFileRoute("/_site/faq")({
  head: () => ({
    meta: [
      { title: "FAQ — MAMBONAMI" },
      { name: "description", content: "Answers to common questions about ordering, delivery, payments and becoming a farmer partner." },
      { property: "og:title", content: "MAMBONAMI FAQ" },
      { property: "og:description", content: "Common questions answered." },
    ],
  }),
  component: FAQ,
});

const faqs = [
  { q: "How do I place an order?", a: "Browse produce on our app, add items to your cart and pay via M-Pesa. Your order ships within 24 hours of harvest." },
  { q: "What areas do you deliver to?", a: "We currently serve 47 counties across Kenya with same-day or next-day delivery depending on your location." },
  { q: "How are payments protected?", a: "All payments are held in secure M-Pesa escrow. Farmers are paid only when you confirm delivery." },
  { q: "Can I become a farmer partner?", a: "Yes! Visit our Contact page to apply. We work with verified cooperatives and independent farmers of every scale." },
  { q: "What if my order has an issue?", a: "Contact support within 24 hours of delivery and our team will resolve disputes quickly and fairly." },
  { q: "Are prices fixed or negotiable?", a: "Prices are set transparently by farmers based on harvest quality and market rates — no hidden markups." },
];

function FAQ() {
  const [open, setOpen] = useState<number | null>(0);
  return (
    <>
      <section className="bg-gradient-warm py-20">
        <div className="container mx-auto px-4 sm:px-6 lg:px-8 max-w-3xl text-center">
          <h1 className="font-display text-5xl md:text-6xl font-bold mb-6">Questions, answered.</h1>
          <p className="text-xl text-muted-foreground">Everything you need to know about MAMBONAMI.</p>
        </div>
      </section>

      <section className="py-20">
        <div className="container mx-auto px-4 sm:px-6 lg:px-8 max-w-3xl space-y-3">
          {faqs.map((f, i) => (
            <button
              key={i}
              onClick={() => setOpen(open === i ? null : i)}
              className="w-full text-left bg-card rounded-2xl p-6 border border-border shadow-soft hover:border-primary/30 transition-colors"
            >
              <div className="flex justify-between items-center gap-4">
                <h3 className="font-display text-lg font-bold">{f.q}</h3>
                <ChevronDown className={`w-5 h-5 text-primary transition-transform shrink-0 ${open === i ? "rotate-180" : ""}`} />
              </div>
              {open === i && <p className="text-muted-foreground mt-4 leading-relaxed">{f.a}</p>}
            </button>
          ))}
        </div>
      </section>
    </>
  );
}
