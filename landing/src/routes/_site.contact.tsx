import { createFileRoute } from "@tanstack/react-router";
import { Mail, Phone, MapPin, Send } from "lucide-react";

export const Route = createFileRoute("/_site/contact")({
  head: () => ({
    meta: [
      { title: "Contact — MAMBONAMI" },
      { name: "description", content: "Get in touch with the MAMBONAMI team. We're here to help farmers and buyers." },
      { property: "og:title", content: "Contact MAMBONAMI" },
      { property: "og:description", content: "Reach our team for partnerships, support, or general questions." },
    ],
  }),
  component: Contact,
});

function Contact() {
  return (
    <>
      <section className="bg-gradient-warm py-20">
        <div className="container mx-auto px-4 sm:px-6 lg:px-8 max-w-3xl text-center">
          <h1 className="font-display text-5xl md:text-6xl font-bold mb-6">Let's talk.</h1>
          <p className="text-xl text-muted-foreground">Whether you're a farmer, buyer, or partner — we'd love to hear from you.</p>
        </div>
      </section>

      <section className="py-20">
        <div className="container mx-auto px-4 sm:px-6 lg:px-8 grid lg:grid-cols-2 gap-12 max-w-5xl">
          <div className="space-y-6">
            {[
              { Icon: Mail, t: "Email", d: "hello@mambonami.com" },
              { Icon: Phone, t: "Phone / WhatsApp", d: "+254 724 167 076" },
              { Icon: MapPin, t: "Office", d: "Nairobi, Kenya" },
            ].map(({ Icon, t, d }) => (
              <div key={t} className="flex gap-4 items-start bg-card p-6 rounded-2xl border border-border shadow-soft">
                <div className="w-11 h-11 rounded-xl bg-gradient-hero flex items-center justify-center shrink-0">
                  <Icon className="w-5 h-5 text-primary-foreground" />
                </div>
                <div>
                  <div className="font-display font-bold">{t}</div>
                  <div className="text-muted-foreground">{d}</div>
                </div>
              </div>
            ))}
          </div>

          <form
            className="bg-card p-8 rounded-2xl border border-border shadow-soft space-y-4"
            onSubmit={(e) => {
              e.preventDefault();
              alert("Thank you — we'll be in touch shortly.");
            }}
          >
            <div>
              <label className="text-sm font-semibold mb-1.5 block">Name</label>
              <input required className="w-full rounded-lg border border-input bg-background px-4 py-2.5 focus:outline-none focus:ring-2 focus:ring-primary" />
            </div>
            <div>
              <label className="text-sm font-semibold mb-1.5 block">Email</label>
              <input required type="email" className="w-full rounded-lg border border-input bg-background px-4 py-2.5 focus:outline-none focus:ring-2 focus:ring-primary" />
            </div>
            <div>
              <label className="text-sm font-semibold mb-1.5 block">Message</label>
              <textarea required rows={5} className="w-full rounded-lg border border-input bg-background px-4 py-2.5 focus:outline-none focus:ring-2 focus:ring-primary resize-none" />
            </div>
            <button className="inline-flex items-center gap-2 rounded-full bg-primary text-primary-foreground px-6 py-3 font-semibold hover:bg-primary-dark transition shadow-soft">
              Send Message <Send className="w-4 h-4" />
            </button>
          </form>
        </div>
      </section>
    </>
  );
}
