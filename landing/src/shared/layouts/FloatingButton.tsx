import React, { useEffect, useRef, useState } from 'react'
import {
  Headphones,
  Phone,
  Mail,
  MessageCircle,
  X,
  Check,
  Copy,
  Clock,
  ShieldCheck,
} from 'lucide-react'

export const FloatingButton: React.FC = () => {
  const [isOpen, setIsOpen] = useState(false)
  const [copiedType, setCopiedType] = useState<string | null>(null)
  const containerRef = useRef<HTMLDivElement>(null)

  const supportPhone = '+254728102107'
  const supportPhoneDisplay = '+254 728 102 107'
  const supportEmail = 'hello@mambonami.com'
  const whatsappUrl = `https://wa.me/254728102107?text=${encodeURIComponent("Hello MAMBONAMI - I'd love to learn more about your farm-to-table marketplace.")}`

  useEffect(() => {
    if (!isOpen) return
    const closeOnOutsideClick = (event: MouseEvent) => {
      if (!containerRef.current?.contains(event.target as Node)) setIsOpen(false)
    }
    document.addEventListener('mousedown', closeOnOutsideClick)
    return () => document.removeEventListener('mousedown', closeOnOutsideClick)
  }, [isOpen])

  const copyToClipboard = (text: string, type: string) => {
    void navigator.clipboard?.writeText(text)
    setCopiedType(type)
    setTimeout(() => setCopiedType(null), 2000)
  }

  return (
    <div ref={containerRef} className="fixed bottom-[calc(4.5rem+env(safe-area-inset-bottom))] right-4 z-40 flex flex-col items-end sm:bottom-6 sm:right-6">
      {/* Expanded Support Card Modal */}
      {isOpen && (
        <div className="mb-3 w-80 overflow-hidden rounded-3xl border border-border bg-card shadow-2xl animate-fade-in divide-y divide-border sm:w-96">
          {/* Header */}
          <div className="relative bg-primary-dark p-5 text-primary-foreground">
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-2.5">
                <div className="flex h-9 w-9 items-center justify-center rounded-xl bg-secondary text-secondary-foreground shadow-md">
                  <Headphones className="w-5 h-5" />
                </div>
                <div>
                  <div className="flex items-center gap-2">
                    <h3 className="text-sm font-black text-primary-foreground">MAMBONAMI Help & Support</h3>
                    <span className="h-2 w-2 rounded-full bg-emerald-400 animate-impulse"></span>
                  </div>
                  <p className="text-[11px] text-primary-foreground/70">Live Kenya Support Team</p>
                </div>
              </div>

              <button
                onClick={() => setIsOpen(false)}
                className="rounded-lg p-1 text-primary-foreground/60 transition hover:text-primary-foreground"
                aria-label="Close support modal"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <div className="mt-3.5 flex items-center gap-2 rounded-xl bg-primary-foreground/10 px-3 py-1.5 text-[11px] text-primary-foreground/75 backdrop-blur-xs">
              <Clock className="h-3.5 w-3.5 shrink-0 text-secondary" />
              <span>Mon - Sat: 7:00 AM - 9:00 PM - Fast response</span>
            </div>
          </div>

          {/* Contact Actions */}
          <div className="space-y-2.5 bg-muted/40 p-4">
            {/* 1. WhatsApp Action */}
            <a
              href={whatsappUrl}
              target="_blank"
              rel="noopener noreferrer"
              className="group flex items-center justify-between rounded-2xl border border-emerald-500/30 bg-emerald-500/10 p-3.5 transition hover:bg-emerald-500/20"
            >
              <div className="flex items-center gap-3">
                <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl bg-emerald-500 text-white shadow-xs">
                  <MessageCircle className="w-5 h-5" />
                </div>
                <div className="text-left">
                  <span className="block text-xs font-bold text-foreground group-hover:text-emerald-700">
                    Chat with us on WhatsApp
                  </span>
                  <span className="text-[11px] text-muted-foreground">{supportPhoneDisplay}</span>
                </div>
              </div>
              <span className="shrink-0 rounded-lg bg-emerald-500 px-2 py-1 text-[10px] font-bold text-white">
                Instant
              </span>
            </a>

            {/* 2. Direct Phone Call Action */}
            <div className="flex items-center justify-between rounded-2xl border border-border bg-card p-3 transition hover:bg-muted">
              <a
                href={`tel:${supportPhone}`}
                className="flex items-center gap-3 flex-1 text-left"
              >
                <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl bg-primary text-primary-foreground shadow-xs">
                  <Phone className="w-5 h-5" />
                </div>
                <div>
                  <span className="block text-xs font-bold text-foreground">Direct Phone Call</span>
                  <span className="text-[11px] font-semibold text-primary">{supportPhoneDisplay}</span>
                </div>
              </a>
              <button
                onClick={() => copyToClipboard(supportPhoneDisplay, 'phone')}
                title="Copy phone number"
                className="rounded-lg p-2 text-muted-foreground transition hover:bg-muted hover:text-foreground"
              >
                {copiedType === 'phone' ? (
                  <Check className="w-4 h-4 text-emerald-600" />
                ) : (
                  <Copy className="w-4 h-4" />
                )}
              </button>
            </div>

            {/* 3. Email Support Action */}
            <div className="flex items-center justify-between rounded-2xl border border-border bg-card p-3 transition hover:bg-muted">
              <a
                href={`mailto:${supportEmail}?subject=MAMBONAMI%20Support%20Inquiry`}
                className="flex items-center gap-3 flex-1 text-left"
              >
                <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl bg-secondary text-secondary-foreground shadow-xs">
                  <Mail className="w-5 h-5" />
                </div>
                <div>
                  <span className="block text-xs font-bold text-foreground">Email MAMBONAMI</span>
                  <span className="font-mono text-[11px] text-muted-foreground">{supportEmail}</span>
                </div>
              </a>
              <button
                onClick={() => copyToClipboard(supportEmail, 'email')}
                title="Copy email address"
                className="rounded-lg p-2 text-muted-foreground transition hover:bg-muted hover:text-foreground"
              >
                {copiedType === 'email' ? (
                  <Check className="w-4 h-4 text-emerald-600" />
                ) : (
                  <Copy className="w-4 h-4" />
                )}
              </button>
            </div>
          </div>

          {/* Footer Note */}
          <div className="flex items-center justify-center gap-1.5 bg-muted px-4 py-2.5 text-center text-[10px] font-medium text-muted-foreground">
            <ShieldCheck className="h-3.5 w-3.5 text-primary" />
            <span>Official MAMBONAMI support • Kenya</span>
          </div>
        </div>
      )}

      {/* Floating Trigger Button */}
      <button
        onClick={() => setIsOpen(!isOpen)}
        className={`flex items-center gap-2.5 px-4 py-3.5 rounded-full shadow-2xl transition-all duration-300 font-bold text-sm select-none border-2 border-white/30 ${
          isOpen
            ? 'bg-primary-dark text-primary-foreground rotate-0'
            : 'bg-secondary text-secondary-foreground hover:scale-105 animate-float hover:animate-none shadow-[0_8px_25px_color-mix(in_srgb,var(--color-secondary)_45%,transparent)]'
        }`}
        id="floating-support-btn"
        aria-label="Toggle contact support"
      >
        <div className="relative">
          {isOpen ? (
            <X className="w-5 h-5" />
          ) : (
            <Headphones className="w-5 h-5" />
          )}
          {!isOpen && (
            <span className="absolute -top-1 -right-1 w-2.5 h-2.5 rounded-full bg-emerald-400 animate-impulse ring-2 ring-white"></span>
          )}
        </div>
        <span className="hidden font-black tracking-wide text-xs sm:inline">
          {isOpen ? 'Close Support' : 'Support & Contacts'}
        </span>
      </button>
    </div>
  )
}

