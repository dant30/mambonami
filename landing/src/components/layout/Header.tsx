import { useState } from "react";
import { Link } from "@tanstack/react-router";
import { Menu, X, Leaf } from "lucide-react";

const links = [
  { to: "/", label: "Home" },
  { to: "/about", label: "About" },
  { to: "/services", label: "Services" },
  { to: "/how-it-works", label: "How It Works" },
  { to: "/faq", label: "FAQ" },
  { to: "/contact", label: "Contact" },
] as const;

export function Header() {
  const [open, setOpen] = useState(false);

  return (
    <header className="sticky top-0 z-50 backdrop-blur-md bg-background/80 border-b border-border">
      <div className="container mx-auto px-4 sm:px-6 lg:px-8 h-16 flex items-center justify-between">
        <Link to="/" className="flex items-center gap-2 group">
          <span className="w-9 h-9 rounded-full bg-gradient-hero flex items-center justify-center shadow-soft">
            <Leaf className="w-5 h-5 text-primary-foreground" />
          </span>
          <span className="font-display font-bold text-xl tracking-tight">MAMBONAMI</span>
        </Link>

        <nav className="hidden md:flex items-center gap-7">
          {links.map((l) => (
            <Link
              key={l.to}
              to={l.to}
              activeProps={{ className: "text-primary" }}
              activeOptions={{ exact: l.to === "/" }}
              className="text-sm font-medium text-foreground/80 hover:text-primary transition-colors"
            >
              {l.label}
            </Link>
          ))}
          <Link
            to="/contact"
            className="inline-flex items-center rounded-full bg-primary text-primary-foreground px-5 py-2 text-sm font-semibold hover:bg-primary-dark transition-colors shadow-soft"
          >
            Get Started
          </Link>
        </nav>

        <button
          className="md:hidden p-2 -mr-2"
          onClick={() => setOpen(!open)}
          aria-label="Toggle menu"
        >
          {open ? <X className="w-6 h-6" /> : <Menu className="w-6 h-6" />}
        </button>
      </div>

      {open && (
        <div className="md:hidden border-t border-border bg-background">
          <nav className="container mx-auto px-4 py-4 flex flex-col gap-1">
            {links.map((l) => (
              <Link
                key={l.to}
                to={l.to}
                onClick={() => setOpen(false)}
                activeProps={{ className: "text-primary bg-accent" }}
                activeOptions={{ exact: l.to === "/" }}
                className="px-3 py-2.5 rounded-lg text-sm font-medium hover:bg-accent transition-colors"
              >
                {l.label}
              </Link>
            ))}
          </nav>
        </div>
      )}
    </header>
  );
}
