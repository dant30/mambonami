import { useState } from "react";
import { MessageCircle, Phone, Mail, X } from "lucide-react";

export function FloatingContact() {
  const [open, setOpen] = useState(false);

  const actions = [
    { Icon: MessageCircle, label: "WhatsApp", href: "https://wa.me/254700000000", color: "bg-[#25D366]" },
    { Icon: Phone, label: "Call us", href: "tel:+254700000000", color: "bg-primary" },
    { Icon: Mail, label: "Email", href: "mailto:hello@mambonami.com", color: "bg-secondary" },
  ];

  return (
    <div className="fixed bottom-6 right-6 z-50 flex flex-col items-end gap-3">
      {open &&
        actions.map(({ Icon, label, href, color }, i) => (
          <a
            key={label}
            href={href}
            target="_blank"
            rel="noreferrer"
            className={`group flex items-center gap-3 ${color} text-white pl-4 pr-3 py-2.5 rounded-full shadow-glow animate-fade-in`}
            style={{ animationDelay: `${i * 60}ms` }}
          >
            <span className="text-sm font-medium opacity-0 group-hover:opacity-100 max-w-0 group-hover:max-w-[120px] overflow-hidden transition-all duration-300 whitespace-nowrap">
              {label}
            </span>
            <Icon className="w-5 h-5" />
          </a>
        ))}
      <button
        onClick={() => setOpen(!open)}
        aria-label="Contact us"
        className={`relative w-14 h-14 rounded-full bg-gradient-hero text-primary-foreground shadow-glow flex items-center justify-center transition-transform hover:scale-110 ${
          open ? "rotate-90" : "animate-float"
        }`}
      >
        {open ? <X className="w-6 h-6" /> : <MessageCircle className="w-6 h-6" />}
        {!open && (
          <span className="absolute inset-0 rounded-full bg-primary/40 animate-ping-slow -z-10" />
        )}
      </button>
    </div>
  );
}
