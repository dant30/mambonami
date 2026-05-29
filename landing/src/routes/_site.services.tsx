import { createFileRoute } from "@tanstack/react-router";
import { Users, Package, Truck, CreditCard, LifeBuoy, BarChart3 } from "lucide-react";

export const Route = createFileRoute("/_site/services")({
  head: () => ({
    meta: [
      { title: "Services — MAMBONAMI" },
      { name: "description", content: "Farmer onboarding, order management, logistics, secure M-Pesa escrow payments and support." },
      { property: "og:title", content: "MAMBONAMI Services" },
      { property: "og:description", content: "Everything you need to buy and sell fresh produce, end to end." },
    ],
  }),
  component: Services,
});

const services = [
  { Icon: Users, t: "Farmer Onboarding", d: "Cooperative verification, profile setup and best-practice training." },
  { Icon: Package, t: "Product Listings", d: "List harvests with photos, GPS location, and real-time stock updates." },
  { Icon: Truck, t: "Logistics", d: "Coordinated routes with trusted local transporters for fast delivery." },
  { Icon: CreditCard, t: "Secure Payments", d: "M-Pesa escrow that protects buyers and pays farmers on delivery." },
  { Icon: LifeBuoy, t: "Dispute Resolution", d: "Friendly support team and clear policies if anything goes wrong." },
  { Icon: BarChart3, t: "Insights & Analytics", d: "Farmers see sales trends; buyers track orders and seasonality." },
];

function Services() {
  return (
    <>
      <section className="bg-gradient-warm py-20">
        <div className="container mx-auto px-4 sm:px-6 lg:px-8 max-w-3xl text-center">
          <h1 className="font-display text-5xl md:text-6xl font-bold mb-6">Services</h1>
          <p className="text-xl text-muted-foreground">A complete platform for the modern farm-to-table economy.</p>
        </div>
      </section>

      <section className="py-20">
        <div className="container mx-auto px-4 sm:px-6 lg:px-8 grid md:grid-cols-2 lg:grid-cols-3 gap-6">
          {services.map(({ Icon, t, d }) => (
            <div key={t} className="bg-card rounded-2xl p-8 border border-border shadow-soft hover:shadow-glow transition-shadow">
              <div className="w-12 h-12 rounded-xl bg-gradient-hero flex items-center justify-center mb-5">
                <Icon className="w-6 h-6 text-primary-foreground" />
              </div>
              <h3 className="font-display text-xl font-bold mb-2">{t}</h3>
              <p className="text-muted-foreground">{d}</p>
            </div>
          ))}
        </div>
      </section>
    </>
  );
}
