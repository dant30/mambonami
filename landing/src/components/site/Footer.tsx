import { Link } from "@tanstack/react-router";
import { Leaf, Mail, Phone, MapPin, Apple, Play } from "lucide-react";
import { notifyComingSoon } from "@/lib/coming-soon";

export function Footer() {
  return (
    <footer className="bg-primary-dark text-primary-foreground mt-24">
      <div className="container mx-auto px-4 sm:px-6 lg:px-8 py-14 grid gap-10 md:grid-cols-4">
        <div className="md:col-span-2">
          <div className="flex items-center gap-2 mb-4">
            <span className="w-9 h-9 rounded-full bg-secondary flex items-center justify-center">
              <Leaf className="w-5 h-5 text-primary-dark" />
            </span>
            <span className="font-display font-bold text-xl">MAMBONAMI</span>
          </div>
          <p className="text-primary-foreground/80 max-w-md text-sm leading-relaxed mb-5">
            Connecting Kenyan farmers directly to your table. Fair prices for growers, fresh produce for families.
          </p>

          {/* App store badges */}
          <div className="flex flex-wrap gap-3">
            <button
              type="button"
              onClick={notifyComingSoon}
              className="flex items-center gap-2.5 rounded-xl bg-black/40 hover:bg-black/60 border border-white/10 px-4 py-2.5 transition"
              aria-label="Get it on Google Play — coming soon"
            >
              <Play className="w-5 h-5 fill-current" />
              <span className="text-left leading-tight">
                <span className="block text-[10px] uppercase tracking-wider opacity-70">Coming soon on</span>
                <span className="block text-sm font-semibold">Google Play</span>
              </span>
            </button>
            <button
              type="button"
              onClick={notifyComingSoon}
              className="flex items-center gap-2.5 rounded-xl bg-black/40 hover:bg-black/60 border border-white/10 px-4 py-2.5 transition"
              aria-label="Download on the App Store — coming soon"
            >
              <Apple className="w-5 h-5" />
              <span className="text-left leading-tight">
                <span className="block text-[10px] uppercase tracking-wider opacity-70">Coming soon on the</span>
                <span className="block text-sm font-semibold">App Store</span>
              </span>
            </button>
          </div>
        </div>

        <div>
          <h4 className="font-semibold mb-3 text-sm uppercase tracking-wider">Explore</h4>
          <ul className="space-y-2 text-sm text-primary-foreground/80">
            <li><Link to="/about" className="hover:text-secondary">About</Link></li>
            <li><Link to="/services" className="hover:text-secondary">Services</Link></li>
            <li><Link to="/products" className="hover:text-secondary">Products</Link></li>
            <li><Link to="/how-it-works" className="hover:text-secondary">How It Works</Link></li>
            <li><Link to="/faq" className="hover:text-secondary">FAQ</Link></li>
          </ul>
        </div>

        <div>
          <h4 className="font-semibold mb-3 text-sm uppercase tracking-wider">Contact</h4>
          <ul className="space-y-2 text-sm text-primary-foreground/80">
            <li className="flex items-center gap-2"><Mail className="w-4 h-4" /><span>hello@mambonami.com</span></li>
            <li className="flex items-center gap-2"><Phone className="w-4 h-4" /><a href="tel:+254724167076" className="hover:text-secondary">+254 724 167 076</a></li>
            <li className="flex items-center gap-2"><MapPin className="w-4 h-4" /><span>Nairobi, Kenya</span></li>
          </ul>
        </div>
      </div>
      <div className="border-t border-primary-foreground/10">
        <div className="container mx-auto px-4 py-5 text-xs text-primary-foreground/60 flex flex-col sm:flex-row justify-between gap-2">
          <p>© {new Date().getFullYear()} MAMBONAMI. All rights reserved.</p>
          <div className="flex gap-4">
            <Link to="/privacy" className="hover:text-secondary">Privacy</Link>
            <Link to="/terms" className="hover:text-secondary">Terms</Link>
          </div>
        </div>
      </div>
    </footer>
  );
}
