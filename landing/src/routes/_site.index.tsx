import { createFileRoute, Link } from "@tanstack/react-router";
import { ArrowRight, Sprout, ShoppingBasket, Truck, ShieldCheck, Star, Quote, Store, Building2, Users, Heart, Salad, PackageSearch, Leaf, Mail, CheckCircle2 } from "lucide-react";
import { useState } from "react";
import { toast } from "sonner";
import { notifyComingSoon } from "@/lib/coming-soon";
import heroImg from "@/assets/hero-farm.jpg";
import farmerImg from "@/assets/farmer.jpg";
import produceImg from "@/assets/produce.jpg";
import { Particles } from "@/components/site/Particles";
import { useCountUp } from "@/hooks/use-count-up";
import { Carousel, CarouselContent, CarouselItem, CarouselNext, CarouselPrevious } from "@/components/ui/carousel";
import Autoplay from "embla-carousel-autoplay";

export const Route = createFileRoute("/_site/")({
  head: () => ({
    meta: [
      { title: "MAMBONAMI — Fresh from Farm to Table" },
      { name: "description", content: "Connecting Kenyan farmers directly to your kitchen. Fair prices, fresh produce, doorstep delivery." },
      { property: "og:title", content: "MAMBONAMI — Fresh from Farm to Table" },
      { property: "og:description", content: "Buy directly from local farmers. Fresh produce delivered to your door." },
    ],
  }),
  component: Home,
});

function CountUpStat({ value, label }: { value: string; label: string }) {
  const { display, ref } = useCountUp(value, 2000);
  return (
    <div className="glass rounded-2xl px-4 py-3 text-center">
      <div ref={ref} className="font-display text-2xl font-bold text-secondary">{display}</div>
      <div className="text-[11px] uppercase tracking-wider text-primary-foreground/80">{label}</div>
    </div>
  );
}

function CountUpBigStat({ value, label }: { value: string; label: string }) {
  const { display, ref } = useCountUp(value, 2500);
  return (
    <div>
      <div ref={ref} className="font-display text-3xl md:text-4xl font-bold text-primary">{display}</div>
      <div className="text-sm text-muted-foreground mt-1">{label}</div>
    </div>
  );
}

