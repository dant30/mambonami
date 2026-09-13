// src/features/auth/pages/SplashPage.tsx

import { useEffect } from 'react'
import { useNavigate } from 'react-router-dom'

export function SplashPage() {
  const navigate = useNavigate()

  useEffect(() => {
    const timer = window.setTimeout(() => {
      navigate('/home', { replace: true })
    }, 3000)

    return () => window.clearTimeout(timer)
  }, [navigate])

  return (
    <main className="relative flex min-h-screen items-center justify-center overflow-hidden bg-[#071f12] px-6 text-white">
      {/* =========================================================
          BACKGROUND ATMOSPHERE
          ========================================================= */}

      <div
        aria-hidden="true"
        className="pointer-events-none absolute inset-0 overflow-hidden"
      >
        {/* Green glow - top left */}
        <div className="absolute -left-32 -top-32 h-80 w-80 rounded-full bg-[#3FAE2A]/20 blur-[100px]" />

        {/* Yellow glow - bottom right */}
        <div className="absolute -bottom-40 -right-32 h-96 w-96 rounded-full bg-[#FFD21C]/15 blur-[120px]" />

        {/* Central green glow */}
        <div className="absolute left-1/2 top-1/2 h-80 w-80 -translate-x-1/2 -translate-y-1/2 rounded-full bg-[#3FAE2A]/10 blur-[110px]" />

        {/* Small accent glow */}
        <div className="absolute right-[15%] top-[20%] h-32 w-32 rounded-full bg-[#FFD21C]/10 blur-[70px]" />
      </div>

      {/* =========================================================
          DECORATIVE RINGS
          ========================================================= */}

      <div
        aria-hidden="true"
        className="pointer-events-none absolute left-1/2 top-1/2 h-[22rem] w-[22rem] -translate-x-1/2 -translate-y-1/2 rounded-full border border-white/[0.035]"
      />

      <div
        aria-hidden="true"
        className="pointer-events-none absolute left-1/2 top-1/2 h-[30rem] w-[30rem] -translate-x-1/2 -translate-y-1/2 rounded-full border border-white/[0.02]"
      />

      {/* =========================================================
          MAIN CONTENT
          ========================================================= */}

      <div className="relative z-10 flex w-full max-w-md flex-col items-center text-center">

        {/* =======================================================
            LOGO
            ======================================================= */}

        <div className="animate-[fadeIn_700ms_ease-out]">
          <div className="relative flex items-center justify-center">

            {/* Logo glow */}
            <div
              aria-hidden="true"
              className="absolute h-64 w-64 rounded-full bg-[#7ED321]/15 blur-[90px]"
            />

            {/* Actual Mambonami logo */}
            <div className="relative overflow-hidden rounded-[2rem] border border-white/10 bg-white/[0.04] p-4 shadow-[0_25px_80px_rgba(0,0,0,0.45)] backdrop-blur-sm sm:p-6">
              <img
                src="/assets/icons/logo.png"
                alt="Mambonami"
                className="relative h-auto w-[280px] object-contain sm:w-[350px]"
              />
            </div>
          </div>
        </div>

        {/* =======================================================
            TAGLINE
            ======================================================= */}

        <div className="mt-4 animate-[fadeUp_700ms_250ms_ease-out_both]">
          <p className="text-sm font-medium tracking-wide text-white/65 sm:text-base">
            Fresh food, closer to home.
          </p>
        </div>

        {/* =======================================================
            BRAND MESSAGE
            ======================================================= */}

        <div className="mt-8 animate-[fadeUp_700ms_450ms_ease-out_both]">
          <div className="flex items-center justify-center gap-3">
            <span className="h-px w-8 bg-gradient-to-r from-transparent to-[#7ED321]" />

            <span className="h-1.5 w-1.5 rounded-full bg-[#7ED321]" />

            <span className="h-px w-8 bg-gradient-to-r from-[#FFD21C] to-transparent" />
          </div>

          <p className="mt-5 text-[10px] font-semibold uppercase tracking-[0.28em] text-white/35">
            Connecting farmers • buyers • transport
          </p>
        </div>

      </div>

      {/* =========================================================
          FOOTER
          ========================================================= */}

      <div className="absolute bottom-6 left-0 right-0 z-10 text-center">
        <p className="text-[10px] font-medium tracking-[0.2em] text-white/25">
          MAMBONAMI
        </p>
      </div>

      {/* =========================================================
          LOCAL ANIMATIONS
          ========================================================= */}

      <style>{`
        @keyframes fadeIn {
          from {
            opacity: 0;
            transform: scale(0.92);
          }

          to {
            opacity: 1;
            transform: scale(1);
          }
        }

        @keyframes fadeUp {
          from {
            opacity: 0;
            transform: translateY(14px);
          }

          to {
            opacity: 1;
            transform: translateY(0);
          }
        }

        @media (prefers-reduced-motion: reduce) {
          *,
          *::before,
          *::after {
            animation-duration: 0.01ms !important;
            animation-iteration-count: 1 !important;
            animation-delay: 0ms !important;
          }
        }
      `}</style>
    </main>
  )
}