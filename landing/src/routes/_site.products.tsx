import { createFileRoute } from "@tanstack/react-router";
import { Sprout, Leaf, Apple, Wheat } from "lucide-react";
import g1 from "@/assets/gallery-1.jpg";
import g2 from "@/assets/gallery-2.jpg";
import g3 from "@/assets/gallery-3.jpg";
import g4 from "@/assets/gallery-4.jpg";
import g5 from "@/assets/gallery-5.jpg";
import g6 from "@/assets/gallery-6.jpg";
import { notifyComingSoon } from "@/lib/coming-soon";

export const Route = createFileRoute("/_site/products")({
  head: () => ({
    meta: [
      { title: "Products — MAMBONAMI" },
      { name: "description", content: "Explore the blossoming Kenyan farm produce available on MAMBONAMI — vegetables, fruits, grains and more, sourced directly from verified farms." },
      { property: "og:title", content: "Products — MAMBONAMI" },
      { property: "og:description", content: "Fresh, seasonal Kenyan produce from farm to table." },
    ],
  }),
  component: Products,
});

const gallery = [
  { src: g1, alt: "Blossoming tomato vines at sunrise", tag: "Vine ripened" },
  { src: g2, alt: "Basket of fresh mangoes and avocados", tag: "Tropical fruits" },
  { src: g3, alt: "Freshly harvested sukuma wiki bundles", tag: "Leafy greens" },
  { src: g4, alt: "Colourful capsicums, carrots and onions", tag: "Market fresh" },
  { src: g5, alt: "Coffee blossoms with red cherries", tag: "Highland coffee" },
  { src: g6, alt: "Farmer in golden maize field", tag: "Grains & cereals" },
];

const categories = [
  { Icon: Leaf, name: "Vegetables", desc: "Sukuma wiki, spinach, capsicum, tomatoes, onions, carrots." },
  { Icon: Apple, name: "Fruits", desc: "Mangoes, avocados, bananas, passion fruit, watermelon." },
  { Icon: Wheat, name: "Grains & Cereals", desc: "Maize, beans, millet, sorghum and rice from highland farms." },
  { Icon: Sprout, name: "Herbs & Specials", desc: "Coriander, mint, basil, mushrooms and seasonal specials." },
];

function Products() {
  return (
    <>
      <section className="bg-gradient-warm py-20">
        <div className="container mx-auto px-4 sm:px-6 lg:px-8 max-w-3xl text-center">
          <span className="text-secondary font-semibold uppercase tracking-wider text-sm">Our Produce</span>
          <h1 className="font-display text-5xl md:text-6xl font-bold mt-3 mb-6">A blossoming harvest, every season.</h1>
          <p className="text-xl text-muted-foreground">From rolling tea farms in Kericho to citrus groves in Makueni — discover what's growing on MAMBONAMI today.</p>
        </div>
      </section>

      {/* Categories */}
      <section className="py-16">
        <div className="container mx-auto px-4 sm:px-6 lg:px-8">
          <div className="grid sm:grid-cols-2 lg:grid-cols-4 gap-5">
            {categories.map(({ Icon, name, desc }, i) => (
              <div
                key={name}
                className="glass-card rounded-2xl p-6 hover-lift animate-fade-in-up"
                style={{ animationDelay: `${i * 80}ms` }}
              >
                <div className="w-11 h-11 rounded-xl bg-gradient-hero flex items-center justify-center mb-4">
                  <Icon className="w-5 h-5 text-primary-foreground" />
                </div>
                <h3 className="font-display text-xl font-bold mb-1.5">{name}</h3>
                <p className="text-sm text-muted-foreground leading-relaxed">{desc}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Gallery */}
      <section className="pb-24">
        <div className="container mx-auto px-4 sm:px-6 lg:px-8">
          <div className="max-w-2xl mb-10">
            <h2 className="font-display text-3xl md:text-4xl font-bold mb-3">Gallery — straight from the farm</h2>
            <p className="text-muted-foreground">A glimpse of the blossoming produce flowing through MAMBONAMI partner farms.</p>
          </div>

          <div className="grid grid-cols-2 md:grid-cols-3 gap-4 md:gap-5">
            {gallery.map((g, i) => (
              <figure
                key={g.src}
                className={`group relative overflow-hidden rounded-2xl shadow-soft hover-lift animate-fade-in-up ${
                  i === 0 ? "md:col-span-2 md:row-span-2 aspect-square md:aspect-auto" : "aspect-square"
                }`}
                style={{ animationDelay: `${i * 70}ms` }}
              >
                <img
                  src={g.src}
                  alt={g.alt}
                  loading="lazy"
                  width={1024}
                  height={1024}
                  className="w-full h-full object-cover transition-transform duration-700 group-hover:scale-110"
                />
                <div className="absolute inset-0 bg-gradient-to-t from-primary-dark/80 via-primary-dark/10 to-transparent opacity-90" />
                <figcaption className="absolute bottom-0 left-0 right-0 p-4 text-primary-foreground">
                  <span className="inline-block glass text-xs font-semibold uppercase tracking-wider px-2.5 py-1 rounded-full mb-1.5">
                    {g.tag}
                  </span>
                  <p className="text-sm font-medium drop-shadow">{g.alt}</p>
                </figcaption>
              </figure>
            ))}
          </div>

          <div className="text-center mt-14">
            <button
              type="button"
              onClick={notifyComingSoon}
              className="inline-flex items-center gap-2 rounded-full bg-primary text-primary-foreground px-7 py-3.5 font-semibold hover:bg-primary-dark transition shadow-soft"
            >
              Shop on the MAMBONAMI app
            </button>
            <p className="text-xs text-muted-foreground mt-3">The buying experience is launching soon — join the waitlist via Contact.</p>
          </div>
        </div>
      </section>
    </>
  );
}