function Home() {
  return (
    <>
      {/* Hero */}
      <section className="relative overflow-hidden">
        <div className="absolute inset-0 -z-10">
          <img src={heroImg} alt="" className="w-full h-full object-cover" width={1600} height={1100} />
          <div className="absolute inset-0 bg-gradient-to-r from-primary-dark/90 via-primary-dark/70 to-primary-dark/40" />
        </div>
        {/* Particle network overlay */}
        <Particles className="absolute inset-0 -z-[5] w-full h-full pointer-events-none" color="rgba(255,255,255,0.7)" count={80} />
        {/* Floating glass orbs */}
        <div className="absolute -top-20 -left-20 w-72 h-72 rounded-full bg-secondary/30 blur-3xl animate-float -z-[5]" />
        <div className="absolute bottom-0 right-0 w-96 h-96 rounded-full bg-primary/40 blur-3xl animate-float -z-[5]" style={{ animationDelay: "1.5s" }} />

        <div className="container mx-auto px-4 sm:px-6 lg:px-8 py-24 md:py-36 text-primary-foreground">
          <div className="max-w-2xl animate-fade-in-up">
            <span className="inline-flex items-center gap-2 rounded-full glass px-4 py-1.5 text-xs font-medium text-secondary mb-6">
              <Sprout className="w-3.5 h-3.5 animate-float" /> Farmers • Retailers • Consumers
            </span>
            <h1 className="font-display text-5xl md:text-7xl font-black leading-[1.05] mb-6">
              From <span className="text-gradient animate-gradient bg-gradient-hero italic">farm</span> to retailers, restaurants &amp; homes.
            </h1>
            <p className="text-lg md:text-xl text-primary-foreground/85 mb-10 max-w-xl">
              MAMBONAMI is Kenya's direct-trade marketplace — connecting farmers with retailers, hotels, restaurants, and families. Fair prices, transparent sourcing, doorstep delivery.
            </p>
            <div className="flex flex-wrap gap-3">
              <button type="button" onClick={notifyComingSoon} className="inline-flex items-center gap-2 rounded-full bg-secondary text-secondary-foreground px-7 py-3.5 font-semibold hover:bg-secondary/90 transition shadow-glow hover:scale-105 duration-300">
                Get Started <ArrowRight className="w-4 h-4" />
              </button>
              <Link to="/how-it-works" className="inline-flex items-center gap-2 rounded-full glass text-primary-foreground px-7 py-3.5 font-semibold hover:bg-white/20 transition">
                How it works
              </Link>
            </div>

            {/* Glass stat strip */}
            <div className="mt-12 grid grid-cols-3 gap-3 max-w-lg">
              {[
                { n: "2.5K+", l: "Farmers" },
                { n: "300+", l: "Retailers" },
                { n: "47", l: "Counties" },
              ].map((s) => (
                <CountUpStat key={s.l} value={s.n} label={s.l} />
              ))}
            </div>
          </div>
        </div>
      </section>


      {/* Retailer / B2B band */}
      <section className="bg-primary-dark text-primary-foreground overflow-hidden">
        <div className="flex gap-12 py-4 animate-marquee whitespace-nowrap text-sm uppercase tracking-[0.25em] font-semibold text-secondary">
          {[...Array(2)].map((_, i) => (
            <div key={i} className="flex gap-12 shrink-0">
              <span>🥬 Fresh Daily</span><span>🏪 Trusted by 300+ Retailers</span><span>🍽️ Restaurant Supply</span><span>🚚 Bulk &amp; Wholesale</span><span>🌍 47 Counties</span><span>💳 M-Pesa Escrow</span>
            </div>
          ))}
        </div>
      </section>


      {/* Stats */}
      <section className="border-b border-border bg-background">
        <div className="container mx-auto px-4 sm:px-6 lg:px-8 py-10 grid grid-cols-2 md:grid-cols-4 gap-6 text-center">
          {[
            { n: "2,500+", l: "Farmers onboarded" },
            { n: "15K+", l: "Happy customers" },
            { n: "47", l: "Counties served" },
            { n: "24h", l: "Avg. delivery time" },
          ].map((s) => (
            <CountUpBigStat key={s.l} value={s.n} label={s.l} />
          ))}
        </div>
      </section>

      {/* Features */}
      <section className="py-24 bg-gradient-warm">
        <div className="container mx-auto px-4 sm:px-6 lg:px-8">
          <div className="max-w-2xl mx-auto text-center mb-16">
            <h2 className="font-display text-4xl md:text-5xl font-bold mb-4">A market built for everyone</h2>
            <p className="text-muted-foreground text-lg">No middlemen. No markups. Just fair value moving from soil to supper.</p>
          </div>
          <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-6">
            {[
              { Icon: Sprout, title: "For Farmers", body: "List harvests, get fair prices, receive secure M-Pesa payments straight to your phone." },
              { Icon: Store, title: "For Retailers", body: "Stock your shelves with consistent, traceable produce. Bulk pricing, scheduled deliveries, invoiced." },
              { Icon: Building2, title: "For Restaurants & Hotels", body: "Reliable wholesale supply for kitchens — chef-grade quality with same-day procurement." },
              { Icon: ShoppingBasket, title: "For Consumers", body: "Browse seasonal produce by location, order in seconds, and pay only when delivered." },
            ].map(({ Icon, title, body }, i) => (
              <div key={title} className="glass-card rounded-2xl p-8 shadow-soft hover-lift animate-fade-in-up" style={{ animationDelay: `${i * 100}ms` }}>
                <div className="w-12 h-12 rounded-xl bg-gradient-hero flex items-center justify-center mb-5">
                  <Icon className="w-6 h-6 text-primary-foreground" />
                </div>
                <h3 className="font-display text-2xl font-bold mb-2">{title}</h3>
                <p className="text-muted-foreground leading-relaxed">{body}</p>
              </div>
            ))}
          </div>

        </div>
      </section>

      {/* Split: Farmer story */}
      <section className="py-24">
        <div className="container mx-auto px-4 sm:px-6 lg:px-8 grid lg:grid-cols-2 gap-12 items-center">
          <div className="relative">
            <img src={farmerImg} alt="Smallholder farmer with fresh harvest" loading="lazy" width={1200} height={1400} className="rounded-3xl shadow-glow object-cover w-full aspect-[5/6]" />
            <div className="absolute -bottom-6 -right-6 glass-card rounded-2xl p-5 shadow-glow max-w-xs hidden sm:block">
              <div className="flex gap-1 text-secondary mb-2">
                {[...Array(5)].map((_, i) => <Star key={i} className="w-4 h-4 fill-current" />)}
              </div>
              <p className="text-sm font-medium">"My income doubled in 3 months."</p>
              <p className="text-xs text-muted-foreground mt-1">— Wanjiku, Nyeri</p>
            </div>
          </div>
          <div>
            <span className="text-secondary font-semibold uppercase tracking-wider text-sm">Empowering Growers</span>
            <h2 className="font-display text-4xl md:text-5xl font-bold mt-3 mb-6">Real farmers. Real impact.</h2>
            <p className="text-muted-foreground text-lg mb-6 leading-relaxed">
              We work with farming cooperatives across Kenya — verifying farms, training on best practices, and ensuring every shilling reaches the people who grew the food.
            </p>
            <ul className="space-y-3">
              {["Verified cooperative membership", "Transparent escrow payments", "Real-time harvest tracking", "Direct buyer relationships"].map((f) => (
                <li key={f} className="flex items-center gap-3">
                  <ShieldCheck className="w-5 h-5 text-primary" />
                  <span>{f}</span>
                </li>
              ))}
            </ul>
          </div>
        </div>
      </section>

      {/* Produce showcase */}
      <section className="py-24 bg-accent/40">
        <div className="container mx-auto px-4 sm:px-6 lg:px-8 grid lg:grid-cols-2 gap-12 items-center">
          <div className="order-2 lg:order-1">
            <span className="text-secondary font-semibold uppercase tracking-wider text-sm">Seasonal & Fresh</span>
            <h2 className="font-display text-4xl md:text-5xl font-bold mt-3 mb-6">Picked today. On your table tomorrow.</h2>
            <p className="text-muted-foreground text-lg leading-relaxed mb-6">
              From sukuma wiki to sweet mangoes, every order ships within 24 hours of harvest. You'll know exactly which farm grew it, when it was picked, and how it traveled.
            </p>
            <Link to="/services" className="inline-flex items-center gap-2 text-primary font-semibold hover:text-primary-dark">
              Explore our services <ArrowRight className="w-4 h-4" />
            </Link>
          </div>
          <img src={produceImg} alt="Assortment of fresh Kenyan produce" loading="lazy" width={1400} height={1000} className="rounded-3xl shadow-soft order-1 lg:order-2" />
        </div>
      </section>

      {/* Testimonials */}
      <section className="py-24 bg-gradient-warm">
        <div className="container mx-auto px-4 sm:px-6 lg:px-8 max-w-6xl">
          <div className="text-center mb-14">
            <span className="text-secondary font-semibold uppercase tracking-wider text-sm">Voices from the chain</span>
            <h2 className="font-display text-4xl md:text-5xl font-bold mt-3">Loved by farmers, retailers &amp; families.</h2>
          </div>
          <Carousel
            opts={{
              align: "start",
              loop: true,
            }}
            plugins={[
              Autoplay({ delay: 4000, stopOnInteraction: false }),
            ]}
            className="w-full"
          >
            <CarouselContent className="-ml-4">
              {[
                { q: "My income doubled in 3 months. I now sell straight to retailers in Nairobi without a broker.", who: "Wanjiku", role: "Farmer, Nyeri", Icon: Sprout },
                { q: "We've cut our produce sourcing costs by 28% and our shelves are fresher than ever. Game-changer for our duka.", who: "Mwangi", role: "Retailer, Naivas-affiliated shop", Icon: Store },
                { q: "Reliable, traceable supply for our kitchen. Same-day delivery means zero waste and happier guests.", who: "Chef Achieng", role: "Executive Chef, Nairobi Hotel", Icon: Building2 },
                { q: "I order vegetables every Tuesday for my family and the quality is unmatched. It feels good knowing exactly which farm grew our food.", who: "Sarah", role: "Home Cook, Kiambu", Icon: Heart },
                { q: "Our school feeding program now sources directly from MAMBONAMI farmers. Fresher meals for 800 children, lower costs, and full traceability.", who: "Mr. Oduor", role: "Headteacher, Kisumu Primary", Icon: Salad },
              ].map(({ q, who, role, Icon }, i) => (
                <CarouselItem key={who} className="pl-4 basis-full md:basis-1/2 lg:basis-1/3">
                  <div className="glass-card rounded-2xl p-7 shadow-soft hover-lift h-full animate-fade-in-up" style={{ animationDelay: `${i * 120}ms` }}>
                    <Quote className="w-8 h-8 text-secondary mb-4" />
                    <p className="text-base leading-relaxed mb-6">"{q}"</p>
                    <div className="flex items-center gap-3 pt-4 border-t border-border">
                      <div className="w-10 h-10 rounded-full bg-gradient-hero flex items-center justify-center">
                        <Icon className="w-5 h-5 text-primary-foreground" />
                      </div>
                      <div>
                        <div className="font-display font-bold text-sm">{who}</div>
                        <div className="text-xs text-muted-foreground">{role}</div>
                      </div>
                    </div>
                  </div>
                </CarouselItem>
              ))}
            </CarouselContent>
            <div className="flex justify-center gap-2 mt-8">
              <CarouselPrevious className="relative left-0 translate-y-0" />
              <CarouselNext className="relative right-0 translate-y-0" />
            </div>
          </Carousel>
          <div className="mt-12 flex flex-wrap items-center justify-center gap-x-10 gap-y-4 text-muted-foreground text-sm">
            <span className="flex items-center gap-2"><Users className="w-4 h-4 text-primary" /> 300+ retail partners</span>
            <span className="flex items-center gap-2"><Truck className="w-4 h-4 text-primary" /> 24h average delivery</span>
            <span className="flex items-center gap-2"><ShieldCheck className="w-4 h-4 text-primary" /> Escrow-protected payments</span>
          </div>
        </div>
      </section>


      {/* How it works — 3 steps */}
      <section className="py-24 relative overflow-hidden">
        <div className="absolute -top-20 right-1/4 w-72 h-72 rounded-full bg-secondary/20 blur-3xl animate-blob -z-10" />
        <div className="absolute bottom-0 left-1/4 w-80 h-80 rounded-full bg-primary/20 blur-3xl animate-blob -z-10" style={{ animationDelay: "3s" }} />
        <div className="container mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center max-w-2xl mx-auto mb-14">
            <span className="text-secondary font-semibold uppercase tracking-wider text-sm">How MAMBONAMI works</span>
            <h2 className="font-display text-4xl md:text-5xl font-bold mt-3">Three simple steps. Zero middlemen.</h2>
          </div>
          <div className="grid md:grid-cols-3 gap-6 relative">
            {[
              { Icon: PackageSearch, title: "Browse & order", body: "Discover seasonal produce from verified farms across 47 counties — filter by location, crop, or delivery date.", step: "01" },
              { Icon: Leaf, title: "Harvested for you", body: "Your order is picked the same morning, quality-checked, and packed at the farm — never sitting in a warehouse.", step: "02" },
              { Icon: Truck, title: "Delivered fresh", body: "Doorstep delivery in under 24 hours with M-Pesa escrow — pay only when it arrives in perfect condition.", step: "03" },
            ].map(({ Icon, title, body, step }, i) => (
              <div key={title} className="glass-card rounded-2xl p-8 hover-lift relative animate-fade-in-up" style={{ animationDelay: `${i * 120}ms` }}>
                <div className="absolute top-6 right-6 font-display text-5xl font-black text-primary/10">{step}</div>
                <div className="w-14 h-14 rounded-2xl bg-gradient-hero flex items-center justify-center mb-5 shadow-glow">
                  <Icon className="w-7 h-7 text-primary-foreground" />
                </div>
                <h3 className="font-display text-2xl font-bold mb-2">{title}</h3>
                <p className="text-muted-foreground leading-relaxed">{body}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Trusted by strip */}
      <section className="py-12 border-y border-border bg-accent/30">
        <div className="container mx-auto px-4 sm:px-6 lg:px-8">
          <p className="text-center text-xs uppercase tracking-[0.3em] text-muted-foreground font-semibold mb-6">
            Trusted across the food chain
          </p>
          <div className="flex flex-wrap items-center justify-center gap-x-10 gap-y-4 text-muted-foreground">
            {["Naivas-affiliated", "Carrefour vendors", "Sarova Hotels", "Java House", "ALDI Africa", "WFP Kenya"].map((b) => (
              <span key={b} className="font-display text-lg md:text-xl font-bold opacity-60 hover:opacity-100 transition">
                {b}
              </span>
            ))}
          </div>
        </div>
      </section>

      {/* Newsletter */}
      <NewsletterSection />

      {/* CTA */}
      <section className="pb-24 pt-4">
        <div className="container mx-auto px-4 sm:px-6 lg:px-8">
          <div className="relative bg-gradient-hero animate-gradient rounded-3xl px-8 py-16 md:p-16 text-center text-primary-foreground shadow-glow overflow-hidden">
            <div className="absolute -top-16 -left-16 w-64 h-64 rounded-full bg-secondary/30 blur-3xl animate-blob" />
            <div className="absolute -bottom-16 -right-16 w-64 h-64 rounded-full bg-white/10 blur-3xl animate-blob" style={{ animationDelay: "2s" }} />
            <h2 className="font-display text-4xl md:text-5xl font-bold mb-4 relative">Ready to taste the difference?</h2>
            <p className="text-primary-foreground/85 text-lg max-w-xl mx-auto mb-8 relative">Join thousands experiencing farm-fresh produce, delivered with care.</p>
            <button type="button" onClick={notifyComingSoon} className="relative inline-flex items-center gap-2 rounded-full bg-secondary text-secondary-foreground px-8 py-4 font-semibold hover:bg-secondary/90 hover:scale-105 transition shadow-glow">
              Get Started Today <ArrowRight className="w-4 h-4" />
            </button>
          </div>
        </div>
      </section>
    </>
  );
}

function NewsletterSection() {
  const [email, setEmail] = useState("");
  const [done, setDone] = useState(false);
  const submit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!email || !email.includes("@")) {
      toast.error("Please enter a valid email");
      return;
    }
    setDone(true);
    toast.success("You're on the list! 🌱", { description: "We'll email you the moment MAMBONAMI launches." });
    setEmail("");
  };
  return (
    <section className="py-20">
      <div className="container mx-auto px-4 sm:px-6 lg:px-8">
        <div className="glass-card rounded-3xl p-8 md:p-12 grid md:grid-cols-2 gap-8 items-center shadow-soft">
          <div>
            <span className="inline-flex items-center gap-2 text-secondary font-semibold uppercase tracking-wider text-sm">
              <Mail className="w-4 h-4" /> Early access
            </span>
            <h2 className="font-display text-3xl md:text-4xl font-bold mt-3 mb-3">Be first in line when we launch.</h2>
            <p className="text-muted-foreground">Get seasonal harvest updates, farmer stories, and a 10% welcome credit for your first order.</p>
          </div>
          <form onSubmit={submit} className="flex flex-col sm:flex-row gap-3">
            <input
              type="email"
              required
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              placeholder="you@example.com"
              className="flex-1 rounded-full bg-background border border-border px-5 py-3.5 outline-none focus:ring-2 focus:ring-primary/40 focus:border-primary transition"
              aria-label="Email address"
            />
            <button
              type="submit"
              className="inline-flex items-center justify-center gap-2 rounded-full bg-primary text-primary-foreground px-6 py-3.5 font-semibold hover:bg-primary-dark hover:scale-105 transition shadow-soft"
            >
              {done ? <><CheckCircle2 className="w-4 h-4" /> Subscribed</> : <>Notify me <ArrowRight className="w-4 h-4" /></>}
            </button>
          </form>
        </div>
      </div>
    </section>
  );
}

